import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NominatimService {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'User-Agent': 'TripMateApp/1.0 (com.tripmate.app)',
      },
    ),
  );

  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'accept-language': 'vi,en',
        },
      );

      final data = response.data;
      if (data is Map) {
        // Return display_name or a simplified place address
        return data['display_name'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Nominatim reverse geocode error: $e');
      return null;
    }
  }
}

final nominatimServiceProvider = Provider<NominatimService>((ref) {
  return NominatimService();
});
