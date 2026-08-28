import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/invites_repository.dart';

class InvitesNotifier extends FamilyAsyncNotifier<List<TripInvite>, String> {
  @override
  Future<List<TripInvite>> build(String tripId) {
    return ref.watch(invitesRepositoryProvider).fetch(tripId);
  }

  InvitesRepository get _repo => ref.read(invitesRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetch(arg));
  }

  Future<TripInvite> create({String? expiresAt, int? maxUses}) async {
    final invite = await _repo.create(arg, expiresAt: expiresAt, maxUses: maxUses);
    ref.invalidateSelf();
    return invite;
  }

  Future<void> deactivate(String inviteId) async {
    await _repo.deactivate(arg, inviteId);
    ref.invalidateSelf();
  }
}

final invitesProvider =
    AsyncNotifierProvider.family<InvitesNotifier, List<TripInvite>, String>(
      InvitesNotifier.new,
    );
