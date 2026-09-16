import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/trial_provider.dart';
import '../pages/subscription_settings_screen.dart';

/// Dải thông báo "còn N ngày dùng thử".
///
/// Nguyên tắc: **luôn hiện, và luôn nói đúng ngày giờ kết thúc**. Giấu đồng hồ
/// đi để người dùng quên mất mình đang trong thời gian dùng thử là cách moi
/// tiền, không phải cách thiết kế.
///
/// Chạm vào là mở thẳng màn quản lý gói, nơi có nút dừng — không bắt người
/// dùng đi tìm.
class TrialBanner extends ConsumerStatefulWidget {
  const TrialBanner({super.key});

  @override
  ConsumerState<TrialBanner> createState() => _TrialBannerState();
}

class _TrialBannerState extends ConsumerState<TrialBanner> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Đếm lại mỗi phút. Mỗi giây thì vẽ lại 60 lần cho một con số chỉ đổi mỗi
    // giờ — tốn pin mà không ai nhận ra khác biệt.
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(trialStatusProvider).valueOrNull;
    if (status == null || !status.active) return const SizedBox.shrink();

    final left = status.remaining;
    if (left == Duration.zero) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final warning = isDark ? GenZTokens.warningDark : GenZTokens.warning;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final accentSoft = isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'vi';

    // Dưới 24 giờ thì đổi sang đếm giờ: "còn 0 ngày" vừa vô nghĩa vừa làm
    // người dùng tưởng đã hết.
    final label = left.inHours >= 24
        ? 'trial.days_left'.tr(namedArgs: {'n': '${left.inDays + 1}'})
        : left.inHours >= 1
        ? 'trial.hours_left'.tr(namedArgs: {'n': '${left.inHours}'})
        : 'trial.minutes_left'.tr(namedArgs: {'n': '${left.inMinutes}'});

    // Sắp hết thì đổi màu, nhưng không dùng màu báo lỗi: đây không phải sự cố.
    final urgent = left.inHours < 24;
    final bannerBg = urgent
        ? warning.withValues(alpha: isDark ? 0.18 : 0.12)
        : accentSoft;
    final borderColor = urgent
        ? warning.withValues(alpha: isDark ? 0.4 : 0.3)
        : line;
    final iconColor = urgent ? warning : accent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GenZTokens.space4,
        vertical: GenZTokens.space2,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const SubscriptionSettingsScreen(),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(GenZTokens.space4),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(
              color: borderColor,
              width: GenZTokens.borderWidthThin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                urgent ? PhosphorIcons.hourglassLow() : PhosphorIcons.hourglassHigh(),
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: GenZTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                    // Ngày giờ kết thúc cụ thể, theo giờ máy người dùng. Nói
                    // "còn 2 ngày" thôi thì họ vẫn không biết chính xác lúc
                    // nào mất quyền.
                    Text(
                      'trial.ends_on'.tr(
                        namedArgs: {
                          'when': DateFormat.yMMMd(
                            locale,
                          ).add_Hm().format(status.endsAt!.toLocal()),
                        },
                      ),
                      style: AppFonts.body(
                        fontSize: 12,
                        color: inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(),
                size: 20,
                color: inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
