import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/format/money.dart';
import '../../../../core/network/error_message.dart';
import '../../../../core/theme/gen_z_tokens.dart';

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

  Color get _bg => isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _primary => isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent =>
      isDarkMode ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color get _accentSoft =>
      isDarkMode ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _fill => isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _textPri => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textSec =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tripBalancesProvider(tripId));

    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primary,
        foregroundColor: _onAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          AddExpenseSheet.show(context, tripId, isDarkMode);
        },
        icon: Icon(PhosphorIcons.plus()),
        label: Text(
          'expense.add'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: _onAccent,
          ),
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
                fontWeight: FontWeight.w700,
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
              color: _primary,
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
          color: _fill,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
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
            Icon(
              PhosphorIcons.cloudSlash(),
              color: isDarkMode ? GenZTokens.dangerDark : GenZTokens.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'expense.balances_failed'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
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
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: _onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              onPressed: () => ref.refresh(tripBalancesProvider(tripId)),
              icon: Icon(PhosphorIcons.arrowsClockwise()),
              label: Text(
                'general.retry'.tr(),
                style: TextStyle(color: _onAccent),
              ),
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
                    color: _fill,
                    border: Border.all(
                      color: _line,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Icon(
                    PhosphorIcons.scales(PhosphorIconsStyle.fill),
                    color: _primary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'expense.empty'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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
              fontSize: 17,
              fontWeight: FontWeight.w700,
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
            fontSize: 17,
            fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(PhosphorIcons.arrowRight(), size: 16, color: _primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        s.to.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.heading(
                          fontWeight: FontWeight.w700,
                          color: _textPri,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  formatMoney(s.amount, locale: context.locale.languageCode),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w700,
                    color: _textPri,
                    fontSize: 17,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                border: Border.all(
                  color: _primary,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Text(
                'expense.pay_now'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w700,
                  color: _primary,
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
    final color = positive
        ? (isDarkMode ? GenZTokens.successDark : GenZTokens.success)
        : (isDarkMode ? GenZTokens.dangerDark : GenZTokens.danger);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _fill,
            child: Text(
              b.user.name.isNotEmpty ? b.user.name.characters.first : '?',
              style: AppFonts.heading(
                fontWeight: FontWeight.w700,
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
                fontSize: 15,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                positive ? 'expense.is_owed'.tr() : 'expense.owes'.tr(),
                style: AppFonts.body(fontSize: 12, color: _textSec),
              ),
              Text(
                formatMoney(
                  b.balance.abs(),
                  locale: context.locale.languageCode,
                ),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w700,
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
