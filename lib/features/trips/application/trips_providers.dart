import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../data/trips_repository.dart';
import '../domain/trip.dart';

/// Danh sách chuyến đi của user hiện tại (AsyncValue: loading/error/data).
class TripsNotifier extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() async {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const [];
    return ref.watch(tripsRepositoryProvider).fetchTrips();
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
    await refresh();
    return trip;
  }

  Future<Trip> join(String inviteCode) async {
    final trip = await ref.read(tripsRepositoryProvider).joinTrip(inviteCode);
    await refresh();
    return trip;
  }

  /// Tham gia bằng mã người dùng dán vào (mã invite-link hoặc mã chuyến).
  Future<Trip> joinByAnyCode(String code) async {
    final trip = await ref.read(tripsRepositoryProvider).joinByAnyCode(code);
    await refresh();
    return trip;
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
    final trip = await ref.read(tripsRepositoryProvider).updateTrip(
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
}

final tripsProvider = AsyncNotifierProvider<TripsNotifier, List<Trip>>(
  TripsNotifier.new,
);

/// Chi tiết 1 chuyến.
final tripDetailProvider = FutureProvider.family<Trip, String>((ref, id) async {
  return ref.watch(tripsRepositoryProvider).fetchTrip(id);
});
