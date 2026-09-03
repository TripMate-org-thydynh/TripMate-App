import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/xp_repository.dart';
import '../data/games_repository.dart';
import 'package:flutter/services.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';

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
      'emoji': '☕',
      'title': 'Cafe at 2AM',
      'state': 'normal', // completed, active, normal
    },
    {'emoji': '📸', 'title': 'Accidental Film Photo', 'state': 'normal'},
    {'emoji': '☔', 'title': 'Survive Random Rain', 'state': 'normal'},
    {'emoji': '🗺️', 'title': 'Lost with Squad', 'state': 'normal'},
    {'emoji': '💸', 'title': 'Overspend Budget', 'state': 'normal'},
    {'emoji': '🍕', 'title': 'Eat 4th Meal', 'state': 'normal'},
    {'emoji': '🎤', 'title': 'Public Karaoke', 'state': 'normal'},
    {'emoji': '🏃', 'title': 'Miss a Train', 'state': 'normal'},
    {'emoji': '🌅', 'title': 'Stay up til Sunrise', 'state': 'normal'},
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
      final tripId = ref.read(activeTripIdProvider);
      if (tripId != null) {
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
    final isDark = widget.isDarkMode;
    final surfaceColor = isDark
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);
    final inkColor = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            const Positioned.fill(child: ConfettiOverlay()),
            Center(
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: inkColor, width: 2.5),
                    boxShadow: [
                      BoxShadow(color: inkColor, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'games.bingo_win'.tr(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: GenZTokens.orange,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'games.bingo_full'.tr(),
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: inkColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'games.bingo_line_win'.tr(),
                        textAlign: TextAlign.center,
                        style: AppFonts.body(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark
                              ? GenZTokens.inkSoftDark
                              : GenZTokens.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: GenZTokens.orange,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: inkColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: inkColor,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'games.awesome'.tr(),
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GenZTokens.ink,
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
    final isDark = widget.isDarkMode;

    // Design System colors
    final bgStart = Theme.of(context).scaffoldBackgroundColor;
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final primary = isDark ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
    final secondary = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFFFFD84D);
    final textPrimary = isDark
        ? const Color(0xFFDAE2FD)
        : const Color(0xFF141210);
    final textMuted = isDark
        ? const Color(0xFFCBC3D7)
        : const Color(0xFF4A453E);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: bgStart),
        child: Stack(
          children: [
            // Glowing background orbs
            if (isDark) ...[
              Positioned(
                top: -50,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                bottom: 200,
                left: -100,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],

            SafeArea(
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
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(Color textPrimary) {
    final isDark = widget.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
          Text(
            'trip.mate',
            style: AppFonts.heading(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: textPrimary.withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: widget.onThemeToggle,
              tooltip: 'Toggle Theme',
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
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'games.bingo_sub'.tr(),
            style: AppFonts.body(
              fontSize: 14,
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black),
          width: 2,
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                ),
              ),
              Text(
                // Muc do suy ra tu so o da tick THAT — truoc day luon la
                // "Level 3: Unhinged" du chua tick o nao.
                'games.chaos_level_n'.tr(args: ['${_chaosLevel()}']),
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: currentChaosRatio,
                      backgroundColor: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(secondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(currentChaosRatio * 100).toInt()}%',
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            remainingCount > 0
                ? 'Chaos level increasing. $remainingCount more for Bingo!'
                : 'Bingo achieved! Complete chaos unleashed! 🎉',
            style: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
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

        Color tileBg = surface.withValues(alpha: isDark ? 0.35 : 0.65);
        Color tileBorder = (isDark ? Colors.white : Colors.black).withValues(
          alpha: 0.05,
        );
        double borderWidth = 1.0;
        List<BoxShadow>? tileGlow;

        if (state == 'completed') {
          tileBg = secondary.withValues(alpha: 0.15);
          tileBorder = secondary;
          borderWidth = 1.5;
          tileGlow = [
            BoxShadow(color: secondary.withValues(alpha: 0.1), blurRadius: 0),
          ];
        } else if (state == 'active') {
          tileBg = primary.withValues(alpha: 0.12);
          tileBorder = primary;
          borderWidth = 1.5;
          tileGlow = [
            BoxShadow(color: primary.withValues(alpha: 0.1), blurRadius: 0),
          ];
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
                      namedArgs: {'tile': '${tile['title']}'},
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: secondary,
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tileBorder, width: borderWidth),
              boxShadow: tileGlow,
            ),
            padding: const EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tile['emoji'] as String,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tile['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading(
                        fontSize: 10,
                        fontWeight: state == 'completed'
                            ? FontWeight.w900
                            : FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                if (state == 'completed')
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: secondary,
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: secondary, width: 2),
          boxShadow: [
            BoxShadow(color: secondary.withValues(alpha: 0.05), blurRadius: 0),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                color: secondary,
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
                        ? 'Bingo! $lines line${lines > 1 ? 's' : ''} completed 🎉'
                        : 'No bingo line yet 🎯',
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$done/${_bingoTiles.length} tiles checked.',
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        GenZTokens.yellow,
        GenZTokens.orange,
        GenZTokens.green,
        GenZTokens.purple,
        GenZTokens.pink,
        GenZTokens.blue,
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
