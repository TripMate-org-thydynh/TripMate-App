import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Quyền riêng tư & Tài khoản (PDPD - NĐ 13/2023).
/// Gồm: tóm tắt chính sách, link điều khoản, và xoá tài khoản gọi BE thật.
class AccountPrivacyScreen extends ConsumerStatefulWidget {
  /// CHÚ Ý QUAN TRỌNG: Hai trang web này PHẢI tồn tại thật trước khi nộp Google Play,
  /// nếu không tester của Google Play bấm vào sẽ ra trang lỗi (404/không tải được)
  /// và ứng dụng sẽ bị từ chối phê duyệt (đánh trượt).
  static const String privacyUrl = 'https://tripmate.app/privacy';
  static const String termsUrl = 'https://tripmate.app/terms';

  final bool? isDarkMode;
  const AccountPrivacyScreen({super.key, this.isDarkMode});

  @override
  ConsumerState<AccountPrivacyScreen> createState() =>
      _AccountPrivacyScreenState();
}

class _AccountPrivacyScreenState extends ConsumerState<AccountPrivacyScreen> {
  bool _deleting = false;

  bool get _isDark =>
      widget.isDarkMode ?? (Theme.of(context).brightness == Brightness.dark);
  Color get _bg => _isDark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => _isDark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _ink => _isDark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _line => _isDark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _accent => _isDark ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _danger => _isDark ? GenZTokens.dangerDark : GenZTokens.danger;
  Color get _textPri => _ink;
  Color get _textSec => _isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  Future<void> _confirmDelete() async {
    HapticFeedback.heavyImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          side: BorderSide(color: _line, width: GenZTokens.borderWidthThin),
        ),
        title: Text(
          'settings.delete_confirm'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w700, color: _textPri),
        ),
        content: Text(
          'settings.delete_warn_1'.tr() + 'settings.delete_warn_2'.tr(),
          style: AppFonts.body(color: _textSec, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(color: _textSec),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: GenZTokens.paper,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('settings.delete_forever'.tr()),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _deleting = true);
    try {
      await ref.read(apiClientProvider).deleteData('/users/me');
      await ref.read(authProvider.notifier).logout();
      // Router redirect tự đưa về /auth khi token bị xoá.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: _danger),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('errors.generic'.tr()),
          backgroundColor: _danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _textPri),
        title: Text(
          'settings.privacy_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textPri,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GenZTokens.space4),
        children: [
          _card(
            icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
            title: 'privacy.protected_title'.tr(),
            body:
                'privacy.body_1'.tr() +
                'privacy.body_2'.tr() +
                'privacy.body_3'.tr(),
          ),
          _linkTile(
            PhosphorIcons.fileText(),
            'privacy.policy'.tr(),
            AccountPrivacyScreen.privacyUrl,
          ),
          _linkTile(
            PhosphorIcons.gavel(),
            'privacy.terms'.tr(),
            AccountPrivacyScreen.termsUrl,
          ),
          _linkTile(
            PhosphorIcons.downloadSimple(),
            'privacy.request_copy'.tr(),
            AccountPrivacyScreen.privacyUrl,
          ),
          const SizedBox(height: GenZTokens.space5),

          // Danger zone
          Text(
            'settings.danger_zone'.tr(),
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _danger,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: GenZTokens.space2),
          Container(
            padding: const EdgeInsets.all(GenZTokens.space4),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: _danger.withValues(alpha: 0.35),
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings.delete_account_cta'.tr(),
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _danger,
                  ),
                ),
                const SizedBox(height: GenZTokens.space1),
                Text(
                  'settings.delete_sub'.tr(),
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textSec,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: GenZTokens.space4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _danger,
                      foregroundColor: GenZTokens.paper,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusButton,
                        ),
                      ),
                    ),
                    onPressed: _deleting ? null : _confirmDelete,
                    icon: _deleting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: GenZTokens.paper,
                            ),
                          )
                        : Icon(PhosphorIcons.trash(PhosphorIconsStyle.fill)),
                    label: Text(
                      _deleting
                          ? 'common.deleting'.tr()
                          : 'settings.delete_account_cta'.tr(),
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

  Widget _card({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: GenZTokens.space4),
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _accent, size: 24),
          const SizedBox(width: GenZTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPri,
                  ),
                ),
                const SizedBox(height: GenZTokens.space1),
                Text(
                  body,
                  style: AppFonts.body(
                    fontSize: 13,
                    color: _textSec,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    HapticFeedback.selectionClick();
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.generic'.tr()),
            backgroundColor: _danger,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.generic'.tr()),
            backgroundColor: _danger,
          ),
        );
      }
    }
  }

  Widget _linkTile(IconData icon, String label, String url) {
    return Tooltip(
      message: 'privacy.opens_website'.tr(namedArgs: {'label': label}),
      child: InkWell(
        borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        onTap: () => _openUrl(url),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: GenZTokens.space4,
            vertical: 14,
          ),
          margin: const EdgeInsets.only(bottom: GenZTokens.space2),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
            border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
          ),
          child: Row(
            children: [
              Icon(icon, color: _textSec, size: 20),
              const SizedBox(width: GenZTokens.space3),
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPri,
                  ),
                ),
              ),
              Icon(PhosphorIcons.caretRight(), size: 14, color: _textSec),
            ],
          ),
        ),
      ),
    );
  }
}
