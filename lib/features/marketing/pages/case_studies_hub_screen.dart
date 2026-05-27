import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseStudiesHubScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const CaseStudiesHubScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<CaseStudiesHubScreen> createState() => _CaseStudiesHubScreenState();
}

class _CaseStudiesHubScreenState extends State<CaseStudiesHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final bgColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Case Study 📖',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: textPrimary,
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
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: textSecondary,
          indicatorColor: primaryColor,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: '1. Brand Strategy'),
            Tab(text: '2. Design System'),
            Tab(text: '3. Core Pillars'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildBrandStrategyTab(isDark, surfaceColor, borderCol, primaryColor, secondaryColor, textPrimary, textSecondary),
          _buildDesignSystemTab(isDark, surfaceColor, borderCol, primaryColor, secondaryColor, textPrimary, textSecondary),
          _buildCorePillarsTab(isDark, surfaceColor, borderCol, primaryColor, secondaryColor, textPrimary, textSecondary),
        ],
      ),
    );
  }

  // --- TAB 1: BRAND STRATEGY ---
  Widget _buildBrandStrategyTab(
    bool isDark,
    Color surfaceColor,
    Color borderCol,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Case Study // Part 1',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Travel like your group chat came alive.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Modern group travel isn't a linear process; it's a messy, high-energy collision of ideas, budgets, and wildly different aesthetics. Traditional tools force a sterile structure onto this organic chaos.\n\ntrip.mate embraces the noise. We designed an interface that feels less like a spreadsheet and more like a late-night brainstorming session in a vibrant digital clubhouse.",
            style: GoogleFonts.inter(fontSize: 13.5, color: textSecondary, height: 1.55),
          ),
          const SizedBox(height: 32),

          // Comparison matrix card
          Text(
            'THE FRICTION VS THE FLOW',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              children: [
                _buildComparisonRow(
                  Icons.warning,
                  'The Group chat trap 💀',
                  'Scattered bookings, forgotten bills, endless scrolling to find spots.',
                  Colors.orangeAccent,
                  textPrimary,
                  textSecondary,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: Colors.white10),
                ),
                _buildComparisonRow(
                  Icons.bolt,
                  'The trip.mate Flow ✨',
                  'One master workspace, instant fintech split, interactive maps and recaps.',
                  secondaryColor,
                  textPrimary,
                  textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // User Archetypes Section
          Text(
            'ARCHITECTS OF THE VIBE 🧬',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),

          // Archetype 1
          _buildArchetypeCard(
            'Primary Archetype',
            'The Chaos Coordinator 👑',
            '"If I don\'t book it, we\'re sleeping on the street."',
            'Needs control mechanisms disguised as fun polls. Clear visibility into who hasn\'t paid.',
            primaryColor,
            surfaceColor,
            borderCol,
            textPrimary,
            textSecondary,
          ),
          const SizedBox(height: 12),

          // Archetype 2
          _buildArchetypeCard(
            'Secondary Archetype',
            'The Vibe Curator 📸',
            '"I found this hidden speakeasy on TikTok."',
            'A canvas to drop aesthetic links. Low-friction ways to suggest ideas without committing to logistics.',
            secondaryColor,
            surfaceColor,
            borderCol,
            textPrimary,
            textSecondary,
          ),
        ],
      ),
    );
  }

  // --- TAB 2: DESIGN & MOTION ---
  Widget _buildDesignSystemTab(
    bool isDark,
    Color surfaceColor,
    Color borderCol,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Design & Motion System',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Part 2: Architecting the Luminous Social Travel experience. A deep dive into the UX strategy, design tokens, and kinetic motion models that drive trip.mate.',
            style: GoogleFonts.inter(fontSize: 13.5, color: textSecondary, height: 1.45),
          ),
          const SizedBox(height: 28),

          // 05. UX Strategy
          Text(
            '05. UX STRATEGY & VIRAL LOOP',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          _buildStepCard('1', 'Spontaneous Creation 🪄', 'Frictionless trip initiation using single-tap templates and AI-driven suggestions to overcome the "blank canvas" paralysis.', surfaceColor, borderCol, textPrimary, textSecondary),
          _buildStepCard('2', 'The Social Invite Loop 💌', 'Sharing a highly visual, animated invite card via iMessage/Snapchat. The aesthetic drives FOMO and immediate opt-in.', surfaceColor, borderCol, textPrimary, textSecondary),
          _buildStepCard('3', 'Chaotic Collaboration ⚡', 'Real-time upvoting, dynamic itinerary shifts, and shared expenses happening concurrently in a gamified environment.', surfaceColor, borderCol, textPrimary, textSecondary),

          const SizedBox(height: 32),

          // Interactive journey mockup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Icon(Icons.account_tree, color: secondaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interactive Flow Diagram',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5, color: textPrimary),
                      ),
                      Text(
                        'Mapping the user journey from zero to confirmed itinerary.',
                        style: GoogleFonts.inter(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Motion Language
          Text(
            '06. DESIGN & MOTION PRINCIPLES 🧬',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrincipleRow('Emotional 🪐', 'Travel is a feeling. We use high-saturation gradients and atmospheric blurs to evoke anticipation.', textPrimary, textSecondary),
                const SizedBox(height: 16),
                _buildPrincipleRow('Addictive ⚡', 'Micro-interactions and haptic feedback loops make planning feel less like a chore and more like a game.', textPrimary, textSecondary),
                const SizedBox(height: 16),
                _buildPrincipleRow('Chaotic 💥', 'Embracing the messy reality of group chat planning with asymmetric layouts and overlapping elements.', textPrimary, textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- TAB 3: FEATURES SHOWCASE ---
  Widget _buildCorePillarsTab(
    bool isDark,
    Color surfaceColor,
    Color borderCol,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Four Pillars of Chaos Control.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'An interconnected map of features designed to handle the beautiful mess of group travel, ensuring no detail is lost in the group chat.',
            style: GoogleFonts.inter(fontSize: 13.5, color: textSecondary, height: 1.45),
          ),
          const SizedBox(height: 24),

          // Grid Pillars list
          _buildPillarCard(Icons.explore_outlined, 'Explore & Plan', 'Collaborative moodboards and AI-driven itinerary suggestions that vibe-match your crew.', primaryColor, surfaceColor, borderCol, textPrimary, textSecondary),
          const SizedBox(height: 12),
          _buildPillarCard(Icons.account_balance_wallet_outlined, 'Split & Settle', 'Fintech-grade expense splitting masked as a game. Never argue about who bought the rounds again.', secondaryColor, surfaceColor, borderCol, textPrimary, textSecondary),
          const SizedBox(height: 12),
          _buildPillarCard(Icons.chat_bubble_outline, 'Contextual Chat', 'Threaded conversations tied directly to specific itinerary items or expenses. Keep the main chat clean.', primaryColor, surfaceColor, borderCol, textPrimary, textSecondary),
          const SizedBox(height: 12),
          _buildPillarCard(Icons.photo_library_outlined, 'Shared Memories', 'A persistent digital scrapbook. Everyone drops their camera roll; AI curates the highlight reel.', secondaryColor, surfaceColor, borderCol, textPrimary, textSecondary),

          const SizedBox(height: 32),

          // Companion Matey AI info
          Text(
            'INTELLIGENT COMPANIONSHIP 🤖',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withValues(alpha: 0.15), secondaryColor.withValues(alpha: 0.15)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meet Matey AI & Squad Presence',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  "We didn't just build a planner; we built a co-pilot. Matey AI reads the room, suggests compromises, and breaks ties when the group can't decide.",
                  style: GoogleFonts.inter(fontSize: 12, color: textSecondary, height: 1.45),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAlgorithmDetail('Vibe Matcher 🔮', 'Analyzes past trips and group preferences.', textPrimary, textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAlgorithmDetail('Squad Presence 👥', 'Floating indicators show active planning.', textPrimary, textSecondary),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildComparisonRow(IconData icon, String title, String desc, Color col, Color textPrimary, Color textSecondary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(shape: BoxShape.circle, color: col.withValues(alpha: 0.15)),
          child: Icon(icon, color: col, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
              const SizedBox(height: 2),
              Text(desc, style: GoogleFonts.inter(fontSize: 11.5, color: textSecondary, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArchetypeCard(
    String label,
    String title,
    String desc,
    String needs,
    Color col,
    Color surfaceColor,
    Color borderCol,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: col, letterSpacing: 1),
          ),
          const SizedBox(height: 6),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
          Text(desc, style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: textSecondary)),
          const SizedBox(height: 10),
          Text('Needs:', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: textPrimary)),
          Text(needs, style: GoogleFonts.inter(fontSize: 11, color: textSecondary, height: 1.35)),
        ],
      ),
    );
  }

  Widget _buildStepCard(String num, String title, String desc, Color surfaceColor, Color borderCol, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.indigoAccent),
              child: Center(
                child: Text(
                  num,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5, color: textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc, style: GoogleFonts.inter(fontSize: 11.5, color: textSecondary, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipleRow(String title, String desc, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: GoogleFonts.inter(fontSize: 12, color: textSecondary, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildPillarCard(
    IconData icon,
    String title,
    String desc,
    Color color,
    Color surfaceColor,
    Color borderCol,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.inter(fontSize: 12, color: textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgorithmDetail(String title, String desc, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 11.5, color: textPrimary)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.inter(fontSize: 9.5, color: textSecondary, height: 1.3)),
        ],
      ),
    );
  }
}
