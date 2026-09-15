import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/api_service.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Man gioi thieu ban be.
///
/// Truoc day ma gioi thieu in cung la 'MATEYCHILL' cho MOI tai khoan, va
/// nut sao chep chi hien thong bao chu khong ghi gi vao clipboard.
class ReferralRewardsScreen extends ConsumerStatefulWidget {
  const ReferralRewardsScreen({super.key});

  @override
  ConsumerState<ReferralRewardsScreen> createState() =>
      _ReferralRewardsScreenState();
}

class _ReferralRewardsScreenState extends ConsumerState<ReferralRewardsScreen> {
  /// Mã giới thiệu THẬT, do server sinh và giữ.
  ///
  /// Trước đây mã được suy ra bằng cách viết hoa username. Cách đó có ba lỗi:
  /// mã đổi theo username nên ai đổi tên là mọi mã đã chia sẻ thành vô hiệu;
  /// username lộ ra ngoài; và **server không hề biết mã đó tồn tại**, nên
  /// người nhập vào chỉ nhận một thông báo thành công trống rỗng.
  String? _code;

  /// Người mình đã mời được. Trước đây là danh sách rỗng cứng, và trước nữa là
  /// hai cái tên bịa ("Hoàng Yến 🌸", "Phú Khang 🍕").
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
        _referrals = (mine['invited'] as List?)
                ?.whereType<Map>()
                .map((e) => e.cast<String, dynamic>())
                .toList() ??
            [];
      }
      if (status is Map) {
        _canSubmit = status['canSubmit'] as bool? ?? true;
        _referredBy =
            (status['referredBy'] as Map?)?['name'] as String?;
      }
    });
  }

  Future<void> _submitReferralCode() async {
    final text = _codeController.text.trim().toUpperCase();
    if (text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    // Call live NestJS referrals endpoint!
    final response = await ApiService.post('/premium/referrals', {
      'code': text,
    });

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    // ApiService đã unwrap envelope → thành công khi response khác null.
    if (response != null) {
      final String msg =
          (response is Map ? response['message'] : null) as String? ??
          'referral.code_valid'.tr();
      _codeController.clear();
      // Tải lại: XP vừa đổi, và ô nhập phải biến mất vì mỗi người chỉ được
      // giới thiệu một lần.
      unawaited(_load());

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
      final accent = isDark ? GenZTokens.lilac : GenZTokens.purple;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor:
              isDark ? GenZTokens.paperDark : GenZTokens.paper,
          title: Text(
            'common.success'.tr(),
            style: AppFonts.heading(
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          content: Text(
            msg,
            style: AppFonts.heading(fontSize: 13.5, color: ink),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'common.awesome'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('premium.self_referral'.tr()),
          behavior: SnackBarBehavior.floating,
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
    final backgroundColor =
        isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surfaceColor =
        isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final primaryColor = isDark ? GenZTokens.lilac : GenZTokens.purple;
    final borderCol = ink.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(),
            color: ink,
          ),
          tooltip: 'common.close'.tr(),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'premium.refer_friends'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referral card using brand coloring gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: GenZTokens.yellow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ink,
                  width: GenZTokens.borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ink.withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'premium.your_code'.tr(),
                    style: AppFonts.heading(
                      color: GenZTokens.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _code ?? '…',
                    style: AppFonts.heading(
                      color: GenZTokens.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'referral.code_intro'.tr(),
                    textAlign: TextAlign.center,
                    style: AppFonts.heading(
                      color: GenZTokens.ink,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final code = _code;
                      if (code == null) return;
                      await Clipboard.setData(ClipboardData(text: code));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'premium.code_copied'.tr(args: [_code ?? '']),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: surfaceColor,
                      foregroundColor: ink,
                      side: BorderSide(
                        color: ink,
                        width: GenZTokens.borderWidthThin,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'premium.copy_code'.tr(),
                      style: AppFonts.heading(
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Đã nhập mã của ai rồi thì không hiện ô nhập nữa.
            //
            // Mỗi người chỉ được giới thiệu một lần trong đời, nên để ô nhập
            // ở đó chỉ dẫn tới một lần gõ và một thông báo lỗi.
            if (!_canSubmit) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                      color: GenZTokens.success,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'referral.already_referred'.tr(
                          namedArgs: {'name': _referredBy ?? ''},
                        ),
                        style: AppFonts.heading(
                          fontSize: 13,
                          color: ink,
                        ),
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
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      style: AppFonts.heading(
                        color: ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'referral.friend_code_hint'.tr(),
                        hintStyle: AppFonts.heading(
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
                            color: primaryColor,
                          ),
                        )
                      : TextButton(
                          onPressed: _submitReferralCode,
                          child: Text(
                            'premium.submit_code'.tr(),
                            style: AppFonts.heading(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            ],

            const SizedBox(height: 28),

            Text(
              'referral.list_title'.tr(
                namedArgs: {'n': '${_referrals.length}'},
              ),
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (_referrals.isEmpty)
              // Chưa mời được ai thì để trống, không bịa 2 người như trước.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'premium.no_referrals'.tr(),
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    fontSize: 13,
                    color: inkSoft,
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      color: surfaceColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: borderCol),
                      ),
                      child: ListTile(
                        leading: Icon(
                          PhosphorIcons.userPlus(),
                          color: primaryColor,
                        ),
                        title: Text(
                          (ref['name'] as String?) ?? '—',
                          style: AppFonts.heading(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: ink,
                          ),
                        ),
                        subtitle: Text(
                          _joinedLabel(ref['joinedAt'] as String?),
                          style: AppFonts.heading(
                            fontSize: 11.5,
                            color: inkSoft,
                          ),
                        ),
                        trailing: Text(
                          '+${ref['xp'] ?? 0} XP',
                          style: AppFonts.heading(
                            fontWeight: FontWeight.bold,
                            color: GenZTokens.success,
                            fontSize: 13,
                          ),
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
