// Model ItineraryItem — khớp BE `itineraries` module.
class ItineraryItem {
  final String id;
  final int day;
  final String startTime;
  final String placeName;
  final String? placeAddress;
  final int durationMinutes;
  final String? notes;
  final double? latitude;
  final double? longitude;
  final String? category;

  const ItineraryItem({
    required this.id,
    required this.day,
    required this.startTime,
    required this.placeName,
    this.placeAddress,
    required this.durationMinutes,
    this.notes,
    this.latitude,
    this.longitude,
    this.category,
  });

  bool get hasCoords => latitude != null && longitude != null;

  factory ItineraryItem.fromJson(Map<String, dynamic> j) => ItineraryItem(
    id: j['id'] as String,
    day: (j['day'] as num?)?.toInt() ?? 1,
    startTime: j['startTime'] as String? ?? '',
    placeName: j['placeName'] as String? ?? '',
    placeAddress: j['placeAddress'] as String?,
    durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 60,
    notes: j['notes'] as String?,
    latitude: (j['latitude'] as num?)?.toDouble(),
    longitude: (j['longitude'] as num?)?.toDouble(),
    category: j['category'] as String? ?? 'OTHER',
  );
}
