import 'dart:math' as math;

class ImportedPlace {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String category; // FOOD, ACTIVITIES, ACCOMMODATION, COFFEE, OTHER

  const ImportedPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.category,
  });
}

class PlaceImportService {
  static ImportedPlace? parseExternalLink(String url) {
    final cleanUrl = url.trim().toLowerCase();

    if (cleanUrl.contains('google.com/maps') ||
        cleanUrl.contains('maps.google') ||
        cleanUrl.contains('goo.gl/maps')) {
      // Mock Google Maps import
      if (cleanUrl.contains('phu_quoc') || cleanUrl.contains('phuquoc')) {
        return const ImportedPlace(
          name: 'Bãi Sao Phú Quốc 🏖️',
          address: 'Bãi Sao, An Thới, Phú Quốc, Kiên Giang',
          latitude: 10.0543,
          longitude: 104.0376,
          category: 'ACTIVITIES',
        );
      } else if (cleanUrl.contains('food') ||
          cleanUrl.contains('nhahang') ||
          cleanUrl.contains('quan_an')) {
        return const ImportedPlace(
          name: 'Lẩu Dê Cây Dừa 🍲',
          address: '20 Đường Nguyễn Đình Chiểu, Dương Đông, Phú Quốc',
          latitude: 10.2198,
          longitude: 103.9634,
          category: 'FOOD',
        );
      } else {
        // Default generic Google Maps mock import
        return ImportedPlace(
          name: 'Google Maps Place ${math.Random().nextInt(100)} 📍',
          address: 'imported via Google Maps Link',
          latitude: 10.2100 + (math.Random().nextDouble() - 0.5) * 0.05,
          longitude: 103.9600 + (math.Random().nextDouble() - 0.5) * 0.05,
          category: 'OTHER',
        );
      }
    }

    if (cleanUrl.contains('tripadvisor.com') ||
        cleanUrl.contains('tripadvisor.com.vn')) {
      // Mock TripAdvisor import
      if (cleanUrl.contains('hotel') || cleanUrl.contains('resort')) {
        return const ImportedPlace(
          name: 'InterContinental Phú Quốc Long Beach Resort 🏨',
          address: 'Bãi Trường, Dương Tơ, Phú Quốc, Kiên Giang',
          latitude: 10.1235,
          longitude: 103.9744,
          category: 'ACCOMMODATION',
        );
      } else if (cleanUrl.contains('restaurant') || cleanUrl.contains('cafe')) {
        return const ImportedPlace(
          name: 'Chuồn Chuồn Bistro & Skybar ☕',
          address: 'Đồi Sao Mai, Đường Trần Hưng Đạo, Dương Đông, Phú Quốc',
          latitude: 10.2155,
          longitude: 103.9682,
          category: 'COFFEE',
        );
      } else {
        // Default generic TripAdvisor mock import
        return ImportedPlace(
          name:
              'TripAdvisor Featured Attraction ${math.Random().nextInt(100)} ⭐',
          address: 'imported via TripAdvisor link',
          latitude: 10.2200 + (math.Random().nextDouble() - 0.5) * 0.05,
          longitude: 103.9700 + (math.Random().nextDouble() - 0.5) * 0.05,
          category: 'ACTIVITIES',
        );
      }
    }

    return null; // Invalid link
  }
}
