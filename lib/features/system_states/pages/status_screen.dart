import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Khung chung cho các màn trạng thái hệ thống (404, bảo trì, cần cập nhật):
/// biểu tượng trong ô nền chìm, tiêu đề, mô tả, một nút màu nhấn và tuỳ chọn
/// một nút chữ. Sáng/tối theo token, không bóng, một điểm nhấn.
class StatusScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? footnote;

  const StatusScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = dark ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final fill = dark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = dark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = dark ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                ),
                child: Icon(icon, size: 30, color: ink),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppFonts.heading(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: ink,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(body, style: AppFonts.body(fontSize: 15, color: sub)),
              const Spacer(flex: 3),
              if (primaryLabel != null)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onPrimary,
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
                    child: Text(
                      primaryLabel!,
                      style: AppFonts.heading(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: onAccent,
                      ),
                    ),
                  ),
                ),
              if (secondaryLabel != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: onSecondary,
                    child: Text(
                      secondaryLabel!,
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                  ),
                ),
              ],
              if (footnote != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    footnote!,
                    style: AppFonts.mono(fontSize: 12, color: sub),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 404 — đường dẫn/deep link không tồn tại.
class NotFoundScreen extends StatelessWidget {
  final VoidCallback onHome;
  const NotFoundScreen({super.key, required this.onHome});

  @override
  Widget build(BuildContext context) => StatusScreen(
    icon: PhosphorIcons.compass(),
    title: 'system.not_found_title'.tr(),
    body: 'system.not_found_body'.tr(),
    primaryLabel: 'system.go_home'.tr(),
    onPrimary: onHome,
    footnote: '404',
  );
}

/// Bảo trì — server bật APP_MAINTENANCE hoặc trả 503.
class MaintenanceScreen extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const MaintenanceScreen({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => StatusScreen(
    icon: PhosphorIcons.wrench(),
    title: 'system.maintenance_title'.tr(),
    body: (message?.isNotEmpty ?? false)
        ? message!
        : 'system.maintenance_body'.tr(),
    primaryLabel: 'common.retry'.tr(),
    onPrimary: onRetry,
  );
}

/// Bắt buộc cập nhật — phiên bản thấp hơn APP_MIN_VERSION. Không có nút bỏ qua.
class ForceUpdateScreen extends StatelessWidget {
  final String? storeUrl;
  final String currentVersion;
  final VoidCallback? onRetry;
  const ForceUpdateScreen({
    super.key,
    this.storeUrl,
    required this.currentVersion,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => StatusScreen(
    icon: PhosphorIcons.arrowCircleUp(),
    title: 'system.update_title'.tr(),
    body: 'system.update_force_body'.tr(),
    primaryLabel: storeUrl == null ? null : 'system.update_cta'.tr(),
    onPrimary: storeUrl == null
        ? null
        : () => launchUrl(
            Uri.parse(storeUrl!),
            mode: LaunchMode.externalApplication,
          ),
    footnote: 'v$currentVersion',
    secondaryLabel: onRetry == null ? null : 'common.retry'.tr(),
    onSecondary: onRetry,
  );
}
