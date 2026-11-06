import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/gen_z_widgets.dart';

/// Splash = phần nối tiếp của launch screen gốc (iOS LaunchScreen.storyboard
/// cùng nền kem `GenZTokens.cream`), nên lúc Flutter vẽ khung đầu không bị
/// nháy màu. Chỉ có logo + wordmark, hiện dần một lần rồi rời đi ngay khi
/// đọc xong phiên đăng nhập.
///
/// Bản trước (thẻ viền + bóng đặc, 3 pill tag, nút đổi sáng/tối) đã bỏ: bóng
/// đặc trái spec hiện tại, còn nút đổi theme trên màn chỉ sống 1 giây thì
/// không ai kịp bấm.
class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const SplashScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _intro,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _rise = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void initState() {
    super.initState();
    unawaited(_leaveWhenReady());
  }

  /// Giữ tối thiểu 700ms cho logo kịp hiện, sau đó đi ngay khi phiên đã đọc
  /// xong — người đã đăng nhập vào thẳng app, không ghé màn đăng nhập.
  Future<void> _leaveWhenReady() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    while (mounted && ref.read(authProvider).isLoading) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (!mounted) return;
    final signedIn = ref.read(authProvider).isAuthenticated;
    context.go(signedIn ? '/dashboard' : '/auth');
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _rise,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      isDark
                          ? 'assets/images/symbol_dark.png'
                          : 'assets/images/symbol_light.png',
                      width: 88,
                      height: 76,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(height: GenZTokens.space4),
                    Text(
                      'trip.mate',
                      semanticsLabel: 'TripMate',
                      style: AppFonts.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Khẩu hiệu một dòng, chữ phụ — đủ để nhận ra app, không tranh logo.
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 28,
            child: FadeTransition(
              opacity: _fade,
              child: Text(
                'Plan chill · Chia tiền ez · Lưu moment',
                textAlign: TextAlign.center,
                style: AppFonts.mono(fontSize: 12, color: inkSoft),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
