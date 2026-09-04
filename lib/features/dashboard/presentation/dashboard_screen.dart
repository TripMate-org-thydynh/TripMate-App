import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../trip_planner/presentation/itinerary_tab.dart';
import '../../trip_planner/presentation/create_trip_screen.dart';
import '../../profile/profile_screen.dart';
import '../../profile/data/profile_provider.dart';
import 'pages/home_dashboard_page.dart';
import 'pages/live_trip_page.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/providers/offline_provider.dart';
import '../../../../core/widgets/offline_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final GlobalKey _repaintKey = GlobalKey();
  Offset _rippleCenter = Offset.zero;
  ui.Image? _capturedImage;
  late final AnimationController _rippleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _toggleThemeWithReveal(Offset position) async {
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final img = await boundary.toImage(
          pixelRatio: MediaQuery.of(context).devicePixelRatio,
        );
        setState(() {
          _capturedImage = img;
          _rippleCenter = position;
        });
      }
    } catch (e) {
      debugPrint("Theme screenshot capture failed: $e");
    }

    ref.read(themeProvider.notifier).toggleTheme();

    _rippleController.forward(from: 0.0).then((_) {
      setState(() {
        _capturedImage = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Giữ stream connectivity sống suốt vòng đời app.
    ref.watch(connectivityWatcherProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final bg = theme.scaffoldBackgroundColor;
    final accent = theme.colorScheme.primary;

    // Body pages representing Home flow, Itinerary map, Create trip, Live crew tracking, and Profile
    final List<Widget> pages = [
      HomeDashboardPage(
        onNavigateToLiveMode: () {
          setState(() {
            _selectedIndex = 3; // Navigate to LiveTripPage (Crew/Group tab)
          });
        },
        onNavigateToActivityHub: () {
          setState(() {
            _selectedIndex = 2; // Navigate to CreateTripScreen (Create tab)
          });
        },
        isDarkMode: isDark,
        onThemeToggle: () => _toggleThemeWithReveal(Offset.zero),
      ),
      // Tab lịch trình dùng dữ liệu THẬT (xem itinerary_tab.dart). Trước đây
      // đây là `ItineraryScreen` — một màn demo 1805 dòng không gọi API nào.
      ItineraryTab(isDarkMode: isDark),
      CreateTripScreen(
        isDarkMode: isDark,
        onThemeToggle: () => _toggleThemeWithReveal(Offset.zero),
        hideNavigationBar: true,
        onTripCreated: () => setState(() => _selectedIndex = 0),
      ),
      LiveTripPage(
        isDarkMode: isDark,
        onThemeToggle: () => _toggleThemeWithReveal(Offset.zero),
      ),
      ProfileScreen(
        isDarkMode: isDark,
        onThemeToggleWithPosition: _toggleThemeWithReveal,
      ),
    ];

    final navItems = <({IconData icon, IconData active, String label})>[
      (
        icon: PhosphorIcons.house(),
        active: PhosphorIcons.house(PhosphorIconsStyle.fill),
        label: 'nav.explore'.tr(),
      ),
      (
        icon: PhosphorIcons.mapTrifold(),
        active: PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
        label: 'nav.itinerary'.tr(),
      ),
      (
        icon: PhosphorIcons.plusCircle(),
        active: PhosphorIcons.plusCircle(PhosphorIconsStyle.fill),
        label: 'nav.create'.tr(),
      ),
      (
        icon: PhosphorIcons.usersThree(),
        active: PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
        label: 'nav.live'.tr(),
      ),
      (
        icon: PhosphorIcons.user(),
        active: PhosphorIcons.user(PhosphorIconsStyle.fill),
        label: 'nav.profile'.tr(),
      ),
    ];

    final Widget mainContent = Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Nền cream phẳng + doodle sparkle xoay/nhấp nhẹ liên tục
          Positioned.fill(child: AnimatedDoodleBackground(ink: ink)),
          SafeArea(
            child: Column(
              children: [
                // Banner offline dùng chung cho mọi tab — không phải mỗi màn
                // tự nhớ hiển thị.
                const OfflineBanner(),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: pages),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom nav: nút giữa nhô lên khỏi thanh, thanh lõm ôm quanh nó.
      //
      // Nút "Tạo chuyến" là hành động chính của app nhưng trước đây nằm lẫn
      // giữa bốn tab điều hướng, cùng cỡ cùng kiểu — không có gì cho biết nó
      // quan trọng hơn. Tách nó lên thành nút nổi khiến ngón cái tìm thấy ngay,
      // và vết lõm giữ cho thanh vẫn liền một khối chứ không phải một nút dán
      // đè lên.
      //
      // Style brutalist giữ nguyên: viền ink dày, bóng cứng, item đang chọn là
      // viên accent bo tròn.
      bottomNavigationBar: _NotchedNavBar(
        items: navItems,
        selectedIndex: _selectedIndex,
        centerIndex: 2,
        bg: bg,
        ink: ink,
        accent: accent,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = index);
          if (index == 4) {
            ref.read(profileDataProvider.notifier).loadProfile();
          }
        },
      ),
    );

    return Stack(
      children: [
        RepaintBoundary(key: _repaintKey, child: mainContent),
        if (_capturedImage != null)
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              final screenSize = MediaQuery.of(context).size;
              final center = _rippleCenter == Offset.zero
                  ? Offset(screenSize.width / 2, screenSize.height / 2)
                  : _rippleCenter;
              final maxRadius =
                  math.sqrt(
                    screenSize.width * screenSize.width +
                        screenSize.height * screenSize.height,
                  ) *
                  1.2;
              final currentRadius = _rippleController.value * maxRadius;

              return ClipPath(
                clipper: InvertedCircleClipper(
                  center: center,
                  radius: currentRadius,
                ),
                child: RawImage(
                  image: _capturedImage,
                  fit: BoxFit.cover,
                  width: screenSize.width,
                  height: screenSize.height,
                ),
              );
            },
          ),
      ],
    );
  }
}

class InvertedCircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  InvertedCircleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant InvertedCircleClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}

/// Nền doodle brutalist: sparkle ✦ và dấu + rải rác, opacity thấp.
/// Thay cho aurora mesh gradient cũ — Design DNA là khối màu phẳng.
/// Nền doodle sparkle xoay/nhấp nhẹ liên tục — chuyển động sinh động nhưng
/// tinh tế (opacity thấp). Tự chứa ticker + RepaintBoundary để không kéo
/// theo repaint toàn màn hình.
class AnimatedDoodleBackground extends StatefulWidget {
  final Color ink;
  const AnimatedDoodleBackground({super.key, required this.ink});

  @override
  State<AnimatedDoodleBackground> createState() =>
      _AnimatedDoodleBackgroundState();
}

class _AnimatedDoodleBackgroundState extends State<AnimatedDoodleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: DoodleBackgroundPainter(ink: widget.ink, progress: _c.value),
        ),
      ),
    );
  }
}

class DoodleBackgroundPainter extends CustomPainter {
  final Color ink;
  final double progress;

  DoodleBackgroundPainter({required this.ink, this.progress = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rng = math.Random(7); // seed cố định để nền ổn định giữa các frame
    for (var i = 0; i < 14; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final baseR = 5 + rng.nextDouble() * 7;
      // Mỗi sparkle xoay + nhấp nhẹ theo pha riêng.
      final phase = i * 0.7;
      final spin = progress * math.pi * 2 * (i.isEven ? 1 : -1) + phase;
      final r =
          baseR * (0.85 + 0.15 * math.sin(progress * math.pi * 2 + phase));

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(spin);
      if (i.isEven) {
        // Sparkle 4 cánh ✦
        canvas.drawLine(Offset(-r, 0), Offset(r, 0), paint);
        canvas.drawLine(Offset(0, -r), Offset(0, r), paint);
      } else {
        // Dấu + xoay 45°
        final d = r * 0.7;
        canvas.drawLine(Offset(-d, -d), Offset(d, d), paint);
        canvas.drawLine(Offset(-d, d), Offset(d, -d), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant DoodleBackgroundPainter oldDelegate) =>
      oldDelegate.ink != ink || oldDelegate.progress != progress;
}

/// Thanh điều hướng có vết lõm ôm nút giữa.
///
/// `BottomNavigationBar` dựng sẵn không làm được kiểu này: nó không cho một
/// mục vượt ra ngoài chiều cao thanh. Nên thanh được vẽ bằng `CustomPainter`
/// (để cắt đúng đường cong lõm) và các mục xếp chồng lên trên bằng `Stack`.
class _NotchedNavBar extends StatelessWidget {
  final List<({IconData icon, IconData active, String label})> items;
  final int selectedIndex;
  final int centerIndex;
  final Color bg;
  final Color ink;
  final Color accent;
  final ValueChanged<int> onTap;

  const _NotchedNavBar({
    required this.items,
    required this.selectedIndex,
    required this.centerIndex,
    required this.bg,
    required this.ink,
    required this.accent,
    required this.onTap,
  });

  /// Bán kính nút nổi và khoảng hở quanh nó.
  static const double _fabRadius = 30;
  /// Khoảng hở giữa mép nút và mép vết lõm.
  ///
  /// Phải đủ rộng để nhìn thấy nền ở giữa hai đường viền. Để hẹp thì viền lõm
  /// và viền nút dính vào nhau thành một khối đen dày, trông như lỗi vẽ.
  static const double _fabGap = 11;

  /// Phần nút nhô lên khỏi mặt thanh.
  ///
  /// Bằng đúng bán kính nút, nên **tâm nút nằm ngay trên mặt thanh**: nửa trên
  /// nổi hẳn lên, nửa dưới chìm vào vết lõm. Lấy số khác thì cung lõm và đường
  /// tròn của nút không còn đồng tâm, và hở ra hai "tai" ở hai bên.
  static const double _lift = _fabRadius;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 64.0;

    return SizedBox(
      height: barHeight + _lift + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Mặt thanh + đường viền trên, đã khoét lõm.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight + bottomInset,
            child: CustomPaint(
              painter: _NotchPainter(
                bg: bg,
                ink: ink,
                notchRadius: _fabRadius + _fabGap,
              ),
            ),
          ),
          // Các mục điều hướng; chỗ của nút giữa để trống.
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            height: barHeight,
            child: Row(
              children: List.generate(items.length, (index) {
                if (index == centerIndex) return const Spacer();
                return Expanded(child: _item(index));
              }),
            ),
          ),
          // Nút nổi ở giữa + nhãn của nó.
          //
          // Bốn mục kia đều có nhãn; bỏ nhãn ở đây thì hàng chữ bị khuyết một
          // ô giữa, nhìn như lỗi bố cục.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _centerButton(),
                // Canh cho thẳng hàng với nhãn của bốn mục kia — chúng nằm
                // thấp hơn vì được căn giữa trong chiều cao thanh.
                const SizedBox(height: 10),
                Text(
                  items[centerIndex].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFonts.heading(
                    fontSize: 10,
                    fontWeight: selectedIndex == centerIndex
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selectedIndex == centerIndex
                        ? ink
                        : ink.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int index) {
    final item = items[index];
    final selected = index == selectedIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
              border: selected
                  ? Border.all(color: ink, width: GenZTokens.borderWidthThin)
                  : null,
            ),
            child: Icon(
              selected ? item.active : item.icon,
              size: 22,
              color: selected ? GenZTokens.ink : ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.heading(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? ink : ink.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerButton() {
    final selected = selectedIndex == centerIndex;
    final item = items[centerIndex];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(centerIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: _fabRadius * 2,
        height: _fabRadius * 2,
        decoration: BoxDecoration(
          color: selected ? accent : bg,
          shape: BoxShape.circle,
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
          // Không đổ bóng ở đây: vết lõm đã tạo chiều sâu, thêm bóng nữa là ba
          // lớp đen chồng nhau (viền lõm + viền nút + bóng).
        ),
        child: Icon(
          selected ? item.active : item.icon,
          size: 28,
          color: selected ? GenZTokens.ink : accent,
        ),
      ),
    );
  }
}

/// Vẽ mặt thanh với một vết lõm hình cung ở chính giữa.
class _NotchPainter extends CustomPainter {
  final Color bg;
  final Color ink;
  final double notchRadius;

  const _NotchPainter({
    required this.bg,
    required this.ink,
    required this.notchRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final r = notchRadius;

    // Vết lõm là **một cung tròn tâm ngay trên mặt thanh**, cùng tâm với nút.
    //
    // Bản trước ghép hai đoạn cubic với một cung rồi mới hạ xuống, nên đường
    // cong không trùng đường tròn của nút và hở ra hai "tai" ở hai bên.
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(cx - r, 0)
      ..arcToPoint(
        Offset(cx + r, 0),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = bg);
    canvas.drawPath(
      path,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = GenZTokens.borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _NotchPainter old) =>
      old.bg != bg || old.ink != ink || old.notchRadius != notchRadius;
}
