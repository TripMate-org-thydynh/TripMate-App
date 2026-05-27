import '../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Existing Pages
import 'pages/launch_campaign_screen.dart';
import 'pages/investor_pitch_screen.dart';
import 'pages/product_roadmap_screen.dart';
import 'pages/team_introduction_screen.dart';
import 'pages/community_showcase_screen.dart';

// Newly added Batch 12 Screens
import 'pages/premium_landing_screen.dart';
import 'pages/case_studies_hub_screen.dart';
import 'pages/motion_breakdowns_hub_screen.dart';
import 'pages/social_promo_hub_screen.dart';
import 'pages/reputation_campaign_screen.dart';
import 'pages/launch_countdown_screen.dart';

class MarketingHubScreen extends StatefulWidget {
  const MarketingHubScreen({super.key});

  @override
  State<MarketingHubScreen> createState() => _MarketingHubScreenState();
}

class _MarketingHubScreenState extends State<MarketingHubScreen> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    
    // Brand design system tokens
    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final backgroundColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Marketing Billboard Header
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: primaryColor,
                ),
                onPressed: _toggleTheme,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Showcase & Pitch Space 🗺️',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                      ? [const Color(0xFF1E1B4B), backgroundColor]
                      : [const Color(0xFFEEF2FF), backgroundColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: -20,
                      top: 30,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -10,
                      bottom: 40,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text('📢', style: TextStyle(fontSize: 38)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Options List
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Brand intro card
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderCol(isDark, primaryColor)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'trip.mate Core Showcase 🎒',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đây là trung tâm tài nguyên marketing, giới thiệu kế hoạch kinh doanh và lộ trình phát triển sản phẩm của TripMate.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'Chiến Dịch Cao Cấp (Batch 12) 💎',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildOptionCard(
                  title: 'Premium Landing Page 🛬',
                  desc: 'Trang đáp giới thiệu Manifesto và Perks tối thượng của câu lạc bộ',
                  icon: Icons.star_purple500,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumLandingScreen(
                        isDarkMode: _isDarkMode,
                        onThemeToggle: _toggleTheme,
                      ),
                    ),
                  ),
                ),

                _buildOptionCard(
                  title: 'Product Case Study 📖',
                  desc: 'Tập hợp Case Study về Triết lý "Social Chaos" & các Cột trụ cốt lõi',
                  icon: Icons.menu_book,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaseStudiesHubScreen(
                        isDarkMode: _isDarkMode,
                        onThemeToggle: _toggleTheme,
                      ),
                    ),
                  ),
                ),

                _buildOptionCard(
                  title: 'Motion Language Showcase 🛸',
                  desc: 'Không gian trải nghiệm Kinetic Motion, Easing spring và Snapping',
                  icon: Icons.animation,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MotionBreakdownsHubScreen(
                        isDarkMode: _isDarkMode,
                        onThemeToggle: _toggleTheme,
                      ),
                    ),
                  ),
                ),

                _buildOptionCard(
                  title: 'Social Ads Space 📢',
                  desc: 'Tài nguyên quảng cáo đa nền tảng TikTok, Insta, Reels và Ghost Cam',
                  icon: Icons.video_library_outlined,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SocialPromoHubScreen(
                        isDarkMode: _isDarkMode,
                        onThemeToggle: _toggleTheme,
                      ),
                    ),
                  ),
                ),

                _buildOptionCard(
                  title: 'Campaign Chaos Squad 👑',
                  desc: 'Bình chọn Chaos King và định hình danh tiếng nhóm độc lạ',
                  icon: Icons.emoji_events_outlined,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReputationCampaignScreen(
                        isDarkMode: _isDarkMode,
                        onThemeToggle: _toggleTheme,
                      ),
                    ),
                  ),
                ),

                _buildOptionCard(
                  title: 'Launch Countdown Banner ⏳',
                  desc: 'Đếm ngược ngày phát hành kèm tiến độ hoàn tất và đăng ký Beta',
                  icon: Icons.hourglass_empty_outlined,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LaunchCountdownScreen(
                        isDarkMode: _isDarkMode,
                        onThemeToggle: _toggleTheme,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Chiến Dịch & Tài Chính Cũ 📊',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildOptionCard(
                  title: 'Launch Campaigns 🚀',
                  desc: 'Kịch bản viral, chiến dịch quảng cáo TikTok, FB Shorts',
                  icon: Icons.campaign_outlined,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LaunchCampaignScreen()),
                  ),
                ),
                _buildOptionCard(
                  title: 'Investor Pitch Visuals 📈',
                  desc: 'Chỉ số TAM, tỷ lệ giữ chân user và biểu đồ tăng trưởng 3 năm',
                  icon: Icons.bar_chart_outlined,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InvestorPitchScreen()),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Tầm Nhìn & Con Người 🧬',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildOptionCard(
                  title: 'Product Roadmap 📅',
                  desc: 'Milestones lộ trình phát triển tương lai AR Live Map, Voice AI',
                  icon: Icons.map_outlined,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductRoadmapScreen()),
                  ),
                ),
                _buildOptionCard(
                  title: 'Founders Profile 🛡️',
                  desc: 'Polaroids stack giới thiệu chân dung đội ngũ sáng lập sáng tạo',
                  icon: Icons.people_outline,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeamIntroductionScreen()),
                  ),
                ),
                _buildOptionCard(
                  title: 'Community Showcase 🌏',
                  desc: 'Bộ sưu tập ảnh check-in và ý kiến nhận xét của các elite squads',
                  icon: Icons.forum_outlined,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CommunityShowcaseScreen()),
                  ),
                ),

                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color borderCol(bool isDark, Color color) {
    return isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1);
  }

  Widget _buildOptionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color surfaceColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol(isDark, color)),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          subtitle: Text(
            desc,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey, height: 1.3),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ),
      ),
    );
  }
}
