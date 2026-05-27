import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquadVoiceCallScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const SquadVoiceCallScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<SquadVoiceCallScreen> createState() => _SquadVoiceCallScreenState();
}

class _SquadVoiceCallScreenState extends State<SquadVoiceCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;

  bool _isMuted = false;
  bool _isVolumeHigh = true;
  int _activeNavIndex = 1; // Squads is index 1

  // Color Tokens matching chat_search_screen.dart and specs
  static const _darkBgStart = Color(0xFF0B1326);
  static const _darkBgEnd = Color(0xFF030712);
  static const _darkSurface = Color(0xFF171F33);
  static const _primaryDark = Color(0xFFD0BCFF);
  static const _secondaryDark = Color(0xFF45DFA4);
  static const _errorDark = Color(0xFFFFB4AB);

  static const _lightBgStart = Color(0xFFFCFAF6);
  static const _lightBgEnd = Color(0xFFEEF2F6);
  static const _primaryLight = Color(0xFF6D3BD7);
  static const _secondaryLight = Color(0xFF059669);
  static const _errorLight = Color(0xFFBA1A1A);

  // Active status values for the visual elements
  final List<double> _waveAmplitudes = List.generate(10, (_) => 0.0);
  late Timer _waveTimer;

  @override
  void initState() {
    super.initState();
    // Pulse animation for active speakers' avatar glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Wave animation controller for audio visualizer
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Periodic simulation of active audio wave levels
    _waveTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted) {
        setState(() {
          for (int i = 0; i < _waveAmplitudes.length; i++) {
            _waveAmplitudes[i] = math.Random().nextDouble();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _waveTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final bgStart = isDark ? _darkBgStart : _lightBgStart;
    final bgEnd = isDark ? _darkBgEnd : _lightBgEnd;
    final surface = isDark ? _darkSurface : Colors.white;
    final primary = isDark ? _primaryDark : _primaryLight;
    final secondary = isDark ? _secondaryDark : _secondaryLight;
    final error = isDark ? _errorDark : _errorLight;

    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header Bar ─────────────────────────────────────────────
              _buildHeader(isDark, textPrimary, textMuted, primary),

              const SizedBox(height: 12),

              // ── Kyoto Drift Squad Header ────────────────────────────────
              _buildSquadTitleSection(isDark, textPrimary, textMuted, primary, secondary),

              const SizedBox(height: 20),

              // ── Live Grid of Members ───────────────────────────────────
              Expanded(
                child: _buildSpeakersGrid(isDark, surface, primary, secondary, textPrimary, textMuted),
              ),

              // ── Audio Wave Visualizer Dock ─────────────────────────────
              _buildAudioVisualizerDock(isDark, surface, primary, secondary),

              const SizedBox(height: 16),

              // ── Floating Calling Controls (mic_off, volume_up, call_end) ──
              _buildCallingControls(isDark, surface, primary, error),

              const SizedBox(height: 24),

              // ── Custom Bottom Nav Bar ──────────────────────────────────
              _buildBottomNavBar(isDark, surface, primary, secondary, textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color textPrimary, Color textMuted, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // [Interactive] Text: "menu"
          IconButton(
            icon: Icon(Icons.menu_rounded, color: textPrimary, size: 24),
            onPressed: () {},
            tooltip: 'menu',
          ),
          // [h1] trip.mate
          Text(
            'trip.mate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: textPrimary,
            ),
          ),
          // Actions: Theme toggle & [Interactive] Text: "notifications"
          Row(
            children: [
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: textMuted,
                    size: 22,
                  ),
                  onPressed: widget.onThemeToggle,
                ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: textPrimary, size: 24),
                onPressed: () {},
                tooltip: 'notifications',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquadTitleSection(
      bool isDark, Color textPrimary, Color textMuted, Color primary, Color secondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [h2] Kyoto Drift Squad
              Text(
                'Kyoto Drift Squad',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // [p] sensorsLive / [span] sensors
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'sensorsLive',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '• sensors',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // [div text] group4 / [span] group
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.group_rounded, color: primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'group4',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakersGrid(
      bool isDark, Color surface, Color primary, Color secondary, Color textPrimary, Color textMuted) {
    // Kyoto Drift Squad Call Members:
    // 1. Nam Trung (Active Speaker)
    // 2. Vy (Active Speaker)
    // 3. Alex (Muted)
    // 4. Sam (Idle Speaker)

    final members = [
      {
        'name': 'Nam Trung 🎙',
        'isMuted': false,
        'isSpeaking': true,
        'avatar': 'NT',
        'avatarColor': const Color(0xFF6D3BD7),
      },
      {
        'name': 'Vy 🎙',
        'isMuted': false,
        'isSpeaking': true,
        'avatar': 'VY',
        'avatarColor': const Color(0xFFF43F5E),
      },
      {
        'name': 'Alex (Muted)',
        'isMuted': true,
        'isSpeaking': false,
        'avatar': 'AL',
        'avatarColor': const Color(0xFF0EA5E9),
      },
      {
        'name': 'Sam',
        'isMuted': false,
        'isSpeaking': false,
        'avatar': 'SM',
        'avatarColor': const Color(0xFFF59E0B),
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final isSpeaking = member['isSpeaking'] as bool && !_isMuted; // Toggle with global mute simulator
        final memberMuted = member['isMuted'] as bool || (member['name'] == 'Nam Trung 🎙' && _isMuted);

        return Stack(
          children: [
            // Speaker Card Container with high glassmorphism and blurred border
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSpeaking
                        ? secondary.withValues(alpha: isDark ? 0.08 : 0.12)
                        : surface.withValues(alpha: isDark ? 0.45 : 0.75),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSpeaking
                          ? secondary.withValues(alpha: 0.5)
                          : primary.withValues(alpha: 0.15),
                      width: isSpeaking ? 2 : 1,
                    ),
                    boxShadow: isSpeaking
                        ? [
                            BoxShadow(
                              color: secondary.withValues(alpha: 0.15),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar with speaking indicator glows
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulseValue = _pulseController.value;
                            return Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isSpeaking
                                    ? Border.all(
                                        color: secondary.withValues(
                                          alpha: (1 - pulseValue).clamp(0.0, 1.0),
                                        ),
                                        width: 3.0 + pulseValue * 6.0,
                                      )
                                    : null,
                              ),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      (member['avatarColor'] as Color),
                                      (member['avatarColor'] as Color).withValues(alpha: 0.6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (member['avatarColor'] as Color).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    member['avatar'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Member text / name tag
                      Text(
                        member['name'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Status Label / Subtext
                      Text(
                        memberMuted
                            ? 'Muted'
                            : (isSpeaking ? 'Speaking...' : 'Connected'),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: memberMuted
                              ? Colors.redAccent
                              : (isSpeaking ? secondary : textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Microphone Status Tag
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: memberMuted
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : (isSpeaking
                          ? secondary.withValues(alpha: 0.15)
                          : surface.withValues(alpha: 0.4)),
                  border: Border.all(
                    color: memberMuted
                        ? Colors.redAccent.withValues(alpha: 0.4)
                        : (isSpeaking
                            ? secondary.withValues(alpha: 0.4)
                            : primary.withValues(alpha: 0.1)),
                  ),
                ),
                child: Icon(
                  memberMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  size: 14,
                  color: memberMuted
                      ? Colors.redAccent
                      : (isSpeaking ? secondary : textPrimary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioVisualizerDock(
      bool isDark, Color surface, Color primary, Color secondary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.3 : 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Squad Chaos Frequency',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                '92% Active',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Wave bars
          SizedBox(
            height: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_waveAmplitudes.length, (index) {
                final amp = _waveAmplitudes[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 6,
                  height: 4 + (amp * 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [secondary, primary],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallingControls(bool isDark, Color surface, Color primary, Color error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Microphone Toggle (mic_off)
          _buildCircleButton(
            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            tooltip: 'mic_off',
            isColored: _isMuted,
            color: error.withValues(alpha: 0.15),
            iconColor: _isMuted ? error : (isDark ? Colors.white : Colors.black87),
            border: Border.all(color: _isMuted ? error.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
            onTap: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
          ),

          // 2. End Call (call_end)
          _buildCircleButton(
            icon: Icons.call_end_rounded,
            tooltip: 'call_end',
            isColored: true,
            color: Colors.redAccent.withValues(alpha: 0.2),
            iconColor: Colors.redAccent,
            iconSize: 28,
            width: 64,
            height: 64,
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6), width: 1.5),
            shadows: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
            onTap: () {
              Navigator.maybePop(context);
            },
          ),

          // 3. Speaker Toggle (volume_up)
          _buildCircleButton(
            icon: _isVolumeHigh ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
            tooltip: 'volume_up',
            isColored: !_isVolumeHigh,
            color: primary.withValues(alpha: 0.15),
            iconColor: isDark ? Colors.white : Colors.black87,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            onTap: () {
              setState(() {
                _isVolumeHigh = !_isVolumeHigh;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
    Color? iconColor,
    double iconSize = 24,
    double width = 56,
    double height = 56,
    BoxBorder? border,
    List<BoxShadow>? shadows,
    bool isColored = false,
  }) {
    final isDark = widget.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color ?? (isDark ? _darkSurface.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8)),
            border: border,
            boxShadow: shadows,
          ),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(
      bool isDark, Color surface, Color primary, Color secondary, Color textMuted) {
    // Bottom nav bar items mimicking:
    // [Interactive] Text: "exploreExplore"
    // [Interactive] Text: "groupSquads" (Selected)
    // [Interactive] Text: "add_circlePlan"
    // [Interactive] Text: "photo_libraryMemories"
    // [Interactive] Text: "personProfile"

    final navItems = [
      {'label': 'Explore', 'icon': Icons.explore_outlined, 'activeIcon': Icons.explore_rounded},
      {'label': 'Squads', 'icon': Icons.group_outlined, 'activeIcon': Icons.group_rounded},
      {'label': 'Plan', 'icon': Icons.add_circle_outline_rounded, 'activeIcon': Icons.add_circle_rounded},
      {'label': 'Memories', 'icon': Icons.photo_library_outlined, 'activeIcon': Icons.photo_library_rounded},
      {'label': 'Profile', 'icon': Icons.person_outline_rounded, 'activeIcon': Icons.person_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.75 : 0.85),
        border: Border(
          top: BorderSide(
            color: primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isActive = _activeNavIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeNavIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: isActive
                  ? BoxDecoration(
                      color: secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: secondary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? (item['activeIcon'] as IconData) : (item['icon'] as IconData),
                    color: isActive ? secondary : textMuted,
                    size: isActive ? 26 : 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? secondary : textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
