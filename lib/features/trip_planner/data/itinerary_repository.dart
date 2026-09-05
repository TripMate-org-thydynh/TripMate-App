import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/offline_provider.dart';
import '../domain/itinerary_item.dart';

/// Repository cho Itinerary — `/trips/:tripId/itinerary`.
class ItineraryRepository {
  final ApiClient _client;
  final Ref _ref;
  ItineraryRepository(this._client, this._ref);

  String _base(String tripId) => '/trips/$tripId/itinerary';

  Future<List<ItineraryItem>> fetch(String tripId) async {
    try {
      final data = await _client.getData(_base(tripId));
      if (data is List) {
        // Cache data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cache_itinerary_$tripId', jsonEncode(data));

        // Reset offline status
        _ref.read(offlineProvider.notifier).state = false;

        return data
            .whereType<Map>()
            .map((e) => ItineraryItem.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      return const [];
    } catch (e) {
      // Fetch failed -> Attempt fallback to local cache
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cache_itinerary_$tripId');
      if (cached != null) {
        final decoded = jsonDecode(cached);
        if (decoded is List) {
          // Set offline status to true
          _ref.read(offlineProvider.notifier).state = true;

          return decoded
              .whereType<Map>()
              .map((e) => ItineraryItem.fromJson(e.cast<String, dynamic>()))
              .toList();
        }
      }
      rethrow;
    }
  }

  Future<ItineraryItem> create(
    String tripId, {
    required int day,
    required String startTime,
    required String placeName,
    String? placeAddress,
    int durationMinutes = 60,
    String? notes,
    String? category,
    // Toa do la tuy chon, nhung khi co thi phai gui len: diem khong co toa do
    // se khong hien tren man Ban do chuyen va khong tinh vao quang duong.
    double? latitude,
    double? longitude,
  }) async {
    final data = await _client.postData(_base(tripId), {
      'day': day,
      'startTime': startTime,
      'placeName': placeName,
      'placeAddress': placeAddress,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'category': category,
      'latitude': ?latitude,
      'longitude': ?longitude,
    });
    return ItineraryItem.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> delete(String tripId, String id) =>
      _client.deleteData('${_base(tripId)}/$id');
}

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepository(ref.watch(apiClientProvider), ref);
});

/// Lịch trình của 1 trip, gom theo `day`.
final tripItineraryProvider =
    FutureProvider.family<Map<int, List<ItineraryItem>>, String>((
      ref,
      tripId,
    ) async {
      final items = await ref.watch(itineraryRepositoryProvider).fetch(tripId);
      final grouped = <int, List<ItineraryItem>>{};
      for (final it in items) {
        grouped.putIfAbsent(it.day, () => []).add(it);
      }
      return grouped;
    });
