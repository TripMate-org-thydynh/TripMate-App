import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../dashboard/data/home_feed_repository.dart';
import '../../trips/application/trips_providers.dart';
import '../data/games_repository.dart';

class WhoPaysWheelScreen extends ConsumerStatefulWidget {
  const WhoPaysWheelScreen({super.key});

  @override
  ConsumerState<WhoPaysWheelScreen> createState() => _WhoPaysWheelScreenState();
}

class _WhoPaysWheelScreenState extends ConsumerState<WhoPaysWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  List<Map<String, String>> _allMembers = [];
  List<Map<String, String>> _currentParticipants = [];
  bool _hasInitialized = false;
  bool _hasPromptedPicker = false;
  int _winnerIndex = -1;
  bool _isSpinning = false;
  double _startRotation = 0.0;
  double _endRotation = 0.0;
  double _lastTickRotation = 0.0;
  double _pointerAngle = 0.0;

  void _openParticipantPicker() {
    if (_isSpinning) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ParticipantPickerSheet(
          allMembers: _allMembers,
          initiallySelected: _currentParticipants,
          isDark: isDark,
          onConfirmed: (newSelected) {
            setState(() {
              _currentParticipants = newSelected;
              _winnerIndex = -1;
            });
          },
        );
      },
    );
  }

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
              ((alignedAngle / sectorAngle).floor()) %
              _currentParticipants.length;
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
      await ref
          .read(gamesRepositoryProvider)
          .createSession(
            tripId,
            gameType: 'SPIN_WHEEL',
            state: {
              'winner': winnerName,
              'players': _currentParticipants.length,
            },
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
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? GenZTokens.paperDark : GenZTokens.paper,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            side: BorderSide(
              color: line,
              width: GenZTokens.borderWidthThin,
            ),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('games.chaos_payer'),
                  style: AppFonts.heading(
                    color: danger,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: danger,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: danger.withValues(alpha: 0.12),
                    backgroundImage: NetworkImage(winner['avatar']!),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  winner['name']!,
                  style: AppFonts.heading(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('games.wheel_loser'),
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: danger,
                    foregroundColor: onAccent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    tr('games.accept_fate'),
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: onAccent,
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
    _allMembers = tripsAsync.maybeWhen(
      data: (trips) {
        if (trips.isEmpty || trips.first.members.isEmpty) return const [];
        return trips.first.members
            .map((m) => {'name': m.name, 'avatar': m.avatarUrl ?? ''})
            .toList();
      },
      orElse: () => const [],
    );

    if (!_hasInitialized && _allMembers.isNotEmpty) {
      _hasInitialized = true;
      if (_allMembers.length <= 10) {
        _currentParticipants = List.from(_allMembers);
      } else {
        _currentParticipants = _allMembers.take(10).toList();
        if (!_hasPromptedPicker) {
          _hasPromptedPicker = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _allMembers.length > 10) {
              _openParticipantPicker();
            }
          });
        }
      }
    } else if (_allMembers.length <= 10 &&
        _allMembers.isNotEmpty &&
        _currentParticipants.length != _allMembers.length) {
      _currentParticipants = List.from(_allMembers);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Chưa có chuyến/thành viên thì không có gì để quay — hiện hướng dẫn thay
    // vì một bánh xe rỗng hoặc (trước đây) bánh xe toàn người bịa.
    // Quay với 1 người là vô nghĩa (và bánh xe 1 múi hiển thị chữ lộn ngược),
    // nên yêu cầu tối thiểu 2 thành viên.
    if (_allMembers.length < 2) {
      final bgColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
          ),
        ),
        body: AppEmptyState(
          isDark: isDark,
          icon: PhosphorIcons.diceFive(),
          title: tr('games.wheel_need_squad_title'),
          body: tr('games.wheel_need_squad_body'),
        ),
      );
    }

    final Color bgColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final Color accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final Color onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final Color surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final Color textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final Color textSecondary =
        isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final Color line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
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
                      icon: Icon(PhosphorIcons.arrowLeft(), color: textPrimary),
                      style: IconButton.styleFrom(
                        backgroundColor: surfaceColor,
                        shape: const CircleBorder(),
                        side: BorderSide(
                          color: line,
                          width: GenZTokens.borderWidthThin,
                        ),
                      ),
                    ),
                    Text(
                      'trip.mate',
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: accent,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),

                // Flashing Alert Pill
                const FlashingPill(),
                const SizedBox(height: 16),

                // Title Text
                Text(
                  tr('games.who_pays_title'),
                  style: AppFonts.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr('games.chaos_mode_sub'),
                  style: AppFonts.body(fontSize: 13, color: textSecondary),
                ),
                if (_allMembers.length > 10) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isSpinning ? null : _openParticipantPicker,
                    icon: Icon(
                      PhosphorIcons.usersThree(),
                      size: 18,
                      color: accent,
                    ),
                    label: Text(
                      tr(
                        'games.select_participants_btn',
                        namedArgs: {'count': '${_currentParticipants.length}'},
                      ),
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: surfaceColor,
                      side: BorderSide(color: accent, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(GenZTokens.radiusButton),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 36),

                // Spinning Wheel Widget Stack
                SizedBox(
                  width: 360,
                  height: 360,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Left bubble
                      FloatingBubble(
                        text: tr('games.wheel_bubble_left'),
                        top: -12,
                        left: 4,
                        textColor: textSecondary,
                        isDark: isDark,
                      ),
                      // Right bubble
                      FloatingBubble(
                        text: tr('games.wheel_bubble_right'),
                        top: 160,
                        right: 4,
                        textColor: textSecondary,
                        isDark: isDark,
                      ),
                      // Wheel border container
                      Container(
                        width: 312,
                        height: 312,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: line,
                            width: 2,
                          ),
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
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: surfaceColor,
                            border: Border.all(
                              color: accent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              PhosphorIcons.diceFive(PhosphorIconsStyle.fill),
                              color: accent,
                              size: 26,
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
                            PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
                            color: accent,
                            size: 42,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 56),

                // Bottom Single Accent SPIN TO DECIDE button
                GestureDetector(
                  onTap: _spin,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.diceFive(PhosphorIconsStyle.fill),
                          color: onAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tr('games.spin_cta'),
                          style: AppFonts.heading(
                            color: onAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
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
    final count = participants.length;
    if (count < 2) return;
    final sectorAngle = (2 * pi) / count;

    final colors = const [
      GenZTokens.chart1,
      GenZTokens.chart2,
      GenZTokens.chart3,
      GenZTokens.chart4,
      GenZTokens.chart5,
      GenZTokens.chart6,
    ];

    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    for (int i = 0; i < count; i++) {
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
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sectorAngle,
        sectorAngle,
        true,
        borderPaint,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: participants[i]['name'] ?? '',
          style: AppFonts.heading(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            shadows: const [
              Shadow(
                color: Color(0x66000000),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      );
      tp.layout(maxWidth: radius * 0.52);

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
  bool shouldRepaint(covariant ChaosWheelPainter oldDelegate) =>
      oldDelegate.participants != participants || oldDelegate.isDark != isDark;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
            border: Border.all(
              color: danger.withValues(alpha: _opacityAnimation.value),
              width: GenZTokens.borderWidthThin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tr('games.chaos_mode'),
                style: AppFonts.heading(
                  color: danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isDark ? GenZTokens.paperDark : GenZTokens.paper,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(
              color: widget.isDark ? GenZTokens.lineDark : GenZTokens.line,
              width: GenZTokens.borderWidthThin,
            ),
          ),
          child: Text(
            widget.text,
            style: AppFonts.body(
              color: widget.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantPickerSheet extends StatefulWidget {
  final List<Map<String, String>> allMembers;
  final List<Map<String, String>> initiallySelected;
  final bool isDark;
  final ValueChanged<List<Map<String, String>>> onConfirmed;

  const _ParticipantPickerSheet({
    required this.allMembers,
    required this.initiallySelected,
    required this.isDark,
    required this.onConfirmed,
  });

  @override
  State<_ParticipantPickerSheet> createState() =>
      _ParticipantPickerSheetState();
}

class _ParticipantPickerSheetState extends State<_ParticipantPickerSheet> {
  late List<Map<String, String>> _selected;
  late TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initiallySelected);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    final filtered = widget.allMembers.where((m) {
      if (_query.trim().isEmpty) return true;
      final name = (m['name'] ?? '').toLowerCase();
      return name.contains(_query.trim().toLowerCase());
    }).toList();

    final isValidCount = _selected.length >= 2 && _selected.length <= 10;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: line,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('games.select_participants_title'),
                            style: AppFonts.heading(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr('games.select_participants_subtitle'),
                            style: AppFonts.body(
                              fontSize: 12,
                              color: inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isValidCount
                            ? accent.withValues(alpha: 0.12)
                            : GenZTokens.warning.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(GenZTokens.radiusPill),
                        border: Border.all(
                          color: isValidCount
                              ? accent
                              : (isDark
                                  ? GenZTokens.warningDark
                                  : GenZTokens.warning),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_selected.length}/10',
                        style: AppFonts.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isValidCount
                              ? accent
                              : (isDark
                                  ? GenZTokens.warningDark
                                  : GenZTokens.warning),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Search Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _query = val),
                  style: AppFonts.body(fontSize: 14, color: ink),
                  decoration: InputDecoration(
                    hintText: tr('games.search_member'),
                    hintStyle: AppFonts.body(fontSize: 14, color: inkSoft),
                    prefixIcon: Icon(
                      PhosphorIcons.magnifyingGlass(),
                      color: inkSoft,
                      size: 18,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                              color: inkSoft,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: fill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(GenZTokens.radiusButton),
                      borderSide: BorderSide(
                        color: line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(GenZTokens.radiusButton),
                      borderSide: BorderSide(
                        color: accent,
                        width: GenZTokens.borderWidthFocus,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Member List
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Text(
                            tr('common.empty'),
                            style: AppFonts.body(fontSize: 14, color: inkSoft),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => Divider(
                          color: line,
                          height: 1,
                          thickness: 0.5,
                        ),
                        itemBuilder: (context, i) {
                          final member = filtered[i];
                          final isChecked = _selected.any(
                            (s) => s['name'] == member['name'],
                          );
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isChecked) {
                                  _selected.removeWhere(
                                    (s) => s['name'] == member['name'],
                                  );
                                } else {
                                  if (_selected.length >= 10) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          tr('games.max_participants_warning'),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  _selected.add(member);
                                }
                              });
                            },
                            borderRadius:
                                BorderRadius.circular(GenZTokens.radiusButton),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 4,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        accent.withValues(alpha: 0.12),
                                    backgroundImage: (member['avatar'] != null &&
                                            member['avatar']!.isNotEmpty)
                                        ? NetworkImage(member['avatar']!)
                                        : null,
                                    child: (member['avatar'] == null ||
                                            member['avatar']!.isEmpty)
                                        ? Text(
                                            (member['name']?.isNotEmpty ?? false)
                                                ? member['name']![0].toUpperCase()
                                                : '?',
                                            style: AppFonts.heading(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: accent,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      member['name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.body(
                                        fontSize: 15,
                                        fontWeight: isChecked
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: ink,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isChecked
                                        ? PhosphorIcons.checkSquare(
                                            PhosphorIconsStyle.fill,
                                          )
                                        : PhosphorIcons.square(),
                                    color: isChecked ? accent : inkSoft,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Warning if < 2 selected
              if (_selected.length < 2)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Text(
                    tr('games.min_participants_warning'),
                    style: AppFonts.body(
                      fontSize: 12,
                      color: isDark ? GenZTokens.dangerDark : GenZTokens.danger,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Confirm button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: ElevatedButton(
                  onPressed: isValidCount
                      ? () {
                          widget.onConfirmed(_selected);
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: onAccent,
                    disabledBackgroundColor:
                        isDark ? GenZTokens.fillDark : GenZTokens.fill,
                    disabledForegroundColor:
                        isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(GenZTokens.radiusButton),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    tr(
                      'games.confirm_selection',
                      namedArgs: {'count': '${_selected.length}'},
                    ),
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isValidCount
                          ? onAccent
                          : (isDark
                              ? GenZTokens.inkSoftDark
                              : GenZTokens.inkSoft),
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
}
