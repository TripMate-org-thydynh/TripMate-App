import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/api_service.dart';
import '../../../core/app_messenger.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Màn giới thiệu bạn bè.
///
/// Trước đây link mời in cứng _inviteLink — một
/// username không có thật — và nút sao chép chỉ hiện thông báo chứ không hề
/// ghi vào clipboard. Nay link dùng username THẬT của người dùng và bấm là
/// copy thật.
class ReferralCampaignScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const ReferralCampaignScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  ConsumerState<ReferralCampaignScreen> createState() =>
      _ReferralCampaignScreenState();
}

class _ReferralCampaignScreenState
    extends ConsumerState<ReferralCampaignScreen> {
  /// Link mời mang MÃ GIỚI THIỆU thật do server sinh.
  String get _inviteLink => _code == null
      ? 'https://tripmate.app/invite'
      : 'https://tripmate.app/invite/$_code';

  String? _code;

  /// Số bạn đã mời được, đọc từ server.
  int _spotsFilled = 0;

  int _rewardPerInvite = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.get('/premium/referrals/me');
    if (!mounted || res is! Map) return;
    setState(() {
      _code = res['code'] as String?;
      _spotsFilled = (res['count'] as num?)?.toInt() ?? 0;
      _rewardPerInvite = (res['rewardPerInvite'] as num?)?.toInt() ?? 0;
    });
  }

  void _shareLink() {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
      ),
      backgroundColor: surfaceColor,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(GenZTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: line,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                ),
              ),
            ),
            const SizedBox(height: GenZTokens.space4),
            Text(
              'premium.share_referral'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space2),
            Text(
              'referral.share_intro'.tr(),
              style: AppFonts.body(fontSize: 13, color: inkSoft, height: 1.4),
            ),
            const SizedBox(height: GenZTokens.space4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: GenZTokens.space4,
                vertical: GenZTokens.space3,
              ),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.link(), color: inkSoft, size: 20),
                  const SizedBox(width: GenZTokens.space3),
                  Expanded(
                    child: Text(
                      _inviteLink,
                      style: AppFonts.mono(fontSize: 13, color: ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: GenZTokens.space2),
                  IconButton(
                    icon: Icon(PhosphorIcons.copy(), color: accent, size: 20),
                    tooltip: 'premium.copy_code'.tr(),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _inviteLink));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'premium.link_copied'.tr(),
                            style: AppFonts.body(
                              fontSize: 13,
                              color: isDark
                                  ? GenZTokens.inkDark
                                  : GenZTokens.cream,
                            ),
                          ),
                          backgroundColor: isDark
                              ? GenZTokens.paperDark
                              : GenZTokens.ink,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusInput,
                            ),
                            side: BorderSide(
                              color: line,
                              width: GenZTokens.borderWidthThin,
                            ),
                          ),
                        ),
                      );
                      unawaited(_load());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GenZTokens.space4),
          ],
        ),
      ),
    );
  }

  void _showInstruction() {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
        ),
        backgroundColor: surfaceColor,
        title: Text(
          'premium.how_it_works'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
        content: Text(
          'referral.steps'.tr(),
          style: AppFonts.body(fontSize: 13, height: 1.5, color: inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.got_it'.tr(),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final accentSoft = isDark
        ? GenZTokens.accentSoftDark
        : GenZTokens.accentSoft;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GenZTokens.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: GenZTokens.space3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            PhosphorIcons.arrowLeft(),
                            color: textPrimary,
                          ),
                          tooltip: 'common.close'.tr(),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: GenZTokens.space1),
                        Text(
                          'TripMate',
                          style: AppFonts.heading(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isDark ? PhosphorIcons.sun() : PhosphorIcons.moon(),
                            color: textPrimary,
                          ),
                          tooltip: isDark
                              ? 'theme.switch_light'.tr()
                              : 'theme.switch_dark'.tr(),
                          onPressed: widget.onThemeToggle,
                        ),
                        const SizedBox(width: GenZTokens.space2),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: line,
                              width: GenZTokens.borderWidthThin,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              PhosphorIcons.bell(),
                              color: textPrimary,
                            ),
                            tooltip: 'notifications.title'.tr(),
                            onPressed: () =>
                                showGlobalSnack('common.feature_wip2'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GenZTokens.space4),

              // Campaign Exclusive tag banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GenZTokens.space3,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.crown(PhosphorIconsStyle.fill),
                      color: accent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'premium.exclusive'.tr(),
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GenZTokens.space3),

              // Slogans
              Text(
                'premium.referral_slogan'.tr(),
                style: AppFonts.heading(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: GenZTokens.space2),
              Text(
                'premium.refer_desc'.tr(),
                style: AppFonts.body(fontSize: 15, color: textSecondary),
              ),

              const SizedBox(height: GenZTokens.space5),

              // Progress Squad check circles
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GenZTokens.space5),
                decoration: BoxDecoration(
                  color: surfaceColor,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'premium.your_squad'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '$_spotsFilled',
                          style: AppFonts.mono(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'referral.reward_note'.tr(
                        namedArgs: {'xp': '$_rewardPerInvite'},
                      ),
                      style: AppFonts.body(fontSize: 12, color: textSecondary),
                    ),
                    const SizedBox(height: GenZTokens.space5),

                    // Interactive Check Row Circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProgressSpot(
                          1,
                          accent: accent,
                          accentSoft: accentSoft,
                          line: line,
                          fill: fill,
                          textSecondary: textSecondary,
                        ),
                        _buildProgressSpot(
                          2,
                          accent: accent,
                          accentSoft: accentSoft,
                          line: line,
                          fill: fill,
                          textSecondary: textSecondary,
                        ),
                        _buildProgressSpot(
                          3,
                          accent: accent,
                          accentSoft: accentSoft,
                          line: line,
                          fill: fill,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // CTA share invite button - Điểm nhấn chính duy nhất của màn
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _shareLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: onAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.export(), color: onAccent, size: 18),
                      const SizedBox(width: GenZTokens.space2),
                      Text(
                        'premium.share_invite'.tr(),
                        style: AppFonts.heading(
                          color: onAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: GenZTokens.space3),

              // How it works text link
              Center(
                child: TextButton(
                  onPressed: _showInstruction,
                  child: Text(
                    'premium.how_it_works'.tr(),
                    style: AppFonts.body(
                      color: textSecondary,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GenZTokens.space5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSpot(
    int spotNum, {
    required Color accent,
    required Color accentSoft,
    required Color line,
    required Color fill,
    required Color textSecondary,
  }) {
    final isFilled = _spotsFilled >= spotNum;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? accentSoft : fill,
        border: Border.all(
          color: isFilled ? accent : line,
          width: isFilled ? GenZTokens.borderWidth : GenZTokens.borderWidthThin,
        ),
      ),
      child: Center(
        child: isFilled
            ? Icon(
                PhosphorIcons.star(PhosphorIconsStyle.fill),
                color: accent,
                size: 22,
              )
            : Text(
                '$spotNum',
                style: AppFonts.mono(
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}
