import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/app_gate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../system_states/pages/status_screen.dart';
import '../../../core/widgets/gen_z_widgets.dart';
import '../../../core/widgets/trip_illustration.dart';

/// Splash = phần nối tiếp của launch screen gốc (iOS LaunchScreen.storyboard
/// cùng nền kem `GenZTokens.cream`), nên lúc Flutter vẽ khung đầu không bị
/// nháy màu.
///
/// Câu chuyện 1 giây: một nét đường đi tự vẽ từ điểm xuất phát tới ghim đích
/// (= "đi trip"), ghim màu nhấn hiện ra, rồi wordmark `trip.mate` và 3 vế
/// khẩu hiệu lần lượt hiện. Chạy MỘT lần (không lặp trang trí), easeOutCubic,
/// không nảy — đúng spec chuyển động.
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
  static const _total = Duration(milliseconds: 1000);

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _total,
  )..forward();

  Animation<double> _seg(double from, double to) => CurvedAnimation(
        parent: _c,
        curve: Interval(from, to, curve: Curves.easeOutCubic),
      );

  // Logo hiện trước, khẩu hiệu sau, minh hoạ con đường trượt lên cuối.
  late final _logo = _seg(0.0, 0.35);
  late final _art = _seg(0.25, 0.75);
  late final _slogan = _seg(0.35, 0.7);

  @override
  void initState() {
    super.initState();
    unawaited(_leaveWhenReady());
  }

  /// Chờ animation chạy hết (1.3s) rồi đi ngay khi phiên đã đọc xong —
  /// người đã đăng nhập vào thẳng app, không ghé màn đăng nhập.
  AppGateResult? _gate;

  Future<void> _leaveWhenReady() async {
    final reduce = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (reduce) _c.value = 1;
    // Kiểm tra bảo trì / phiên bản chạy song song với animation (timeout 4s,
    // lỗi thì cho qua) nên không làm splash dài thêm.
    final gateFuture = checkAppGate();
    await Future<void>.delayed(
      reduce ? const Duration(milliseconds: 400) : _total + const Duration(milliseconds: 250),
    );
    final gate = await gateFuture;
    if (!mounted) return;
    if (gate.status == GateStatus.maintenance ||
        gate.status == GateStatus.forceUpdate) {
      setState(() => _gate = gate); // chặn tại đây, không vào app
      return;
    }
    while (mounted && ref.read(authProvider).isLoading) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (!mounted) return;
    if (gate.status == GateStatus.softUpdate) {
      await showSoftUpdateDialog(
        context,
        storeUrl: gate.storeUrl,
        latestVersion: gate.latestVersion,
      );
      if (!mounted) return;
    }
    final signedIn = ref.read(authProvider).isAuthenticated;
    context.go(signedIn ? '/dashboard' : '/auth');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final gate = _gate;
    if (gate?.status == GateStatus.maintenance) {
      return MaintenanceScreen(
        message: gate!.message,
        onRetry: () {
          setState(() => _gate = null);
          unawaited(_leaveWhenReady());
        },
      );
    }
    if (gate?.status == GateStatus.forceUpdate) {
      return ForceUpdateScreen(
        storeUrl: gate!.storeUrl,
        currentVersion: gate.currentVersion,
      );
    }
    final isDark = widget.isDarkMode;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    final slogan = [
      'splash.slogan_plan'.tr(),
      'splash.slogan_split'.tr(),
      'splash.slogan_moment'.tr(),
    ].join('  ·  ');

    Widget fade(Animation<double> a, Widget child) => AnimatedBuilder(
          animation: a,
          builder: (_, c) => Opacity(
            opacity: a.value,
            child: Transform.translate(
              offset: Offset(0, (1 - a.value) * 8),
              child: c,
            ),
          ),
          child: child,
        );

    return Scaffold(
      backgroundColor: bg,
      body: Semantics(
        label: 'TripMate — $slogan',
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              fade(
                _logo,
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'trip'),
                    TextSpan(text: '.', style: TextStyle(color: accent)),
                    const TextSpan(text: 'mate'),
                  ]),
                  style: AppFonts.heading(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: ink,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              fade(
                _slogan,
                Text(
                  slogan,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(fontSize: 15, color: inkSoft),
                ),
              ),
              const Spacer(flex: 2),
              ExcludeSemantics(
                child: AnimatedBuilder(
                  animation: _art,
                  builder: (_, c) => Opacity(
                    opacity: _art.value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - _art.value) * 40),
                      child: c,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: TripIllustrationView(
                      TripIllustration.road,
                      height: 260,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
