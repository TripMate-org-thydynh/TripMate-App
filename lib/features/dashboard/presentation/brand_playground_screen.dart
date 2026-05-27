import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandPlaygroundScreen extends StatefulWidget {
  const BrandPlaygroundScreen({super.key});

  @override
  State<BrandPlaygroundScreen> createState() => _BrandPlaygroundScreenState();
}

class _BrandPlaygroundScreenState extends State<BrandPlaygroundScreen> with TickerProviderStateMixin {
  int _activeTab = 0;
  
  // Custom Vibe theme variables for Theme Marketplace preview
  String _activeVibe = 'Tokyo Neon';
  Color _vibePrimary = const Color(0xFFD0BCFF);
  Color _vibeBg = const Color(0xFF0B1326);
  String _vibeFont = 'Plus Jakarta Sans';

  // Sticker tap scale controller map
  final Map<String, double> _stickerScales = {};

  final List<String> _tabs = [
    'Design Core',
    'Motion',
    'Stickers',
    'Vibe Shop',
    'Trophies'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: _activeTab == 3 ? _vibeBg : const Color(0xFF0B1326), // Dynamic background for Vibe shop
      appBar: AppBar(
        title: Text(
          'trip.mate Foundation',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Tab Selector
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = _activeTab == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeTab = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      margin: const EdgeInsets.only(right: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0x288B5CF6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0x3B8B5CF6) : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected ? const Color(0xFFD0BCFF) : Colors.white60,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.white12, height: 1),

            // Tab View Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildActiveTabBody(theme, colorScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabBody(ThemeData theme, ColorScheme colorScheme) {
    switch (_activeTab) {
      case 0:
        return _buildDesignCore(theme, colorScheme);
      case 1:
        return _buildMotionShowcase(theme, colorScheme);
      case 2:
        return _buildStickerStore(theme, colorScheme);
      case 3:
        return _buildThemeMarketplace(theme, colorScheme);
      case 4:
        return _buildBadgeCollection(theme, colorScheme);
      default:
        return const SizedBox();
    }
  }

  // --- TAB 1: DESIGN SYSTEM CORE ---
  Widget _buildDesignCore(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Color Tokens', 'Tailored HSL Gradients'),
          const SizedBox(height: 12),
          // Gradients Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            children: [
              _buildColorTokenCard('Primary (Purple)', '#8B5CF6', const Color(0xFF8B5CF6)),
              _buildColorTokenCard('Secondary (Teal)', '#45DFA4', const Color(0xFF45DFA4)),
              _buildColorTokenCard('Tertiary (Peach)', '#FFB783', const Color(0xFFFFB783)),
              _buildColorTokenCard('Obsidian (Dark)', '#0B1326', const Color(0xFF0B1326)),
            ],
          ),
          const SizedBox(height: 32),

          _buildSectionHeader('Typography System', 'Plus Jakarta Sans & Inter'),
          const SizedBox(height: 16),
          _buildTypographyRow('Display Large', 'trip.mate', 46, FontWeight.w800, true),
          _buildTypographyRow('Headline Large', 'Wanderer Escape', 30, FontWeight.bold, false),
          _buildTypographyRow('Body Medium', 'Plan chill. Chia tiền ez. Lưu moment.', 16, FontWeight.normal, false),
          _buildTypographyRow('Label Small', 'UPGRADE SQUAD', 12, FontWeight.w500, false),
          const SizedBox(height: 32),

          _buildSectionHeader('Component Playground', 'Buttons & Forms'),
          const SizedBox(height: 16),
          // Button state demonstration
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // ROUND_FULL
                    ),
                  ),
                  child: Text('ROUND_FULL Active', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF45DFA4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // ROUND_TWELVE
                    ),
                  ),
                  child: Text('ROUND_TWELVE', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF45DFA4), fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorTokenCard(String name, String hex, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(hex, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyRow(String label, String sample, double size, FontWeight weight, bool isItalic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            sample,
            style: GoogleFonts.plusJakartaSans(
              fontSize: size,
              fontWeight: weight,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: MOTION SHOWCASE ---
  Widget _buildMotionShowcase(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Motion Playground', 'Tap elements to see micro-animations'),
          const SizedBox(height: 20),

          // 1. Elastic Scaling Card
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚡ Elastic Scale Triggered!'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.95, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: _buildShowcaseCard(
                'Elastic Scale & Blur',
                'Perfect for clicking active elements.',
                const Color(0xFF8B5CF6),
                Icons.touch_app_outlined,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Glowing Pulse Box
          _buildShowcaseCard(
            'Atmospheric Glow Pulse',
            'Creates highly premium, rich Gen Z depth.',
            const Color(0xFF45DFA4),
            Icons.blur_circular,
            isGlowing: true,
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseCard(String title, String desc, Color accentColor, IconData icon, {bool isGlowing = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x13FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: STICKER STORE ---
  Widget _buildStickerStore(ThemeData theme, ColorScheme colorScheme) {
    final stickers = [
      {'name': 'Chaos King', 'emoji': '👑', 'color': const Color(0xFF8B5CF6), 'phrase': 'Makes all the rules.'},
      {'name': 'Chill Vibe', 'emoji': '🍹', 'color': const Color(0xFF45DFA4), 'phrase': 'Zero stress traveler.'},
      {'name': 'Debt Overload', 'emoji': '💸', 'color': const Color(0xFFFFB783), 'phrase': 'Owes everyone money.'},
      {'name': 'Moment Maker', 'emoji': '📸', 'color': const Color(0xFF00C6FF), 'phrase': 'Takes 1000 photos.'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Sticker Store', 'Tap stickers to send expressions!'),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: stickers.length,
              itemBuilder: (context, index) {
                final s = stickers[index];
                final name = s['name'] as String;

                return GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      _stickerScales[name] = 0.85;
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      _stickerScales[name] = 1.0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎉 Expressed: ${s['emoji']} $name!'),
                        duration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: _stickerScales[name] ?? 1.0),
                    duration: const Duration(milliseconds: 150),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0x13FFFFFF),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s['emoji'] as String, style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(name, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(s['phrase'] as String, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: THEME MARKETPLACE ---
  Widget _buildThemeMarketplace(ThemeData theme, ColorScheme colorScheme) {
    final vibes = [
      {
        'name': 'Tokyo Neon',
        'color': const Color(0xFFD0BCFF),
        'bg': const Color(0xFF0B1326),
        'font': 'Plus Jakarta Sans',
        'desc': 'Retro cyberpunk aesthetic.'
      },
      {
        'name': 'Amalfi Coast',
        'color': const Color(0xFF45DFA4),
        'bg': const Color(0xFF003825),
        'font': 'Inter',
        'desc': 'Sunny vibes and refreshing teals.'
      },
      {
        'name': 'Swiss Alps',
        'color': const Color(0xFFFFB783),
        'bg': const Color(0xFF301400),
        'font': 'Outfit',
        'desc': 'Cozy warm colors and clean snow styling.'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Theme Marketplace', 'Apply themes to test dynamic vibes!'),
          const SizedBox(height: 16),
          // Live Brand Vibe Preview Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _vibePrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _vibePrimary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE VIBE PREVIEW',
                  style: GoogleFonts.plusJakartaSans(
                    color: _vibePrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'trip.mate is currently styled in $_activeVibe mode.',
                  style: TextStyle(
                    fontFamily: _vibeFont,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: vibes.length,
              itemBuilder: (context, index) {
                final v = vibes[index];
                final isSelected = _activeVibe == v['name'];
                final accentColor = v['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeVibe = v['name'] as String;
                      _vibePrimary = accentColor;
                      _vibeBg = v['bg'] as Color;
                      _vibeFont = v['font'] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor.withValues(alpha: 0.12) : const Color(0x13FFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? accentColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v['name'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(v['desc'] as String, style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: accentColor)
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 5: BADGE COLLECTION (TRAVEL TROPHIES) ---
  Widget _buildBadgeCollection(ThemeData theme, ColorScheme colorScheme) {
    final badges = [
      {'name': 'Road Warrior', 'emoji': '🏍️', 'desc': 'Logged over 500km in a single trip.', 'glow': const Color(0xFF8B5CF6)},
      {'name': 'Budget Master', 'emoji': '📊', 'desc': 'Settled split bill debts within 24h.', 'glow': const Color(0xFF45DFA4)},
      {'name': 'Glamping Guru', 'emoji': '⛺', 'desc': 'Explored 3 different premium campsites.', 'glow': const Color(0xFFFFB783)},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Badge Trophies', 'Tap a trophy to inspect achievement!'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final b = badges[index];
                final color = b['glow'] as Color;

                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF171F33),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(b['emoji'] as String, style: const TextStyle(fontSize: 72)),
                              const SizedBox(height: 16),
                              Text(
                                b['name'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                b['desc'] as String,
                                style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text('Embrace Achievement', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x13FFFFFF),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.08),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(b['emoji'] as String, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b['name'] as String, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(b['desc'] as String, style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            color: Colors.white38,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
