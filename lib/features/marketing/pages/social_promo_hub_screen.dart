import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialPromoHubScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const SocialPromoHubScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<SocialPromoHubScreen> createState() => _SocialPromoHubScreenState();
}

class _SocialPromoHubScreenState extends State<SocialPromoHubScreen> with TickerProviderStateMixin {
  late TabController _promoTabController;
  late AnimationController _floatController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _promoTabController = TabController(length: 6, vsync: this);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _promoTabController.dispose();
    _floatController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Design System Tokens matching claude.md
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C); // Electric Purple / Coral
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A); // Bright Teal / Warm Amber
    final tertiaryColor = isDark ? const Color(0xFFFB923C) : const Color(0xFF8B5CF6); // Orange / Lavender
    final bgColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6); // Obsidian / Cream
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white; // Dark Slate / White
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022); // Ice White / Charcoal
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76); // Cool Grey / Warm Slate

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [primaryColor, secondaryColor],
            ).createShader(bounds);
          },
          child: Text(
            'App Store Preview 📢',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: primaryColor,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
        bottom: TabBar(
          controller: _promoTabController,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary.withValues(alpha: 0.7),
          indicatorColor: primaryColor,
          isScrollable: true,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'Hero Intro'),
            Tab(text: 'AI Planner'),
            Tab(text: 'Expense Split'),
            Tab(text: 'Memory Wall'),
            Tab(text: 'Social Crew'),
            Tab(text: 'Ghost Cam'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Atmospheric glows
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final offset = math.sin(_floatController.value * math.pi * 2) * 15;
                return Stack(
                  children: [
                    Positioned(
                      top: -100 + offset,
                      left: -100,
                      width: 400,
                      height: 400,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -150 - offset,
                      right: -150,
                      width: 500,
                      height: 500,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor.withValues(alpha: isDark ? 0.10 : 0.05),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          TabBarView(
            controller: _promoTabController,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeroIntroTab(primaryColor, secondaryColor, tertiaryColor, bgColor, surfaceColor, textPrimary, textSecondary),
              _buildAiPlannerTab(primaryColor, secondaryColor, tertiaryColor, bgColor, surfaceColor, textPrimary, textSecondary),
              _buildExpenseSplitTab(primaryColor, secondaryColor, tertiaryColor, bgColor, surfaceColor, textPrimary, textSecondary),
              _buildMemoryWallTab(primaryColor, secondaryColor, tertiaryColor, bgColor, surfaceColor, textPrimary, textSecondary),
              _buildSocialCrewTab(primaryColor, secondaryColor, tertiaryColor, bgColor, surfaceColor, textPrimary, textSecondary),
              _buildGhostCamTab(primaryColor, secondaryColor, tertiaryColor, bgColor, surfaceColor, textPrimary, textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  // --- 1. HERO INTRO TAB ---
  Widget _buildHeroIntroTab(Color primaryColor, Color secondaryColor, Color tertiaryColor, Color bgColor, Color surfaceColor, Color textPrimary, Color textSecondary) {
    return _buildTabWrapper(
      titleLine1: 'your chaos',
      gradientText: 'squad',
      titleLine2: 'lives here.',
      subtitle: 'Where late-night plans, shared bills, and ghost moments sync in real time.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAUbrIKxHZ5duBBvjBiBDgcj41KnwLH6l5FynaHggVF1Slh8zCtUU6XHrOmAQYaEtmKQXE4tID3CmnakyR3McSLBr7uc8wveILDEWKgqCXg-c5ohUlrMb780wfE1LCHNryshQS1cpVrUHWWVEMzbB77fi4bkt-ok1sVEw6TXi9WzxdSIFkjd35HpMnIpuKU6S_-Bih4HGri6MRLVCahyApTxrUxBdHsls1vgPo0UAiQpmQu7Ddh2F7VVOok3PjQwQ-I5MHxb_dRS2sf',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      bgColor: bgColor,
      surfaceColor: surfaceColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      floatingWidgets: [
        // Star Badge
        Positioned(
          top: 10,
          left: 10,
          child: _buildStickerBadge(
            icon: Icons.stars,
            color: tertiaryColor,
            rotation: -10,
            size: 44,
          ),
        ),
        // Heart Badge
        Positioned(
          top: 80,
          right: 15,
          child: _buildStickerBadge(
            icon: Icons.favorite,
            color: primaryColor,
            rotation: 15,
            size: 50,
          ),
        ),
      ],
    );
  }

  // --- 2. AI PLANNER TAB ---
  Widget _buildAiPlannerTab(Color primaryColor, Color secondaryColor, Color tertiaryColor, Color bgColor, Color surfaceColor, Color textPrimary, Color textSecondary) {
    return _buildTabWrapper(
      titleLine1: 'AI handles the',
      gradientText: 'chaos',
      titleLine2: 'automatically.',
      subtitle: 'Get curated itineraries and custom activities matched to your squad\'s unique vibes.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDa0N5UxFWd__4Wl-4IYSW42SGuaoA57-oLn0SjodslWyr1VZa3G-FFAXYAuKu3UNZg7mG8ecxb5pQdEfxY6pak2b-7ScsqESpaltV6jO-lCT84zq-PgsEtF2rHXeIICyKrpGLP9CBOG5EHWs9DAAs3ALU--XebrRemFWoGa2dbv2mpu-ruM4mAoQXCIsAtXi4NWDdvC8jzgQAG6oLxsA229dakEvd_tTh78BFOMCHoVZWEBqiCZ6EI8ZJuOvO-LqVBdPPzzO__UPML',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      bgColor: bgColor,
      surfaceColor: surfaceColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      floatingWidgets: [
        // Sparkles Badge
        Positioned(
          top: 40,
          left: 20,
          child: _buildStickerBadge(
            icon: Icons.auto_awesome,
            color: secondaryColor,
            rotation: -15,
            size: 48,
          ),
        ),
        // Bolt Badge
        Positioned(
          bottom: 120,
          right: 20,
          child: _buildStickerBadge(
            icon: Icons.bolt,
            color: const Color(0xFFFFD700),
            rotation: 12,
            size: 46,
          ),
        ),
      ],
    );
  }

  // --- 3. EXPENSE SPLIT TAB ---
  Widget _buildExpenseSplitTab(Color primaryColor, Color secondaryColor, Color tertiaryColor, Color bgColor, Color surfaceColor, Color textPrimary, Color textSecondary) {
    return _buildTabWrapper(
      titleLine1: 'split bills without',
      gradientText: 'ruining',
      titleLine2: 'friendships.',
      subtitle: 'Instantly scan receipts, settle debts, and track group funds with total transparency.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAqp1wdOL-9MyAVGArgGRGxoT0jRUX_2n9xYcb0stB6ZZo7--WcPX_ag1RH1Oxt85Lz5f9aojjAFfgAa2LWO8sw2ZBxEF4LeSNGGhInm-MNDfXomkG8tg-qluOp9_Vl9wsXL8C5bO1J3cetyUEjwDdrgTosuamLwsya2OJR0jpVJQdsKL6AaDkWtHSzF407hmPR1TqqjIPWgd2rPj_b0B3C6MaYxMhc08YpwXG1Ah-9gAGPM9Y9MZZeS-91Qd71tfYGimSbYvP0wmzq',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      bgColor: bgColor,
      surfaceColor: surfaceColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      floatingWidgets: [
        // Money sticker
        Positioned(
          top: 30,
          left: 10,
          child: _buildEmojiSticker(
            emoji: '💸',
            rotation: -12,
            size: 38,
          ),
        ),
        // Handshake sticker
        Positioned(
          top: 100,
          right: 15,
          child: _buildEmojiSticker(
            emoji: '🤝',
            rotation: 8,
            size: 40,
          ),
        ),
      ],
    );
  }

  // --- 4. MEMORY WALL TAB ---
  Widget _buildMemoryWallTab(Color primaryColor, Color secondaryColor, Color tertiaryColor, Color bgColor, Color surfaceColor, Color textPrimary, Color textSecondary) {
    return _buildTabWrapper(
      titleLine1: 'turn trips into',
      gradientText: 'core',
      titleLine2: 'memories.',
      subtitle: 'The collaborative shared album that actually looks like a premium digital scrapbook.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCF3ynceY4x7kyGXQT-_JXbuYOc7iy4eihymie7NoLUqMXN3CAxzPhLFqJERrAusjEXSTmNP02xYgtUuj6cwBexsQRsduCO_GGcurMq8h6cIlCTSj7qcPUZNLPUEg2pIvtqz4wn47OkmJlTznb5o6R5wrDCUdjPBN6Wqske3tf07axoK9OFiOdq8Ae2rgsUoV1jnRAoS2rZIasdUaB5gZQtGb0mqNqtZSQ6YlbGG9lTQQaZy218ES95QYTSmRQRf07qdpvHKOzumPuY',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      bgColor: bgColor,
      surfaceColor: surfaceColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      floatingWidgets: [
        // Floating Polaroid Card
        Positioned(
          bottom: 20,
          left: -15,
          child: Transform.rotate(
            angle: -0.15,
            child: Container(
              padding: const EdgeInsets.all(8),
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCNm-CME_sQJBxpKfAQFzR-ThYBh6W-8iZQhn7DhJoz-nDGd3G6FqUYBMYlJptvS3wed6RXpI8XBqZ1QrADMnXgG176CQJubuExCbUho4w0159fMpo0n8zB6_CkoS0os8E-m-YRUzb1NHp8BqJSTIjgM4JPvtc94-m2e2tdF1V-_wtMqpnvlyBs5ADzL9r5HIbN_9Wz4aS-DMP6sHuzm_5vd3vjCg0Dzfeye1raYkdHUqcM1P9fniPuu1xO-Am6QSn3ibsBacewvsbF',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ibiza \'23 🌴',
                    style: GoogleFonts.caveat(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 5. SOCIAL CREW TAB ---
  Widget _buildSocialCrewTab(Color primaryColor, Color secondaryColor, Color tertiaryColor, Color bgColor, Color surfaceColor, Color textPrimary, Color textSecondary) {
    return _buildTabWrapper(
      titleLine1: 'travel like your',
      gradientText: 'group chat',
      titleLine2: 'came alive.',
      subtitle: 'Connect real-time location pins, send rapid chat fires, and keep the crew sync\'d.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBr5Pobff9C9Rl1Qac2lVhy5gGGwVJSwMGuHFRwii3Vqq-Zmut-lk7hhdeLgiFvDbp2Xhw9QjClBP-0lmjnNhwo78Bif6XmojRxryDsyxB3-9jq9Ff1oQxwoziSZzEU_vGfjzktmoz1zhC0SoEQhxpGioXNCKCQ1QqZvAYxFyb-FdLynu0AkZ2c0mQ3POlISSeFLTITQCKNx55U_VgZXudBmLhATUmMb17QqxZcvudPzoDSRfbkMY2QO9YJybxqgfMc-6eNzt4rMNh4',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      bgColor: bgColor,
      surfaceColor: surfaceColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      floatingWidgets: [
        // Speech Bubble: LFG!
        Positioned(
          top: 30,
          right: -10,
          child: Transform.rotate(
            angle: 0.1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'LFG!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Live Avatar Glow
        Positioned(
          top: 100,
          left: -15,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: secondaryColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: secondaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCVAZyenHymZxfOsEjLN3WDRhzrxZaj0vliKXRXXpix91LVimaVxljCCSZIRKnK-i0Eq257ubVAO11XYhDI3NUfETt9MhAiw8Acp553pBgUEHoEI6gZOHkvIf5A20TcDsJRqHsxvpT4lClNJ-eo_1lub9EbwiMKyGjJUyiBdBL_ES3PXck54SPcGcb1u-O2Vxz5Y019O7NfAUXE8_hh8F1KrqqzVxojD8TyZS9GsqLtPCvZ9LC7FFChxqmmm-kgLFwBkCjcQIx9pJCu',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 6. GHOST CAM TAB ---
  Widget _buildGhostCamTab(Color primaryColor, Color secondaryColor, Color tertiaryColor, Color bgColor, Color surfaceColor, Color textPrimary, Color textSecondary) {
    return _buildTabWrapper(
      titleLine1: 'capture the',
      gradientText: 'chaos',
      titleLine2: 'unexpectedly.',
      subtitle: 'The shared camera that catches raw, unfiltered, candid memories automatically.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA1q4VZlHYWfUJuDPEvQdnIE4pR4pS0AKLD4J7-SKWwD4A2LYwEAgQ0YfmEopqaRysrHsMi1rjhgBOWZpWe6uWgD_IvTcmiCQMoYAphmitwb4D3QPiAbE4Cyxi9sWeAAK2ZaZ0PIB91JY2OgNv63JyOWUOZHDWw_uhoJob6c0D1Jise0o5vhQr_NSClBMTXxKmVg4Rs0Jmeqm-O9EdgUvM2QMO1QmbvbbCpxKsnMEzBRcd_xLDGOdh7qtrMt7AqJiUpYdKX4acDq_TU',
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      bgColor: bgColor,
      surfaceColor: surfaceColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      floatingWidgets: [
        // Camera Sticker
        Positioned(
          top: 30,
          right: 5,
          child: _buildStickerBadge(
            icon: Icons.photo_camera,
            color: primaryColor,
            rotation: 12,
            size: 46,
          ),
        ),
        // Live pulsing HUD
        Positioned(
          bottom: 120,
          left: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: Colors.white, size: 8),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- REUSABLE UTILITIES & WRAPPERS ---
  Widget _buildTabWrapper({
    required String titleLine1,
    required String gradientText,
    required String titleLine2,
    required String subtitle,
    required String imageUrl,
    required Color primaryColor,
    required Color secondaryColor,
    required Color tertiaryColor,
    required Color bgColor,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
    required List<Widget> floatingWidgets,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // 1. Copywriting Header
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: textPrimary,
                  ),
                  children: [
                    TextSpan(text: '$titleLine1\n'),
                    TextSpan(
                      text: '$gradientText\n',
                      style: TextStyle(
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                    ),
                    TextSpan(text: titleLine2),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 2. Main Mobile Showcase container
          Expanded(
            child: Center(
              child: SizedBox(
                width: 320,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Mockup Phone Frame (snapping float animation)
                    AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        final floatOffset = math.sin(_floatController.value * math.pi * 2) * 10;
                        return Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: Center(
                            child: Container(
                              width: 230,
                              height: 480,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: textSecondary.withValues(alpha: 0.15),
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  // Mockup screen content image
                                  Positioned.fill(
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.black,
                                        child: const Center(
                                          child: Icon(Icons.broken_image, color: Colors.white24),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Dynamic Island Notch
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width: 80,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Reflection overlay
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.05),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Floating overlays (Stars, badges, speech bubbles, polaroids)
                    ...floatingWidgets,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerBadge({
    required IconData icon,
    required Color color,
    required double rotation,
    required double size,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.cos((_floatController.value * math.pi * 2) + 0.5) * 8;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.rotate(
            angle: rotation * (math.pi / 180),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: size * 0.55,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmojiSticker({
    required String emoji,
    required double rotation,
    required double size,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.cos(_floatController.value * math.pi * 2) * 6;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.rotate(
            angle: rotation * (math.pi / 180),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: size * 0.55),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
