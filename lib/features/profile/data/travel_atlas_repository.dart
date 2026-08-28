import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/api_client.dart';
import '../domain/travel_stats.dart';

/// Marker trên bản đồ Atlas — từ itinerary (PLACE) hoặc moment GPS (CHECKIN).
class AtlasMarker {
  final LatLng coords;
  final String name;
  final bool isCheckIn;

  const AtlasMarker({
    required this.coords,
    required this.name,
    this.isCheckIn = false,
  });

  factory AtlasMarker.fromJson(Map<String, dynamic> j) => AtlasMarker(
    coords: LatLng(
      (j['lat'] as num?)?.toDouble() ?? 0,
      (j['lng'] as num?)?.toDouble() ?? 0,
    ),
    name: j['name'] as String? ?? '',
    isCheckIn: (j['type'] as String?) == 'CHECKIN',
  );
}

/// Số liệu THẬT cho Travel Atlas (BE `users/me/travel-atlas`).
class TravelAtlasData {
  final int totalTrips;
  final int placesExplored;
  final int checkIns;
  final int streakMonths;
  final List<AtlasMarker> markers;
  final List<TravelBadge> badges;

  const TravelAtlasData({
    this.totalTrips = 0,
    this.placesExplored = 0,
    this.checkIns = 0,
    this.streakMonths = 0,
    this.markers = const [],
    this.badges = const [],
  });

  factory TravelAtlasData.fromJson(Map<String, dynamic> j) {
    final raw = j['markers'];
    final rawBadges = j['badges'];
    return TravelAtlasData(
      totalTrips: (j['totalTrips'] as num?)?.toInt() ?? 0,
      placesExplored: (j['placesExplored'] as num?)?.toInt() ?? 0,
      checkIns: (j['checkIns'] as num?)?.toInt() ?? 0,
      streakMonths: (j['streakMonths'] as num?)?.toInt() ?? 0,
      markers: raw is List
          ? raw
                .whereType<Map>()
                .map((e) => AtlasMarker.fromJson(e.cast<String, dynamic>()))
                .toList()
          : const [],
      badges: rawBadges is List
          ? rawBadges
                .whereType<Map>()
                .map(
                  (e) => TravelBadge(
                    title: e['title'] as String? ?? '',
                    description: e['description'] as String? ?? '',
                    isUnlocked: e['isUnlocked'] as bool? ?? false,
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class TravelAtlasRepository {
  final ApiClient _client;
  TravelAtlasRepository(this._client);

  Future<TravelAtlasData> fetch() async {
    final data = await _client.getData('/users/me/travel-atlas');
    if (data is Map) {
      return TravelAtlasData.fromJson(data.cast<String, dynamic>());
    }
    return const TravelAtlasData();
  }
}

final travelAtlasRepositoryProvider = Provider<TravelAtlasRepository>((ref) {
  return TravelAtlasRepository(ref.watch(apiClientProvider));
});

final travelAtlasProvider = FutureProvider<TravelAtlasData>((ref) {
  return ref.watch(travelAtlasRepositoryProvider).fetch();
});
