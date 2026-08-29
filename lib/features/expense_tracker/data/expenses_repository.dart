import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/offline_provider.dart';
import '../domain/expense.dart';

/// Repository cho Expenses — endpoints nested dưới `/trips/:tripId/expenses`.
class ExpensesRepository {
  final ApiClient _client;
  final Ref _ref;
  ExpensesRepository(this._client, this._ref);

  String _base(String tripId) => '/trips/$tripId/expenses';

  Future<List<Expense>> fetchExpenses(String tripId) async {
    try {
      final data = await _client.getData(_base(tripId));
      if (data is List) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cache_expenses_$tripId', jsonEncode(data));

        _ref.read(offlineProvider.notifier).state = false;

        return data
            .whereType<Map>()
            .map((e) => Expense.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      return const [];
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cache_expenses_$tripId');
      if (cached != null) {
        final decoded = jsonDecode(cached);
        if (decoded is List) {
          _ref.read(offlineProvider.notifier).state = true;
          return decoded
              .whereType<Map>()
              .map((e) => Expense.fromJson(e.cast<String, dynamic>()))
              .toList();
        }
      }
      rethrow;
    }
  }

  Future<BalancesResult> fetchBalances(String tripId) async {
    try {
      final data = await _client.getData('${_base(tripId)}/balances');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cache_balances_$tripId', jsonEncode(data));

      _ref.read(offlineProvider.notifier).state = false;

      return BalancesResult.fromJson((data as Map).cast<String, dynamic>());
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cache_balances_$tripId');
      if (cached != null) {
        _ref.read(offlineProvider.notifier).state = true;
        return BalancesResult.fromJson(
          (jsonDecode(cached) as Map).cast<String, dynamic>(),
        );
      }
      rethrow;
    }
  }

  Future<Expense> createExpense(
    String tripId, {
    required double amount,
    required String category,
    String? description,
    required String splitType,
    String? paidById,
    List<Map<String, dynamic>>? splits,
  }) async {
    final data = await _client.postData(_base(tripId), {
      'amount': amount,
      'category': category,
      'description': description,
      'splitType': splitType,
      'paidById': paidById,
      'splits': splits,
    });
    return Expense.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> payShare(String tripId, String expenseId, String userId) {
    return _client.patchData('${_base(tripId)}/$expenseId/splits/$userId/pay');
  }

  Future<void> deleteExpense(String tripId, String expenseId) {
    return _client.deleteData('${_base(tripId)}/$expenseId');
  }

  Future<Map<String, dynamic>> scanReceipt(
    String tripId,
    String receiptUrl,
  ) async {
    final data = await _client.postData('${_base(tripId)}/ocr', {
      'receiptUrl': receiptUrl,
    });
    return (data as Map).cast<String, dynamic>();
  }
}

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository(ref.watch(apiClientProvider), ref);
});
