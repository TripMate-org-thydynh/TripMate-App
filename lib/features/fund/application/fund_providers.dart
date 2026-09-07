import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fund_repository.dart';

/// Quản lý trạng thái Quỹ chuyến đi theo `tripId`.
class FundNotifier extends FamilyAsyncNotifier<TripFund?, String> {
  @override
  Future<TripFund?> build(String tripId) {
    return ref.watch(fundRepositoryProvider).getFund(tripId);
  }

  FundRepository get _repo => ref.read(fundRepositoryProvider);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getFund(arg));
  }

  Future<void> createFund({
    required double targetAmount,
    DateTime? deadline,
    String? note,
  }) async {
    await _repo.createFund(
      arg,
      targetAmount: targetAmount,
      deadline: deadline,
      note: note,
    );
    ref.invalidateSelf();
  }

  Future<void> contribute({
    required double amount,
    String? note,
    String? clientRequestId,
  }) async {
    await _repo.contribute(
      arg,
      amount: amount,
      note: note,
      clientRequestId: clientRequestId,
    );
    ref.invalidateSelf();
  }

  Future<void> deleteContribution(String contributionId) async {
    await _repo.deleteContribution(arg, contributionId);
    ref.invalidateSelf();
  }
}

final fundProvider =
    AsyncNotifierProvider.family<FundNotifier, TripFund?, String>(
      FundNotifier.new,
    );
