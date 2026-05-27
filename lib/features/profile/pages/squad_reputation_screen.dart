import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquadReputationScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const SquadReputationScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<SquadReputationScreen> createState() => _SquadReputationScreenState();
}

class _SquadReputationScreenState extends State<SquadReputationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _stats = const [
    {
      'emoji': '🌪️',
      'label': 'ChaosScore',
      'value': 0.87,
      'display': '87',
      'color': Color(0xFFFF6B6B),
    },
    {
      'emoji': '🤝',
      'label': 'TrustScore',
      'value': 0.72,
      'display': '72',
      'color': Color(0xFF45DFA4),
    },
    {
      'emoji': '⚡',
      'label': 'MemoryEnergy',
      'value': 0.94,
      'display': '94',
      'color': Color(0xFFFFD700),
    },
    {
      'emoji': '☕',
      'label': 'CafeAddiction',
      'value': 0.85,
      'display': '85',
      'color': Color(0xFFFF8C00),
    },
    {
      'emoji': '🧭',
      'label': 'LostProbability',
      'value': 0.63,
      'display': '63',
      'color': Color(0xFF64B5F6),
    },
    {
      'emoji': '💖',
      'label': 'EmotionalSupport',
      'value': 0.91,
      'display': '91',
      'color': Color(0xFFFF69B4),
    },
  ];

  final List<Map<String, dynamic>> _mvps = const [
    {
      'rank': '1',
      'title': '👑 The Boss',
      'name': 'Thảo Ly',
      'desc': 'Causes 73% of the chaos 😭',
      'color': Color(0xFFFFD700),
    },
    {
      'rank': '2',
      'title': '💰 The Bank',
      'name': 'Nam Trung',
      'desc': 'Carries the squad financially 💸',
      'color': Color(0xFFD0BCFF),
    },
    {
      'rank': '3',
      'title': '📸 Content',
      'name': 'Hải Yến',
      'desc': '10,000 photos, 0 shared 📱',
      'color': Color(0xFF45DFA4),
    },
  ];

  final List<Map<String, dynamic>> _dynamics = const [
    {
      'icon': Icons.local_cafe,
      'label': 'Over-Caffeination Risk',
      'value': 0.85,
      'display': '85%',
      'color': Color(0xFFFF8C00),
    },
    {
      'icon': Icons.map_outlined,
      'label': 'Navigation Competence',
      'value': 0.22,
      'display': '22%',
      'color': Color(0xFF64B5F6),
    },
    {
      'icon': Icons.restaurant,
      'label': 'Food Argument Potential',
      'value': 0.98,
      'display': '98%',
      'color': Color(0xFFFF6B6B),
    },
  ];

  int _selectedNavIdx = 1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF0F0FF);
    final surface = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.8);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.55);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF45DFA4).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD0BCFF).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        'trip.mate',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFD0BCFF),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onThemeToggle,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 20,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vibe Header Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF45DFA4)
                                        .withValues(alpha: isDark ? 0.12 : 0.1),
                                    const Color(0xFFD0BCFF)
                                        .withValues(alpha: isDark ? 0.1 : 0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF45DFA4)
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Minh Nhật's Vibe",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your travel reputation precedes you.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Stats Hexagon Grid
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                          children: List.generate(_stats.length, (i) {
                            final stat = _stats[i];
                            final color = stat['color'] as Color;
                            final value = stat['value'] as double;
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        stat['emoji'] as String,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                      const SizedBox(height: 6),
                                      AnimatedBuilder(
                                        animation: _pulseAnim,
                                        builder: (context, child) =>
                                            Transform.scale(
                                          scale: value > 0.8
                                              ? _pulseAnim.value
                                              : 1.0,
                                          child: child,
                                        ),
                                        child: Text(
                                          stat['display'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        stat['label'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: LinearProgressIndicator(
                                          value: value,
                                          minHeight: 3,
                                          backgroundColor: color
                                              .withValues(alpha: 0.12),
                                          valueColor:
                                              AlwaysStoppedAnimation(color),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        // AI Summary
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFD0BCFF)
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF7B2FF7),
                                          Color(0xFF45DFA4),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text('✨',
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AI Summary',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFD0BCFF),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '"Reliable for finding coffee, completely unreliable with maps. Will carry your emotional baggage."',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: textPrimary,
                                            height: 1.5,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Squad MVPs
                        Text(
                          'Squad MVPs',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ...List.generate(_mvps.length, (i) {
                          final mvp = _mvps[i];
                          final color = mvp['color'] as Color;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color.withValues(alpha: 0.15),
                                          border: Border.all(
                                            color:
                                                color.withValues(alpha: 0.4),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            mvp['rank'] as String,
                                            style:
                                                GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              mvp['title'] as String,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: color,
                                              ),
                                            ),
                                            Text(
                                              mvp['name'] as String,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: textPrimary,
                                              ),
                                            ),
                                            Text(
                                              mvp['desc'] as String,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // Group Dynamics
                        Text(
                          'Group Dynamics',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                children: List.generate(_dynamics.length, (i) {
                                  final dyn = _dynamics[i];
                                  final dynColor = dyn['color'] as Color;
                                  final isLast = i == _dynamics.length - 1;
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            dyn['icon'] as IconData,
                                            size: 18,
                                            color: dynColor,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              dyn['label'] as String,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            dyn['display'] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: dynColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: LinearProgressIndicator(
                                          value: dyn['value'] as double,
                                          minHeight: 6,
                                          backgroundColor:
                                              dynColor.withValues(alpha: 0.12),
                                          valueColor: AlwaysStoppedAnimation(
                                              dynColor),
                                        ),
                                      ),
                                      if (!isLast)
                                        const SizedBox(height: 16),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Bottom nav
                _buildBottomNav(isDark: isDark, surface: surface),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav({required bool isDark, required Color surface}) {
    final icons = [
      Icons.explore_outlined,
      Icons.group,
      Icons.add_circle,
      Icons.map_outlined,
      Icons.person_outlined,
    ];
    final labels = ['Explore', 'Squad', '', 'Map', 'Profile'];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (i) {
              final isActive = i == _selectedNavIdx;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIdx = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFF45DFA4).withValues(alpha: 0.18)
                            : Colors.transparent,
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF45DFA4)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        icons[i],
                        size: 22,
                        color: isActive
                            ? const Color(0xFF45DFA4)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                    if (labels[i].isNotEmpty)
                      Text(
                        labels[i],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isActive
                              ? const Color(0xFF45DFA4)
                              : isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.3),
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
