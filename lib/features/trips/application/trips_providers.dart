import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/auth_provider.dart';
import '../data/trips_repository.dart';
import '../domain/trip.dart';

/// Danh sách chuyến đi của user hiện tại (AsyncValue: loading/error/data).
class TripsNotifier extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    final repository = ref.watch(tripsRepositoryProvider);
    final userId = auth.user?['id'] as String?;
    final trips = await repository.fetchTrips();
    if (userId != null) unawaited(_saveTripsSnapshot(userId, trips));
    return trips;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tripsRepositoryProvider).fetchTrips(),
    );
  }

  Future<Trip> create({
    required String name,
    String? description,
    String? destination,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImage,
    String currency = 'VND',
    double? budget,
    String? vibe,
    String? theme,
    bool isPublic = false,
  }) async {
    final trip = await ref
        .read(tripsRepositoryProvider)
        .createTrip(
          name: name,
          description: description,
          destination: destination,
          startDate: startDate,
          endDate: endDate,
          coverImage: coverImage,
          currency: currency,
          budget: budget,
          vibe: vibe,
          theme: theme,
          isPublic: isPublic,
        );
    _upsert(trip);
    return trip;
  }

  Future<Trip> join(String inviteCode) async {
    final trip = await ref.read(tripsRepositoryProvider).joinTrip(inviteCode);
    _upsert(trip);
    return trip;
  }

  /// Tham gia bằng mã người dùng dán vào (mã invite-link hoặc mã chuyến).
  Future<Trip> joinByAnyCode(String code) async {
    final trip = await ref.read(tripsRepositoryProvider).joinByAnyCode(code);
    _upsert(trip);
    return trip;
  }

  void _upsert(Trip trip) {
    final others = state.valueOrNull;
    if (others == null) {
      ref.invalidateSelf();
      return;
    }
    final updated = [trip, ...others.where((item) => item.id != trip.id)];
    state = AsyncData(updated);
    final userId = ref.read(authProvider).user?['id'] as String?;
    if (userId != null) unawaited(_saveTripsSnapshot(userId, updated));
  }

  Future<Trip> updateTrip(
    String id, {
    String? name,
    String? description,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? coverImage,
    String? currency,
    double? budget,
    String? vibe,
    bool? isPublic,
  }) async {
    final trip = await ref
        .read(tripsRepositoryProvider)
        .updateTrip(
          id,
          name: name,
          description: description,
          destination: destination,
          startDate: startDate,
          endDate: endDate,
          coverImage: coverImage,
          currency: currency,
          budget: budget,
          vibe: vibe,
          isPublic: isPublic,
        );
    await refresh();
    ref.invalidate(tripDetailProvider(id));
    return trip;
  }

  Future<void> deleteTrip(String id) async {
    await ref.read(tripsRepositoryProvider).deleteTrip(id);
    await refresh();
    ref.invalidate(tripDetailProvider(id));
  }

  Future<void> leaveTrip(String id) async {
    await ref.read(tripsRepositoryProvider).leaveTrip(id);
    await refresh();
    ref.invalidate(tripDetailProvider(id));
  }

  Future<void> removeMember(String id, String userId) async {
    await ref.read(tripsRepositoryProvider).removeMember(id, userId);
    await refresh();
    ref.invalidate(tripDetailProvider(id));
  }
}

final tripsProvider = AsyncNotifierProvider<TripsNotifier, List<Trip>>(
  TripsNotifier.new,
);

String _snapshotKey(String userId) => 'home_trips_v1_$userId';

Future<void> _saveTripsSnapshot(String userId, List<Trip> trips) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _snapshotKey(userId),
      jsonEncode({
        'captured': DateTime.now().millisecondsSinceEpoch,
        'trips': trips
            .take(40)
            .map(
              (trip) => {
                'id': trip.id,
                'name': trip.name,
                'destination': trip.destination,
                'coverImage': trip.coverImage,
                'currency': trip.currency,
                'startDate': trip.startDate.toIso8601String(),
                'endDate': trip.endDate.toIso8601String(),
                '_count': {'members': trip.memberCount},
              },
            )
            .toList(),
      }),
    );
  } catch (_) {
    // The snapshot improves startup but is never needed to open a trip.
  }
}

final homeTripsSnapshotProvider = FutureProvider.autoDispose<List<Trip>>((
  ref,
) async {
  final userId =
      ref.watch(authProvider.select((auth) => auth.user?['id'])) as String?;
  if (userId == null) return const [];
  try {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_snapshotKey(userId));
    if (json == null) return const [];
    final snapshot = jsonDecode(json) as Map;
    if (DateTime.now().millisecondsSinceEpoch - (snapshot['captured'] as int) >
        const Duration(days: 7).inMilliseconds) {
      return const [];
    }
    return (snapshot['trips'] as List)
        .whereType<Map>()
        .map((data) => Trip.fromJson(data.cast<String, dynamic>()))
        .toList();
  } catch (_) {
    return const [];
  }
});

/// Chi tiết 1 chuyến.
final tripDetailProvider = FutureProvider.family<Trip, String>((ref, id) async {
  return ref.watch(tripsRepositoryProvider).fetchTrip(id);
});
