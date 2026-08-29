import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _ink => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _sub =>
      widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _surface =>
      widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

  Future<void> _submit() async {
    final username = _username.text.trim();
    final password = _password.text;

    if (username.length < 3) {
      showGlobalSnack('Username tối thiểu 3 ký tự', isError: true);
      return;
    }
    if (password.length < 6) {
      showGlobalSnack('auth.password_min'.tr(), isError: true);
      return;
    }
    if (_isRegister && password != _confirm.text) {
      showGlobalSnack('Mật khẩu xác nhận không khớp', isError: true);
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
                _isRegister ? 'tạo tài khoản.' : 'đăng nhập.',
                style: AppFonts.heading(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isRegister
                    ? 'Chỉ cần username và mật khẩu là xong.'
                    : 'Nhập username và mật khẩu của bạn.',
                style: AppFonts.body(color: _sub, fontSize: 14),
              ),
              const SizedBox(height: 32),

              _field(_username, 'Username', Icons.alternate_email),
              const SizedBox(height: 14),
              _field(
                _password,
                'auth.password'.tr(),
                Icons.lock_outline,
                obscure: _obscure,
                trailing: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
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
                  'Xác nhận mật khẩu',
                  Icons.lock_outline,
                  obscure: _obscure,
                ),
              ],
              const SizedBox(height: 28),

              // Nút submit brutalist
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                  border: Border.all(
                    color: _ink,
                    width: GenZTokens.borderWidth,
                  ),
                  boxShadow: GenZTokens.hardShadow(_ink),
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GenZTokens.yellow,
                    foregroundColor: GenZTokens.ink,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: GenZTokens.ink,
                          ),
                        )
                      : Text(
                          _isRegister ? 'Đăng ký & vào app' : 'Đăng nhập',
                          style: AppFonts.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GenZTokens.ink,
                          ),
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
                          ? 'Đã có tài khoản? '
                          : 'Chưa có tài khoản? ',
                      style: AppFonts.body(color: _sub, fontSize: 14),
                      children: [
                        TextSpan(
                          text: _isRegister ? 'Đăng nhập' : 'Đăng ký',
                          style: AppFonts.heading(
                            color: _ink,
                            fontWeight: FontWeight.w800,
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
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
        border: Border.all(color: _ink, width: GenZTokens.borderWidthThin),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: AppFonts.body(
          color: _ink,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: _ink.withValues(alpha: 0.5), size: 20),
          hintText: hint,
          hintStyle: AppFonts.body(
            color: _ink.withValues(alpha: 0.4),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          border: InputBorder.none,
          suffixIcon: trailing,
        ),
      ),
    );
  }
}
