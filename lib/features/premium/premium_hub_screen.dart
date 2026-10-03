// Chi lay `tr` + extension locale: easy_localization re-export intl, va intl
// cung co TextDirection -> va cham voi dart:ui neu import ca goi.
import 'package:easy_localization/easy_localization.dart'
    show tr, BuildContextEasyLocalizationExtension;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/format/money.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/theme/gen_z_tokens.dart';
import 'data/entitlement_provider.dart';
import 'data/trial_provider.dart';
import 'pages/billing_history_screen.dart';
import 'pages/creator_revenue_dashboard_screen.dart';
import 'pages/referral_campaign_screen.dart';
import 'pages/referral_rewards_screen.dart';
import 'pages/subscription_checkout_screen.dart';
import 'pages/subscription_settings_screen.dart';

/// Hạn mức của gói trả phí, khớp `PAID_LIMITS` ở backend
/// (`premium/entitlement.service.ts`). Chỉ để HIỂN THỊ bảng so sánh cho người
/// đang ở Free — quyết định thật vẫn do server kiểm. Chuyến và khoảnh khắc
/// không giới hạn nên không có số ở đây.
const int _eliteMembersPerTrip = 30;
const int _eliteAiPerMonth = 300;

/// Màn nâng cấp tài khoản.
///
/// Bố cục: thẻ hero đảo màu (điểm nhìn đầu tiên) → bảng so sánh Free/Elite
/// bằng hạn mức thật → đặc quyền → cài đặt dịch vụ. Hành động chính nằm ở
/// thanh cố định dưới đáy nên luôn trong tầm tay dù cuộn tới đâu; đó cũng là
/// vùng DUY NHẤT dùng màu nhấn đặc trên màn này.
class PremiumHubScreen extends ConsumerWidget {
  const PremiumHubScreen({super.key});

  static const List<String> _themes = [
    'Tokyo Neon',
    'Đà Lạt Mist',
    'Beach Chaos',
    'Retro Film',
    'Cyber Night',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theo đúng chế độ sáng/tối của app thay vì giữ cờ riêng — cờ riêng làm màn
    // này lệch pha với theme người dùng đã chọn.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = _Palette.of(context, isDark);

    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? Entitlement.free;
    final trial = ref.watch(trialStatusProvider).valueOrNull ?? TrialStatus.none;
    // Đang dùng thử vẫn là khách cần được mời mua, nên chỉ coi là "đã có gói"
    // khi quyền đến từ tiền thật hoặc ghế được cấp.
    final hasPlan = entitlement.isPaid && !entitlement.isTrial;
    // Còn mời dùng thử được: chưa có gói, chưa từng thử. Điều khoản "không tự
    // trừ tiền" là thứ màn này hứa, nên chỉ mời khi server xác nhận đúng vậy.
    final canStartTrial =
        !hasPlan && trial.canStart && !trial.terms.autoCharge;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(PhosphorIcons.arrowLeft(), color: c.ink),
                    tooltip: tr('common.close'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tr('premium.elite_squad'),
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: c.ink,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Hero(
                      palette: c,
                      isDark: isDark,
                      statusLabel: _statusLabel(entitlement, trial),
                    ),
                    if (canStartTrial)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _TrialNote(palette: c, terms: trial.terms),
                      ),
                    const SizedBox(height: 28),
                    _SectionTitle(
                      tr('premium.hub_compare_title'),
                      color: c.ink,
                    ),
                    const SizedBox(height: 12),
                    _CompareCard(palette: c),
                    const SizedBox(height: 28),
                    _SectionTitle(tr('premium.hub_perks_title'), color: c.ink),
                    const SizedBox(height: 12),
                    _PerksGrid(palette: c),
                    const SizedBox(height: 28),
                    _SectionTitle(
                      tr('premium.cinematic_themes'),
                      color: c.ink,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final name in _themes)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: c.card,
                              borderRadius: BorderRadius.circular(
                                GenZTokens.radiusPill,
                              ),
                              border: Border.all(
                                color: c.line,
                                width: GenZTokens.borderWidthThin,
                              ),
                            ),
                            child: Text(
                              name,
                              style: AppFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: c.ink,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _SectionTitle(
                      tr('premium.services_settings'),
                      color: c.ink,
                    ),
                    const SizedBox(height: 12),
                    _SettingsGroup(palette: c, isDark: isDark),
                  ],
                ),
              ),
            ),
            _BottomBar(
              palette: c,
              isDark: isDark,
              hasPlan: hasPlan,
              entitlement: entitlement,
              priceFrom: trial.terms.priceAfter,
              trialDays: canStartTrial ? trial.terms.days : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Nhãn trạng thái ở góc thẻ hero: người dùng thấy ngay mình đang ở đâu.
  static String _statusLabel(Entitlement e, TrialStatus trial) {
    if (e.isTrial || trial.active) {
      final days = (trial.remaining.inHours / 24).ceil().clamp(1, 99);
      return tr('premium.hub_trial_left', namedArgs: {'n': '$days'});
    }
    final until = e.activeUntil;
    if (e.isPaid && until != null) {
      return tr(
        'premium.hub_plan_until',
        namedArgs: {'plan': e.plan, 'date': _formatDate(until)},
      );
    }
    if (e.isPaid) return e.plan;
    return tr('premium.hub_plan_free');
  }
}

/// dd/MM/yyyy theo giờ máy — đủ cho ngày hết hạn, không cần kéo `intl` vào.
String _formatDate(DateTime d) {
  final l = d.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(l.day)}/${two(l.month)}/${l.year}';
}

/// Gom màu theo chế độ sáng/tối một lần, các widget con chỉ việc dùng.
class _Palette {
  final Color bg, card, fill, line, ink, inkSoft, accent, onAccent, accentSoft;

  /// Bề mặt đảo màu của thẻ hero: mực đậm trên nền sáng, kem trên nền tối.
  final Color heroBg, heroInk;

  const _Palette({
    required this.bg,
    required this.card,
    required this.fill,
    required this.line,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.heroBg,
    required this.heroInk,
  });

  factory _Palette.of(BuildContext context, bool isDark) {
    final scheme = Theme.of(context).colorScheme;
    return _Palette(
      bg: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      card: isDark ? GenZTokens.paperDark : GenZTokens.paper,
      fill: isDark ? GenZTokens.fillDark : GenZTokens.fill,
      line: isDark ? GenZTokens.lineDark : GenZTokens.line,
      ink: isDark ? GenZTokens.inkDark : GenZTokens.ink,
      inkSoft: isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft,
      accent: scheme.primary,
      onAccent: scheme.onPrimary,
      accentSoft: isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft,
      heroBg: isDark ? GenZTokens.inkDark : GenZTokens.ink,
      heroInk: isDark ? GenZTokens.creamDark : GenZTokens.cream,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.heading(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

/// Thẻ hero đảo màu. Không dùng màu nhấn: độ nổi bật đến từ tương phản bề mặt,
/// để màu nhấn chỉ dành cho nút hành động ở đáy màn.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.palette,
    required this.isDark,
    required this.statusLabel,
  });

  final _Palette palette;
  final bool isDark;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final fg = palette.heroInk;
    final fgSoft = fg.withValues(alpha: 0.72);
    final hairline = fg.withValues(alpha: 0.18);

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: palette.heroBg,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: GenZTokens.ink.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fg.withValues(alpha: 0.12),
                ),
                child: Icon(
                  PhosphorIcons.crown(PhosphorIconsStyle.fill),
                  color: fg,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr('premium.hub_badge'),
                  style: AppFonts.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: fgSoft,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: hairline,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            tr('premium.hub_headline'),
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.15,
              color: fg,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tr('premium.hero_sub'),
            style: AppFonts.body(fontSize: 15, height: 1.4, color: fgSoft),
          ),
          const SizedBox(height: 22),
          Container(height: GenZTokens.borderWidthThin, color: hairline),
          const SizedBox(height: 18),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HeroStat(
                    value: null,
                    label: tr('premium.hub_stat_trips'),
                    fg: fg,
                    fgSoft: fgSoft,
                  ),
                ),
                Container(
                  width: GenZTokens.borderWidthThin,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: hairline,
                ),
                Expanded(
                  child: _HeroStat(
                    value: '$_eliteMembersPerTrip',
                    label: tr('premium.hub_stat_members'),
                    fg: fg,
                    fgSoft: fgSoft,
                  ),
                ),
                Container(
                  width: GenZTokens.borderWidthThin,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: hairline,
                ),
                Expanded(
                  child: _HeroStat(
                    value: '$_eliteAiPerMonth',
                    label: tr('premium.hub_stat_ai'),
                    fg: fg,
                    fgSoft: fgSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Hiện ra một lần khi mở màn: trượt nhẹ lên + rõ dần. Không lặp.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: card,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 12),
          child: child,
        ),
      ),
    );
  }
}

/// Một con số trong thẻ hero. [value] null nghĩa là "không giới hạn".
class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.fg,
    required this.fgSoft,
  });

  final String? value;
  final String label;
  final Color fg;
  final Color fgSoft;

  @override
  Widget build(BuildContext context) {
    final v = value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
          child: Align(
            alignment: Alignment.centerLeft,
            child: v == null
                ? Icon(
                    PhosphorIcons.infinity(PhosphorIconsStyle.bold),
                    color: fg,
                    size: 26,
                    semanticLabel: tr('premium.hub_unlimited'),
                  )
                : Text(
                    v,
                    style: AppFonts.mono(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppFonts.body(fontSize: 12, height: 1.3, color: fgSoft),
        ),
      ],
    );
  }
}

class _TrialNote extends StatelessWidget {
  const _TrialNote({required this.palette, required this.terms});

  final _Palette palette;
  final TrialTerms terms;

  @override
  Widget build(BuildContext context) {
    final price = formatMoney(
      terms.priceAfter,
      locale: context.locale.languageCode,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIcons.shieldCheck(), size: 18, color: palette.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nói đủ điều khoản NGAY cạnh nút bắt đầu: bao lâu, hết hạn về
                // đâu, có trừ tiền không, mua tiếp giá bao nhiêu.
                Text(
                  terms.priceAfter > 0
                      ? tr(
                          'trial.terms_no_charge',
                          namedArgs: {'n': '${terms.days}', 'price': price},
                        )
                      : tr(
                          'premium.hub_trial_note',
                          namedArgs: {'days': '${terms.days}'},
                        ),
                  style: AppFonts.body(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                // Mua thẳng không qua dùng thử vẫn phải làm được.
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionCheckoutScreen(),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      tr('premium.hub_buy_now'),
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.accent,
                      ).copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bảng so sánh Free / Elite bằng hạn mức thật của hai gói.
class _CompareCard extends StatelessWidget {
  const _CompareCard({required this.palette});

  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    const free = Entitlement.free;
    // (nhãn, giá trị Free, giá trị Elite — null = không giới hạn)
    final rows = <(String, int, int?)>[
      (tr('premium.hub_row_trips'), free.limitOf(Quota.activeTrips), null),
      (
        tr('premium.hub_row_members'),
        free.limitOf(Quota.membersPerTrip),
        _eliteMembersPerTrip,
      ),
      (
        tr('premium.hub_row_moments'),
        free.limitOf(Quota.momentsPerTrip),
        null,
      ),
      (
        tr('premium.hub_row_ai'),
        free.limitOf(Quota.aiPerMonth),
        _eliteAiPerMonth,
      ),
    ];
    const radius = Radius.circular(GenZTokens.radiusButton);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: palette.line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        children: [
          _CompareRow(
            palette: palette,
            label: const SizedBox.shrink(),
            free: Text(
              tr('premium.hub_col_free'),
              style: AppFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.inkSoft,
              ),
            ),
            elite: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.crown(PhosphorIconsStyle.fill),
                  size: 14,
                  color: palette.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  tr('premium.hub_col_elite'),
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.accent,
                  ),
                ),
              ],
            ),
            eliteRadius: const BorderRadius.vertical(top: radius),
            divider: false,
          ),
          for (var i = 0; i < rows.length; i++)
            _CompareRow(
              palette: palette,
              label: Text(
                rows[i].$1,
                style: AppFonts.body(
                  fontSize: 15,
                  height: 1.3,
                  color: palette.ink,
                ),
              ),
              free: Text(
                '${rows[i].$2}',
                style: AppFonts.mono(fontSize: 15, color: palette.inkSoft),
              ),
              elite: rows[i].$3 == null
                  ? Icon(
                      PhosphorIcons.infinity(PhosphorIconsStyle.bold),
                      size: 20,
                      color: palette.accent,
                      semanticLabel: tr('premium.hub_unlimited'),
                    )
                  : Text(
                      '${rows[i].$3}',
                      style: AppFonts.mono(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: palette.accent,
                      ),
                    ),
              eliteRadius: i == rows.length - 1
                  ? const BorderRadius.vertical(bottom: radius)
                  : BorderRadius.zero,
              divider: true,
            ),
        ],
      ),
    );
  }
}

/// Một hàng của bảng so sánh. Ô Elite có nền màu nhấn nhạt nối liền nhau theo
/// chiều dọc, tạo thành một cột nổi lên so với cột Free.
class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.palette,
    required this.label,
    required this.free,
    required this.elite,
    required this.eliteRadius,
    required this.divider,
  });

  final _Palette palette;
  final Widget label;
  final Widget free;
  final Widget elite;
  final BorderRadius eliteRadius;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final top = divider
        ? Border(
            top: BorderSide(
              color: palette.line,
              width: GenZTokens.borderWidthThin,
            ),
          )
        : null;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(border: top),
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.centerLeft,
              child: label,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(border: top),
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              child: free,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: palette.accentSoft,
                borderRadius: eliteRadius,
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              child: elite,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lưới 2 cột các đặc quyền.
class _PerksGrid extends StatelessWidget {
  const _PerksGrid({required this.palette});

  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    final perks = <(IconData, String, String)>[
      (
        PhosphorIcons.sparkle(),
        tr('premium.feat_identity_title'),
        tr('premium.feat_identity_desc'),
      ),
      (
        PhosphorIcons.mapPin(),
        tr('premium.feat_spots_title'),
        tr('premium.feat_spots_desc'),
      ),
      (
        PhosphorIcons.smiley(),
        tr('premium.feat_reactions_title'),
        tr('premium.feat_reactions_desc'),
      ),
      (
        PhosphorIcons.cloudArrowUp(),
        tr('premium.feat_storage_title'),
        tr('premium.feat_storage_desc'),
      ),
    ];

    Widget cell((IconData, String, String) p) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: palette.line,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: palette.fill,
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
              child: Icon(p.$1, size: 18, color: palette.ink),
            ),
            const SizedBox(height: 12),
            Text(
              p.$2,
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              p.$3,
              style: AppFonts.body(
                fontSize: 13,
                height: 1.4,
                color: palette.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        for (var i = 0; i < perks.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                cell(perks[i]),
                const SizedBox(width: 10),
                cell(perks[i + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Các mục cài đặt dịch vụ gom vào một thẻ, ngăn nhau bằng đường kẻ.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.palette, required this.isDark});

  final _Palette palette;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }

    final items = <(IconData, String, String, VoidCallback)>[
      (
        PhosphorIcons.gear(),
        tr('premium.sub_settings_title'),
        tr('premium.sub_settings_desc'),
        () => open(const SubscriptionSettingsScreen()),
      ),
      (
        PhosphorIcons.receipt(),
        tr('premium.invoices_title'),
        tr('premium.invoices_desc'),
        () => open(const BillingHistoryScreen()),
      ),
      (
        PhosphorIcons.gift(),
        tr('premium.referral_rewards_title'),
        tr('premium.referral_rewards_desc'),
        () => open(const ReferralRewardsScreen()),
      ),
      (
        PhosphorIcons.usersThree(),
        tr('premium.referral_campaign_title'),
        tr('premium.referral_campaign_desc'),
        () => open(
          ReferralCampaignScreen(isDarkMode: isDark, onThemeToggle: () {}),
        ),
      ),
      (
        PhosphorIcons.paintBrush(),
        tr('premium.creator_shop_title'),
        tr('premium.creator_shop_desc'),
        () => open(const CreatorRevenueDashboardScreen()),
      ),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: palette.line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 62),
                  child: Container(
                    height: GenZTokens.borderWidthThin,
                    color: palette.line,
                  ),
                ),
              ListTile(
                onTap: items[i].$4,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: palette.fill,
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                  child: Icon(items[i].$1, size: 18, color: palette.ink),
                ),
                title: Text(
                  items[i].$2,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                ),
                subtitle: Text(
                  items[i].$3,
                  style: AppFonts.body(fontSize: 13, color: palette.inkSoft),
                ),
                trailing: Icon(
                  PhosphorIcons.caretRight(),
                  size: 16,
                  color: palette.inkSoft,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thanh hành động cố định ở đáy: giá khởi điểm bên trái, nút chính bên phải.
class _BottomBar extends ConsumerStatefulWidget {
  const _BottomBar({
    required this.palette,
    required this.isDark,
    required this.hasPlan,
    required this.entitlement,
    required this.priceFrom,
    required this.trialDays,
  });

  final _Palette palette;
  final bool isDark;
  final bool hasPlan;
  final Entitlement entitlement;

  /// Giá tháng thấp nhất do server trả về (kèm điều khoản dùng thử). 0 = chưa
  /// biết giá → không hiện số, tránh nói một giá mà server thu một giá khác.
  final int priceFrom;

  /// Số ngày dùng thử khi còn mời được; `null` = không mời (đã thử, đã có gói).
  /// Có giá trị thì nút chính bắt đầu dùng thử thay vì mở trang thanh toán.
  final int? trialDays;

  @override
  ConsumerState<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<_BottomBar> {
  bool _starting = false;

  _Palette get palette => widget.palette;
  bool get hasPlan => widget.hasPlan;
  Entitlement get entitlement => widget.entitlement;
  int get priceFrom => widget.priceFrom;

  Future<void> _startTrial() async {
    if (_starting) return;
    setState(() => _starting = true);
    final messenger = ScaffoldMessenger.of(context);
    String message;
    try {
      await ref.read(trialActionsProvider).start();
      message = tr(
        'trial.started',
        namedArgs: {'n': '${widget.trialDays ?? 3}'},
      );
    } on ApiException catch (e) {
      // Server là nơi quyết định có được thử hay không; ở đây chỉ nói lại lý
      // do bằng lời người dùng hiểu, và chỉ đúng việc cần làm tiếp.
      if (e.code == 'TRIAL_NOT_ELIGIBLE') {
        message = e.details['needsVerification'] == true
            ? tr('trial.needs_verification')
            : tr('trial.not_eligible');
      } else if (e.statusCode == 429 || e.isNetwork) {
        message = e.message;
      } else {
        message = tr('trial.start_failed');
      }
      // Trạng thái trên máy có thể đã cũ (vd. đã thử ở máy khác) — tải lại để
      // nút không tiếp tục mời một thứ không còn.
      ref.invalidate(trialStatusProvider);
      ref.invalidate(entitlementProvider);
    } catch (_) {
      message = tr('trial.start_failed');
    }
    if (!mounted) return;
    setState(() => _starting = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final trialDays = widget.trialDays;

    final Widget? leading;
    if (hasPlan) {
      final until = entitlement.activeUntil;
      leading = _BarInfo(
        palette: palette,
        top: tr('premium.hub_current_plan'),
        value: entitlement.plan,
        bottom: until == null ? null : _formatDate(until),
      );
    } else if (priceFrom > 0) {
      leading = _BarInfo(
        palette: palette,
        top: tr('premium.hub_price_from'),
        value: formatMoney(priceFrom, locale: locale),
        bottom: tr('premium.hub_per_month'),
      );
    } else {
      leading = null;
    }

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(
          top: BorderSide(
            color: palette.line,
            width: GenZTokens.borderWidthThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              if (leading != null) ...[leading, const SizedBox(width: 16)],
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _starting
                        ? null
                        : trialDays != null
                        ? _startTrial
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => hasPlan
                                  ? const SubscriptionSettingsScreen()
                                  : const SubscriptionCheckoutScreen(),
                            ),
                          ),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accent,
                      foregroundColor: palette.onAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusButton,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            hasPlan
                                ? tr('premium.hub_manage')
                                : trialDays != null
                                ? tr(
                                    'trial.cta',
                                    namedArgs: {'n': '$trialDays'},
                                  )
                                : tr('premium.join_elite'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: palette.onAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                          size: 18,
                          color: palette.onAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Khối chữ bên trái thanh đáy: nhãn nhỏ, giá trị lớn, chú thích nhỏ.
class _BarInfo extends StatelessWidget {
  const _BarInfo({
    required this.palette,
    required this.top,
    required this.value,
    required this.bottom,
  });

  final _Palette palette;
  final String top;
  final String value;
  final String? bottom;

  @override
  Widget build(BuildContext context) {
    final b = bottom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          top,
          style: AppFonts.body(fontSize: 12, color: palette.inkSoft),
        ),
        Text(
          value,
          style: AppFonts.mono(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
        if (b != null)
          Text(b, style: AppFonts.body(fontSize: 12, color: palette.inkSoft)),
      ],
    );
  }
}
