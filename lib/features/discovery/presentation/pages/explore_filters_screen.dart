import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreFiltersScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const ExploreFiltersScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<ExploreFiltersScreen> createState() => _ExploreFiltersScreenState();
}

class _ExploreFiltersScreenState extends State<ExploreFiltersScreen> {
  final Set<String> _selectedVibes = {};
  double _budgetValue = 500000;
  double _distanceValue = 5;
  String _squadSize = '';

  // ── Color helpers ──────────────────────────────────────────────────────────
  Color get _primary =>
      widget.isDarkMode ? const Color(0xFFD0BCFF) : const Color(0xFF6D3BD7);
  Color get _secondary =>
      widget.isDarkMode ? const Color(0xFF45DFA4) : const Color(0xFF059669);
  Color get _tertiary => const Color(0xFFFFB783);
  Color get _textPrimary =>
      widget.isDarkMode ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022);
  Color get _textMuted =>
      widget.isDarkMode ? Colors.white38 : Colors.black38;
  Color get _glassBg =>
      widget.isDarkMode
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.75);
  Color get _glassBorder =>
      widget.isDarkMode
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.07);
  Color get _panelBg =>
      widget.isDarkMode ? const Color(0xFF171F33) : Colors.white;
  Color get _sectionLabelColor =>
      widget.isDarkMode ? Colors.white70 : Colors.black87;

  void _resetFilters() {
    setState(() {
      _selectedVibes.clear();
      _budgetValue = 500000;
      _distanceValue = 5;
      _squadSize = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: Stack(
        children: [
          // Backdrop blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox.expand(),
            ),
          ),

          // Bottom Sheet panel
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: _panelBg.withValues(alpha: widget.isDarkMode ? 0.92 : 0.97),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border(
              top: BorderSide(color: _glassBorder, width: 1.2),
              left: BorderSide(color: _glassBorder, width: 0.6),
              right: BorderSide(color: _glassBorder, width: 0.6),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [_primary, _secondary],
                          ).createShader(bounds),
                          child: Text(
                            'Filter the Chaos 🎛️',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _glassBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: _glassBorder),
                          ),
                          child: Icon(Icons.close, color: _textMuted, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVibeSection(),
                        const SizedBox(height: 24),
                        _buildBudgetSection(),
                        const SizedBox(height: 24),
                        _buildDistanceSection(),
                        const SizedBox(height: 24),
                        _buildSquadSizeSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom buttons
                _buildBottomButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section header helper ──────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _sectionLabelColor,
          ),
        ),
      ],
    );
  }

  // ── Section 1: Vibe ────────────────────────────────────────────────────────
  Widget _buildVibeSection() {
    final vibes = [
      '🔥 Chaos Mode',
      '☕ Chill Mode',
      '💎 Hidden Gem',
      '💸 Budget',
      '👑 Elite Squad',
      '🎭 Cultural',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('The Vibe', Icons.explore, _secondary),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vibes.map((label) {
            final isSelected = _selectedVibes.contains(label);
            return FilterChip(
              label: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? _secondary : _textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedVibes.add(label);
                  } else {
                    _selectedVibes.remove(label);
                  }
                });
              },
              selectedColor: _secondary.withValues(alpha: 0.18),
              backgroundColor: _glassBg,
              checkmarkColor: _secondary,
              side: BorderSide(
                color: isSelected
                    ? _secondary.withValues(alpha: 0.5)
                    : _glassBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Section 2: Budget ──────────────────────────────────────────────────────
  Widget _buildBudgetSection() {
    final quickBudgets = <String, double>{
      '< 200k': 200000,
      '200–500k': 350000,
      '500k–1M': 750000,
      '1M+': 1500000,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Budget Range', Icons.attach_money, _secondary),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(_budgetValue / 1000).round()}k VND',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _secondary,
              ),
            ),
            Text(
              'max budget',
              style: GoogleFonts.inter(fontSize: 12, color: _textMuted),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _secondary,
            thumbColor: _secondary,
            inactiveTrackColor: _secondary.withValues(alpha: 0.2),
            overlayColor: _secondary.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: _budgetValue,
            min: 0,
            max: 5000000,
            divisions: 50,
            onChanged: (v) => setState(() => _budgetValue = v),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: quickBudgets.entries.map((entry) {
            final isActive =
                (_budgetValue - entry.value).abs() < 50000;
            return GestureDetector(
              onTap: () => setState(() => _budgetValue = entry.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? _secondary.withValues(alpha: 0.18)
                      : _glassBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? _secondary.withValues(alpha: 0.5)
                        : _glassBorder,
                  ),
                ),
                child: Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? _secondary : _textMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Section 3: Distance ────────────────────────────────────────────────────
  Widget _buildDistanceSection() {
    final quickDistances = <String, double>{
      '<1km': 1,
      '<5km': 5,
      '<10km': 10,
      'Anywhere': 50,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Distance', Icons.my_location, _primary),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_distanceValue.round()} km',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
            Text(
              'radius',
              style: GoogleFonts.inter(fontSize: 12, color: _textMuted),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _primary,
            thumbColor: _primary,
            inactiveTrackColor: _primary.withValues(alpha: 0.2),
            overlayColor: _primary.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: _distanceValue,
            min: 0,
            max: 50,
            divisions: 50,
            onChanged: (v) => setState(() => _distanceValue = v),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: quickDistances.entries.map((entry) {
            final isActive = (_distanceValue - entry.value).abs() < 0.5;
            return GestureDetector(
              onTap: () => setState(() => _distanceValue = entry.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? _primary.withValues(alpha: 0.15)
                      : _glassBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? _primary.withValues(alpha: 0.5)
                        : _glassBorder,
                  ),
                ),
                child: Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? _primary : _textMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Section 4: Squad Size ──────────────────────────────────────────────────
  Widget _buildSquadSizeSection() {
    final sizes = ['Solo', 'Duo 👫', 'Small Squad (3-5)', 'Full Chaos (6+)'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Squad Size', Icons.group, _tertiary),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sizes.map((size) {
            final isSelected = _squadSize == size;
            return GestureDetector(
              onTap: () => setState(
                () => _squadSize = isSelected ? '' : size,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _tertiary.withValues(alpha: 0.18)
                      : _glassBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _tertiary.withValues(alpha: 0.55)
                        : _glassBorder,
                  ),
                ),
                child: Text(
                  size,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? _tertiary : _textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Bottom Buttons ─────────────────────────────────────────────────────────
  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show Results
          Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_secondary, _primary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _secondary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Showing filtered results! 🔍✨'
                      '${_selectedVibes.isNotEmpty ? " Vibes: ${_selectedVibes.length}" : ""}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text(
                'Show Results',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Reset
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Reset',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
