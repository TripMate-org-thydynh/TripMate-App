import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
class AIPlanningMateyScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AIPlanningMateyScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<AIPlanningMateyScreen> createState() => _AIPlanningMateyScreenState();
}

class _AIPlanningMateyScreenState extends State<AIPlanningMateyScreen>
    with TickerProviderStateMixin {
  bool _isGenerating = true;
  final List<String> _selectedParams = [
    '3-Day Weekend Trip',
    'Deep Chill',
    'Nature Focus',
  ];

  late AnimationController _pulseController;
  late AnimationController _glowController;

  final List<Map<String, String>> _allParams = [
    {'name': '3-Day Weekend Trip', 'emoji': '📅'},
    {'name': 'Deep Chill', 'emoji': '🌿'},
    {'name': 'High Energy', 'emoji': '🔥'},
    {'name': 'Nature Focus', 'emoji': '🏕'},
    {'name': 'City Exploration', 'emoji': '🌃'},
  ];

  final List<Map<String, dynamic>> _suggestions = [
    {
      'time': '09:00',
      'title': 'Still Cafe',
      'desc': 'Japanese-style wooden house with quiet gardens.',
      'tag': 'Coffee',
      'match': '98% Crew Match',
      'matchPct': 0.98,
    },
    {
      'time': '11:30',
      'title': 'The Hill Station',
      'desc': 'Signature cold cuts and wine with a valley view.',
      'tag': 'Brunch',
      'match': '85% Crew Match',
      'matchPct': 0.85,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _simulatePlanning();
  }

  void _simulatePlanning() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark
        ? const Color(0xFFC9B8FF)
        : const Color(0xFFF5822B);
    final secondaryColor = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFF059669);
    final bgColor = isDark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark ? Colors.white : const Color(0xFF141210);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background glow orbs
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(
                    alpha: 0.07 + 0.04 * _pulseController.value,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // CUSTOM GLASS APP BAR
                _buildAppBar(isDark, primaryColor, textPrimary, textMuted),
                const SizedBox(height: 8),

                // MAIN SCROLL BODY
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE: Matey is planning...
                          Text(
                            'Matey is planning...',
                            style: AppFonts.heading(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // TRIP INFO CARD: Đà Lạt Chill
                          _buildTripInfoCard(
                            isDark,
                            primaryColor,
                            secondaryColor,
                            cardBg,
                            textPrimary,
                            textMuted,
                          ),
                          const SizedBox(height: 24),

                          // VIBE PARAMS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Squad Vibe Parameters',
                                style: AppFonts.heading(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Editing parameters... ✏️'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Edit Parameters',
                                  style: AppFonts.heading(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _allParams.map((param) {
                              final isSelected = _selectedParams.contains(
                                param['name'],
                              );
                              return GestureDetector(
                                onTap: _isGenerating
                                    ? null
                                    : () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedParams.remove(
                                              param['name']!,
                                            );
                                          } else {
                                            _selectedParams.add(param['name']!);
                                          }
                                        });
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor.withValues(alpha: 0.12)
                                        : cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : (isDark
                                                ? Colors.white12
                                                : Colors.black12),
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: primaryColor.withValues(
                                                alpha: 0.2,
                                              ),
                                              blurRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        param['emoji']!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        param['name']!,
                                        style: AppFonts.heading(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? primaryColor
                                              : textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 28),

                          // DRAFTING SECTION
                          Row(
                            children: [
                              Text(
                                'Drafting Day 1...',
                                style: AppFonts.heading(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (_isGenerating)
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (_, child) => Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor.withValues(
                                        alpha:
                                            0.5 + 0.5 * _pulseController.value,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(
                                            alpha: 0.4 * _pulseController.value,
                                          ),
                                          blurRadius: 0,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ITINERARY ITEMS
                          ..._suggestions.asMap().entries.map((entry) {
                            return _buildTimelineItem(
                              entry.value,
                              isDark,
                              primaryColor,
                              secondaryColor,
                              cardBg,
                              textPrimary,
                              textMuted,
                              entry.key,
                            );
                          }),

                          // Third item placeholder (still loading)
                          if (_isGenerating)
                            _buildLoadingPlaceholder(
                              isDark,
                              primaryColor,
                              cardBg,
                            ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FLOATING BOTTOM ACTION
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingAction(isDark, primaryColor, secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    bool isDark,
    Color primaryColor,
    Color textPrimary,
    Color textMuted,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x800B1326) : const Color(0x9EFFFFFF),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: textPrimary,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'trip.mate',
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: primaryColor,
                  letterSpacing: -1.2,
                ),
              ),
              Icon(Icons.notifications_outlined, color: primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripInfoCard(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color textPrimary,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đà Lạt Chill',
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month, size: 14, color: textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '3-Day Weekend Trip',
                    style: AppFonts.body(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.thermostat_outlined,
                    size: 14,
                    color: Colors.amber[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '18°C',
                    style: AppFonts.body(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Vibe sliders
          _buildVibeSlider(
            'Deep Chill',
            'High Energy',
            0.25,
            primaryColor,
            textMuted,
          ),
          const SizedBox(height: 8),
          _buildVibeSlider(
            'Nature Focus',
            'City Exploration',
            0.7,
            secondaryColor,
            textMuted,
          ),

          const SizedBox(height: 14),

          // Crew match badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.green, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Crew vibe check:',
                  style: AppFonts.body(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '92% Match',
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeSlider(
    String left,
    String right,
    double value,
    Color color,
    Color textMuted,
  ) {
    return Row(
      children: [
        Text(left, style: AppFonts.body(fontSize: 11, color: textMuted)),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(right, style: AppFonts.body(fontSize: 11, color: textMuted)),
      ],
    );
  }

  Widget _buildTimelineItem(
    Map<String, dynamic> item,
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color textPrimary,
    Color textMuted,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 0),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag indicator
          Column(
            children: [
              const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
              const SizedBox(height: 4),
              // Time bubble
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['time'] as String,
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['desc'] as String,
                  style: AppFonts.body(
                    fontSize: 13,
                    color: textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['tag'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.group,
                            size: 11,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['match'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(
    bool isDark,
    Color primaryColor,
    Color cardBg,
  ) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: primaryColor.withValues(
              alpha: 0.2 + 0.2 * _pulseController.value,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(
                alpha: 0.08 * _pulseController.value,
              ),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.black12,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAction(
    bool isDark,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x800B1326) : const Color(0x9EFFFFFF),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isGenerating = !_isGenerating;
                if (!_isGenerating) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Generation stopped. You can now edit the itinerary. ✏️',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, child) => Container(
                height: 56,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                        alpha: 0.3 + 0.1 * _pulseController.value,
                      ),
                      blurRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.stop_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stop Generation & Edit',
                      style: AppFonts.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
