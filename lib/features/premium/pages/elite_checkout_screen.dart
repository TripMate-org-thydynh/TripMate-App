import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'premium_comparison_screen.dart';

class EliteCheckoutScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const EliteCheckoutScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<EliteCheckoutScreen> createState() => _EliteCheckoutScreenState();
}

class _EliteCheckoutScreenState extends State<EliteCheckoutScreen> {
  int _selectedTierIndex = 1; // Default to The 'Main Character'

  final List<Map<String, dynamic>> _tiers = [
    {
      'title': 'The \'Tourist\'',
      'price': 'Free',
      'desc': 'Basic planning for simple weekends.',
      'icon': Icons.beach_access_rounded,
      'color': const Color(0xFFCBC3D7),
      'features': [
        {'icon': Icons.check_circle_outline_rounded, 'text': '1 Active Trip', 'available': true},
        {'icon': Icons.check_circle_outline_rounded, 'text': 'Basic Itinerary', 'available': true},
        {'icon': Icons.cancel_outlined, 'text': 'No AI Recap', 'available': false},
      ],
    },
    {
      'title': 'The \'Main Character\'',
      'price': '\$8/mo',
      'desc': 'For the solo traveler curating immaculate vibes.',
      'icon': Icons.face_retouching_natural_rounded,
      'color': const Color(0xFFD0BCFF),
      'popular': true,
      'features': [
        {'icon': Icons.auto_awesome, 'text': '✨ AI cinematic recap', 'available': true},
        {'icon': Icons.palette_outlined, 'text': '🎨 exclusive themes', 'available': true},
        {'icon': Icons.sentiment_very_satisfied_outlined, 'text': '😭 premium stickers', 'available': true},
      ],
    },
    {
      'title': 'The \'Vibe Architect\'',
      'price': '\$15/mo',
      'desc': 'Group planning without the group chat trauma.',
      'icon': Icons.architecture_rounded,
      'color': const Color(0xFF45DFA4),
      'features': [
        {'icon': Icons.group_add_rounded, 'text': 'Up to 10 friends', 'available': true},
        {'icon': Icons.photo_library_outlined, 'text': '📸 unlimited memories', 'available': true},
        {'icon': Icons.horizontal_split_rounded, 'text': 'Bill splitting logic', 'available': true},
      ],
    },
    {
      'title': 'The \'Odyssey Director\'',
      'price': '\$29/mo',
      'desc': 'Full production studio for travel influencers.',
      'icon': Icons.movie_creation_rounded,
      'color': const Color(0xFFFFB783),
      'features': [
        {'icon': Icons.movie_outlined, 'text': '🔥 creator export tools', 'available': true},
        {'icon': Icons.four_k_rounded, 'text': '4K Video renders', 'available': true},
        {'icon': Icons.analytics_outlined, 'text': 'Engagement analytics', 'available': true},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primary = isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6D3BD7);
    final secondary = isDark ? const Color(0xFF45DFA4) : const Color(0xFF00BD85);
    final tertiary = isDark ? const Color(0xFFFFB783) : const Color(0xFFF59E0B);

    final bg = isDark ? const Color(0xFF040914) : const Color(0xFFFCFAF6);
    final cardBg = isDark ? const Color(0xFF171F33) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);
    final glassBorder = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);

    final activeTier = _tiers[_selectedTierIndex];
    final activeColor = activeTier['color'] as Color;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background soft aurora glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.3,
                  colors: isDark
                      ? [const Color(0xFF2C1B4D).withValues(alpha: 0.15), Colors.transparent]
                      : [const Color(0xFFF5EDFF).withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cardBg,
                            border: Border.all(color: glassBorder),
                          ),
                          child: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 16),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primary, secondary, tertiary],
                        ).createShader(bounds),
                        child: Text(
                          'trip.mate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (widget.onThemeToggle != null)
                            IconButton(
                              icon: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: textPrimary.withValues(alpha: 0.7),
                              ),
                              onPressed: widget.onThemeToggle,
                            ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cardBg,
                              border: Border.all(color: glassBorder),
                            ),
                            child: Icon(Icons.notifications, color: primary, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Premium access header badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: primary, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Premium Access',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: primary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'upgrade your chaos.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -1.0,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'your memories deserve premium treatment.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Pricing plan horizontal cards
                        SizedBox(
                          height: 152,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _tiers.length,
                            itemBuilder: (context, index) {
                              final tier = _tiers[index];
                              final isSelected = _selectedTierIndex == index;
                              final tierColor = tier['color'] as Color;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedTierIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? tierColor.withValues(alpha: 0.15) : cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? tierColor : glassBorder,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: tierColor.withValues(alpha: 0.25), blurRadius: 10)]
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(tier['icon'] as IconData, color: isSelected ? tierColor : textSecondary, size: 20),
                                          if (tier['popular'] == true)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: tierColor.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Popular',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.w900,
                                                  color: tierColor,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        tier['title'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        tier['price'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected ? tierColor : textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Active Tier Detail card
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: activeColor.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeTier['title'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activeTier['desc'],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(color: Colors.white10),
                              const SizedBox(height: 12),
                              // Features bullet lists
                              ...List.generate(
                                (activeTier['features'] as List).length,
                                (fIndex) {
                                  final feat = (activeTier['features'] as List)[fIndex];
                                  final isAv = feat['available'] as bool;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          feat['icon'] as IconData,
                                          color: isAv ? activeColor : textSecondary.withValues(alpha: 0.5),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          feat['text'],
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isAv ? textPrimary : textSecondary.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Bottom Actions Area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_rounded, color: secondary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '1.2M Squads Upgraded',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              colors: [primary, activeColor],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.35),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                            label: Text(
                              'Upgrade Your Chaos',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PremiumComparisonScreen(
                                  isDarkMode: widget.isDarkMode,
                                  onThemeToggle: widget.onThemeToggle,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View Premium Comparison',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, color: textPrimary, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
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
