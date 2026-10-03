import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_service.dart';
import '../../../core/app_messenger.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Đăng nhập / đăng ký bằng username + mật khẩu.
/// Đăng ký chỉ cần username + mật khẩu + xác nhận mật khẩu.
class PasswordAuthScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  const PasswordAuthScreen({super.key, required this.isDarkMode});

  @override
  ConsumerState<PasswordAuthScreen> createState() => _PasswordAuthScreenState();
}

class _PasswordAuthScreenState extends ConsumerState<PasswordAuthScreen> {
  bool _isRegister = false;
  bool _loading = false;
  bool _obscure = true;

  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Color get _bg => widget.isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _ink => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _sub =>
      widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _fill =>
      widget.isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line =>
      widget.isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _accent =>
      widget.isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent =>
      widget.isDarkMode ? GenZTokens.onAccentDark : GenZTokens.onAccent;

  Future<void> _submit() async {
    final username = _username.text.trim();
    final password = _password.text;

    if (username.length < 3) {
      showGlobalSnack('auth.username_min'.tr(), isError: true);
      return;
    }
    // Tài khoản mới: tối thiểu 8 ký tự (khớp server). Đăng nhập chỉ chặn ô
    // trống để tài khoản cũ có mật khẩu 6–7 ký tự vẫn vào được.
    if (_isRegister ? password.length < 8 : password.isEmpty) {
      showGlobalSnack('auth.password_min'.tr(), isError: true);
      return;
    }
    if (_isRegister && password != _confirm.text) {
      showGlobalSnack('auth.password_mismatch'.tr(), isError: true);
      return;
    }

    setState(() => _loading = true);
    HapticFeedback.mediumImpact();

    final res = _isRegister
        ? await ApiService.post('/auth/register-password', {
            'username': username,
            'password': password,
            'confirmPassword': _confirm.text,
          })
        : await ApiService.post('/auth/login-password', {
            'username': username,
            'password': password,
          });

    if (!mounted) return;
    setState(() => _loading = false);

    // Thành công → res là { user, token }. Lỗi → null (ApiService đã hiện snackbar).
    if (res is Map && res['token'] != null) {
      final user = (res['user'] as Map?)?.cast<String, dynamic>() ?? {};
      await ref
          .read(authProvider.notifier)
          .setSession(res['token'].toString(), user);
      // AuthState có token → root tự chuyển vào dashboard.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isRegister
                    ? 'auth.register_title'.tr()
                    : 'auth.login_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isRegister
                    ? 'auth.register_sub'.tr()
                    : 'auth.login_sub'.tr(),
                style: AppFonts.body(color: _sub, fontSize: 15),
              ),
              const SizedBox(height: 32),

              _field(_username, 'auth.username'.tr(), PhosphorIcons.at()),
              const SizedBox(height: 14),
              _field(
                _password,
                'auth.password'.tr(),
                PhosphorIcons.lock(),
                obscure: _obscure,
                trailing: IconButton(
                  icon: Icon(
                    _obscure ? PhosphorIcons.eyeSlash() : PhosphorIcons.eye(),
                    color: _sub,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (_isRegister) ...[
                const SizedBox(height: 14),
                _field(
                  _confirm,
                  'auth.confirm_password'.tr(),
                  PhosphorIcons.lock(),
                  obscure: _obscure,
                ),
              ],
              const SizedBox(height: 28),

              // Nút submit accent duy nhất
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _onAccent,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
                child: _loading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _onAccent,
                        ),
                      )
                    : Text(
                        _isRegister
                            ? 'auth.register_cta'.tr()
                            : 'auth.sign_in'.tr(),
                        style: AppFonts.heading(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _onAccent,
                        ),
                      ),
              ),
              const SizedBox(height: 18),

              Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() => _isRegister = !_isRegister),
                  child: Text.rich(
                    TextSpan(
                      text: _isRegister
                          ? 'auth.have_account'.tr()
                          : 'auth.no_account_prefix'.tr(),
                      style: AppFonts.body(color: _sub, fontSize: 15),
                      children: [
                        TextSpan(
                          text: _isRegister
                              ? 'auth.sign_in'.tr()
                              : 'auth.sign_up'.tr(),
                          style: AppFonts.heading(
                            color: _accent,
                            fontWeight: FontWeight.w700,
                          ),
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

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: AppFonts.body(
          color: _ink,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: _sub, size: 20),
          hintText: hint,
          hintStyle: AppFonts.body(
            color: _sub,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          border: InputBorder.none,
          suffixIcon: trailing,
        ),
      ),
    );
  }
}
