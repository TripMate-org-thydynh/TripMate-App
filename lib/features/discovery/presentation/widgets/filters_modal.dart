import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class FiltersModal extends StatefulWidget {
  final bool isDarkMode;
  final Function(Map<String, dynamic> filters) onApply;

  const FiltersModal({
    super.key,
    required this.isDarkMode,
    required this.onApply,
  });

  @override
  State<FiltersModal> createState() => _FiltersModalState();
}

class _FiltersModalState extends State<FiltersModal> with SingleTickerProviderStateMixin {
  String _selectedVibe = 'Chill';
  double _damageIndex = 1.0; // 0: Broke Student, 1: Balanced, 2: Luxury Chaos
  double _radiusIndex = 1.0; // 0: Walkable, 1: Nearby, 2: Roadtrip-worthy

  bool _isAnalyzing = false;
  late AnimationController _pulseController;

  final List<Map<String, String>> _vibes = [
    {'name': 'Chill', 'emoji': '🌿'},
    {'name': 'Chaos', 'emoji': '🔥'},
    {'name': 'Aesthetic', 'emoji': '📸'},
    {'name': 'Foodie', 'emoji': '🍜'},
    {'name': 'Nature', 'emoji': '🏕'},
    {'name': 'Nightlife', 'emoji': '🌃'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerApply() {
    setState(() {
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        widget.onApply({
          'vibe': _selectedVibe,
          'damage': _damageIndex,
          'radius': _radiusIndex,
        });
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFCFAF6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _isAnalyzing
              ? _buildVibeMeterLoader(primaryColor, secondaryColor)
              : _buildFiltersForm(theme, colorScheme, primaryColor, secondaryColor, isDark),
        ),
      ),
    );
  }

  Widget _buildVibeMeterLoader(Color primaryColor, Color secondaryColor) {
    return Column(
      key: const ValueKey('loader'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [primaryColor, secondaryColor, primaryColor],
                  transform: GradientRotation(_pulseController.value * 2 * 3.1415),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFCFAF6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Text(
          'discovery.vibe_meter'.tr(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'finding your squad\'s energy...',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFiltersForm(
    ThemeData theme,
    ColorScheme colorScheme,
    Color primaryColor,
    Color secondaryColor,
    bool isDark,
  ) {
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'discovery.filter_chaos'.tr(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Vibe Grid
        Text(
          'discovery.vibe_label'.tr(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _vibes.map((vibe) {
            final isSelected = _selectedVibe == vibe['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVibe = vibe['name']!;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.15)
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.1),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vibe['emoji']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      vibe['name']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Damage Slider (Cost)
        Text(
          'discovery.damage_label'.tr(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: secondaryColor,
            inactiveTrackColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            thumbColor: secondaryColor,
            overlayColor: secondaryColor.withValues(alpha: 0.2),
            valueIndicatorColor: secondaryColor,
            showValueIndicator: ShowValueIndicator.onDrag,
          ),
          child: Slider(
            value: _damageIndex,
            min: 0.0,
            max: 2.0,
            divisions: 2,
            onChanged: (val) {
              setState(() {
                _damageIndex = val;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSliderLabel('discovery.damage_broke'.tr(), _damageIndex == 0.0, primaryColor, isDark),
              _buildSliderLabel('discovery.damage_balanced'.tr(), _damageIndex == 1.0, primaryColor, isDark),
              _buildSliderLabel('discovery.damage_luxury'.tr(), _damageIndex == 2.0, primaryColor, isDark),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Radius Slider
        Text(
          'discovery.radius_label'.tr(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: primaryColor,
            inactiveTrackColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            thumbColor: primaryColor,
            overlayColor: primaryColor.withValues(alpha: 0.2),
            valueIndicatorColor: primaryColor,
            showValueIndicator: ShowValueIndicator.onDrag,
          ),
          child: Slider(
            value: _radiusIndex,
            min: 0.0,
            max: 2.0,
            divisions: 2,
            onChanged: (val) {
              setState(() {
                _radiusIndex = val;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSliderLabel('discovery.radius_walk'.tr(), _radiusIndex == 0.0, primaryColor, isDark),
              _buildSliderLabel('discovery.radius_nearby'.tr(), _radiusIndex == 1.0, primaryColor, isDark),
              _buildSliderLabel('discovery.radius_roadtrip'.tr(), _radiusIndex == 2.0, primaryColor, isDark),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Apply Vibe Trigger Button
        GestureDetector(
          onTap: _triggerApply,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'discovery.apply_filters'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderLabel(String text, bool isActive, Color activeColor, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        color: isActive
            ? activeColor
            : (isDark ? Colors.white38 : Colors.black38),
      ),
    );
  }
}
