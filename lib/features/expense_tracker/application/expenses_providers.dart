import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/expenses_repository.dart';
import '../domain/expense.dart';

/// Danh sách chi tiêu của 1 trip.
final tripExpensesProvider = FutureProvider.family<List<Expense>, String>((
  ref,
  tripId,
) async {
  return ref.watch(expensesRepositoryProvider).fetchExpenses(tripId);
});

/// Số dư + quyết toán tối giản của 1 trip.
final tripBalancesProvider = FutureProvider.family<BalancesResult, String>((
  ref,
  tripId,
) async {
  return ref.watch(expensesRepositoryProvider).fetchBalances(tripId);
});
