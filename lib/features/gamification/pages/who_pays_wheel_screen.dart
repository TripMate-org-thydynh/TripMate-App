import 'dart:math';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../widgets/game_state_views.dart';
import '../../../core/theme/gen_z_tokens.dart';
// Chỉ lấy `.tr()`: easy_localization re-export intl, gây va chạm
// `TextDirection` với dart:ui dùng trong CustomPainter bên dưới.
import 'package:easy_localization/easy_localization.dart' show tr;
import '../../dashboard/data/home_feed_repository.dart';
import '../data/games_repository.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_messenger.dart';
import '../../trips/application/trips_providers.dart';

class WhoPaysWheelScreen extends ConsumerStatefulWidget {
  const WhoPaysWheelScreen({super.key});

  @override
  ConsumerState<WhoPaysWheelScreen> createState() => _WhoPaysWheelScreenState();
}

class _WhoPaysWheelScreenState extends ConsumerState<WhoPaysWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  List<Map<String, String>> _currentParticipants = [];
  int _winnerIndex = -1;
  bool _isSpinning = false;
  double _startRotation = 0.0;
  double _endRotation = 0.0;
  double _lastTickRotation = 0.0;
  double _pointerAngle = 0.0;

  void _triggerPointerBounce() {
    setState(() {
      _pointerAngle = 0.25;
    });
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) {
        setState(() {
          _pointerAngle = -0.12;
        });
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            setState(() {
              _pointerAngle = 0.0;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_spinController);

    _spinAnimation.addListener(() {
      if (_currentParticipants.length < 2) return;
      final sectorAngle = (2 * pi) / _currentParticipants.length;
      final currentRotation = _spinAnimation.value;
      if ((currentRotation - _lastTickRotation).abs() >= sectorAngle) {
        _lastTickRotation = currentRotation;
        HapticFeedback.lightImpact();
        _triggerPointerBounce();
      }
    });

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          final finalAngle = _endRotation % (2 * pi);
          final sectorAngle = (2 * pi) / _currentParticipants.length;
          final alignedAngle = (5 * pi / 2 - finalAngle) % (2 * pi);
          _winnerIndex =
              ((alignedAngle / sectorAngle).floor()) % _currentParticipants.length;
        });
        _showChaosPayerDialog();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || _currentParticipants.length < 2) return;
    setState(() {
      _isSpinning = true;
      _winnerIndex = -1;
      _startRotation = _endRotation % (2 * pi);
      final random = Random();
      final extraSpins = 5 + random.nextInt(4);
      final targetAngle = random.nextDouble() * 2 * pi;
      _endRotation = _startRotation + (extraSpins * 2 * pi) + targetAngle;

      _spinAnimation = Tween<double>(begin: _startRotation, end: _endRotation)
          .animate(
            CurvedAnimation(parent: _spinController, curve: Curves.decelerate),
          );
    });

    _lastTickRotation = _startRotation;
    _spinController.reset();
    _spinController.forward();
  }

  /// Ghi lại ván quay thành một game session.
  ///
  /// Nhờ vậy trò chơi đóng góp vào XP của squad và xuất hiện trong feed
  /// hoạt động — trước đây quay xong là trôi mất, không để lại dấu vết nào.
  Future<void> _recordSpin(String winnerName) async {
    final tripId = ref.read(activeTripIdProvider);
    if (tripId == null) return;
    try {
      await ref.read(gamesRepositoryProvider).createSession(
        tripId,
        gameType: 'SPIN_WHEEL',
        state: {'winner': winnerName, 'players': _currentParticipants.length},
      );
      ref.invalidate(squadXpProvider(tripId));
      ref.invalidate(squadActivitiesProvider);
    } catch (_) {
      // Không chặn trải nghiệm chơi nếu ghi nhận thất bại.
    }
  }

  void _showChaosPayerDialog() {
    final winner = _currentParticipants[_winnerIndex];
    unawaited(_recordSpin(winner['name'] ?? ''));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262019) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: const Color(0xFFD8422B), width: 2.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🔥 CHAOS PAYER 🔥',
                  style: AppFonts.heading(
                    color: const Color(0xFFD8422B),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD8422B),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD8422B).withValues(alpha: 0.3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    backgroundImage: NetworkImage(winner['avatar']!),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  winner['name']!,
                  style: AppFonts.heading(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFFDAE2FD)
                        : const Color(0xFF141210),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thần tài hỗn loạn đã gõ đầu cưng! Ngoài việc phải bao trọn hóa đơn này, cưng còn phải thực hiện một thử thách Dare ngẫu nhiên tiếp theo! 💀💸',
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFFCBC3D7)
                        : const Color(0xFF4A453E),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD8422B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Chấp nhận số phận 💸',
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);
    // Chỉ quay trên thành viên THẬT của chuyến. Trước đây khi chưa có chuyến,
    // bánh xe rơi về 4 người bịa (Minh Nhật / Thảo Ly / Nam Trung / Duy Khang)
    // — quay ra một người không tồn tại thì trò chơi vô nghĩa.
    _currentParticipants = tripsAsync.maybeWhen(
      data: (trips) {
        if (trips.isEmpty || trips.first.members.isEmpty) return const [];
        return trips.first.members
            .map((m) => {'name': m.name, 'avatar': m.avatarUrl ?? ''})
            .toList();
      },
      orElse: () => const [],
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Chưa có chuyến/thành viên thì không có gì để quay — hiện hướng dẫn thay
    // vì một bánh xe rỗng hoặc (trước đây) bánh xe toàn người bịa.
    // Quay với 1 người là vô nghĩa (và bánh xe 1 múi hiển thị chữ lộn ngược),
    // nên yêu cầu tối thiểu 2 thành viên.
    if (_currentParticipants.length < 2) {
      return Scaffold(
        backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
          ),
        ),
        body: GameEmptyState(
          isDark: isDark,
          icon: Icons.casino_outlined,
          title: tr('games.wheel_need_squad_title'),
          body: tr('games.wheel_need_squad_body'),
        ),
      );
    }

    // Standard Palette colors
    final Color bgColor = isDark
        ? const Color(0xFF1A1712)
        : const Color(0xFFFDF6D3);
    final Color primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B);
    final Color surfaceColor = isDark
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);
    final Color textPrimary = isDark
        ? const Color(0xFFDAE2FD)
        : const Color(0xFF141210);
    final Color textSecondary = isDark
        ? const Color(0xFFCBC3D7)
        : const Color(0xFF4A453E);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: isDark
            ? const BoxDecoration(color: Color(0xFF1A1712))
            : null,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  // Top Navigation Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: textPrimary),
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor.withValues(
                            alpha: isDark ? 0.3 : 0.8,
                          ),
                          shape: const CircleBorder(),
                        ),
                      ),
                      Text(
                        'trip.mate',
                        style: AppFonts.heading(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => showGlobalSnack(
                          'Tính năng đang được hoàn thiện 🚧',
                        ),
                        icon: Icon(
                          Icons.add_reaction_outlined,
                          color: primaryColor,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: surfaceColor.withValues(
                            alpha: isDark ? 0.3 : 0.8,
                          ),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Flashing Alert Pill
                  const FlashingPill(),
                  const SizedBox(height: 16),

                  // Title Text
                  Text(
                    'Who Pays?',
                    style: AppFonts.heading(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chế độ tăng cực mạnh chỉ số hỗn loạn của cả Squad!',
                    style: AppFonts.body(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Spinning Wheel Widget Stack with comical floaty bubbles
                  SizedBox(
                    width: 360,
                    height: 360,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Left bubble: please not me
                        FloatingBubble(
                          text: tr('games.wheel_bubble_left'),
                          top: -12,
                          left: 4,
                          textColor: const Color(0xFFFB923C),
                          isDark: isDark,
                        ),
                        // Right bubble: my wallet is empty
                        FloatingBubble(
                          text: tr('games.wheel_bubble_right'),
                          top: 160,
                          right: 4,
                          textColor: const Color(0xFF1FA85C),
                          isDark: isDark,
                        ),
                        // Wheel glowing outer border container
                        Container(
                          width: 312,
                          height: 312,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(
                                      0xFFF5822B,
                                    ).withValues(alpha: 0.3)
                                  : const Color(
                                      0xFFF5822B,
                                    ).withValues(alpha: 0.3),
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? const Color(0xFFF5822B)
                                            : const Color(0xFFF5822B))
                                        .withValues(alpha: 0.15),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),
                        // The Spinning Wheel
                        GestureDetector(
                          onTap: _spin,
                          child: AnimatedBuilder(
                            animation: _spinAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _spinAnimation.value,
                                child: CustomPaint(
                                  size: const Size(300, 300),
                                  painter: ChaosWheelPainter(
                                    participants: _currentParticipants,
                                    isDark: isDark,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Wheel Center Hub with Dice icon
                        GestureDetector(
                          onTap: _spin,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF262019)
                                  : Colors.white,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFFF5822B)
                                    : const Color(0xFFF5822B),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? const Color(0xFFF5822B)
                                              : const Color(0xFFF5822B))
                                          .withValues(alpha: 0.4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.casino,
                                color: isDark
                                    ? const Color(0xFFF5822B)
                                    : const Color(0xFFF5822B),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        // Top pointer indicator
                        Positioned(
                          top: -12,
                          child: Transform.rotate(
                            angle: _pointerAngle,
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.arrow_drop_down_sharp,
                              color: isDark
                                  ? const Color(0xFFF5822B)
                                  : const Color(0xFFF5822B),
                              size: 42,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Bottom Gradient "casino SPIN TO DECIDE" button
                  GestureDetector(
                    onTap: _spin,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.casino,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SPIN TO DECIDE',
                            style: AppFonts.heading(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChaosWheelPainter extends CustomPainter {
  final List<Map<String, String>> participants;
  final bool isDark;

  ChaosWheelPainter({required this.participants, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);
    final sectorAngle = (2 * pi) / participants.length;

    final darkColors = [
      const Color(0xFFF5822B), // Purple
      const Color(0xFF1FA85C), // Mint Green
      const Color(0xFFFB923C), // Orange
      const Color(0xFFD8422B), // Red
    ];

    final lightColors = [
      const Color(0xFFF5822B), // Coral
      const Color(0xFFFFD84D), // Amber
      const Color(0xFF3D8BFF), // Blue
      const Color(0xFF1FA85C), // Emerald
    ];

    final colors = isDark ? darkColors : lightColors;

    for (int i = 0; i < participants.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sectorAngle,
        sectorAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sectorAngle,
        sectorAngle,
        true,
        borderPaint,
      );

      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(
        text: participants[i]['name']!,
        style: AppFonts.heading(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 1),
              blurRadius: 0,
            ),
          ],
        ),
      );
      tp.layout();

      final angle = i * sectorAngle + (sectorAngle / 2);
      canvas.save();
      canvas.translate(
        center.dx + cos(angle) * (radius * 0.58),
        center.dy + sin(angle) * (radius * 0.58),
      );
      canvas.rotate(angle);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlashingPill extends StatefulWidget {
  const FlashingPill({super.key});

  @override
  State<FlashingPill> createState() => _FlashingPillState();
}

class _FlashingPillState extends State<FlashingPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFD8422B).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(
                0xFFD8422B,
              ).withValues(alpha: _opacityAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFD8422B,
                ).withValues(alpha: _opacityAnimation.value * 0.2),
                blurRadius: 0,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFD8422B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Chaos Mode Active ⚠️',
                style: AppFonts.heading(
                  color: const Color(0xFFD8422B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class FloatingBubble extends StatefulWidget {
  final String text;
  final double top;
  final double? left;
  final double? right;
  final double? bottom;
  final Color textColor;
  final bool isDark;

  const FloatingBubble({
    super.key,
    required this.text,
    required this.top,
    this.left,
    this.right,
    this.bottom,
    required this.textColor,
    required this.isDark,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _translateAnimation = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotateAnimation = Tween<double>(
      begin: -0.06,
      end: 0.06,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateAnimation.value),
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF262019).withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: AppFonts.body(
              color: widget.textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
