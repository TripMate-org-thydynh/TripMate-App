import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/api_service.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Màn giới thiệu bạn bè và phần thưởng.
///
/// Trước đây mã giới thiệu in cứng là 'MATEYCHILL' cho MỌI tài khoản, và
/// nút sao chép chỉ hiện thông báo chứ không ghi gì vào clipboard.
class ReferralRewardsScreen extends ConsumerStatefulWidget {
  const ReferralRewardsScreen({super.key});

  @override
  ConsumerState<ReferralRewardsScreen> createState() =>
      _ReferralRewardsScreenState();
}

class _ReferralRewardsScreenState extends ConsumerState<ReferralRewardsScreen> {
  /// Mã giới thiệu THẬT, do server sinh và giữ.
  String? _code;

  /// Người mình đã mời được.
  List<Map<String, dynamic>> _referrals = [];

  /// Mình đã nhập mã của ai chưa — dùng để ẩn ô nhập thay vì để người dùng gõ
  /// vào rồi nhận lỗi.
  bool _canSubmit = true;
  String? _referredBy;

  bool _loading = true;

  final _codeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ApiService.get('/premium/referrals/me'),
      ApiService.get('/premium/referrals/status'),
    ]);
    if (!mounted) return;
    final mine = results[0];
    final status = results[1];
    setState(() {
      _loading = false;
      if (mine is Map) {
        _code = mine['code'] as String?;
        _referrals =
            (mine['invited'] as List?)
                ?.whereType<Map>()
                .map((e) => e.cast<String, dynamic>())
                .toList() ??
            [];
      }
      if (status is Map) {
        _canSubmit = status['canSubmit'] as bool? ?? true;
        _referredBy = (status['referredBy'] as Map?)?['name'] as String?;
      }
    });
  }

  Future<void> _submitReferralCode() async {
    final text = _codeController.text.trim().toUpperCase();
    if (text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final response = await ApiService.post('/premium/referrals', {
      'code': text,
    });

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (response != null) {
      final String msg =
          (response is Map ? response['message'] : null) as String? ??
          'referral.code_valid'.tr();
      _codeController.clear();
      unawaited(_load());

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
      final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
      final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
          ),
          backgroundColor: isDark ? GenZTokens.paperDark : GenZTokens.paper,
          title: Text(
            'common.success'.tr(),
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
          content: Text(msg, style: AppFonts.body(fontSize: 13, color: ink)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'common.awesome'.tr(),
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
    } else {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'premium.self_referral'.tr(),
            style: AppFonts.body(
              fontSize: 13,
              color: isDark ? GenZTokens.inkDark : GenZTokens.cream,
            ),
          ),
          backgroundColor: isDark ? GenZTokens.paperDark : GenZTokens.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
            side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// "Tham gia 6 thg 9, 2026" — ngày thật, theo giờ máy người dùng.
  String _joinedLabel(String? iso) {
    final t = DateTime.tryParse(iso ?? '')?.toLocal();
    if (t == null) return '';
    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'vi';
    return 'referral.joined_on'.tr(
      namedArgs: {'when': DateFormat.yMMMd(locale).format(t)},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final backgroundColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final accentSoft = isDark
        ? GenZTokens.accentSoftDark
        : GenZTokens.accentSoft;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
          tooltip: 'common.close'.tr(),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'premium.refer_friends'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(GenZTokens.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referral card displaying code
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GenZTokens.space5),
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'premium.your_code'.tr(),
                    style: AppFonts.heading(
                      color: inkSoft,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: GenZTokens.space3),
                  SelectableText(
                    _code ?? '…',
                    style: AppFonts.mono(
                      color: ink,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: GenZTokens.space3),
                  Text(
                    'referral.code_intro'.tr(),
                    textAlign: TextAlign.center,
                    style: AppFonts.body(
                      color: inkSoft,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: GenZTokens.space4),
                  // Điểm nhấn chính duy nhất của màn
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () async {
                        final code = _code;
                        if (code == null) return;
                        await Clipboard.setData(ClipboardData(text: code));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'premium.code_copied'.tr(args: [_code ?? '']),
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
                      },
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIcons.copy(), size: 16, color: onAccent),
                          const SizedBox(width: 8),
                          Text(
                            'premium.copy_code'.tr(),
                            style: AppFonts.heading(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: onAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: GenZTokens.space5),

            // Đã nhập mã của ai rồi thì không hiện ô nhập nữa.
            if (!_canSubmit) ...[
              Container(
                padding: const EdgeInsets.all(GenZTokens.space4),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                      color: success,
                      size: 20,
                    ),
                    const SizedBox(width: GenZTokens.space3),
                    Expanded(
                      child: Text(
                        'referral.already_referred'.tr(
                          namedArgs: {'name': _referredBy ?? ''},
                        ),
                        style: AppFonts.body(fontSize: 13, color: ink),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Submit friend's code block
              Text(
                'premium.enter_code'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: ink,
                ),
              ),
              const SizedBox(height: GenZTokens.space3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GenZTokens.space4,
                  vertical: 4,
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
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        style: AppFonts.body(
                          color: ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'referral.friend_code_hint'.tr(),
                          hintStyle: AppFonts.body(
                            color: inkSoft,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accent,
                            ),
                          )
                        : TextButton(
                            onPressed: _submitReferralCode,
                            child: Text(
                              'premium.submit_code'.tr(),
                              style: AppFonts.heading(
                                color: accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: GenZTokens.space5),

            Text(
              'referral.list_title'.tr(
                namedArgs: {'n': '${_referrals.length}'},
              ),
              style: AppFonts.heading(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: ink,
              ),
            ),
            const SizedBox(height: GenZTokens.space3),

            if (_loading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: GenZTokens.space5,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                ),
              )
            else if (_referrals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: GenZTokens.space4,
                ),
                child: Center(
                  child: Text(
                    'premium.no_referrals'.tr(),
                    textAlign: TextAlign.center,
                    style: AppFonts.body(fontSize: 13, color: inkSoft),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _referrals.length,
                itemBuilder: (context, index) {
                  final ref = _referrals[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: GenZTokens.space3),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusCard,
                      ),
                      border: Border.all(
                        color: line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: GenZTokens.space4,
                        vertical: GenZTokens.space2,
                      ),
                      leading: Icon(
                        PhosphorIcons.userPlus(),
                        color: inkSoft,
                        size: 20,
                      ),
                      title: Text(
                        (ref['name'] as String?) ?? '—',
                        style: AppFonts.heading(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: ink,
                        ),
                      ),
                      subtitle: Text(
                        _joinedLabel(ref['joinedAt'] as String?),
                        style: AppFonts.body(fontSize: 12, color: inkSoft),
                      ),
                      trailing: Text(
                        '+${ref['xp'] ?? 0} XP',
                        style: AppFonts.mono(
                          fontWeight: FontWeight.w700,
                          color: success,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
