import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../profile/profile_screen.dart';
import '../../trips/presentation/my_trips_screen.dart';
import '../../ai/pages/matey_ai_emotional_chaos_screen.dart';
import '../../trips/application/trips_providers.dart';
import 'pages/home_dashboard_page.dart';
import 'widgets/campaign_prompt.dart';
import '../../itinerary_templates/presentation/template_explore_screen.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/providers/offline_provider.dart';
import '../../../../core/providers/capabilities_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/offline_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  static bool _reportedOpen = false;
  final _visited = <int>{0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _reportedOpen) return;
      _reportedOpen = true;
      try {
        await ref
            .read(apiClientProvider)
            .postData('/beta-events/app-opened', {});
      } catch (_) {
        // A missed signal must never delay or interrupt the Home screen.
      }
    });
  }

  final GlobalKey _repaintKey = GlobalKey();
  Offset _rippleCenter = Offset.zero;
  ui.Image? _capturedImage;
  late final AnimationController _rippleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void dispose() {
    _capturedImage?.dispose();
    _capturedImage = null;
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
          pixelRatio: MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0),
        );
        _capturedImage?.dispose();
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
      if (!mounted) return;
      _capturedImage?.dispose();
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
    final bg = theme.scaffoldBackgroundColor;
    final matey = ref.watch(capabilityProvider('matey'));
    final tabs = [0, 1, if (!matey.hidden) 2, 3];
    final currentTab = tabs.contains(_selectedIndex) ? _selectedIndex : 0;

    final pages = [
      HomeDashboardPage(
        isDarkMode: isDark,
        onThemeToggle: () => _toggleThemeWithReveal(Offset.zero),
      ),
      MyTripsScreen(isDarkMode: isDark),
      MateyAiEmotionalChaosScreen(
        isDarkMode: isDark,
        embedded: true,
        onThemeToggle: () => _toggleThemeWithReveal(Offset.zero),
      ),
      ProfileScreen(
        isDarkMode: isDark,
        onThemeToggleWithPosition: _toggleThemeWithReveal,
      ),
    ];

    final mainContent = Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index: currentTab,
                children: [
                  for (var index = 0; index < pages.length; index++)
                    if (_visited.contains(index))
                      TickerMode(
                        enabled: index == currentTab,
                        child: pages[index],
                      )
                    else
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabs.indexOf(currentTab),
        onDestinationSelected: (position) {
          final index = tabs[position];
          HapticFeedback.selectionClick();
          setState(() {
            _visited.add(index);
            _selectedIndex = index;
          });
          if (index == 1 && ref.read(tripsProvider).hasError) {
            ref.invalidate(tripsProvider);
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house()),
            label: 'beta.home'.tr(),
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.mapTrifold()),
            label: 'beta.trips'.tr(),
          ),
          if (!matey.hidden)
            NavigationDestination(
              icon: Icon(PhosphorIcons.sparkle()),
              label: 'Matey',
            ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.user()),
            label: 'nav.profile'.tr(),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        CampaignPrompt(
          isHome: currentTab == 0,
          onOpen: (cta) {
            if (cta == 'trips') {
              setState(() {
                _visited.add(1);
                _selectedIndex = 1;
              });
            } else if (cta == 'templates') {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TemplateExploreScreen(isDarkMode: isDark),
                ),
              );
            }
          },
          child: RepaintBoundary(key: _repaintKey, child: mainContent),
        ),
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
