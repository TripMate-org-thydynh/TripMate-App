import 'dart:math';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../gamification/data/games_repository.dart';
import '../../../trips/application/trips_providers.dart';
import '../../data/home_feed_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveTripPage extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const LiveTripPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  ConsumerState<LiveTripPage> createState() => _LiveTripPageState();
}

class _LiveTripPageState extends ConsumerState<LiveTripPage>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _particlesController;
  final List<Particle> _particles = [];
  final Random _random = Random();

  /// Mức "vibe energy" đọc từ tiến độ XP THẬT của chuyến (xem
  /// [_vibeEnergy]). Biến này chỉ còn giữ phần thưởng tạm khi người dùng
  /// lắc máy, cộng dồn lên trên giá trị thật.
  double _shakeBonus = 0.0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _particlesController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  void _triggerVibeBoost() {
    _shakeController.forward(from: 0.0);
    setState(() {
      _shakeBonus = min(0.15, _shakeBonus + 0.05);
    });

    // Generate falling color particle sparks
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(
        Particle(
          x: 100 + _random.nextDouble() * 80,
          y: 80 + _random.nextDouble() * 50,
          vx: (_random.nextDouble() - 0.5) * 10,
          vy: (_random.nextDouble() - 0.5) * 8 - 4,
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
          size: _random.nextDouble() * 6 + 3,
        ),
      );
    }
    _particlesController.forward(from: 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('live.vibe_boost_toast'.tr()),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B);
    final secondaryColor = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFFFFD84D);

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);
    final textSecondary = isDark
        ? const Color(0xFFB8AE9C)
        : const Color(0xFF4A453E);
    final glassBorder = textPrimary; // viền ink brutalist

    if (_particlesController.isAnimating) {
      for (var p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.2; // Gravity effect
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Live Mode header block
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tripName(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.heading(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'live_trip.member_count'.tr(
                                namedArgs: {'count': '${_memberCount()}'},
                              ),
                              style: AppFonts.body(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? secondaryColor : const Color(0xFF1B8A4C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Đã gỡ nút "LIVE MAP": màn đích vẽ vị trí cứng của các
                      // thành viên bịa, mà app không thu thập vị trí thật (đã bỏ
                      // quyền GPS). Khôi phục khi có chia sẻ vị trí thật.
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Đã gỡ khối "mini map" ở đây: nó vẽ 3 pin cứng mang tên
                  // Nam Trung / Ly / Nhật trên một lưới giả, trong khi app không
                  // thu thập vị trí thật của thành viên nào (đã bỏ quyền GPS).
                  // Khôi phục khi có tính năng chia sẻ vị trí thật.

                  // Circular Vibe energy meter gauge & Shake booster panel (2 columns)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: glassBorder, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: glassBorder,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(110, 110),
                                painter: EnergyCirclePainter(
                                  progress: _vibeEnergy(),
                                  color: secondaryColor,
                                  backgroundColor: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(_vibeEnergy() * 100).toInt()}%',
                                    style: AppFonts.heading(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  Text(
                                    'live.vibe_energy'.tr(),
                                    style: AppFonts.body(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              // Spans floating particles when boosted
                              if (_particlesController.isAnimating)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: FallingParticlesPainter(
                                        particles: _particles,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _triggerVibeBoost,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.vibration,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'live.shake_hint'.tr(),
                                    textAlign: TextAlign.center,
                                    style: AppFonts.heading(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Real-time Live Updates timeline list section
                  Text(
                    'live.updates'.tr(),
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hiển thị hoạt động THẬT của squad. Trước đây ở đây là 3 dòng
                  // cứng ("Minh Nhật is at The Hill Station"...) hiện cho mọi tài khoản.
                  Consumer(
                    builder: (context, ref, _) {
                      final async = ref.watch(squadActivitiesProvider);
                      return async.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (_, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'errors.load_failed'.tr(),
                            style: AppFonts.body(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        data: (items) {
                          if (items.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'live_trip.no_updates'.tr(),
                                style: AppFonts.body(
                                  fontSize: 13,
                                  color: textSecondary,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final a in items.take(6))
                                _buildLiveFeedItem(
                                  _activityEmoji(a.type),
                                  a.label,
                                  a.tripName,
                                  cardBg,
                                  glassBorder,
                                  textPrimary,
                                  textSecondary,
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tên chuyến gần nhất của user. Trước đây header hardcode "Đà Lạt Chill".
  String _tripName() {
    return ref
        .watch(tripsProvider)
        .maybeWhen(
          data: (trips) =>
              trips.isEmpty ? 'live_trip.no_trip'.tr() : trips.first.name,
          orElse: () => '…',
        );
  }

  /// Số thành viên thật. Trước đây luôn là "6 idiots".
  int _memberCount() {
    return ref
        .watch(tripsProvider)
        .maybeWhen(
          data: (trips) => trips.isEmpty ? 0 : trips.first.memberCount,
          orElse: () => 0,
        );
  }

  /// "Vibe energy" = tiến độ XP thật của chuyến, cộng thêm phần thưởng khi lắc
  /// máy. Trước đây con số này cố định 85% cho mọi tài khoản.
  double _vibeEnergy() {
    final tripId = ref.watch(activeTripIdProvider);
    if (tripId == null) return _shakeBonus.clamp(0.0, 1.0);
    final base = ref
        .watch(squadXpProvider(tripId))
        .maybeWhen(data: (xp) => xp.levelProgress, orElse: () => 0.0);
    return (base + _shakeBonus).clamp(0.0, 1.0);
  }

  /// Emoji minh hoạ cho từng loại hoạt động trong feed.
  static String _activityEmoji(String type) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return '💸';
      case 'MOMENT_SHARED':
        return '📸';
      case 'ITINERARY_ADDED':
        return '🗺️';
      case 'CHAT_SENT':
        return '💬';
      case 'GAME_STARTED':
        return '🎮';
      case 'POLL_CREATED':
        return '🗳️';
      case 'MEMBER_JOINED':
        return '👋';
      case 'JOURNAL_WRITTEN':
        return '📔';
      case 'NOTE_ADDED':
        return '📝';
      case 'DOCUMENT_UPLOADED':
        return '📎';
      default:
        return '✨';
    }
  }

  Widget _buildLiveFeedItem(
    String emoji,
    String title,
    String time,
    Color cardBg,
    Color glassBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glassBorder, width: 2),
        boxShadow: [BoxShadow(color: glassBorder, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.heading(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppFonts.body(fontSize: 10, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  double x, y;
  double vx, vy;
  Color color;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

class FallingParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  FallingParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      paint.color = p.color;
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EnergyCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  EnergyCirclePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 8.0;

    // Background complete ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // Front progress ring
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      pi * 0.75,
      pi * 1.5 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MiniMapGridPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;

  MiniMapGridPainter({required this.isDark, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.black.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    final roadPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(100, 40, 160, 100);
    path.quadraticBezierTo(200, 160, size.width, 140);

    path.moveTo(80, 0);
    path.lineTo(60, size.height);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
