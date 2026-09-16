import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/theme/gen_z_tokens.dart';

/// Bảng dự báo 16 ngày (Open-Meteo) — mở từ thẻ thời tiết ở home.
class WeatherForecastSheet extends StatelessWidget {
  final WeatherData weather;
  final bool isDarkMode;

  const WeatherForecastSheet({
    super.key,
    required this.weather,
    required this.isDarkMode,
  });

  static void show(BuildContext context, WeatherData weather, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GenZTokens.paper.withValues(alpha: 0),
      builder: (_) =>
          WeatherForecastSheet(weather: weather, isDarkMode: isDarkMode),
    );
  }

  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _surface => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _info => isDarkMode ? GenZTokens.infoDark : GenZTokens.info;
  Color get _warning => isDarkMode ? GenZTokens.warningDark : GenZTokens.warning;
  Color get _danger => isDarkMode ? GenZTokens.dangerDark : GenZTokens.danger;
  Color _bg(BuildContext context) =>
      isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;

  static const _weekdaysVi = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static const _weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _dayLabel(BuildContext context, DateTime d, int index) {
    if (index == 0) return 'weather.today'.tr();
    final vi = context.locale.languageCode == 'vi';
    final names = vi ? _weekdaysVi : _weekdaysEn;
    return names[(d.weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final days = weather.daily;
    // Miền nhiệt độ để vẽ thanh gradient tương đối.
    final allMin = days
        .map((d) => d.minTemp)
        .fold<double>(999, (a, b) => a < b ? a : b);
    final allMax = days
        .map((d) => d.maxTemp)
        .fold<double>(-999, (a, b) => a > b ? a : b);
    final span = (allMax - allMin).abs() < 1 ? 1 : (allMax - allMin);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: _bg(context),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(GenZTokens.radiusCard),
          ),
          border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: _line,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(weather.icon, color: weather.color, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'weather.forecast_16'.tr(),
                          style: AppFonts.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        Text(
                          '${weather.temp.toStringAsFixed(0)}°C · ${weather.description}',
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: _inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: _line, height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: days.length,
                itemBuilder: (context, i) {
                  final d = days[i];
                  final leftFrac = ((d.minTemp - allMin) / span).clamp(
                    0.0,
                    1.0,
                  );
                  final widthFrac = ((d.maxTemp - d.minTemp) / span).clamp(
                    0.08,
                    1.0,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusCard,
                      ),
                      border: Border.all(
                        color: _line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 42,
                          child: Text(
                            _dayLabel(context, d.date, i),
                            style: AppFonts.heading(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                        ),
                        Icon(d.icon, color: d.color, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          '${d.minTemp.toStringAsFixed(0)}°',
                          style: AppFonts.mono(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _inkSoft,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Thanh nhiệt độ min→max tương đối.
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, c) => Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _fill,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                Positioned(
                                  left: c.maxWidth * leftFrac,
                                  child: Container(
                                    height: 6,
                                    width: c.maxWidth * widthFrac,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _info,
                                          _warning,
                                          _danger,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${d.maxTemp.toStringAsFixed(0)}°',
                          style: AppFonts.mono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
