import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/format/money.dart';
import '../../../../core/network/error_message.dart';

import '../../../../core/services/payment_launcher.dart';
import '../../../social/presentation/pages/trip_polls_screen.dart';
import '../../application/expenses_providers.dart';
import '../../domain/expense.dart';
import 'add_expense_sheet.dart';
import '../../../../core/widgets/offline_banner.dart';

/// Số dư & quyết toán của 1 chuyến — wired thật vào BE (`/expenses/balances`).
/// Kết nối 3 mảng: trips → expenses balances → PaymentLauncher (trả ngay).
class TripBalancesScreen extends ConsumerWidget {
  final String tripId;
  final String tripName;
  final bool isDarkMode;

  const TripBalancesScreen({
    super.key,
    required this.tripId,
    required this.tripName,
    this.isDarkMode = false,
  });

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  /// Accent lấy từ theme đang chọn.
  ///
  /// Truoc day la `isDark ? Color(0xFFF5822B) : Color(0xFFF5822B)` — hai
  /// nhanh y het nhau, va 0xFFF5822B chinh la accent cua preset *grape*.
  /// Nguoi dung o mint (vang) van thay man nay mau cam, va doi theme khong
  /// an. Doc tu `colorScheme` de mau di theo lua chon that.
  Color _primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  Color get _textPri => isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tripBalancesProvider(tripId));

    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryOf(context),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () {
          HapticFeedback.mediumImpact();
          AddExpenseSheet.show(context, tripId, isDarkMode);
        },
        icon: const Icon(Icons.add),
        label: Text(
          'expense.add'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w800),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'expense.split_title'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            Text(tripName, style: AppFonts.body(fontSize: 12, color: _textSec)),
          ],
        ),
        actions: [
          IconButton(
            // Icon phieu bau chu khong phai bieu do: nut nay mo man Binh chon
            // nhom, icon bieu do lam nguoi dung tuong la thong ke chi tieu.
            tooltip: 'polls.title'.tr(),
            icon: Icon(PhosphorIcons.listChecks(), color: _textPri),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TripPollsScreen(tripId: tripId, isDarkMode: isDarkMode),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              color: _primaryOf(context),
              onRefresh: () async => ref.refresh(tripBalancesProvider(tripId)),
              child: async.when(
                loading: () => _skeleton(),
                error: (e, _) => _error(context, ref, e),
                data: (result) => _content(context, result),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeleton() => ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      5,
      (i) => Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );

  Widget _error(BuildContext context, WidgetRef ref, Object e) => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'expense.balances_failed'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                friendlyError(e),
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 13, color: _textSec),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _primaryOf(context)),
              onPressed: () => ref.refresh(tripBalancesProvider(tripId)),
              icon: const Icon(Icons.refresh),
              label: Text('general.retry'.tr()),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _content(BuildContext context, BalancesResult result) {
    if (result.balances.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 130),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryOf(context).withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    PhosphorIcons.scales(PhosphorIconsStyle.fill),
                    color: _primaryOf(context),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'expense.empty'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _textPri,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'expense.empty_sub'.tr(),
                  style: AppFonts.body(fontSize: 14, color: _textSec),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      // Chừa chỗ cho FAB: trước đây nút nổi đè lên mục cuối danh sách
      // (BUG-006) — nội dung và cả control khác bị che, không bấm được.
      padding: const EdgeInsets.all(20).copyWith(bottom: 96),
      children: [
        // Settlements (ai trả ai)
        if (result.settlements.isNotEmpty) ...[
          Text(
            'expense.settle_minimal'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textPri,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'expense.settle_count'.tr(
              namedArgs: {'n': '${result.settlements.length}'},
            ),
            style: AppFonts.body(fontSize: 13, color: _textSec),
          ),
          const SizedBox(height: 14),
          ...result.settlements.map((s) => _settlementCard(context, s)),
          const SizedBox(height: 28),
        ],

        // Balances per member
        Text(
          'expense.per_person'.tr(),
          style: AppFonts.heading(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
        const SizedBox(height: 14),
        ...result.balances.map((b) => _balanceRow(context, b)),
      ],
    );
  }

  Widget _settlementCard(BuildContext context, Settlement s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      s.from.name,
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w700,
                        color: _textPri,
                        fontSize: 14,
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 16, color: _primaryOf(context)),
                    Flexible(
                      child: Text(
                        s.to.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.heading(
                          fontWeight: FontWeight.w700,
                          color: _textPri,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formatMoney(s.amount, locale: context.locale.languageCode),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w900,
                    // So tien la thong tin quan trong nhat man nay — phai doc
                    // duoc. Accent mint la vang, dat tren nen trang thi khong.
                    color: _textPri,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              PaymentLauncher.showPaymentSheet(
                context,
                recipientName: s.to.name,
                recipientPhone: '', // SĐT lấy từ profile người nhận khi có
                amount: s.amount,
                isDarkMode: isDarkMode,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _primaryOf(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'expense.pay_now'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  // Nen la accent: dung `onPrimary` cua preset thay vi trang cung,
                  // vi accent mint la vang thi chu trang chim han.
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(BuildContext context, MemberBalance b) {
    final positive = b.balance >= 0;
    final color = positive ? const Color(0xFF1FA85C) : Colors.redAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _primaryOf(context).withValues(alpha: 0.15),
            child: Text(
              b.user.name.isNotEmpty ? b.user.name.characters.first : '?',
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                // Chu vang tren nen vang nhat (alpha 0.15) gan nhu vo hinh.
                color: _textPri,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              b.user.name,
              style: AppFonts.heading(
                fontWeight: FontWeight.w700,
                color: _textPri,
                fontSize: 14,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                positive
                    ? 'expense.is_owed'.tr()
                    : 'expense.owes'.tr(),
                style: AppFonts.body(fontSize: 12, color: _textSec),
              ),
              Text(
                formatMoney(b.balance.abs(), locale: context.locale.languageCode),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
