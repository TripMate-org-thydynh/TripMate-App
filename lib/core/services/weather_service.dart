import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../theme/gen_z_tokens.dart';

class WeatherData {
  final double temp;
  final String description;
  final IconData icon;
  final Color color;
  final String details; // text for status warning (e.g. rain detected)
  final List<DailyForecast> daily;

  WeatherData({
    required this.temp,
    required this.description,
    required this.icon,
    required this.color,
    this.details = '',
    required this.daily,
  });
}

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String description;
  final IconData icon;
  final Color color;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class WeatherService {
  final Dio _dio = Dio();

  /// `null` khi không lấy được thời tiết.
  ///
  /// Trước đây nhánh lỗi trả về 22°C + "mây rải rác" cứng, nên mất mạng
  /// hay API hỏng thì người dùng vẫn thấy một con số như thật.
  Future<WeatherData?> fetchWeather(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current': 'temperature_2m,weather_code',
          'daily': 'temperature_2m_max,temperature_2m_min,weather_code',
          'timezone': 'auto',
          'forecast_days': 16,
        },
      );

      final data = response.data;
      final current = data['current'];
      final currentTemp = (current['temperature_2m'] as num).toDouble();
      final currentCode = (current['weather_code'] as num).toInt();

      final mappedCurrent = _mapWmoCode(currentCode);

      // Map daily forecast (16 days)
      final daily = data['daily'];
      final List<DailyForecast> dailyList = [];
      final List<dynamic> times = daily['time'];
      final List<dynamic> maxTemps = daily['temperature_2m_max'];
      final List<dynamic> minTemps = daily['temperature_2m_min'];
      final List<dynamic> codes = daily['weather_code'];

      for (int i = 0; i < times.length; i++) {
        final date = DateTime.tryParse(times[i].toString()) ?? DateTime.now();
        final maxT = (maxTemps[i] as num).toDouble();
        final minT = (minTemps[i] as num).toDouble();
        final code = (codes[i] as num).toInt();
        final mappedDaily = _mapWmoCode(code);

        dailyList.add(
          DailyForecast(
            date: date,
            minTemp: minT,
            maxTemp: maxT,
            description: mappedDaily.desc,
            icon: mappedDaily.icon,
            color: mappedDaily.color,
          ),
        );
      }

      // Check if rain or storm in next 24 hours (first 2 days)
      bool hasRainSoon = codes
          .take(2)
          .any(
            (code) =>
                [51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99].contains(code),
          );

      return WeatherData(
        temp: currentTemp,
        description: mappedCurrent.desc,
        icon: mappedCurrent.icon,
        color: mappedCurrent.color,
        details: hasRainSoon
            ? 'weather.rain_warning'.tr()
            : 'weather.nice_day'.tr(),
        daily: dailyList,
      );
    } catch (e) {
      debugPrint('Failed to fetch weather from Open-Meteo: $e');
      // Không bịa số liệu: UI sẽ hiện trạng thái "chưa lấy được".
      return null;
    }
  }

  _WmoMapping _mapWmoCode(int code) {
    if (code == 0) {
      return _WmoMapping(
        'Trời quang',
        Icons.wb_sunny_outlined,
        GenZTokens.yellow,
      );
    } else if ([1, 2, 3].contains(code)) {
      return _WmoMapping(
        'weather.cond_scattered_clouds'.tr(),
        Icons.cloud_queue_outlined,
        GenZTokens.lilac,
      );
    } else if ([45, 48].contains(code)) {
      return _WmoMapping(
        'Sương mù',
        Icons.filter_drama_outlined,
        GenZTokens.lilac,
      );
    } else if ([51, 53, 55].contains(code)) {
      return _WmoMapping(
        'Mưa phùn',
        Icons.water_drop_outlined,
        GenZTokens.blue,
      );
    } else if ([61, 63, 65].contains(code)) {
      return _WmoMapping(
        'weather.cond_rain'.tr(),
        Icons.umbrella_outlined,
        GenZTokens.blue,
      );
    } else if ([71, 73, 75, 77, 85, 86].contains(code)) {
      return _WmoMapping(
        'weather.cond_snow'.tr(),
        Icons.ac_unit_outlined,
        GenZTokens.blue,
      );
    } else if ([80, 81, 82].contains(code)) {
      return _WmoMapping(
        'weather.cond_showers'.tr(),
        Icons.thunderstorm_outlined,
        GenZTokens.blue,
      );
    } else if ([95, 96, 99].contains(code)) {
      return _WmoMapping('Giông bão', Icons.thunderstorm, GenZTokens.red);
    }
    return _WmoMapping('Không xác định', Icons.help_outline, GenZTokens.lilac);
  }
}

class _WmoMapping {
  final String desc;
  final IconData icon;
  final Color color;

  _WmoMapping(this.desc, this.icon, this.color);
}

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

// Weather State Notifier
class WeatherStateNotifier extends StateNotifier<AsyncValue<WeatherData?>> {
  final WeatherService _service;
  WeatherStateNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadWeather(double lat, double lng) async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.fetchWeather(lat, lng);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final weatherProvider =
    StateNotifierProvider<WeatherStateNotifier, AsyncValue<WeatherData?>>((
      ref,
    ) {
      return WeatherStateNotifier(ref.watch(weatherServiceProvider));
    });

final weatherFutureProvider = FutureProvider.family<WeatherData?, LatLng>((
  ref,
  latLng,
) async {
  return ref
      .watch(weatherServiceProvider)
      .fetchWeather(latLng.latitude, latLng.longitude);
});
