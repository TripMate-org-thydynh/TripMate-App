import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../planning/presentation/pages/ai_planning_matey_screen.dart';
import '../../planning/presentation/pages/ai_weather_replanning_screen.dart';
import '../../planning/presentation/pages/squad_voting_democracy_screen.dart';
import '../../planning/presentation/pages/ai_route_optimization_screen.dart';
import '../../planning/presentation/pages/transport_planning_screen.dart';
import '../../planning/presentation/pages/squad_checklist_packing_screen.dart';
import '../../planning/presentation/pages/flight_hotel_info_screen.dart';
import '../../planning/presentation/pages/activity_detail_screen.dart';

class ItineraryScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const ItineraryScreen({
    super.key,
    this.isDarkMode = true,
    required this.onThemeToggle,
  });

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> with SingleTickerProviderStateMixin {
  int _activeDayIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _itineraryDays = [
    {
      'day': 'Day 1',
      'title': 'Arrival & Exploring Gion',
      'date': 'June 12, 2026',
      'activities': [
        {
          'time': '09:00 AM',
          'title': 'Land at Kansai Airport (KIX)',
          'location': 'KIX Terminal 1, Osaka',
          'description': 'Express train Haruka directly to Kyoto Station. Keep your digital tickets ready!',
          'icon': Icons.flight_land,
          'color': Color(0xFFE0533C),
        },
        {
          'time': '02:00 PM',
          'title': 'Check-in at Ryokan Koto',
          'location': 'Higashiyama Ward, Kyoto',
          'description': 'Traditional room with tatami mats, paper screens, and hot tub gardens.',
          'icon': Icons.hotel,
          'color': Color(0xFFEBA83A),
        },
        {
          'time': '05:30 PM',
          'title': 'Evening Walk in Gion District',
          'location': 'Gion-machi, Kyoto',
          'description': 'Spotting geiko and visiting Yasaka Shrine. Grab street food mochi on the go.',
          'icon': Icons.directions_walk,
          'color': Color(0xFF8B5CF6),
        },
      ]
    },
    {
      'day': 'Day 2',
      'title': 'Golden Pavilion & Bamboo Groves',
      'date': 'June 13, 2026',
      'activities': [
        {
          'time': '08:00 AM',
          'title': 'Kinkaku-ji (Golden Pavilion)',
          'location': 'Kita Ward, Kyoto',
          'description': 'Early morning visit to beat the crazy crowd. Peak sunshine reflection!',
          'icon': Icons.temple_hindu,
          'color': Color(0xFF06B6D4),
        },
        {
          'time': '11:30 AM',
          'title': 'Arashiyama Bamboo Forest',
          'location': 'Arashiyama, Kyoto',
          'description': 'Scenic walk through towering bamboo pathways. Super aesthetic energy.',
          'icon': Icons.park,
          'color': Colors.green,
        },
        {
          'time': '03:00 PM',
          'title': 'Tenryu-ji Zen Garden',
          'location': 'Arashiyama, Kyoto',
          'description': 'Reflective garden paths by the mountainside. Grab iced tea.',
          'icon': Icons.spa,
          'color': Colors.teal,
        },
      ]
    },
    {
      'day': 'Day 3',
      'title': 'Fushimi Inari Shrine Hike',
      'date': 'June 14, 2026',
      'activities': [
        {
          'time': '07:30 AM',
          'title': 'Fushimi Inari 10k Torii Gates',
          'location': 'Fushimi Ward, Kyoto',
          'description': 'Mountain hike through iconic vermilion shrines. Drink lots of water.',
          'icon': Icons.terrain,
          'color': Color(0xFFE0533C),
        },
        {
          'time': '01:00 PM',
          'title': 'Nishiki Market Lunch Tour',
          'location': 'Nakagyo Ward, Kyoto',
          'description': 'Street food crawling: octopus skewers, matcha mochi, fresh sashimi.',
          'icon': Icons.restaurant,
          'color': Color(0xFFEBA83A),
        },
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = widget.isDarkMode;

    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final neonAmber = const Color(0xFFFFB300);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradStart, bgGradEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header Panel (Aesthetic Brand Bar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SQUAD WORKSPACE',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: isDark ? neonCyan : theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kyoto Crew Vibe',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            color: textPrimary,
                          ),
                          onPressed: widget.onThemeToggle,
                        ),
                        const SizedBox(width: 8),
                        // Magic Build AI Trigger
                        GestureDetector(
                          onTap: () => _navigateToScreen(
                            AIPlanningMateyScreen(
                              isDarkMode: isDark,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [theme.primaryColor, neonPink],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Magic Build',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weather Alert / Replanning Trigger Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => _navigateToScreen(
                    AIWeatherReplanningScreen(
                      isDarkMode: isDark,
                      onThemeToggle: widget.onThemeToggle,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.withValues(alpha: 0.15), neonPink.withValues(alpha: 0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '☔',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rain warning on Day 1 night market!',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap to let Matey AI swap to cozy indoor vibes.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange[800]),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating Horizontal Quick Actions Panel (Module 4 Workspace Shortcuts)
              Container(
                height: 75,
                margin: const EdgeInsets.symmetric(vertical: 14),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildQuickActionItem(
                      emoji: '🗳️',
                      label: 'Squad Voting',
                      color: neonCyan,
                      screen: SquadVotingDemocracyScreen(
                        isDarkMode: isDark,
                        onThemeToggle: widget.onThemeToggle,
                      ),
                    ),
                    _buildQuickActionItem(
                      emoji: '🚀',
                      label: 'Optimize Route',
                      color: neonPink,
                      screen: AIRouteOptimizationScreen(
                        isDarkMode: isDark,
                        onThemeToggle: widget.onThemeToggle,
                      ),
                    ),
                    _buildQuickActionItem(
                      emoji: '🛵',
                      label: 'Transport Split',
                      color: neonAmber,
                      screen: TransportPlanningScreen(
                        isDarkMode: isDark,
                        onThemeToggle: widget.onThemeToggle,
                      ),
                    ),
                    _buildQuickActionItem(
                      emoji: '📦',
                      label: 'Gear Packing',
                      color: Colors.greenAccent,
                      screen: SquadChecklistPackingScreen(
                        isDarkMode: isDark,
                        onThemeToggle: widget.onThemeToggle,
                      ),
                    ),
                    _buildQuickActionItem(
                      emoji: '🎫',
                      label: 'Boarding Passes',
                      color: Colors.purpleAccent,
                      screen: FlightHotelInfoScreen(
                        isDarkMode: isDark,
                        onThemeToggle: widget.onThemeToggle,
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Day Selection bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: SizedBox(
                  height: 65,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _itineraryDays.length,
                    itemBuilder: (context, index) {
                      final dayData = _itineraryDays[index];
                      final isSelected = _activeDayIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeDayIndex = index;
                              _animController.reset();
                              _animController.forward();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 85,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor
                                  : cardBg.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : colorScheme.onSurface.withValues(alpha: 0.08),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.primaryColor.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayData['day'] as String,
                                  style: GoogleFonts.outfit(
                                    color: isSelected ? Colors.white : textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Day ${index + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Title and Date Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _itineraryDays[_activeDayIndex]['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _itineraryDays[_activeDayIndex]['date'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Timeline Body
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: (_itineraryDays[_activeDayIndex]['activities'] as List).length,
                    itemBuilder: (context, index) {
                      final activity =
                          (_itineraryDays[_activeDayIndex]['activities'] as List)[index];
                      final isLast = index ==
                          (_itineraryDays[_activeDayIndex]['activities'] as List).length - 1;

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Timeline nodes
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (activity['color'] as Color).withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: activity['color'] as Color,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Icon(
                                    activity['icon'] as IconData,
                                    color: activity['color'] as Color,
                                    size: 18,
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2.5,
                                      color: (activity['color'] as Color).withValues(alpha: 0.2),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),

                            // Clickable Activity Card Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: GestureDetector(
                                  onTap: () => _navigateToScreen(
                                    ActivityDetailScreen(
                                      isDarkMode: isDark,
                                      onThemeToggle: widget.onThemeToggle,
                                      title: activity['title'] as String,
                                      time: activity['time'] as String,
                                      location: activity['location'] as String,
                                      description: activity['description'] as String,
                                      themeColor: activity['color'] as Color,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: cardBg.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.05),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                activity['time'] as String,
                                                style: GoogleFonts.outfit(
                                                  color: activity['color'] as Color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: textSecondary.withValues(alpha: 0.4),
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            activity['title'] as String,
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            activity['description'] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: textSecondary,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required String emoji,
    required String label,
    required Color color,
    required Widget screen,
  }) {
    final isDark = widget.isDarkMode;
    return GestureDetector(
      onTap: () => _navigateToScreen(screen),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
