import 'package:easy_localization/easy_localization.dart';
// Models cho feature Expenses — khớp response BE (`expenses` module).

class ExpenseUser {
  final String id;
  final String name;
  final String? avatarUrl;
  const ExpenseUser({required this.id, required this.name, this.avatarUrl});

  factory ExpenseUser.fromJson(Map<String, dynamic> j) => ExpenseUser(
    id: j['id'] as String? ?? '',
    name: j['name'] as String? ?? 'common.anonymous'.tr(),
    avatarUrl: j['avatarUrl'] as String?,
  );
}

class Expense {
  final String id;
  final double amount;
  final String category;
  final String? description;
  final String splitType;
  final String? receiptUrl;
  final ExpenseUser? paidBy;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    this.description,
    required this.splitType,
    this.receiptUrl,
    this.paidBy,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> j) {
    final paid = j['paidBy'];
    return Expense(
      id: j['id'] as String,
      amount: _num(j['amount']),
      category: j['category'] as String? ?? 'OTHER',
      description: j['description'] as String?,
      splitType: j['splitType'] as String? ?? 'EQUAL',
      receiptUrl: j['receiptUrl'] as String?,
      paidBy: paid is Map
          ? ExpenseUser.fromJson(paid.cast<String, dynamic>())
          : null,
      createdAt:
          DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Số dư ròng của 1 thành viên (>0 được nhận, <0 phải trả).
class MemberBalance {
  final ExpenseUser user;
  final double balance;
  const MemberBalance({required this.user, required this.balance});

  factory MemberBalance.fromJson(Map<String, dynamic> j) => MemberBalance(
    user: ExpenseUser.fromJson(
      (j['user'] as Map? ?? {}).cast<String, dynamic>(),
    ),
    balance: _num(j['balance']),
  );
}

/// Một giao dịch quyết toán đã được tối giản (debt simplification).
class Settlement {
  final ExpenseUser from;
  final ExpenseUser to;
  final double amount;
  const Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });

  factory Settlement.fromJson(Map<String, dynamic> j) => Settlement(
    from: ExpenseUser.fromJson(
      (j['from'] as Map? ?? {}).cast<String, dynamic>(),
    ),
    to: ExpenseUser.fromJson((j['to'] as Map? ?? {}).cast<String, dynamic>()),
    amount: _num(j['amount']),
  );
}

/// Kết quả `/expenses/balances`.
class BalancesResult {
  final List<MemberBalance> balances;
  final List<Settlement> settlements;
  const BalancesResult({required this.balances, required this.settlements});

  factory BalancesResult.fromJson(Map<String, dynamic> j) => BalancesResult(
    balances: (j['balances'] as List? ?? [])
        .whereType<Map>()
        .map((e) => MemberBalance.fromJson(e.cast<String, dynamic>()))
        .toList(),
    settlements: (j['settlements'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Settlement.fromJson(e.cast<String, dynamic>()))
        .toList(),
  );
}

double _num(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}
