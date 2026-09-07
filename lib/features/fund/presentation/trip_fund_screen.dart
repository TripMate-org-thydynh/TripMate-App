import 'dart:math';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/app_messenger.dart';
import '../../../core/format/money.dart';
import '../../../core/network/api_exception.dart';
import '../application/fund_providers.dart';
import '../data/fund_repository.dart';

/// Màn hình Quỹ chuyến đi — xem tiến độ, mục tiêu, tạo quỹ, đóng góp & lịch sử đóng góp.
/// Hỗ trợ cả Light mode và Dark mode theo quy chuẩn Gen Z Design System của TripMate.
class TripFundScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;

  const TripFundScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  @override
  ConsumerState<TripFundScreen> createState() => _TripFundScreenState();
}

class _TripFundScreenState extends ConsumerState<TripFundScreen> {
  bool _isDeleting = false;

  bool get _dark => widget.isDarkMode;
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      _dark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary => const Color(0xFF10B981);
  Color get _textPri => _dark ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      _dark ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);
  Color get _border => _dark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.08);

  // ── Mở Form Tạo Quỹ ──
  void _openCreateFundSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _CreateFundSheet(
          tripId: widget.tripId,
          isDarkMode: _dark,
          primaryColor: _primary,
        ),
      ),
    );
  }

  // ── Mở Form Đóng Góp ──
  void _openContributeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _ContributeSheet(
          tripId: widget.tripId,
          isDarkMode: _dark,
          primaryColor: _primary,
        ),
      ),
    );
  }

  // ── Xác nhận & Xoá khoản đóng góp (Chặn Double-Tap & Bắt 403) ──
  Future<void> _confirmDelete(
    BuildContext context,
    FundContribution contribution,
  ) async {
    if (_isDeleting) return;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        bool isDialogSubmitting = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: _surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'fund.delete_contribution_confirm'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDialogSubmitting ? null : () => Navigator.pop(ctx),
                child: Text(
                  'general.cancel'.tr(),
                  style: AppFonts.body(color: _textSec),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD8422B),
                ),
                onPressed: isDialogSubmitting
                    ? null
                    : () async {
                        if (isDialogSubmitting) return;
                        setDialogState(() => isDialogSubmitting = true);
                        if (mounted) setState(() => _isDeleting = true);
                        try {
                          HapticFeedback.mediumImpact();
                          await ref
                              .read(fundProvider(widget.tripId).notifier)
                              .deleteContribution(contribution.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          showGlobalSnack(
                            'fund.delete_contribution_success'.tr(),
                          );
                        } on ApiException catch (e) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          final msg = (e.isForbidden || e.statusCode == 403)
                              ? 'fund.error_forbidden_delete'.tr()
                              : e.message;
                          showGlobalSnack(msg, isError: true);
                        } catch (e) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          showGlobalSnack(e.toString(), isError: true);
                        } finally {
                          if (ctx.mounted) {
                            setDialogState(() => isDialogSubmitting = false);
                          }
                          if (mounted) {
                            setState(() => _isDeleting = false);
                          }
                        }
                      },
                child: isDialogSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('general.delete2'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(fundProvider(widget.tripId));
    final fund = async.valueOrNull;

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'fund.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
      ),
      floatingActionButton: fund == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              onPressed: () => _openContributeSheet(context),
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'fund.contribute_btn'.tr(),
                style: AppFonts.heading(fontWeight: FontWeight.w800),
              ),
            ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () =>
            ref.read(fundProvider(widget.tripId).notifier).refresh(),
        child: async.when(
          loading: () => _skeleton(),
          error: (e, _) => _error(),
          data: (fundData) {
            if (fundData == null) {
              return _emptyView(context);
            }
            return _fundContent(context, fundData);
          },
        ),
      ),
    );
  }

  // ── Màn hình rỗng khi chưa tạo quỹ ──
  Widget _emptyView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      children: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.piggyBank(PhosphorIconsStyle.fill),
              size: 56,
              color: _primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'fund.empty_title'.tr(),
          textAlign: TextAlign.center,
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: _textPri,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'fund.empty_desc'.tr(),
          textAlign: TextAlign.center,
          style: AppFonts.body(
            fontSize: 14,
            color: _textSec,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        Center(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () => _openCreateFundSheet(context),
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              'fund.create_fund_btn'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Nội dung quỹ khi đã tồn tại ──
  Widget _fundContent(BuildContext context, TripFund fund) {
    final isCompleted =
        fund.totalCollected >= fund.targetAmount && fund.targetAmount > 0;
    final double ratio = fund.targetAmount > 0
        ? (fund.totalCollected / fund.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final pct = fund.progressPercent;
    final remaining = fund.targetAmount > fund.totalCollected
        ? fund.targetAmount - fund.totalCollected
        : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      children: [
        // 1. Tiến độ & mục tiêu
        _progressCard(context, fund, ratio, pct, isCompleted, remaining),
        const SizedBox(height: 24),

        // 2. Header Lịch sử đóng góp
        Row(
          children: [
            Icon(
              PhosphorIcons.wallet(PhosphorIconsStyle.fill),
              size: 20,
              color: _primary,
            ),
            const SizedBox(width: 8),
            Text(
              'fund.contributions'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _textPri,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${fund.contributions.length})',
              style: AppFonts.mono(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _textSec,
              ),
            ),
            const Spacer(),
            if (fund.contributions.isNotEmpty)
              Text(
                'fund.delete_tip'.tr(),
                style: AppFonts.body(
                  fontSize: 11,
                  color: _textSec.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Danh sách các khoản đóng góp
        if (fund.contributions.isEmpty)
          _emptyContributionsCard()
        else
          ...fund.contributions.map(
            (item) => _contributionTile(context, item),
          ),
      ],
    );
  }

  // ── Card tiến độ quỹ ──
  Widget _progressCard(
    BuildContext context,
    TripFund fund,
    double ratio,
    double pct,
    bool isCompleted,
    double remaining,
  ) {
    final locale = context.locale.languageCode;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row tiêu đề card: icon + Tiến độ + %
          Row(
            children: [
              Icon(
                isCompleted
                    ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                    : PhosphorIcons.piggyBank(PhosphorIconsStyle.fill),
                color: _primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'fund.progress'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: _textPri,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${pct.toStringAsFixed(pct.truncateToDouble() == pct ? 0 : 1)}%',
                  style: AppFonts.mono(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Thanh LinearProgressIndicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 12,
              backgroundColor: _bgOf(context),
              valueColor: AlwaysStoppedAnimation(_primary),
            ),
          ),
          const SizedBox(height: 16),

          // Số tiền Đã thu vs Mục tiêu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'fund.total_collected'.tr(),
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSec,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatMoney(fund.totalCollected, locale: locale),
                    style: AppFonts.mono(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'fund.target_amount'.tr(),
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSec,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatMoney(fund.targetAmount, locale: locale),
                    style: AppFonts.mono(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _textPri,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Còn thiếu / Đã hoàn thành
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? _primary.withValues(alpha: 0.1)
                  : _bgOf(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCompleted
                  ? 'fund.completed'.tr()
                  : 'fund.remaining_amount'.tr(
                      namedArgs: {
                        'amount': formatMoney(remaining, locale: locale),
                      },
                    ),
              style: AppFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isCompleted ? _primary : _textSec,
              ),
            ),
          ),
          const SizedBox(height: 14),

          Divider(height: 1, color: _border),
          const SizedBox(height: 12),

          // Hạn chót
          Row(
            children: [
              Icon(
                PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
                size: 17,
                color: _textSec,
              ),
              const SizedBox(width: 8),
              Text(
                'fund.deadline'.tr(),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textSec,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                fund.deadline != null
                    ? DateFormat('dd/MM/yyyy').format(fund.deadline!)
                    : 'fund.no_deadline'.tr(),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fund.deadline != null ? _textPri : _textSec,
                ),
              ),
            ],
          ),

          // Ghi chú của quỹ nếu có
          if (fund.note != null && fund.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PhosphorIcons.note(PhosphorIconsStyle.fill),
                  size: 17,
                  color: _textSec,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fund.note!.trim(),
                    style: AppFonts.body(
                      fontSize: 13,
                      color: _textSec,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Thẻ trống khi chưa có khoản đóng góp nào ──
  Widget _emptyContributionsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Center(
        child: Text(
          'fund.no_contributions'.tr(),
          textAlign: TextAlign.center,
          style: AppFonts.body(
            fontSize: 13.5,
            color: _textSec,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ── Tile từng khoản đóng góp ──
  Widget _contributionTile(BuildContext context, FundContribution item) {
    final locale = context.locale.languageCode;
    final userName = item.user?.name.trim();
    final displayName =
        (userName != null && userName.isNotEmpty) ? userName : '...';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final avatarUrl = item.user?.avatarUrl;

    return GestureDetector(
      onLongPress: () => _confirmDelete(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withValues(alpha: 0.15),
                image: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Text(
                      initial,
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Thông tin người & ghi chú & thời gian
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'fund.by_user'.tr(namedArgs: {'name': displayName}),
                    style: AppFonts.body(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _textPri,
                    ),
                  ),
                  if (item.note != null && item.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.note!.trim(),
                      style: AppFonts.body(
                        fontSize: 12,
                        color: _textSec,
                      ),
                    ),
                  ],
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('HH:mm · dd/MM/yyyy').format(item.createdAt!),
                      style: AppFonts.mono(
                        fontSize: 11,
                        color: _textSec.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Số tiền đóng góp
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${formatMoney(item.amount, locale: locale)}',
                  style: AppFonts.mono(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: _primary,
                  ),
                ),
              ],
            ),

            // Nút xoá tiện lợi
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                PhosphorIcons.trash(),
                size: 18,
                color: _textSec.withValues(alpha: 0.6),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => _confirmDelete(context, item),
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton loading ──
  Widget _skeleton() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 170,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: _dark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          ...List.generate(
            4,
            (i) => Container(
              height: 64,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _dark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      );

  // ── Báo lỗi khi tải thất bại ──
  Widget _error() => ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.redAccent,
                  size: 44,
                ),
                const SizedBox(height: 14),
                Text(
                  'fund.error_load'.tr(),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w800,
                    color: _textPri,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _primary),
                  onPressed: () =>
                      ref.read(fundProvider(widget.tripId).notifier).refresh(),
                  child: Text('general.retry'.tr()),
                ),
              ],
            ),
          ),
        ],
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET TẠO QUÝ MỚI
// ══════════════════════════════════════════════════════════════════════════════
class _CreateFundSheet extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;
  final Color primaryColor;

  const _CreateFundSheet({
    required this.tripId,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  ConsumerState<_CreateFundSheet> createState() => _CreateFundSheetState();
}

class _CreateFundSheetState extends ConsumerState<_CreateFundSheet> {
  final _targetCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime? _deadline;
  bool _isSubmitting = false;

  bool get _dark => widget.isDarkMode;
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      _dark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _textPri => _dark ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      _dark ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  @override
  void dispose() {
    _targetCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final rawText =
        _targetCtrl.text.trim().replaceAll('.', '').replaceAll(',', '');
    final target = double.tryParse(rawText);
    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('fund.target_amount_invalid'.tr()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      HapticFeedback.mediumImpact();
      await ref.read(fundProvider(widget.tripId).notifier).createFund(
            targetAmount: target,
            deadline: _deadline,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
      }
      showGlobalSnack('fund.create_success'.tr());
    } on ApiException catch (e) {
      showGlobalSnack(e.message, isError: true);
    } catch (e) {
      showGlobalSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề Sheet
          Row(
            children: [
              Text(
                'fund.create_fund_title'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: _textPri,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: _textSec),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mục tiêu quỹ
          Text(
            'fund.target_amount'.tr(),
            style: AppFonts.body(
              fontWeight: FontWeight.w700,
              color: _textSec,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _targetCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: AppFonts.mono(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: _textPri,
            ),
            decoration: InputDecoration(
              hintText: 'fund.target_hint'.tr(),
              hintStyle: AppFonts.body(color: _textSec.withValues(alpha: 0.6)),
              filled: true,
              fillColor: _bgOf(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                PhosphorIcons.piggyBank(PhosphorIconsStyle.fill),
                color: widget.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hạn chót (Date picker)
          Text(
            'fund.deadline'.tr(),
            style: AppFonts.body(
              fontWeight: FontWeight.w700,
              color: _textSec,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _deadline ?? now.add(const Duration(days: 7)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 365 * 5)),
                builder: (context, child) => Theme(
                  data: _dark
                      ? ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: widget.primaryColor,
                            surface: _surface,
                          ),
                        )
                      : ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: widget.primaryColor,
                          ),
                        ),
                  child: child!,
                ),
              );
              if (picked != null && mounted) {
                setState(() => _deadline = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: _bgOf(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
                    color: _textSec,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _deadline != null
                          ? DateFormat('dd/MM/yyyy').format(_deadline!)
                          : 'fund.deadline_hint'.tr(),
                      style: AppFonts.body(
                        color: _deadline != null ? _textPri : _textSec,
                        fontWeight: _deadline != null
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (_deadline != null)
                    GestureDetector(
                      onTap: () => setState(() => _deadline = null),
                      child: Text(
                        'fund.clear_deadline'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ghi chú
          Text(
            'fund.note'.tr(),
            style: AppFonts.body(
              fontWeight: FontWeight.w700,
              color: _textSec,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            style: AppFonts.body(color: _textPri),
            decoration: InputDecoration(
              hintText: 'fund.note_hint'.tr(),
              hintStyle: AppFonts.body(color: _textSec.withValues(alpha: 0.6)),
              filled: true,
              fillColor: _bgOf(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nút tạo quỹ
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: widget.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'fund.create_fund_btn'.tr(),
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET ĐÓNG GÓP VÀO QUỸ
// ══════════════════════════════════════════════════════════════════════════════
String _newRequestId() {
  final r = Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

class _ContributeSheet extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;
  final Color primaryColor;

  const _ContributeSheet({
    required this.tripId,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  ConsumerState<_ContributeSheet> createState() => _ContributeSheetState();
}

class _ContributeSheetState extends ConsumerState<_ContributeSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late final String _requestId;
  bool _isSubmitting = false;

  static const _quickAmounts = [50000, 100000, 200000, 500000, 1000000, 2000000];

  @override
  void initState() {
    super.initState();
    _requestId = _newRequestId();
  }

  bool get _dark => widget.isDarkMode;
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      _dark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _textPri => _dark ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      _dark ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final rawText =
        _amountCtrl.text.trim().replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(rawText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('fund.amount_invalid'.tr()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      HapticFeedback.mediumImpact();
      await ref.read(fundProvider(widget.tripId).notifier).contribute(
            amount: amount,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            clientRequestId: _requestId,
          );
      if (mounted) {
        Navigator.pop(context);
      }
      showGlobalSnack('fund.contribute_success'.tr());
    } on ApiException catch (e) {
      showGlobalSnack(e.message, isError: true);
    } catch (e) {
      showGlobalSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Sheet
          Row(
            children: [
              Text(
                'fund.contribute_title'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: _textPri,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: _textSec),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Số tiền
          Text(
            'fund.amount'.tr(),
            style: AppFonts.body(
              fontWeight: FontWeight.w700,
              color: _textSec,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: AppFonts.mono(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: _textPri,
            ),
            decoration: InputDecoration(
              hintText: 'fund.amount_hint'.tr(),
              hintStyle: AppFonts.body(color: _textSec.withValues(alpha: 0.6)),
              filled: true,
              fillColor: _bgOf(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                PhosphorIcons.wallet(PhosphorIconsStyle.fill),
                color: widget.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Chọn nhanh (Quick amounts)
          Text(
            'fund.quick_amounts'.tr(),
            style: AppFonts.body(
              fontWeight: FontWeight.w600,
              color: _textSec,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAmounts.map((val) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _amountCtrl.text = val.toString();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _bgOf(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _textSec.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    formatMoney(val, locale: locale),
                    style: AppFonts.mono(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textPri,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Ghi chú
          Text(
            'fund.note'.tr(),
            style: AppFonts.body(
              fontWeight: FontWeight.w700,
              color: _textSec,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteCtrl,
            style: AppFonts.body(color: _textPri),
            decoration: InputDecoration(
              hintText: 'fund.note_hint'.tr(),
              hintStyle: AppFonts.body(color: _textSec.withValues(alpha: 0.6)),
              filled: true,
              fillColor: _bgOf(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nút gửi đóng góp
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: widget.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'fund.contribute_btn'.tr(),
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
