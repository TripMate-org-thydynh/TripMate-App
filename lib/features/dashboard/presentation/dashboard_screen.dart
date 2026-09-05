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
      // Cho thân màn chạy XUỐNG DƯỚI thanh điều hướng.
      //
      // Không có nó thì vết lõm tuy đã khoét thủng mặt thanh nhưng phía sau vẫn
      // là nền Scaffold, nên nhìn ra một mảng nền thừa ôm quanh nút thay vì
      // thấy nội dung xuyên qua. Nền doodle phía sau cũng nhờ đó phủ liền mạch
      // tới đáy màn.
      extendBody: true,
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

/// Thanh điều hướng có vết lõm **bám theo tab đang chọn**.
///
/// `BottomNavigationBar` dựng sẵn không làm được kiểu này: nó không cho một
/// mục vượt ra ngoài chiều cao thanh. Nên mặt thanh được vẽ bằng
/// `CustomPainter` (để cắt đúng đường cong) và các mục xếp chồng bằng `Stack`.
///
/// Bản trước cố định nút nổi ở giữa, nên đổi tab thì vết lõm đứng yên còn ô
/// được chọn nằm chỗ khác — hai thứ rời nhau, không cho biết đang ở đâu. Nay
/// icon của tab đang chọn **nhấc lên thành nút nổi** và vết lõm trượt theo,
/// nên vị trí trên thanh chính là câu trả lời cho "mình đang ở tab nào".
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
  ///
  /// Khoảng hở phải đủ rộng để nhìn thấy nền giữa hai đường viền; để hẹp thì
  /// viền lõm và viền nút dính vào nhau thành một khối đen dày.
  static const double _fabRadius = 28;

  /// Khoảng nút bay lên khỏi mặt thanh.
  ///
  /// Trước đây tâm nút nằm đúng trên mặt thanh, nên nửa dưới nút chìm vào hốc
  /// và nhìn như bị dính vào thanh. Nâng tâm lên khỏi mặt thanh khiến nút tách
  /// hẳn ra — hốc chỉ còn là vệt lõm nông đỡ phía dưới.
  static const double _fabFloat = 23;

  /// Khoảng hở giữa mép nút và mép vết lõm.
  ///
  /// Nhỏ vừa đủ để hốc trông mềm mà không lộ ra vành nền quanh nút.
  static const double _fabGap = 4;

  /// Tổng phần nút chiếm phía trên mặt thanh.
  static const double _lift = _fabRadius + _fabFloat;

  static const double _barHeight = 62;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Chiều cao chỉ tính mặt thanh — KHÔNG cộng phần nút nhô lên.
    //
    // Trước đây cộng cả `_lift`, nên Scaffold dành thêm một dải trống bằng nửa
    // nút phía trên vạch ngăn: nội dung bị đẩy lên mà chỗ đó chẳng có gì. Nay
    // nút tràn ra ngoài khung thanh (`Clip.none`) và chỉ đè lên nội dung,
    // đúng như một nút nổi.
    return SizedBox(
      height: _barHeight + bottomInset,
      child: LayoutBuilder(
        builder: (context, c) {
          final slot = c.maxWidth / items.length;
          // Kẹp biên ngay tại đây để nút và vết lõm dùng CHUNG một toạ độ.
          // Nếu chỉ painter tự kẹp thì ở tab đầu/cuối vết lõm dừng lại còn nút
          // vẫn trượt tiếp và lòi ra ngoài mép màn hình.
          // Chừa đủ chỗ cho CẢ hốc, không chỉ cho nút.
          //
          // Để hẹp thì ở tab đầu/cuối nửa hốc nằm ngoài màn: nút trông như bị
          // cắt cụt và đường viền bên ngoài biến mất. Cộng thêm bán kính hốc
          // thay vì một số nhỏ tuỳ ý.
          const edge = _fabRadius + _fabGap + 18;
          final targetX = (slot * (selectedIndex + 0.5))
              .clamp(edge, c.maxWidth - edge);

          // Một Tween duy nhất cho cả vết lõm lẫn nút: hai thứ phải trượt
          // cùng nhịp, lệch một khung hình là thấy ngay nút rời khỏi hốc.
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: targetX, end: targetX),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, notchX, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NotchPainter(
                        bg: bg,
                        ink: ink,
                        notchRadius: _fabRadius + _fabGap,
                        notchCenterX: notchX,
                        notchLift: _fabFloat,
                      ),
                    ),
                  ),
                  // Nhãn của mọi mục nằm dưới, luôn hiện.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomInset,
                    height: _barHeight,
                    child: Row(
                      children: List.generate(
                        items.length,
                        (i) => Expanded(child: _item(i)),
                      ),
                    ),
                  ),
                  // Nút nổi: icon của tab đang chọn, trượt theo.
                  //
                  // `top` âm để tâm nút nằm đúng trên mặt thanh mà không cần
                  // khung thanh phải cao thêm.
                  Positioned(
                    left: notchX - _fabRadius,
                    top: -_lift,
                    child: _floatingButton(),
                  ),
                ],
              );
            },
          );
        },
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
          // Ô đang chọn không vẽ icon ở đây — icon của nó đã được nhấc lên
          // thành nút nổi. Vẫn chừa đúng chỗ để hàng nhãn không xô lệch.
          SizedBox(
            height: 26,
            child: selected
                ? null
                : Icon(
                    item.icon,
                    size: 22,
                    color: ink.withValues(alpha: 0.55),
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

  Widget _floatingButton() {
    final item = items[selectedIndex];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(selectedIndex),
      child: Container(
        width: _fabRadius * 2,
        height: _fabRadius * 2,
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
          // Bóng cứng kiểu brutalist. Trước đây nút chìm vào hốc nên bóng chỉ
          // chồng thêm một lớp đen; nay nút đã tách hẳn ra, bóng mới có việc:
          // nói cho mắt biết nó đang bay phía trên thanh.
          boxShadow: [
            BoxShadow(color: ink, offset: const Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Icon(item.active, size: 26, color: GenZTokens.ink),
      ),
    );
  }
}

/// Vẽ mặt thanh với một vết lõm hình cung, tâm tại [notchCenterX].
class _NotchPainter extends CustomPainter {
  final Color bg;
  final Color ink;
  final double notchRadius;
  final double notchCenterX;

  /// Tâm nút nằm cao hơn mặt thanh bao nhiêu.
  ///
  /// Truyền vào để hốc được khoét đúng phần nút thực sự chìm xuống: nút bay
  /// càng cao thì hốc càng nông.
  final double notchLift;

  const _NotchPainter({
    required this.bg,
    required this.ink,
    required this.notchRadius,
    required this.notchCenterX,
    required this.notchLift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dùng `CircularNotchedRectangle` của Flutter thay vì tự ghép cung.
    //
    // Bản tự vẽ nối cung vào đường kẻ bằng một góc gãy, nên hai đầu hốc nhô lên
    // thành hai cái "sừng" phía trên vạch ngăn cách navbar với màn hình. Lớp
    // này dựng sẵn hai đoạn cong chuyển tiếp ở hai bên, cho đúng dáng hốc liền
    // mạch — cũng chính là thứ Material dùng cho `BottomAppBar`.
    final host = Rect.fromLTWH(0, 0, size.width, size.height);
    final guest = Rect.fromCircle(
      center: Offset(notchCenterX, -notchLift),
      radius: notchRadius,
    );
    final path = const CircularNotchedRectangle().getOuterPath(host, guest);

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
      old.bg != bg ||
      old.ink != ink ||
      old.notchRadius != notchRadius ||
      old.notchCenterX != notchCenterX ||
      old.notchLift != notchLift;
}
