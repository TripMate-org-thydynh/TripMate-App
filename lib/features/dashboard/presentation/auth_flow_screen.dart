import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../settings/presentation/account_privacy_screen.dart';
import '../../../core/network/error_message.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api_service.dart';
import '../../../core/theme/gen_z_tokens.dart';
import 'password_auth_screen.dart';

/// Chuẩn hoá SĐT về dạng quốc tế +84 (UI luôn hiển thị +84).
/// Fix bug cũ: số không có '0'/'+' đứng đầu bị thiếu mã quốc gia 84.
String _formatVnPhone(String raw) {
  final s = raw.trim().replaceAll(' ', '');
  if (s.startsWith('+')) return s;
  final digits = s.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0')) return '+84${digits.substring(1)}';
  if (digits.startsWith('84')) return '+$digits';
  return '+84$digits';
}

class AuthFlowScreen extends ConsumerStatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const AuthFlowScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ConsumerState<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

/// Đăng nhập bằng SMS OTP. Tắt cho tới khi backend có tài khoản Twilio —
/// bật lại bằng `--dart-define=PHONE_LOGIN=true`.
const bool _phoneLoginEnabled = bool.fromEnvironment('PHONE_LOGIN');

class _AuthFlowScreenState extends ConsumerState<AuthFlowScreen> {
  int _currentStep =
      0; // 0: Màn chào + chọn cách đăng nhập, 1: Email/Quên MK, 2: Verification, 3: Profile, 4: Success

  // State variables for inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _instaController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();

  bool _isForgotPasswordMode = false;
  bool _isEmailInput = !_phoneLoginEnabled;
  bool _isSubmitting = false;
  String? _emailError;

  // serverClientId KHÔNG được hỗ trợ trên Web (client ID lấy từ meta tag
  // google-signin-client_id trong web/index.html). Chỉ truyền trên mobile.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: defaultTargetPlatform == TargetPlatform.iOS
        ? '1072006483967-ivo08438p51d47131637v9359hkl9p56.apps.googleusercontent.com'
        : null,
    serverClientId: kIsWeb
        ? null
        : '1072006483967-ivo0843uk7j8a557l18eevr4q2clargm.apps.googleusercontent.com',
    scopes: const ['email', 'profile'],
  );
  String? _tempSupabaseId;
  // Vé đăng ký do server cấp sau khi xác minh OTP / Google; bắt buộc khi gọi
  // /auth/register.
  String? _tempRegistrationToken;
  String? _tempEmail;
  String? _tempAuthToken;
  Map<String, dynamic>? _tempUser;
  int _otpTimer = 30;
  Timer? _timer;

  /// Cách đăng nhập đang chạy ('apple' | 'google'), để khoá các nút khác.
  String? _busyMethod;

  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => _openUrl(AccountPrivacyScreen.termsUrl);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _openUrl(AccountPrivacyScreen.privacyUrl);

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailInputChanged);
  }

  void _onEmailInputChanged() {
    if (!_phoneLoginEnabled) return;
    final text = _emailController.text.trim();
    if (text.isEmpty) return;
    final isEmail = text.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(text);
    if (isEmail != _isEmailInput) {
      setState(() {
        _isEmailInput = isEmail;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailInputChanged);
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _instaController.dispose();
    _tiktokController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpTimer == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _otpTimer--;
        });
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_isSubmitting) return;
    final input = _emailController.text.trim();
    if (input.isEmpty) return;
    final target = _isEmailInput ? input : _formatVnPhone(input);
    setState(() => _isSubmitting = true);
    try {
      final sendRes = await ApiService.post('/auth/send-otp', {
        'phoneNumber': target,
      });
      if (!mounted) return;
      if (sendRes != null && sendRes['success'] == true) {
        _startOtpTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEmailInput
                  ? 'auth.otp_sent_email'.tr(namedArgs: {'email': target})
                  : 'auth.otp_sent_phone'.tr(namedArgs: {'phone': target}),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
      if (_currentStep == 2) {
        _startOtpTimer();
      }
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    if (_currentStep == 0) {
      return Scaffold(
        backgroundColor: bg,
        body: _buildWelcome(accent, onAccent),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: bg,
        elevation: 0,
        leading: _currentStep < 4
            ? IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icon(PhosphorIcons.arrowLeft(), color: ink, size: 22),
                onPressed: _prevStep,
              )
            : null,
      ),
      // Cuộn được khi bàn phím bật lên.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: GenZTokens.durationBase),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: _buildActiveStepWidget(theme, accent, onAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveStepWidget(ThemeData theme, Color accent, Color onAccent) {
    switch (_currentStep) {
      case 0:
        return _buildWelcome(accent, onAccent);
      case 1:
        return _buildAuthentication(theme, accent, onAccent);
      case 2:
        return _buildOtpVerification(theme, accent, onAccent);
      case 3:
        return _buildProfileSetup(theme, accent, onAccent);
      case 4:
        return _buildWelcomeSuccess(theme, accent, onAccent);
      default:
        return const SizedBox();
    }
  }

  // --- STEP 0: MÀN CHÀO = CHỌN CÁCH ĐĂNG NHẬP ---
  //
  // Thay băng chuyền "chọn vibe" cũ (ảnh AI dựng sẵn, bắt chọn 3 vibe trước
  // khi đăng nhập rồi sau đăng nhập lại hỏi vibe lần nữa ở /onboarding).
  // Giờ: một câu nói rõ app làm gì, một bản xem trước dựng từ chính UI của app
  // (thẻ chuyến + số dư chia tiền) thay cho ảnh minh hoạ, rồi các nút đăng nhập.
  Widget _buildWelcome(Color accent, Color onAccent) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return SafeArea(
      key: const ValueKey('welcome_step'),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Image.asset(
                        isDark
                            ? 'assets/images/symbol_dark.png'
                            : 'assets/images/symbol_light.png',
                        width: 30,
                        height: 26,
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'trip.mate',
                        style: AppFonts.heading(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'auth.welcome_title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -0.6,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'auth.welcome_sub'.tr(),
                    style: AppFonts.body(
                      fontSize: 15,
                      height: 1.45,
                      color: inkSoft,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _WelcomePreview(isDark: isDark, accent: accent),
                  const Spacer(),
                  const SizedBox(height: 28),
                  if (isIos) ...[
                    _AuthOptionButton(
                      label: 'auth.continue_apple'.tr(),
                      icon: PhosphorIcons.appleLogo(PhosphorIconsStyle.fill),
                      // Theo HIG: nút Apple nền đen ở chế độ sáng, nền trắng
                      // ở chế độ tối.
                      background: isDark ? GenZTokens.inkDark : GenZTokens.ink,
                      foreground: isDark
                          ? GenZTokens.creamDark
                          : GenZTokens.paper,
                      busy: _busyMethod == 'apple',
                      onTap: _handleAppleSignIn,
                    ),
                    const SizedBox(height: 10),
                  ],
                  _AuthOptionButton(
                    label: 'auth.continue_google'.tr(),
                    icon: PhosphorIcons.googleLogo(PhosphorIconsStyle.bold),
                    background: isDark
                        ? GenZTokens.paperDark
                        : GenZTokens.paper,
                    foreground: ink,
                    border: isDark ? GenZTokens.lineDark : GenZTokens.line,
                    busy: _busyMethod == 'google',
                    onTap: () =>
                        _handleRealGoogleSignIn(context, accent, onAccent),
                  ),
                  const SizedBox(height: 10),
                  _AuthOptionButton(
                    label: 'auth.continue_email'.tr(),
                    icon: PhosphorIcons.envelopeSimple(PhosphorIconsStyle.bold),
                    background: isDark
                        ? GenZTokens.paperDark
                        : GenZTokens.paper,
                    foreground: ink,
                    border: isDark ? GenZTokens.lineDark : GenZTokens.line,
                    onTap: () => setState(() {
                      _isForgotPasswordMode = false;
                      _currentStep = 1;
                    }),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _openPasswordAuth,
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(
                      'auth.password_login_link'.tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ink,
                        decoration: TextDecoration.underline,
                        decorationColor: inkSoft,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegalFooter(accent),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openPasswordAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PasswordAuthScreen(isDarkMode: widget.isDarkMode),
      ),
    );
  }

  /// "Khi tiếp tục bạn đồng ý với điều khoản và chính sách bảo mật" — hai cụm
  /// cuối mở được (trước đây chỉ tô màu, bấm không có gì xảy ra).
  Widget _buildLegalFooter(Color accent) {
    final isDark = widget.isDarkMode;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final link = TextStyle(
      color: ink,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: inkSoft,
    );
    return Text.rich(
      TextSpan(
        text: '${'auth.agree_prefix'.tr()} ',
        style: AppFonts.body(color: inkSoft, fontSize: 12, height: 1.5),
        children: [
          TextSpan(text: 'auth.terms'.tr(), style: link, recognizer: _termsTap),
          TextSpan(text: ' ${'auth.and_sep'.tr()} '),
          TextSpan(
            text: 'auth.privacy'.tr(),
            style: link,
            recognizer: _privacyTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  }

  /// Người dùng đã có tài khoản: lưu phiên luôn, router tự chuyển sang
  /// /onboarding hoặc /dashboard. Trước đây phải qua thêm màn "tên lửa" và bấm
  /// "Vào app thôi!" dù chẳng có gì mới để xem.
  Future<void> _finishSignIn(String token, Map<String, dynamic>? user) async {
    await ref
        .read(authProvider.notifier)
        .setSession(token, user ?? {'email': _emailController.text.trim()});
  }

  Map<String, dynamic>? _unwrapData(dynamic res) {
    if (res is Map && res['data'] is Map) {
      return (res['data'] as Map).cast<String, dynamic>();
    }
    return res is Map ? res.cast<String, dynamic>() : null;
  }

  Future<void> _handleAppleSignIn() async {
    if (_busyMethod != null) return;
    setState(() => _busyMethod = 'apple');
    final messenger = ScaffoldMessenger.of(context);
    try {
      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final identityToken = cred.identityToken;
      if (identityToken == null) {
        throw StateError('Apple không trả về identity token');
      }
      // Apple chỉ gửi tên ở LẦN ĐẦU người dùng cho phép.
      final name = [
        cred.givenName,
        cred.familyName,
      ].whereType<String>().join(' ').trim();
      final res = await ApiService.post('/auth/apple', {
        'identityToken': identityToken,
        'authorizationCode': cred.authorizationCode,
        if (cred.email != null) 'email': cred.email,
        if (name.isNotEmpty) 'name': name,
      });
      if (!mounted) return;
      final data = _unwrapData(res);
      final token = data?['token']?.toString();
      if (token != null) {
        await _finishSignIn(
          token,
          (data!['user'] as Map?)?.cast<String, dynamic>(),
        );
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Người dùng tự huỷ bảng Apple → không báo lỗi.
      if (e.code != AuthorizationErrorCode.canceled && mounted) {
        _showAuthError(messenger, 'auth.apple_failed', e.message);
      }
    } catch (e) {
      if (mounted) {
        _showAuthError(messenger, 'auth.apple_failed', friendlyError(e));
      }
    } finally {
      if (mounted) setState(() => _busyMethod = null);
    }
  }

  void _showAuthError(
    ScaffoldMessengerState messenger,
    String key,
    String err,
  ) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(key.tr(namedArgs: {'err': err})),
        backgroundColor: widget.isDarkMode
            ? GenZTokens.dangerDark
            : GenZTokens.danger,
      ),
    );
  }

  // --- STEP 1: AUTHENTICATION / JOIN THE SQUAD & FORGOT PASSWORD ---
  Widget _buildAuthentication(ThemeData theme, Color accent, Color onAccent) {
    final isDark = widget.isDarkMode;
    final fInk = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final fSub = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    if (_isForgotPasswordMode) {
      return Column(
        key: const ValueKey('forgot_step'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'auth.forgot_title'.tr(),
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: fInk,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'auth.forgot_sub'.tr(),
            style: AppFonts.body(color: fSub, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildGlassField(
            _emailController,
            'auth.email_hint'.tr(),
            PhosphorIcons.envelope(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (_isSubmitting) return;
                if (_emailController.text.isNotEmpty) {
                  setState(() {
                    _isSubmitting = true;
                    _isEmailInput = true;
                  });
                  try {
                    final email = _emailController.text.trim();

                    final sendRes = await ApiService.post('/auth/send-otp', {
                      'phoneNumber': email,
                    });

                    if (!mounted) return;
                    if (sendRes != null && sendRes['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'auth.otp_sent_email'.tr(
                              namedArgs: {'email': email},
                            ),
                          ),
                        ),
                      );
                      setState(() {
                        _otpController.clear();
                        _newPasswordController.clear();
                        _nextStep(); // Goes to verification code + new password screen with _isForgotPasswordMode = true
                      });
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              child: Text(
                'auth.reset_password'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isForgotPasswordMode = false;
                });
              },
              child: Text(
                'auth.back_to_login'.tr(),
                style: AppFonts.heading(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final emailMode = _isEmailInput;
    return Column(
      key: const ValueKey('auth_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'auth.email_title'.tr(),
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: fInk,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'auth.email_sub'.tr(),
          style: AppFonts.body(fontSize: 15, height: 1.45, color: fSub),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _emailController,
          autofocus: true,
          keyboardType: emailMode
              ? TextInputType.emailAddress
              : TextInputType.phone,
          textInputAction: TextInputAction.send,
          autofillHints: [
            emailMode ? AutofillHints.email : AutofillHints.telephoneNumber,
          ],
          autocorrect: false,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          onSubmitted: (_) => _sendLoginCode(),
          style: AppFonts.body(fontSize: 15, color: fInk),
          decoration: InputDecoration(
            hintText: emailMode
                ? 'auth.your_email'.tr()
                : 'auth.phone_number'.tr(),
            hintStyle: AppFonts.body(fontSize: 15, color: fSub),
            errorText: _emailError,
            prefixIcon: Icon(
              emailMode
                  ? PhosphorIcons.envelopeSimple()
                  : PhosphorIcons.deviceMobile(),
              size: 20,
              color: fSub,
            ),
            prefixText: emailMode ? null : '+84  ',
            prefixStyle: AppFonts.body(fontSize: 15, color: fInk),
            filled: true,
            fillColor: fill,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
              borderSide: BorderSide(color: line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
              borderSide: BorderSide(
                color: fInk,
                width: GenZTokens.borderWidthFocus,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
              borderSide: BorderSide(
                color: isDark ? GenZTokens.dangerDark : GenZTokens.danger,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
              borderSide: BorderSide(
                color: isDark ? GenZTokens.dangerDark : GenZTokens.danger,
                width: GenZTokens.borderWidthFocus,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: FilledButton(
            onPressed: _isSubmitting ? null : _sendLoginCode,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
              disabledBackgroundColor: accent.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onAccent,
                    ),
                  )
                : Text(
                    'auth.send_code_btn'.tr(),
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: onAccent,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        if (_phoneLoginEnabled)
          TextButton(
            onPressed: () => setState(() {
              _isEmailInput = !_isEmailInput;
              _emailError = null;
              _emailController.clear();
            }),
            child: Text(
              _isEmailInput ? 'auth.use_phone'.tr() : 'auth.use_email'.tr(),
              style: AppFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fInk,
              ),
            ),
          ),
        TextButton(
          onPressed: () => setState(() {
            _isForgotPasswordMode = true;
            _emailError = null;
          }),
          child: Text(
            'auth.forgot_link'.tr(),
            style: AppFonts.body(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fInk,
              decoration: TextDecoration.underline,
              decorationColor: fSub,
            ),
          ),
        ),
      ],
    );
  }

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Gửi mã OTP đăng nhập tới email (hoặc SĐT khi bật PHONE_LOGIN).
  Future<void> _sendLoginCode() async {
    if (_isSubmitting) return;
    final input = _emailController.text.trim();
    if (_isEmailInput && !_emailPattern.hasMatch(input)) {
      setState(() => _emailError = 'auth.email_invalid'.tr());
      return;
    }
    if (input.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final target = _isEmailInput ? input : _formatVnPhone(input);
      final sendRes = await ApiService.post('/auth/send-otp', {
        'phoneNumber': target,
      });
      if (!mounted) return;
      if (sendRes != null && sendRes['success'] == true) {
        _otpController.clear();
        _nextStep();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- STEP 2: OTP / EMAIL VERIFICATION ---
  Widget _buildOtpVerification(ThemeData theme, Color accent, Color onAccent) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final code = _otpController.text;

    return Column(
      key: const ValueKey('otp_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.verify_title'.tr(),
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'auth.enter_otp_sent_to'.tr(
            namedArgs: {
              'target': _isEmailInput
                  ? _emailController.text.trim()
                  : _formatVnPhone(_emailController.text.trim()),
            },
          ),
          style: AppFonts.body(color: sub, fontSize: 14),
        ),
        const SizedBox(height: 32),
        // Sticker minh hoạ
        Center(
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Icon(
              PhosphorIcons.chatTeardropDots(PhosphorIconsStyle.fill),
              size: 32,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Ô nhập OTP dạng 6 khối (server gửi mã 6 số)
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 304,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    final filled = i < code.length;
                    final active = i == code.length;
                    return Container(
                      width: 44,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusInput,
                        ),
                        border: Border.all(
                          color: (active || filled) ? accent : line,
                          width: (active || filled)
                              ? GenZTokens.borderWidth
                              : GenZTokens.borderWidthThin,
                        ),
                      ),
                      child: Text(
                        filled ? code[i] : '',
                        style: AppFonts.heading(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // TextField trong suốt phủ lên, bắt input + focus khi chạm.
              SizedBox(
                width: 304,
                height: 58,
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  autofocus: true,
                  showCursor: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: GenZTokens.paper.withValues(alpha: 0),
                    height: 0.01,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        if (_isForgotPasswordMode) ...[
          const SizedBox(height: 24),
          _buildGlassField(
            _newPasswordController,
            'auth.new_password_hint'.tr(),
            PhosphorIcons.lockKey(),
            obscure: true,
          ),
        ],
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Text(
                'auth.no_code'.tr(),
                style: AppFonts.body(color: sub, fontSize: 13),
              ),
              const SizedBox(height: 4),
              _otpTimer > 0
                  ? Text(
                      'auth.otp_resend_in'.tr(namedArgs: {'s': '$_otpTimer'}),
                      style: AppFonts.heading(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                  : TextButton(
                      onPressed: _resendOtp,
                      child: Text(
                        'auth.resend_otp'.tr(),
                        style: AppFonts.heading(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (_isSubmitting) return;
              if (_otpController.text.length == 6) {
                if (_isForgotPasswordMode) {
                  final newPassword = _newPasswordController.text.trim();
                  if (newPassword.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('auth.password_min'.tr())),
                    );
                    return;
                  }
                  setState(() => _isSubmitting = true);
                  try {
                    final input = _emailController.text.trim();
                    final target = _isEmailInput
                        ? input
                        : _formatVnPhone(input);
                    final code = _otpController.text.trim();

                    final resetRes = await ApiService.post(
                      '/auth/reset-password',
                      {
                        'identifier': target,
                        'code': code,
                        'newPassword': newPassword,
                      },
                    );
                    if (!mounted) return;
                    if (resetRes != null) {
                      // Đăng nhập bằng mật khẩu dùng USERNAME chứ không phải
                      // email → nhắc lại username để người dùng không bị kẹt.
                      final username = _unwrapData(resetRes)?['username'];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 6),
                          content: Text(
                            username is String && username.isNotEmpty
                                ? 'auth.reset_done_username'.tr(
                                    namedArgs: {'username': username},
                                  )
                                : 'auth.reset_done'.tr(),
                          ),
                        ),
                      );
                      setState(() {
                        _isForgotPasswordMode = false;
                        _otpController.clear();
                        _newPasswordController.clear();
                        _currentStep = 0;
                      });
                      _openPasswordAuth();
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                  return;
                }

                setState(() => _isSubmitting = true);
                try {
                  final input = _emailController.text.trim();
                  final target = _isEmailInput ? input : _formatVnPhone(input);
                  final code = _otpController.text.trim();

                  final verifyRes = await ApiService.post('/auth/verify-otp', {
                    'phoneNumber': target,
                    'code': code,
                  });

                  if (!mounted) return;

                  final data = (verifyRes is Map && verifyRes['data'] is Map)
                      ? (verifyRes['data'] as Map).cast<String, dynamic>()
                      : (verifyRes is Map
                            ? verifyRes.cast<String, dynamic>()
                            : null);
                  if (data != null) {
                    if (data['exists'] == true) {
                      _tempAuthToken = data['token']?.toString();
                      _tempUser = (data['user'] as Map?)
                          ?.cast<String, dynamic>();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'auth.welcome_back'.tr(
                                namedArgs: {
                                  'name': '${_tempUser?['name'] ?? ''}',
                                },
                              ),
                            ),
                          ),
                        );
                        await _finishSignIn(_tempAuthToken!, _tempUser);
                      }
                    } else {
                      _tempSupabaseId = data['supabaseId']?.toString();
                      _tempEmail = data['email']?.toString();
                      _tempRegistrationToken = data['registrationToken']
                          ?.toString();
                      if (mounted) {
                        _nextStep();
                      }
                    }
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isSubmitting = false);
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            child: Text(
              _isForgotPasswordMode
                  ? 'auth.reset_password'.tr()
                  : 'auth.verify_continue'.tr(),
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 3: USERNAME / PROFILE SETUP (EDIT IDENTITY) ---
  Widget _buildProfileSetup(ThemeData theme, Color accent, Color onAccent) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    return SingleChildScrollView(
      key: const ValueKey('profile_step'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'auth.main_character'.tr(),
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'auth.pick_username'.tr(),
            style: AppFonts.body(color: sub, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildGlassField(
            _nameController,
            'auth.display_name_hint'.tr(),
            PhosphorIcons.smiley(),
          ),
          const SizedBox(height: 16),
          _buildGlassField(
            _usernameController,
            'auth.username_hint'.tr(),
            PhosphorIcons.at(),
          ),
          const SizedBox(height: 32),
          Text(
            'auth.social_links'.tr(),
            style: AppFonts.heading(
              color: sub,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassField(
            _instaController,
            'auth.instagram_hint'.tr(),
            PhosphorIcons.camera(),
          ),
          const SizedBox(height: 12),
          _buildGlassField(
            _tiktokController,
            'auth.tiktok_hint'.tr(),
            PhosphorIcons.musicNote(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (_isSubmitting) return;
                if (_nameController.text.isNotEmpty &&
                    _usernameController.text.isNotEmpty) {
                  setState(() => _isSubmitting = true);
                  try {
                    final rawInput = _emailController.text.trim();
                    final String email;
                    final String supabaseId;

                    if (_tempEmail != null) {
                      email = _tempEmail!;
                    } else if (_isEmailInput) {
                      email = rawInput;
                    } else {
                      final formattedPhone = _formatVnPhone(rawInput);
                      email =
                          '${formattedPhone.replaceAll('+', '')}@phone.tripmate.com';
                    }

                    if (_tempSupabaseId != null) {
                      supabaseId = _tempSupabaseId!;
                    } else if (_isEmailInput) {
                      supabaseId =
                          'sb-email-${rawInput.replaceAll('@', '-').replaceAll('.', '-')}';
                    } else {
                      final formattedPhone = _formatVnPhone(rawInput);
                      supabaseId =
                          'sb-${formattedPhone.replaceAll('+', '').replaceAll(' ', '')}';
                    }

                    // Call Register API on the NestJS backend
                    final regRes = await ApiService.post('/auth/register', {
                      'registrationToken': _tempRegistrationToken ?? '',
                      'email': email,
                      'name': _nameController.text.trim(),
                      'username': _usernameController.text.trim(),
                      'supabaseId': supabaseId,
                      'avatarUrl':
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_nameController.text.trim())}&background=FFD84D&color=141210&bold=true&size=256',
                    });

                    if (!mounted) return;

                    final regData = (regRes is Map && regRes['data'] is Map)
                        ? (regRes['data'] as Map).cast<String, dynamic>()
                        : (regRes is Map
                              ? regRes.cast<String, dynamic>()
                              : null);
                    if (regData != null && regData['token'] != null) {
                      _tempAuthToken = regData['token'].toString();
                      _tempUser = (regData['user'] as Map?)
                          ?.cast<String, dynamic>();
                      ApiService.authToken = _tempAuthToken;

                      if (_instaController.text.isNotEmpty ||
                          _tiktokController.text.isNotEmpty) {
                        await ApiService.patch('/users/me/social-links', {
                          'instagram': _instaController.text.isNotEmpty
                              ? 'https://instagram.com/${_instaController.text.trim()}'
                              : null,
                          'tiktok': _tiktokController.text.isNotEmpty
                              ? 'https://tiktok.com/@${_tiktokController.text.trim()}'
                              : null,
                        });
                        if (!mounted) return;
                      }

                      _nextStep();
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              child: Text(
                'auth.save_profile'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 4: WELCOME SUCCESS SCREEN ---
  Widget _buildWelcomeSuccess(ThemeData theme, Color accent, Color onAccent) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    return Column(
      key: const ValueKey('success_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft,
            shape: BoxShape.circle,
            border: Border.all(color: line, width: GenZTokens.borderWidthThin),
          ),
          child: Icon(
            PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            size: 40,
            color: accent,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'auth.done_title'.tr(),
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'auth.done_sub'.tr(),
          style: AppFonts.body(color: sub, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              if (_tempAuthToken == null) {
                setState(() => _currentStep = 1);
                return;
              }
              final user =
                  _tempUser ??
                  {
                    'email': _tempEmail ?? _emailController.text.trim(),
                    'name': _nameController.text.trim().isEmpty
                        ? 'Traveller'
                        : _nameController.text.trim(),
                    'username': _usernameController.text.trim().isEmpty
                        ? 'traveller'
                        : _usernameController.text.trim(),
                  };
              await ref
                  .read(authProvider.notifier)
                  .setSession(_tempAuthToken!, user);
              // Vibe giờ chỉ hỏi một lần ở /onboarding (VibeQuiz) sau bước này.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            child: Text(
              'auth.enter_app'.tr(),
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helpers
  Widget _buildGlassField(
    TextEditingController controller,
    String placeholder,
    IconData icon, {
    bool obscure = false,
  }) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        autofillHints: obscure ? const [AutofillHints.newPassword] : null,
        style: AppFonts.body(
          color: ink,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: inkSoft, size: 20),
          hintText: placeholder,
          hintStyle: AppFonts.body(color: inkSoft, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _handleRealGoogleSignIn(
    BuildContext context,
    Color accent,
    Color onAccent,
  ) async {
    if (_busyMethod != null) return;
    setState(() => _busyMethod = 'google');
    final messenger = ScaffoldMessenger.of(context);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null || !mounted) return;

      final auth = await account.authentication;
      if (!mounted) return;
      final idToken = auth.idToken;

      if (idToken == null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('auth.google_no_token'.tr()),
            backgroundColor: widget.isDarkMode
                ? GenZTokens.dangerDark
                : GenZTokens.danger,
          ),
        );
        return;
      }

      final response = await ApiService.post('/auth/google', {
        'idToken': idToken,
        'email': account.email,
        'name': account.displayName ?? '',
        'avatarUrl': account.photoUrl ?? '',
      });

      if (!mounted) return;

      final data = (response is Map && response['data'] is Map)
          ? (response['data'] as Map).cast<String, dynamic>()
          : (response is Map ? response.cast<String, dynamic>() : null);
      if (data != null) {
        if (data['exists'] == true) {
          _tempAuthToken = data['token']?.toString();
          _tempUser = (data['user'] as Map?)?.cast<String, dynamic>();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'auth.welcome_back'.tr(
                  namedArgs: {'name': account.displayName ?? ''},
                ),
              ),
            ),
          );
          await _finishSignIn(_tempAuthToken!, _tempUser);
        } else {
          _tempSupabaseId = data['supabaseId']?.toString();
          _tempEmail = data['email']?.toString() ?? account.email;
          _tempRegistrationToken = data['registrationToken']?.toString();
          _nameController.text =
              data['name']?.toString() ?? account.displayName ?? '';
          if (mounted) setState(() => _currentStep = 3);
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'auth.google_signin_failed'.tr(
                namedArgs: {'err': friendlyError(e)},
              ),
            ),
            backgroundColor: widget.isDarkMode
                ? GenZTokens.dangerDark
                : GenZTokens.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busyMethod = null);
    }
  }
}

/// Nút chọn cách đăng nhập: cao 50, chữ + icon căn giữa, có trạng thái đang
/// chạy để người dùng không bấm hai lần khi bảng Apple/Google đang mở.
class _AuthOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color? border;
  final bool busy;
  final VoidCallback onTap;

  const _AuthOptionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(GenZTokens.radiusButton);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border == null
              ? BorderSide.none
              : BorderSide(color: border!, width: GenZTokens.borderWidthThin),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: busy ? null : onTap,
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: busy
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foreground,
                        )
                      : Icon(icon, size: 20, color: foreground),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bản xem trước dựng từ chính các thành phần của app: một thẻ chuyến đi và
/// một thẻ số dư chia tiền chồng lên góc. Cho người mới thấy ngay app làm gì,
/// thay vì ảnh minh hoạ chung chung.
class _WelcomePreview extends StatelessWidget {
  final bool isDark;
  final Color accent;

  const _WelcomePreview({required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    final paper = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;
    // Chế độ tối không dùng bóng, tách lớp bằng viền (theo spec).
    final shadow = isDark
        ? const <BoxShadow>[]
        : [
            BoxShadow(
              color: GenZTokens.ink.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ];
    BoxDecoration card() => BoxDecoration(
      color: paper,
      borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
      border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      boxShadow: shadow,
    );
    const chart = [GenZTokens.chart1, GenZTokens.chart2, GenZTokens.chart3];

    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 36, bottom: 44),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'auth.preview_trip'.tr(),
                              style: AppFonts.heading(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'auth.preview_trip_meta'.tr(),
                              style: AppFonts.mono(
                                fontSize: 12,
                                color: inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (var i = 0; i < 3; i++)
                        Align(
                          widthFactor: 0.72,
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.alphaBlend(
                                chart[i].withValues(alpha: 0.28),
                                paper,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: paper, width: 2),
                            ),
                            child: Text(
                              const ['M', 'A', 'K'][i],
                              style: AppFonts.heading(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        '+1',
                        style: AppFonts.mono(fontSize: 12, color: inkSoft),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, thickness: 1, color: line),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '19:30',
                        style: AppFonts.mono(fontSize: 12, color: inkSoft),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'auth.preview_item'.tr(),
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 176,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'auth.preview_balance'.tr(),
                    style: AppFonts.body(fontSize: 12, color: inkSoft),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+240.000đ',
                    style: AppFonts.mono(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'auth.preview_balance_sub'.tr(),
                    style: AppFonts.body(fontSize: 12, color: inkSoft),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
