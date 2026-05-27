import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/add_to_itinerary_sheet.dart';

class AIVibeMatchScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AIVibeMatchScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AIVibeMatchScreen> createState() => _AIVibeMatchScreenState();
}

class _AIVibeMatchScreenState extends State<AIVibeMatchScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String _statusMessage = 'Nam Trung is typing... 💬';
  
  late AnimationController _radialController;
  late AnimationController _meshController;
  late AnimationController _bobController;
  late AnimationController _particleController;

  final List<String> _typingSteps = [
    'Minh Nhật is mapping coordinates... 🗺️',
    'Thảo Ly is checking aesthetic ratings... 📸',
    'Nam Trung is typing... 💬',
    'Syncing squad chemistry... ⚡',
  ];
  int _currentStepIndex = 0;

  // Particle models
  final List<MatchParticle> _particles = [];

  // Floating reactions state
  final List<FloatingReactionEmoji> _activeReactions = [];
  Timer? _reactionTimer;

  @override
  void initState() {
    super.initState();
    _radialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate background particles
    final random = math.Random();
    for (int i = 0; i < 25; i++) {
      _particles.add(
        MatchParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.04 + 0.015,
          opacity: random.nextDouble() * 0.4 + 0.1,
          angle: random.nextDouble() * math.pi * 2,
        ),
      );
    }

    _simulateLoading();
  }

  void _simulateLoading() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 950));
      if (!mounted) return false;
      if (_currentStepIndex < _typingSteps.length - 1) {
        setState(() {
          _currentStepIndex++;
          _statusMessage = _typingSteps[_currentStepIndex];
        });
        return true;
      } else {
        setState(() {
          _isLoading = false;
        });
        _radialController.forward();
        _startReactionEmitter();
        return false;
      }
    });
  }

  void _startReactionEmitter() {
    final random = math.Random();
    final emojis = ['🔥', '❤️', '😂', '✨', '👍', '👀'];
    _reactionTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (random.nextDouble() > 0.45) {
        setState(() {
          _activeReactions.add(
            FloatingReactionEmoji(
              emoji: emojis[random.nextInt(emojis.length)],
              xOffset: (random.nextDouble() - 0.5) * 60, // random start horizontal jitter
              controller: AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 2500),
              )..forward().then((_) {
                  // clean up when done
                  _activeReactions.removeWhere((r) => r.emoji == emojis[random.nextInt(emojis.length)]);
                }),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _radialController.dispose();
    _meshController.dispose();
    _bobController.dispose();
    _particleController.dispose();
    _reactionTimer?.cancel();
    for (var reaction in _activeReactions) {
      reaction.controller.dispose();
    }
    super.dispose();
  }

  void _openAddToItinerary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToItinerarySheet(
        placeName: 'The Hill Station',
        placeAddress: 'Old Town, Hội An',
        isDarkMode: widget.isDarkMode,
        onAdded: (itineraryData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Successfully added to Itinerary! 🎉"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: widget.isDarkMode ? const Color(0xFF34D399) : Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1326), // Premium dark canvas
      body: Stack(
        children: [
          // 1. Mesh Breathing Ambient Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _meshController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MatchMeshPainter(progress: _meshController.value, isDarkMode: isDark),
                );
              },
            ),
          ),

          // 2. Floating Particle Backdrop
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MatchParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Custom Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26.withValues(alpha: 0.3),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
                        ),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Text(
                        'trip.mate',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.8,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance leading widget
                    ],
                  ),
                ),

                // Main Changing Canvas
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    child: _isLoading
                        ? _buildTypingView(primaryColor, secondaryColor, isDark)
                        : _buildResultsView(primaryColor, secondaryColor, isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Visual Mock Loading View
  Widget _buildTypingView(Color primaryColor, Color secondaryColor, bool isDark) {
    return Center(
      key: const ValueKey('typing_view'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Rotating breathing circular loader rings
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.12),
                        width: 12,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB783)), // Warm light indicator
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB783).withValues(alpha: 0.2),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFB783),
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 54),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black26.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.4)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'matching chemistry tags...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fullscreen Cinematic Results View
  Widget _buildResultsView(Color primaryColor, Color secondaryColor, bool isDark) {
    return Padding(
      key: const ValueKey('results_view'),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        children: [
          // 1. Interactive Matching Header (Gauge + Avatars)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fullscreen Cinematic Card visual background
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuB0YoMZ3ZBgI30lTMzDsoy25uXUOOcS8hp7Jh_gH5V8y_cMOjGQq8ikDCMXL2xlZA-Kw8wl9-jMX8KpWwdCaAfVU_1Ubxi_Icfu-MG4p9IWr9VDrh35IWf1A1pJhspj7DTvyoa6Tf5cd2z2WrNltqZkjUH4IrE_hA2lTzEeHMB9AbJtHYA2HzkcmrECmO6ay_6QRfqwlAHbtSZq1ZxdMfeq8UvQBKSGMNAZw0LXrtAbgpCYxirDwCM0zqRYry8cj9XaT4xWEsKNTqhW',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black87),
                          ),
                        ),
                        // Cinematic Dark overlay gradient
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black45,
                                  Colors.black87,
                                  Color(0xFF0B1326),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Match Gauge Overlay
                Positioned(
                  top: 36,
                  child: AnimatedBuilder(
                    animation: _radialController,
                    builder: (context, child) {
                      final progress = _radialController.value * 0.87;
                      return Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Base Meter Circle back glow
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black26.withValues(alpha: 0.35),
                              boxShadow: [
                                BoxShadow(
                                  color: secondaryColor.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // Custom Painter gauge stroke
                          CustomPaint(
                            size: const Size(116, 116),
                            painter: VisualMatchPercentPainter(
                              progress: progress,
                              strokeColor: secondaryColor,
                              backColor: Colors.white10,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '87%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: secondaryColor,
                                  letterSpacing: -1,
                                  shadows: [
                                    Shadow(
                                      color: secondaryColor.withValues(alpha: 0.8),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'SQUAD MATCH',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),

                          // Floating Squad Avatars positioned around matching gauge
                          Positioned(
                            left: -22,
                            top: 10,
                            child: _buildFloatingAvatar(
                              'Minh Nhật',
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuB60ii0WkYusRAogyP7WxQ6KtCLjpi-fZazA3b7Hw_63SE76TTaTSYBlGn5gz8shuvpPAQIiS1UiyYmdWSciccncnq4y_m76yf0y7FTRLIYWSFqV6rjgfiwk7yPJT1DP-0RIcQ92w1a_TJZ281zFnle8zoP2y4vSggh1V1sYoi_mp4oIvRRWKhZeqIQ3rx4KJ2qUyQyZPN_fPGpu7_5Uv7xWk9Msa1Q5oU5bN8eEMtm6hEIIOo4lp4ye_DjDeIhgchKeWqQODMJtOT3',
                              secondaryColor,
                              0,
                            ),
                          ),
                          Positioned(
                            right: -24,
                            top: 36,
                            child: _buildFloatingAvatar(
                              'Thảo Ly',
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuB244M5yGCCxo4CnE1QbSwnOgbUvLW0EYlAQHgrIJaM_f_Nu4zoOioIRa_1hxA549ndJTO19XGaIGmsMVvXB0qfI2kQ28fTEAlImfIqK-8BkfrCrvA2yNCnpVqf2-SXr9-knPAtaoF5QKwxyZNaeD4lf569BT6Q0m_UTmBtw1Guj-hcrK4fYFSKLtDslymGQQxRESbhDogyXt8YneAyg--MnXiqhJBPMkTnWhIvNgcEeaN34P8fdWHmc1QttIe7PZi7wg0fbzf29Wq-',
                              primaryColor,
                              1.5,
                            ),
                          ),
                          Positioned(
                            left: -12,
                            bottom: -10,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black38.withValues(alpha: 0.5),
                                border: Border.all(color: Colors.white24, width: 1.0),
                              ),
                              child: const Center(
                                child: Icon(Icons.add, color: Colors.white54, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Floating glass tags bobbing up and down
                Positioned(
                  top: 195,
                  child: AnimatedBuilder(
                    animation: _bobController,
                    builder: (context, child) {
                      final bobValue1 = math.sin(_bobController.value * math.pi * 2) * 6;
                      final bobValue2 = math.cos((_bobController.value * math.pi * 2) + 1) * 5;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: Offset(0, bobValue1),
                            child: _buildGlassChip('📸 aesthetic hidden gem'),
                          ),
                          const SizedBox(height: 8),
                          Transform.translate(
                            offset: Offset(0, bobValue2),
                            child: _buildGlassChip('🌿 chill coffee squad'),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom Content overlay details
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Header
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Old Town, Hội An',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The Hill Station',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // AI Magic Copywriter board
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withValues(alpha: 0.12),
                              secondaryColor.withValues(alpha: 0.04),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          border: const Border(
                            left: BorderSide(color: Color(0xFF8B5CF6), width: 3.5),
                          ),
                        ),
                        child: Text(
                          '"This is giving: main character Đà Lạt episode. Your squad would absolutely romanticize this cafe." ✨',
                          style: GoogleFonts.caveat(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE9DDFF),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Chat Typing indicator & Bubble emojis reactions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 48,
              child: Stack(
                children: [
                  // Nam Trung bubble typing indicator
                  Positioned(
                    left: 0,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAHv_wMKIY-_-fuY5MX_0fgt720aCkJF6IqOZh7Ee-UvfG2q_t_rHUFw3ufFKAIC0rW0StnBZPkR-7-WGrPMdJ-UR3mk_NJJVBa_mIyaVw2Dn6GHrVDVz7RlHlb0pv_gh816-8gkQb7udbrZwr_VdaV65AlLGb2LNEIQvk_c_soo9hGLsT4uj0TJlBAy3sLBxnNx5C9-E6quRqsjOfrouyKCo-2mqWi-ACFyUVCiyrbPAKws-vCq3rzcSLBnflNoRdcbuIns8WHFz0b',
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nam Trung is typing...',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating emojis reactions stacked on bottom-right
                  Positioned(
                    right: 16,
                    bottom: 0,
                    top: 0,
                    width: 80,
                    child: Stack(
                      children: _activeReactions.map((reaction) {
                        return AnimatedBuilder(
                          animation: reaction.controller,
                          builder: (context, child) {
                            final val = reaction.controller.value;
                            final yPos = (1.0 - val) * 44; // floating up
                            final scale = math.sin(val * math.pi) * 1.3; // scale up and fade
                            final opacity = (1.0 - val).clamp(0.0, 1.0);

                            return Positioned(
                              bottom: yPos,
                              left: 40 + reaction.xOffset,
                              child: Opacity(
                                opacity: opacity,
                                child: Transform.scale(
                                  scale: scale,
                                  child: Text(
                                    reaction.emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Neon Glass Controls Row (Skip, Neutral, Must-Go)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dislike/Close (Red Glow)
                _buildNeonGlassButton(
                  icon: Icons.close,
                  glowColor: const Color(0xFFFFB4AB),
                  iconColor: const Color(0xFFFFB4AB),
                  size: 60,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Skipped The Hill Station! Next gem...'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        key: const ValueKey('snack_skipped'),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 24),
                // Maybe/Neutral (Amber Glow)
                _buildNeonGlassButton(
                  icon: Icons.sentiment_neutral,
                  glowColor: const Color(0xFFFFB783),
                  iconColor: const Color(0xFFFFB783),
                  size: 52,
                  isFilled: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Added to squad maybe list! 🗳️'),
                        backgroundColor: const Color(0xFFFFB783),
                        behavior: SnackBarBehavior.floating,
                        key: const ValueKey('snack_maybe'),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                // Must-Go / Fire Location (Green Glow)
                _buildNeonGlassButton(
                  icon: Icons.local_fire_department,
                  glowColor: secondaryColor,
                  iconColor: secondaryColor,
                  size: 72,
                  onTap: _openAddToItinerary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // High aesthetics glass chip bobbing builder
  Widget _buildGlassChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // Floating squad avatars with bobbing animations
  Widget _buildFloatingAvatar(String label, String url, Color borderColor, double initialPhase) {
    return AnimatedBuilder(
      animation: _bobController,
      builder: (context, child) {
        final val = math.sin((_bobController.value * math.pi * 2) + initialPhase) * 6;
        return Transform.translate(
          offset: Offset(0, val),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(url),
              backgroundColor: Colors.transparent,
            ),
          ),
        );
      },
    );
  }

  // Glass control buttons builder
  Widget _buildNeonGlassButton({
    required IconData icon,
    required Color glowColor,
    required Color iconColor,
    required double size,
    bool isFilled = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: glowColor.withValues(alpha: 0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

// Particle Models
class MatchParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double angle;

  MatchParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
  });

  void update(double progress) {
    y -= speed * 0.005;
    x += math.sin(progress * math.pi * 4 + angle) * 0.0012;
    if (y < -0.1) y = 1.1;
    if (x < -0.1) x = 1.1;
    if (x > 1.1) x = -0.1;
  }
}

class MatchParticlePainter extends CustomPainter {
  final List<MatchParticle> particles;
  final double progress;

  MatchParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      p.update(progress);
      paint.color = Colors.white.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MatchParticlePainter oldDelegate) => true;
}

// Custom Painter matching gauge
class VisualMatchPercentPainter extends CustomPainter {
  final double progress;
  final Color strokeColor;
  final Color backColor;

  VisualMatchPercentPainter({
    required this.progress,
    required this.strokeColor,
    required this.backColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 5.0;
    final rect = const Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    final bgPaint = Paint()
      ..color = backColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, 0, 2 * 3.1415, false, bgPaint);

    final fgPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -3.1415 / 2, 2 * 3.1415 * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant VisualMatchPercentPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Background mesh gradients painter
class MatchMeshPainter extends CustomPainter {
  final double progress;
  final bool isDarkMode;

  MatchMeshPainter({required this.progress, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Glowing mesh violet center
    final center1 = Offset(
      size.width * 0.15 + math.sin(progress * math.pi * 2) * 20,
      size.height * 0.5 + math.cos(progress * math.pi * 2) * 40,
    );
    final radius1 = size.width * 0.9;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF6D3BD7).withValues(alpha: isDarkMode ? 0.16 : 0.08),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center1, radius: radius1));
    canvas.drawCircle(center1, radius1, paint);

    // Emerald center
    final center2 = Offset(
      size.width * 0.85 - math.cos(progress * math.pi * 2) * 30,
      size.height * 0.3 + math.sin(progress * math.pi * 2) * 25,
    );
    final radius2 = size.width * 0.85;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF00BD85).withValues(alpha: isDarkMode ? 0.12 : 0.06),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center2, radius: radius2));
    canvas.drawCircle(center2, radius2, paint);
  }

  @override
  bool shouldRepaint(covariant MatchMeshPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Floating emoji reaction models
class FloatingReactionEmoji {
  final String emoji;
  final double xOffset;
  final AnimationController controller;

  FloatingReactionEmoji({
    required this.emoji,
    required this.xOffset,
    required this.controller,
  });
}
