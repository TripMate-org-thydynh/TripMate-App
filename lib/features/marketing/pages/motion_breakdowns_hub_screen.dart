import 'dart:math';
import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MotionBreakdownsHubScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const MotionBreakdownsHubScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<MotionBreakdownsHubScreen> createState() => _MotionBreakdownsHubScreenState();
}

class _MotionBreakdownsHubScreenState extends State<MotionBreakdownsHubScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // AI Sync animations
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // Explosive reactions lists
  final List<Offset> _stickerOffsets = [];
  final List<String> _stickersList = ['🔥', '😭', '💀', '💯', '✨', '☕', '💸'];

  // Magnetic Snapping position
  Offset _dragOffset = const Offset(0, 0);
  bool _isSnapped = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Sync Pulse controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseScale = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerStickerExplosion() {
    final rand = Random();
    setState(() {
      _stickerOffsets.clear();
      for (int i = 0; i < 15; i++) {
        _stickerOffsets.add(
          Offset(
            rand.nextDouble() * 200 - 100, // X diff
            rand.nextDouble() * -150 - 50,  // Y upward motion
          ),
        );
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _stickerOffsets.clear();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final bgColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Motion Language 🛸',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: primaryColor,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          indicatorColor: primaryColor,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: 'AI Pulse'),
            Tab(text: 'Explosions'),
            Tab(text: 'Delight Snaps'),
            Tab(text: 'Easing Rules'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildAiPulseTab(isDark, surfaceColor, borderCol, primaryColor, secondaryColor, textPrimary, textSecondary),
          _buildExplosiveReactionsTab(isDark, surfaceColor, borderCol, primaryColor, secondaryColor, textPrimary, textSecondary),
          _buildDelightSnapsTab(isDark, surfaceColor, borderCol, primaryColor, secondaryColor, textPrimary, textSecondary),
          _buildEasingRulesTab(isDark, surfaceColor, borderCol, primaryColor, secondaryColor, textPrimary, textSecondary),
        ],
      ),
    );
  }

  // --- TAB 1: AI SYNC PULSE ---
  Widget _buildAiPulseTab(
    bool isDark,
    Color surfaceColor,
    Color borderCol,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intelligent Sync: Realtime Awareness',
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience the zero-latency connection of Squad Sync powered by generative AI pulses.',
            style: GoogleFonts.inter(fontSize: 13.5, color: textSecondary),
          ),
          const SizedBox(height: 48),

          // Custom animated sync radar visualizer
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing rings
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 140 * _pulseScale.value,
                      height: 140 * _pulseScale.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondaryColor.withValues(alpha: 0.15 * _pulseOpacity.value),
                        border: Border.all(
                          color: secondaryColor.withValues(alpha: _pulseOpacity.value),
                          width: 1.5,
                        ),
                      ),
                    );
                  },
                ),

                // Center core node
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor.withValues(alpha: 0.35),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text('🤖⚡', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Details row
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology, color: primaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Processing intent: 98%',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5, color: textPrimary),
                      ),
                      Text(
                        'Generative AI pulses mapping the collaborative route.',
                        style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- TAB 2: EXPLOSIVE STICKERS ---
  Widget _buildExplosiveReactionsTab(
    bool isDark,
    Color surfaceColor,
    Color borderCol,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final rand = Random();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Energy: Explosive Interactions',
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Visualizing the chaotic-fun spirit of Gen Z group planning through immersive physics sticker bursts.',
            style: GoogleFonts.inter(fontSize: 13.5, color: textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Interactive sandbox area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderCol),
                  ),
                  child: const Center(
                    child: Text(
                      'Tab Here to Explode Stickers 💥',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),

                // Absolute touch action
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _triggerStickerExplosion,
                    behavior: HitTestBehavior.opaque,
                  ),
                ),

                // Explosion elements overlays
                if (_stickerOffsets.isNotEmpty)
                  ...List.generate(_stickerOffsets.length, (idx) {
                    final offset = _stickerOffsets[idx];
                    final stkr = _stickersList[rand.nextInt(_stickersList.length)];
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      top: 150 + offset.dy,
                      left: 150 + offset.dx,
                      child: Text(
                        stkr,
                        style: const TextStyle(fontSize: 36),
                      ),
                    );
                  })
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Explanatory list notes
          Row(
            children: [
              Expanded(
                child: _buildSpecDetail('Physics curves ☄️', 'Stickers float out mimicking realistic momentum.', textPrimary, textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecDetail('Layered depth 🥞', 'Translucent stacking and heavy blurs.', textPrimary, textSecondary),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- TAB 3: MAGNETIC SNAPPING ---
  Widget _buildDelightSnapsTab(
    bool isDark,
    Color surfaceColor,
    Color borderCol,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Satisfying Finish',
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Exploring utility and delight through snapping layouts and physical docking grids.',
            style: GoogleFonts.inter(fontSize: 13.5, color: textSecondary),
          ),
          const SizedBox(height: 36),

          // Snapping Drag box
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center snapping target zone
                  Positioned(
                    top: 100,
                    child: Container(
                      width: 160,
                      height: 80,
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: _isSnapped ? 0.25 : 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isSnapped ? secondaryColor : borderCol,
                          style: _isSnapped ? BorderStyle.solid : BorderStyle.solid,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _isSnapped ? 'SUCCESS!' : 'SNAP ZONE',
                          style: GoogleFonts.plusJakartaSans(
                            color: _isSnapped ? secondaryColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Draggable item
                  Positioned(
                    top: 100 + _dragOffset.dy,
                    left: 80 + _dragOffset.dx,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _dragOffset += details.delta;
                          // Snap logic threshold
                          final double snapTargetY = 0;
                          final double snapTargetX = 40; // Relative offsets
                          if ((_dragOffset.dy - snapTargetY).abs() < 24 && (_dragOffset.dx - snapTargetX).abs() < 40) {
                            _dragOffset = const Offset(40, 0);
                            _isSnapped = true;
                          } else {
                            _isSnapped = false;
                          }
                        });
                      },
                      onPanEnd: (details) {
                        if (!_isSnapped) {
                          setState(() {
                            _dragOffset = const Offset(0, 120); // Reset to base
                          });
                        }
                      },
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor),
                          boxShadow: [
                            BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 10)
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.flight_takeoff, color: Colors.purpleAccent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tokyo Arrival',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 11, color: textPrimary),
                                  ),
                                  Text('14:30 JST', style: GoogleFonts.inter(fontSize: 8.5, color: textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.drag_indicator, color: Colors.grey, size: 14),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info success shimmers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Friendship Restored 🌈',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                      ),
                      Text(
                        'Payment success state displays with simulated shimmers.',
                        style: GoogleFonts.inter(fontSize: 10.5, color: textSecondary),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- TAB 4: VELOCITY & EASING ---
  Widget _buildEasingRulesTab(
    bool isDark,
    Color surfaceColor,
    Color borderCol,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Motion Language: The Soul of the Squad',
            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Cinematic. • Fluid. • Chaotic.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: textSecondary),
          ),
          const SizedBox(height: 24),

          _buildCurveCard('Fluid Momentum 🛼', 'cubic-bezier(0.4, 0.0, 0.2, 1)', 'Standard soft easing for sliding panels.', surfaceColor, borderCol, textPrimary, textSecondary),
          _buildCurveCard('Instant Snapping ⚡', 'cubic-bezier(0.0, 0.0, 0.2, 1)', 'High speed deceleration for lists docking.', surfaceColor, borderCol, textPrimary, textSecondary),
          _buildCurveCard('Chaotic Bounce 🤸🏼‍♂️', 'spring(mass: 1, stiffness: 180, damping: 12)', 'Playful bounce curves for reactions overlays.', surfaceColor, borderCol, textPrimary, textSecondary),

          const SizedBox(height: 36),

          // Speed statistics details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Velocity Threshold',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                ),
                Text(
                  '1200px/s',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: primaryColor),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- HELPERS TAB ---
  Widget _buildSpecDetail(String title, String desc, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 11.5, color: textPrimary)),
          const SizedBox(height: 2),
          Text(desc, style: GoogleFonts.inter(fontSize: 9.5, color: textSecondary, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildCurveCard(String title, String formula, String desc, Color surfaceColor, Color borderCol, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5, color: textPrimary)),
                  const SizedBox(height: 2),
                  Text(formula, style: GoogleFonts.outfit(fontSize: 10, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: GoogleFonts.inter(fontSize: 11, color: textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.speed, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
