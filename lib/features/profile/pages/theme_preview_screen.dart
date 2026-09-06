import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ThemePreviewScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;
  final String? initialTheme;

  const ThemePreviewScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
    this.initialTheme,
  });

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _floatController;
  late Animation<double> _glowAnim;
  late Animation<double> _floatAnim;

  late PageController _pageController;
  int _selectedIdx = 0;

  final List<Map<String, dynamic>> _themes = const [
    {
      'emoji': '🌃',
      'name': 'Tokyo Neon',
      'desc':
          'Electric cyberpunk nights. Neon-soaked streets and infinite vibes.',
      'gradient': [Color(0xFF7B2FF7), Color(0xFFFF007F), Color(0xFF00F0FF)],
      'accent': Color(0xFFFF007F),
      'preview': 'Tokyo Bound ✈️',
    },
    {
      'emoji': '🌧',
      'name': 'Đà Lạt Mist',
      'desc': 'Emerald fog rolling over pine forests. Cozy highland energy.',
      'gradient': [Color(0xFF134E4A), Color(0xFF1FA85C), Color(0xFF6EE7B7)],
      'accent': Color(0xFF1FA85C),
      'preview': 'Mountain Escape 🍃',
    },
    {
      'emoji': '🏖',
      'name': 'Beach Chaos',
      'desc': 'Salt air and golden hour. Pure Gen-Z summer chaos energy.',
      'gradient': [Color(0xFFFB923C), Color(0xFF3D8BFF), Color(0xFFFF6B6B)],
      'accent': Color(0xFFFB923C),
      'preview': 'Sun & Chaos 🌊',
    },
    {
      'emoji': '📼',
      'name': 'Retro VHS',
      'desc': 'Lo-fi nostalgia. Grainy filters and late-night analog dreams.',
      'gradient': [Color(0xFF92400E), Color(0xFFF5822B), Color(0xFFD8422B)],
      'accent': Color(0xFFF5822B),
      'preview': 'Rewind Mode 📼',
    },
    {
      'emoji': '⚡',
      'name': 'Cyber Punk',
      'desc': 'Hard-edged neon and midnight chrome. The future is chaotic.',
      'gradient': [Color(0xFF141210), Color(0xFF1FA85C), Color(0xFF7B2FF7)],
      'accent': Color(0xFF1FA85C),
      'preview': 'System Override ⚡',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Find initial theme index
    int startIdx = 0;
    if (widget.initialTheme != null) {
      final idx = _themes.indexWhere((t) => t['name'] == widget.initialTheme);
      if (idx >= 0) startIdx = idx;
    }
    _selectedIdx = startIdx;

    _pageController = PageController(
      initialPage: startIdx,
      viewportFraction: 0.78,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _current => _themes[_selectedIdx];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final currentTheme = _current;
    final List<Color> grad = currentTheme['gradient'] as List<Color>;
    final Color accent = currentTheme['accent'] as Color;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    grad[0].withValues(alpha: 0.85),
                    const Color(0xFF080818),
                    grad[1].withValues(alpha: 0.3),
                  ]
                : [
                    grad[0].withValues(alpha: 0.4),
                    Colors.white,
                    grad[1].withValues(alpha: 0.25),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Ambient blobs
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (context, child) => Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: -80,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        _buildGlassButton(
                          icon: Icons.close,
                          onTap: () => Navigator.pop(context),
                          isDark: isDark,
                          color: Colors.white,
                        ),
                        const Spacer(),
                        // Theme Preview label
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              'profile.theme_preview'.tr(),
                              style: AppFonts.heading(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildGlassButton(
                          icon: isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          onTap: widget.onThemeToggle ?? () {},
                          isDark: isDark,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  // Tag line
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile.theme_tagline'.tr(),
                          style: AppFonts.body(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "choose your squad's aesthetic.",
                          style: AppFonts.heading(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mock phone preview - floating card with current theme
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _floatAnim.value * 0.4),
                        child: child,
                      ),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _themes.length,
                        onPageChanged: (idx) {
                          setState(() => _selectedIdx = idx);
                        },
                        itemBuilder: (context, idx) {
                          final theme = _themes[idx];
                          final themeGrad = theme['gradient'] as List<Color>;
                          final themeAccent = theme['accent'] as Color;
                          final isActive = idx == _selectedIdx;

                          return AnimatedScale(
                            scale: isActive ? 1.0 : 0.88,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _buildThemeCard(
                                theme: theme,
                                themeGrad: themeGrad,
                                themeAccent: themeAccent,
                                isActive: isActive,
                                isDark: isDark,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Page indicator dots
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_themes.length, (i) {
                        final isActive = i == _selectedIdx;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Bottom nav mock
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      left: 20,
                      right: 20,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Icon(Icons.flight, color: Colors.white54, size: 22),
                            Icon(
                              Icons.explore,
                              color: Colors.white54,
                              size: 22,
                            ),
                            Icon(
                              Icons.map_outlined,
                              color: Colors.white54,
                              size: 22,
                            ),
                            Icon(
                              Icons.person_outlined,
                              color: Colors.white54,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Apply button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (context, child) => Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: grad[0],
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(
                                alpha: 0.45 * _glowAnim.value,
                              ),
                              blurRadius: 0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✨ ${_current['name']} applied!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: accent,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: Center(
                              child: Text(
                                'profile.theme_apply'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildThemeCard({
    required Map<String, dynamic> theme,
    required List<Color> themeGrad,
    required Color themeAccent,
    required bool isActive,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: themeGrad[0].withValues(alpha: isActive ? 0.5 : 0.2),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: themeAccent.withValues(alpha: 0.3),
                    blurRadius: 0,
                    spreadRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme badge
              Row(
                children: [
                  Text(
                    theme['emoji'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme['name'] as String,
                          style: AppFonts.heading(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: themeAccent.withValues(alpha: 0.25),
                              border: Border.all(
                                color: themeAccent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              'profile.theme_selected'.tr(),
                              style: AppFonts.body(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: themeAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                theme['desc'] as String,
                style: AppFonts.body(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Mock UI Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    children: [
                      // Mock chat message
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: themeGrad[0],
                            ),
                            child: const Center(
                              child: Text('✈️', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  theme['preview'] as String,
                                  style: AppFonts.heading(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'profile.preview_sample_sub'.tr(),
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: themeAccent.withValues(alpha: 0.2),
                            ),
                            child: Text(
                              '+XP',
                              style: AppFonts.body(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: themeAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Mock progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: 0.72,
                          minHeight: 5,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(themeAccent),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Squad Energy 72%',
                            style: AppFonts.body(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                          Text(
                            'profile.preview_sample_badge'.tr(),
                            style: AppFonts.body(
                              fontSize: 11.5,
                              color: themeAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
