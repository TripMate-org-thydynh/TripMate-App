import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../../core/theme/gen_z_tokens.dart';
import '../../profile/data/xp_repository.dart';
import '../data/games_repository.dart';

class TripBingoScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const TripBingoScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  ConsumerState<TripBingoScreen> createState() => _TripBingoScreenState();
}

class _TripBingoScreenState extends ConsumerState<TripBingoScreen>
    with SingleTickerProviderStateMixin {
  /// Id ván bingo trên server — dùng để lưu lại các ô đã tick.
  String? _sessionId;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<List<int>> _winningLines = const [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6], // Diagonals
  ];
  final Set<int> _completedLineIndices = {};

  final List<Map<String, dynamic>> _bingoTiles = [
    {
      'icon': PhosphorIcons.coffee(),
      'titleKey': 'games.bingo_tile_cafe',
      'state': 'normal', // completed, active, normal
    },
    {
      'icon': PhosphorIcons.camera(),
      'titleKey': 'games.bingo_tile_photo',
      'state': 'normal',
    },
    {
      'icon': PhosphorIcons.cloudRain(),
      'titleKey': 'games.bingo_tile_rain',
      'state': 'normal',
    },
    {
      'icon': PhosphorIcons.mapTrifold(),
      'titleKey': 'games.bingo_tile_lost',
      'state': 'normal',
    },
    {
      'icon': PhosphorIcons.money(),
      'titleKey': 'games.bingo_tile_overspend',
      'state': 'normal',
    },
    {
      'icon': PhosphorIcons.pizza(),
      'titleKey': 'games.bingo_tile_meal',
      'state': 'normal',
    },
    {
      'icon': PhosphorIcons.microphone(),
      'titleKey': 'games.bingo_tile_karaoke',
      'state': 'normal',
    },
    {
      'icon': PhosphorIcons.train(),
      'titleKey': 'games.bingo_tile_train',
      'state': 'normal',
    },
    {
      'icon': PhosphorIcons.sunHorizon(),
      'titleKey': 'games.bingo_tile_sunrise',
      'state': 'normal',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBoard());
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Recalculate chaos progress level dynamically
  double _getChaosLevel() {
    int completedCount = _bingoTiles
        .where((t) => t['state'] == 'completed')
        .length;
    return (completedCount / _bingoTiles.length);
  }

  /// Nạp ván bingo đã lưu của chuyến, hoặc mở ván mới.
  Future<void> _loadBoard() async {
    final tripId = ref.read(activeTripIdProvider);
    if (tripId == null) return;
    try {
      final repo = ref.read(gamesRepositoryProvider);
      final existing = await repo.fetchBingo(tripId);
      if (!mounted) return;
      if (existing != null) {
        setState(() {
          _sessionId = existing.id;
          for (final i in existing.marked) {
            if (i >= 0 && i < _bingoTiles.length) {
              _bingoTiles[i]['state'] = 'completed';
            }
          }
        });
        _checkBingoWin(celebrate: false);
      } else {
        final id = await repo.startBingo(tripId);
        if (!mounted) return;
        setState(() => _sessionId = id);
      }
    } catch (_) {
      // Không chặn người chơi: bảng vẫn tick được, chỉ là không lưu được.
    }
  }

  /// Lưu các ô đã tick lên server để lần sau vào vẫn còn.
  Future<void> _saveBoard() async {
    final tripId = ref.read(activeTripIdProvider);
    final id = _sessionId;
    if (tripId == null || id == null) return;
    final marked = <int>[
      for (var i = 0; i < _bingoTiles.length; i++)
        if (_bingoTiles[i]['state'] == 'completed') i,
    ];
    try {
      await ref.read(gamesRepositoryProvider).saveBingo(tripId, id, marked);
    } catch (_) {
      // Lưu hỏng thì bỏ qua — sẽ lưu lại ở lần tick sau.
    }
  }

  /// 0 o -> 1, tick het -> 5.
  int _chaosLevel() {
    final done = _bingoTiles.where((x) => x['state'] == 'completed').length;
    if (_bingoTiles.isEmpty) return 1;
    return 1 + ((done / _bingoTiles.length) * 4).round();
  }

  void _checkBingoWin({bool celebrate = true}) {
    bool newBingoAchieved = false;

    for (int i = 0; i < _winningLines.length; i++) {
      final line = _winningLines[i];
      final isLineComplete = line.every(
        (idx) => _bingoTiles[idx]['state'] == 'completed',
      );

      if (isLineComplete) {
        if (!_completedLineIndices.contains(i)) {
          _completedLineIndices.add(i);
          newBingoAchieved = true;
        }
      } else {
        _completedLineIndices.remove(i);
      }
    }

    if (newBingoAchieved && celebrate) {
      HapticFeedback.heavyImpact();
      _showBingoCelebrationDialog();
      // Ăn được một hàng thì XP vào squad thật, không chỉ hiện dialog.
      // Đồng thời kết thúc ván hiện tại trên server để lần sau vào màn tạo ván mới.
      final tripId = ref.read(activeTripIdProvider);
      final sessionId = _sessionId;
      if (tripId != null) {
        if (sessionId != null) {
          ref
              .read(gamesRepositoryProvider)
              .endBingo(tripId, sessionId)
              .catchError((_) {});
        }
        ref
            .read(gamesRepositoryProvider)
            .createSession(
              tripId,
              gameType: 'CARD_MATCH',
              state: {
                'game': 'BINGO_LINE',
                'lines': _completedLineIndices.length,
              },
            )
            .then((_) {
              if (!mounted) return;
              ref.invalidate(squadXpProvider(tripId));
              ref.invalidate(leaderboardProvider(tripId));
              ref.invalidate(xpWalletProvider);
            })
            .catchError((_) {});
      }
    }
  }

  void _showBingoCelebrationDialog() {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final inkColor = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            const Positioned.fill(child: ConfettiOverlay()),
            Center(
              child: Dialog(
                backgroundColor: surfaceColor,
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
                        'games.bingo_win'.tr(),
                        style: AppFonts.heading(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'games.bingo_full'.tr(),
                        style: AppFonts.heading(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: inkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'games.bingo_line_win'.tr(),
                        textAlign: TextAlign.center,
                        style: AppFonts.body(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark
                              ? GenZTokens.inkSoftDark
                              : GenZTokens.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusButton,
                            ),
                          ),
                          child: Text(
                            'games.awesome'.tr(),
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: onAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    // Design System colors
    final bgStart = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final primary = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final secondary = isDark ? GenZTokens.successDark : GenZTokens.success;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textMuted = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Scaffold(
      backgroundColor: bgStart,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Top App Bar
              _buildTopAppBar(textPrimary),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Heading titles
                      _buildHeaderSection(textPrimary, textMuted),

                      const SizedBox(height: 24),

                      // Chaos level progress bar panel
                      _buildChaosProgressCard(
                        surface,
                        secondary,
                        textPrimary,
                        textMuted,
                        isDark,
                      ),

                      const SizedBox(height: 28),

                      // 3x3 Bingo Grid
                      _buildBingoGrid(
                        surface,
                        primary,
                        secondary,
                        textPrimary,
                        textMuted,
                        isDark,
                      ),

                      const SizedBox(height: 28),

                      // Financial Reward unlocked alert card
                      _buildRewardCard(
                        surface,
                        primary,
                        secondary,
                        textPrimary,
                        textMuted,
                        isDark,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar(Color textPrimary) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              PhosphorIcons.arrowLeft(),
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'common.back'.tr(),
          ),
          Text(
            'trip.mate',
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: textPrimary,
            ),
          ),
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                isDark ? PhosphorIcons.sun() : PhosphorIcons.moon(),
                color: textPrimary.withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: widget.onThemeToggle,
              tooltip: 'theme.toggle'.tr(),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Color textPrimary, Color textMuted) {
    return Center(
      child: Column(
        children: [
          Text(
            'games.bingo_title'.tr(),
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'games.bingo_sub'.tr(),
            style: AppFonts.body(
              fontSize: 13,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaosProgressCard(
    Color surface,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    bool isDark,
  ) {
    final currentChaosRatio = _getChaosLevel();
    final remainingCount = _bingoTiles
        .where((t) => t['state'] != 'completed')
        .length;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'games.chaos_level'.tr(),
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
              Text(
                // Muc do suy ra tu so o da tick THAT — truoc day luon la
                // "Level 3: Unhinged" du chua tick o nao.
                'games.chaos_level_n'.tr(args: ['${_chaosLevel()}']),
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: currentChaosRatio,
                      backgroundColor: fill,
                      valueColor: AlwaysStoppedAnimation<Color>(secondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(currentChaosRatio * 100).toInt()}%',
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            remainingCount > 0
                ? 'games.bingo_remaining'
                    .tr(namedArgs: {'count': '$remainingCount'})
                : 'games.bingo_unleashed'.tr(),
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBingoGrid(
    Color surface,
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    bool isDark,
  ) {
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _bingoTiles.length,
      itemBuilder: (context, index) {
        final tile = _bingoTiles[index];
        final state = tile['state'] as String;

        Color tileBg = surface;
        Color tileBorder = line;
        double borderWidth = GenZTokens.borderWidthThin;
        Color tileTextColor = textPrimary;
        Color tileIconColor = textPrimary;

        if (state == 'completed') {
          tileBg = accentSoft;
          tileBorder = primary;
          borderWidth = GenZTokens.borderWidth;
          tileTextColor = primary;
          tileIconColor = primary;
        } else if (state == 'active') {
          tileBg = fill;
          tileBorder = primary;
          borderWidth = GenZTokens.borderWidth;
          tileTextColor = textPrimary;
          tileIconColor = primary;
        }

        return BouncingTile(
          onTap: () {
            setState(() {
              if (state == 'completed') {
                tile['state'] = 'normal';
              } else {
                tile['state'] = 'completed';
              }
            });
            _checkBingoWin();
            _saveBoard();

            if (tile['state'] == 'completed') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'games.bingo_tile_checked'.tr(
                      namedArgs: {'tile': (tile['titleKey'] as String).tr()},
                    ),
                    style: AppFonts.body(
                      fontSize: 13,
                      color: isDark
                          ? GenZTokens.onAccentDark
                          : GenZTokens.onAccent,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: primary,
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: tileBorder, width: borderWidth),
            ),
            padding: const EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tile['icon'] as IconData,
                      size: 24,
                      color: tileIconColor,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (tile['titleKey'] as String).tr(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: state == 'completed'
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: tileTextColor,
                      ),
                    ),
                  ],
                ),
                if (state == 'completed')
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(
                      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                      color: primary,
                      size: 14,
                    ),
                  )
                else if (state == 'active')
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
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

  Widget _buildRewardCard(
    Color surface,
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    bool isDark,
  ) {
    // Con so that: so o da tick va so hang bingo da hoan thanh.
    // Truoc day the nay in cung "+50 Chaos Points awarded" ke ca khi chua tick o nao.
    final done = _bingoTiles.where((t) => t['state'] == 'completed').length;
    final lines = _completedLineIndices.length;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      padding: const EdgeInsets.all(GenZTokens.space4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.trophy(PhosphorIconsStyle.fill),
              color: primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lines > 0
                      ? 'games.bingo_lines_completed'
                          .tr(namedArgs: {'count': '$lines'})
                      : 'games.bingo_no_lines'.tr(),
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'games.bingo_tiles_count'.tr(
                    namedArgs: {
                      'done': '$done',
                      'total': '${_bingoTiles.length}',
                    },
                  ),
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confetti Particle Animation Overlay ──────────────────────────────────────

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    vsync: this,
  )..forward();

  final List<_ConfettiParticle> _particles = List.generate(40, (index) {
    final random = Random();
    return _ConfettiParticle(
      color: [
        GenZTokens.chart1,
        GenZTokens.chart2,
        GenZTokens.chart3,
        GenZTokens.chart4,
        GenZTokens.chart5,
        GenZTokens.chart6,
      ][random.nextInt(6)],
      x: random.nextDouble(),
      y: -0.1 - random.nextDouble() * 0.4,
      speedY: 2.0 + random.nextDouble() * 3.5,
      speedX: -1.5 + random.nextDouble() * 3.0,
      size: 6.0 + random.nextDouble() * 8.0,
      rotation: random.nextDouble() * 2 * pi,
      rotationSpeed: -0.05 + random.nextDouble() * 0.1,
    );
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final elapsed = _controller.value;
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(particles: _particles, elapsed: elapsed),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final Color color;
  double x;
  double y;
  final double speedY;
  final double speedX;
  final double size;
  double rotation;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double elapsed;

  _ConfettiPainter({required this.particles, required this.elapsed});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY =
          p.y * size.height + (p.speedY * elapsed * size.height * 0.25);
      final currentX =
          p.x * size.width + (p.speedX * elapsed * size.width * 0.08);
      final currentRotation = p.rotation + (p.rotationSpeed * elapsed * 20);

      if (currentY > size.height || currentX < 0 || currentX > size.width) {
        continue;
      }

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 1.5,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Tactile Squishy Bouncing Button/Tile ─────────────────────────────────────

class BouncingTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BouncingTile({super.key, required this.child, required this.onTap});

  @override
  State<BouncingTile> createState() => _BouncingTileState();
}

class _BouncingTileState extends State<BouncingTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );
  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 1.0,
    end: 0.9,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
