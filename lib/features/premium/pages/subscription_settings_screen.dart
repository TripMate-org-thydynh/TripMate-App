import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api_service.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/entitlement_provider.dart';
import '../data/trial_provider.dart';

/// Thiết lập gói cước.
class SubscriptionSettingsScreen extends ConsumerStatefulWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  ConsumerState<SubscriptionSettingsScreen> createState() =>
      _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState
    extends ConsumerState<SubscriptionSettingsScreen> {
  Map<String, dynamic>? _sub;
  List<Map<String, dynamic>> _squadSeats = const [];
  bool _loading = true;
  bool _failed = false;
  bool _restoring = false;
  bool _addingSeat = false;
  final TextEditingController _seatIdentifierController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _seatIdentifierController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final res = await ApiService.get('/premium/subscriptions');
    List<Map<String, dynamic>> seats = const [];
    if (res is Map &&
        res['status'] == 'ACTIVE' &&
        res['plan'] == 'SQUAD' &&
        (res['via'] == null || res['via'] == 'own')) {
      try {
        final seatsRes = await ApiService.get('/premium/squad/seats');
        final rawList = seatsRes is List
            ? seatsRes
            : (seatsRes is Map ? seatsRes['seats'] as List? : null);
        if (rawList != null) {
          seats = rawList
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _sub = res is Map ? res.cast<String, dynamic>() : null;
      _squadSeats = seats;
      _failed = res == null;
      _loading = false;
    });
  }

  Future<void> _restorePurchases() async {
    if (_restoring) return;
    setState(() => _restoring = true);
    try {
      await InAppPurchase.instance.restorePurchases();
      ref.invalidate(entitlementProvider);
      await _fetch();
      if (mounted) {
        final isEn = context.locale.languageCode == 'en';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn
                  ? 'Purchases restored successfully'
                  : 'Đã khôi phục giao dịch mua',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        final isEn = context.locale.languageCode == 'en';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn
                  ? 'Could not restore purchases'
                  : 'Không thể khôi phục giao dịch mua',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _addSquadSeat() async {
    final identifier = _seatIdentifierController.text.trim();
    if (identifier.isEmpty || _addingSeat) return;
    setState(() => _addingSeat = true);
    try {
      final res = await ApiService.post('/premium/squad/seats', {
        'identifier': identifier,
        'email': identifier,
      });
      if (!mounted) return;
      if (res != null) {
        _seatIdentifierController.clear();
        await _fetch();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _addingSeat = false);
    }
  }

  Future<void> _removeSquadSeat(String userId) async {
    try {
      await ApiService.delete('/premium/squad/seats/$userId');
      if (mounted) await _fetch();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final isEn = context.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'premium.settings_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _restoring ? null : _restorePurchases,
            child: Text(
              isEn ? 'Restore' : 'Khôi phục',
              style: AppFonts.heading(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: _body(isDark),
    );
  }

  Widget _body(bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_failed) {
      return AppErrorState(isDark: isDark, onRetry: _fetch);
    }

    final isActive = _sub?['status'] == 'ACTIVE';
    if (!isActive) {
      return AppEmptyState(
        isDark: isDark,
        icon: PhosphorIcons.crown(),
        title: 'premium.no_plan_title'.tr(),
        body: 'premium.no_plan_body'.tr(),
      );
    }

    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = Theme.of(context).colorScheme.primary;
    final accentSoft = isDark
        ? GenZTokens.accentSoftDark
        : GenZTokens.accentSoft;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;
    final price = (_sub?['price'] as num?)?.toInt() ?? 0;
    final next = _parseDate(_sub?['activeUntil'] as String?);
    final plan = _sub?['plan'] as String? ?? 'PLUS';
    final via = _sub?['via'] as String? ?? 'own';
    final isTrial = _sub?['isTrial'] as bool? ?? false;
    final yearly = _sub?['billingCycle'] == 'YEARLY';
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isPlay =
        !isIOS && _sub?['provider'] == 'GOOGLE_PLAY' && via == 'own';
    final manageUrl = _sub?['manageUrl'] as String?;
    final autoRenew = _sub?['autoRenew'] as bool? ?? false;
    final isEn = context.locale.languageCode == 'en';

    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView(
        padding: const EdgeInsets.all(GenZTokens.space5),
        children: [
          Container(
            padding: const EdgeInsets.all(GenZTokens.space4),
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: accent, width: GenZTokens.borderWidth),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'premium.plan_$plan'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                const SizedBox(height: GenZTokens.space2),
                Text(
                  isTrial
                      ? 'trial.badge'.tr()
                      : (yearly
                                ? 'premium.price_yearly'
                                : 'premium.price_monthly')
                            .tr(args: [_money(price)]),
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'premium.active_until'.tr(
                      args: [
                        DateFormat.yMMMd(
                          context.locale.toLanguageTag(),
                        ).format(next),
                      ],
                    ),
                    style: AppFonts.body(fontSize: 13, color: inkSoft),
                  ),
                ],
              ],
            ),
          ),
          if (isTrial) ...[
            const SizedBox(height: GenZTokens.space4),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _cancelTrial,
                style: OutlinedButton.styleFrom(
                  foregroundColor: danger,
                  side: BorderSide(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
                child: Text(
                  'trial.cancel_cta'.tr(),
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: danger,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: GenZTokens.space5),
          Container(
            padding: const EdgeInsets.all(GenZTokens.space4),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(PhosphorIcons.info(), size: 18, color: inkSoft),
                const SizedBox(width: GenZTokens.space3),
                Expanded(
                  child: Text(
                    isTrial
                        ? 'trial.settings_notice'.tr()
                        : via == 'seat'
                        ? 'premium.via_seat_notice'.tr()
                        : isPlay
                        ? (autoRenew
                                  ? (yearly
                                        ? 'premium.play_autorenew_yearly'
                                        : 'premium.play_autorenew_monthly')
                                  : 'premium.play_canceled_notice')
                              .tr()
                        : 'premium.no_autorenew_notice'.tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      color: inkSoft,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPlay && manageUrl != null) ...[
            const SizedBox(height: GenZTokens.space4),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(manageUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: Icon(PhosphorIcons.arrowSquareOut(), size: 18),
                label: Text(
                  'premium.play_manage_cta'.tr(),
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  side: BorderSide(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: GenZTokens.space4),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _restoring ? null : _restorePurchases,
              icon: Icon(PhosphorIcons.arrowsClockwise(), size: 18),
              label: Text(
                isEn ? 'Restore Purchases' : 'Khôi phục giao dịch mua',
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                side: BorderSide(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
            ),
          ),
          if (plan == 'SQUAD' && via == 'own') ...[
            const SizedBox(height: GenZTokens.space6),
            Text(
              isEn
                  ? 'Squad Members (5 seats)'
                  : 'Quản lý thành viên Squad (5 ghế)',
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space3),
            Container(
              padding: const EdgeInsets.all(GenZTokens.space4),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _seatIdentifierController,
                          style: AppFonts.body(fontSize: 14, color: ink),
                          decoration: InputDecoration(
                            hintText: isEn
                                ? 'Enter email or username'
                                : 'Nhập email hoặc username',
                            hintStyle: AppFonts.body(
                              fontSize: 13,
                              color: inkSoft,
                            ),
                            filled: true,
                            fillColor: fill,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                GenZTokens.radiusInput,
                              ),
                              borderSide: BorderSide(color: line),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                GenZTokens.radiusInput,
                              ),
                              borderSide: BorderSide(color: line),
                            ),
                          ),
                          onSubmitted: (_) => _addSquadSeat(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addingSeat ? null : _addSquadSeat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusButton,
                            ),
                          ),
                        ),
                        child: Text(
                          isEn ? 'Add' : 'Thêm',
                          style: AppFonts.heading(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GenZTokens.space3),
                  if (_squadSeats.isEmpty)
                    Text(
                      isEn
                          ? 'No Squad members added yet.'
                          : 'Chưa có thành viên nào trong gói Squad.',
                      style: AppFonts.body(fontSize: 13, color: inkSoft),
                    )
                  else
                    ..._squadSeats.map((seat) {
                      final seatUser =
                          (seat['user'] as Map?)?.cast<String, dynamic>() ??
                          seat;
                      final seatUserId =
                          seatUser['id']?.toString() ??
                          seat['userId']?.toString() ??
                          '';
                      final seatName =
                          seatUser['fullName']?.toString() ??
                          seatUser['username']?.toString() ??
                          seatUser['email']?.toString() ??
                          seatUserId;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: accentSoft,
                          child: Icon(
                            PhosphorIcons.user(),
                            size: 16,
                            color: accent,
                          ),
                        ),
                        title: Text(
                          seatName,
                          style: AppFonts.heading(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ink,
                          ),
                        ),
                        trailing: seatUserId.isNotEmpty
                            ? IconButton(
                                onPressed: () => _removeSquadSeat(seatUserId),
                                icon: Icon(
                                  PhosphorIcons.trash(),
                                  size: 18,
                                  color: danger,
                                ),
                              )
                            : null,
                      );
                    }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Dừng dùng thử, có xác nhận một lần.
  Future<void> _cancelTrial() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark ? GenZTokens.paperDark : GenZTokens.paper,
        title: Text(
          'trial.cancel_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
        content: Text(
          'trial.cancel_body'.tr(),
          style: AppFonts.body(color: inkSoft, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'trial.cancel_keep'.tr(),
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: inkSoft,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'trial.cancel_confirm'.tr(),
              style: AppFonts.heading(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: danger,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(trialActionsProvider).cancel();
    } catch (_) {
      // ApiClient đã hiện lỗi; vẫn tải lại để màn không kẹt ở trạng thái cũ.
    }
    if (mounted) await _fetch();
  }

  static DateTime? _parseDate(String? raw) =>
      raw == null ? null : DateTime.tryParse(raw);

  /// 99000 -> "99.000" (kiểu VN, không phụ thuộc locale đang chọn).
  static String _money(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}
