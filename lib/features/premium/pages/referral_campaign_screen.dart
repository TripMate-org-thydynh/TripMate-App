import '../../../core/theme/theme.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/api_service.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_messenger.dart';

/// Man gioi thieu ban be.
///
/// Truoc day link moi in cung _inviteLink — mot
/// username khong co that — va nut sao chep chi hien thong bao chu khong he
/// ghi vao clipboard. Nay link dung username THAT cua nguoi dung va bam la
/// copy that.
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
  ///
  /// Trước đây link ghép từ username. Ai đổi tên là mọi link đã chia sẻ thành
  /// vô hiệu, username lộ ra ngoài, và **server không biết mã đó tồn tại** nên
  /// người bấm vào không được tính cho ai cả.
  String get _inviteLink => _code == null
      ? 'https://tripmate.app/invite'
      : 'https://tripmate.app/invite/$_code';

  String? _code;

  /// Số bạn đã mời được, đọc từ server.
  ///
  /// Trước đây con số này tăng lên mỗi lần người dùng **bấm sao chép link** —
  /// một thanh tiến độ tự chạy, không liên quan gì tới việc có ai tham gia hay
  /// không.
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      backgroundColor: widget.isDarkMode
          ? TripMateTheme.darkSurface
          : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'premium.share_referral'.tr(),
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'referral.share_intro'.tr(),
              style: AppFonts.body(
                fontSize: 12.5,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: (widget.isDarkMode ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDarkMode ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _inviteLink,
                      style: AppFonts.body(
                        fontSize: 13,
                        color: widget.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _inviteLink));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('premium.link_copied'.tr()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      // KHÔNG tăng bộ đếm ở đây: sao chép link không phải là
                      // có người tham gia. Con số chỉ đổi khi server xác nhận
                      // một lần giới thiệu thành công, nên tải lại thay vì
                      // đoán.
                      unawaited(_load());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _showInstruction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: widget.isDarkMode
            ? TripMateTheme.darkSurface
            : Colors.white,
        title: Text(
          'premium.how_it_works'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'referral.steps'.tr(),
          style: AppFonts.body(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.got_it'.tr(),
              style: AppFonts.heading(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark
        ? TripMateTheme.darkPrimary
        : TripMateTheme.lightPrimary;
    final tertiaryColor = isDark
        ? TripMateTheme.darkTertiary
        : TripMateTheme.lightSecondary;
    final bgColor = isDark
        ? TripMateTheme.darkBackground
        : TripMateTheme.lightBackground;
    final surfaceColor = isDark
        ? TripMateTheme.darkSurface
        : TripMateTheme.lightSurface;
    final textPrimary = isDark
        ? TripMateTheme.darkTextPrimary
        : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark
        ? TripMateTheme.darkTextSecondary
        : TripMateTheme.lightTextSecondary;
    final borderCol = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Ambient neon auroras
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: textPrimary),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'trip.mate',
                              style: AppFonts.body(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                                letterSpacing: -1.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isDark
                                    ? Icons.light_mode_outlined
                                    : Icons.dark_mode_outlined,
                                color: primaryColor,
                              ),
                              onPressed: widget.onThemeToggle,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: borderCol),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.notifications_none,
                                  color: textPrimary,
                                ),
                                onPressed: () => showGlobalSnack(
                                  'common.feature_wip2'.tr(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Campaign Exclusive tag banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tertiaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: tertiaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'premium.exclusive'.tr(),
                          style: AppFonts.heading(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: tertiaryColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Slogans
                  Text(
                    'bring the squad.\nunlock elite vibes.',
                    style: AppFonts.heading(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'premium.refer_desc'.tr(),
                    style: AppFonts.body(fontSize: 14, color: textSecondary),
                  ),

                  const SizedBox(height: 36),

                  // Progress Squad check circles
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderCol),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              '$_spotsFilled',
                              style: AppFonts.body(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          // Nói đúng phần thưởng CÓ THẬT: mỗi lượt mời thành
                          // công được cộng XP. "3 suất Elite trọn đời" là một
                          // lời hứa không có gì đứng sau — không có chỗ nào
                          // trong hệ thống cấp quyền vĩnh viễn cho ai cả.
                          'referral.reward_note'.tr(
                            namedArgs: {'xp': '$_rewardPerInvite'},
                          ),
                          style: AppFonts.body(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Interactive Check Row Circles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProgressSpot(1, primaryColor),
                            _buildProgressSpot(2, primaryColor),
                            _buildProgressSpot(3, primaryColor),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // CTA share invite button
                  GestureDetector(
                    onTap: _shareLink,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
                            blurRadius: 0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.ios_share,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'premium.share_invite'.tr(),
                              style: AppFonts.heading(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // How it works text link
                  Center(
                    child: TextButton(
                      onPressed: _showInstruction,
                      child: Text(
                        'premium.how_it_works'.tr(),
                        style: AppFonts.heading(
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSpot(int spotNum, Color color) {
    final isFilled = _spotsFilled >= spotNum;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? color.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(color: isFilled ? color : Colors.grey, width: 2),
      ),
      child: Center(
        child: isFilled
            ? Icon(Icons.star, color: color, size: 24)
            : Text(
                '$spotNum',
                style: AppFonts.body(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
