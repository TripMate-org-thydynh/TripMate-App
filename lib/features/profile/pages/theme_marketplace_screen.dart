import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_preview_screen.dart';
import '../../../core/theme/theme.dart';
import '../../../core/api_service.dart';

class ThemeMarketplaceScreen extends StatefulWidget {
  const ThemeMarketplaceScreen({super.key});

  @override
  State<ThemeMarketplaceScreen> createState() => _ThemeMarketplaceScreenState();
}

class _ThemeMarketplaceScreenState extends State<ThemeMarketplaceScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _themes = const [
    {
      'id': 'theme-1',
      'name': 'Tokyo Neon',
      'desc': 'Cyberpunk vibes for night owls.',
      'tag': 'Premium',
      'price': '500 XP',
      'gradient': [Color(0xFFFF007F), Color(0xFF00F0FF)],
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAsV3mIuZwEyG2G5czO4qHzki5pHZTpRkZbSVCMunr5zTvE5uZRmE9llK25ivjTMB2t0vyKeGK7n2ahZV0mOxljA_IcpjQJiJtGIIrvvS9c5Q9Y4vqx-0UQMflh38CHCWVtOOkTVSjKJ7Y-7FOSbYUd0be2sgMGgD7zMuYj2RW_PQlrGxQXWfGmecLUqYhRVnUBxbsITgGvy_tkMljB9Y10i02bSOJgkxZOrpl2UBKniOAa10B7fJiFab_zhM4iFldrSMHpcbKIx5aW',
    },
    {
      'id': 'theme-2',
      'name': 'Đà Lạt Mist',
      'desc': 'Soft greens & foggy mornings.',
      'tag': 'Standard',
      'price': '300 XP',
      'gradient': [Color(0xFF34D399), Color(0xFF131B2E)],
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB25fRGRahnZUdo9FqcZAql_W78jRkxvyCZXStpzZ2UXKrRH1LYdEzYU-ktFKy3QrhIV5YhoGbnhYglXx-3Ql5VsjZ1GHr0t7PKtglZjTV352szwnDH7pm0ztFoG24bs77V3jGiN1fh8a61qLfF0lwYF9kSuf5QVxxRbt5rFq_WGGTOxLrc_eQwuOmV6kYOY128HUJnQ9TwjQf-FOoHrSNP0RyU1_yEyQHqaqOSjnOnjZL_nqsdIotwrQTu6h909L75pirMpPPnJAaT',
    },
    {
      'id': 'theme-3',
      'name': 'Beach Chaos',
      'desc': 'Vibrant orange & electric cyan.',
      'tag': 'Standard',
      'price': '400 XP',
      'gradient': [Color(0xFFFB923C), Color(0xFF06B6D4)],
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBTd_kXDKHr6hHwGknehx3UfhrR2XKSB8QOxZinTer8wuc06LOGPCmFBgcQJ_GLtz-Qe_UBWFVHE6Tztp-Gcgq6iLEvPJ759s_55QVe0lMOkpzvB5E__dDScMecK-Z15yRfigSUZVson-CCtBQ6paOdu-IRB8cwSe3Uwn29A-xIDVEmS3uObwGsrTK6DWAz3-TyI0-G1IS9HfP0beZ4MbfHcrTorXA8XSZ1QZeL0t8LX7WBVnbFUQDZWzwOXVEIRbIrxuBwILGXtWMN',
    },
  ];

  List<Map<String, dynamic>> _liveThemes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fetchLiveThemes();
  }

  Future<void> _fetchLiveThemes() async {
    final response = await ApiService.get('/users/theme-marketplace');
    if (mounted) {
      if (response is List) {
        setState(() {
          _liveThemes = response.map<Map<String, dynamic>>((backendItem) {
            final localMatch = _themes.firstWhere(
              (t) => t['id'] == backendItem['id'],
              orElse: () => {
                'id': backendItem['id'],
                'name': backendItem['name'],
                'desc': 'Curated travel theme with dynamic ambiance.',
                'tag': 'Premium',
                'price': '${backendItem['priceXP']} XP',
                'gradient': [const Color(0xFFFF8A00), const Color(0xFFDA1B60)],
                'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAsV3mIuZwEyG2G5czO4qHzki5pHZTpRkZbSVCMunr5zTvE5uZRmE9llK25ivjTMB2t0vyKeGK7n2ahZV0mOxljA_IcpjQJiJtGIIrvvS9c5Q9Y4vqx-0UQMflh38CHCWVtOOkTVSjKJ7Y-7FOSbYUd0be2sgMGgD7zMuYj2RW_PQlrGxQXWfGmecLUqYhRVnUBxbsITgGvy_tkMljB9Y10i02bSOJgkxZOrpl2UBKniOAa10B7fJiFab_zhM4iFldrSMHpcbKIx5aW',
              },
            );

            return {
              ...localMatch,
              'name': backendItem['name'] ?? localMatch['name'],
              'price': '${backendItem['priceXP'] ?? 500} XP',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _liveThemes = List.from(_themes);
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Force always dark to match the premium cinematic dark onboarding screen
    final isDark = context.mounted;

    // Stitch Token Integration mapped to premium Tailwind hex color tokens
    final primaryColor = const Color(0xFFD0BCFF);
    final secondaryColor = const Color(0xFF45DFA4);
    final backgroundColor = TripMateTheme.darkBackground;
    final surfaceColor = TripMateTheme.darkSurface;
    final textPrimaryColor = TripMateTheme.darkTextPrimary;
    final textSecondaryColor = TripMateTheme.darkTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1. Ambient Background Layer (Mesh Gradients)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, -0.6),
                radius: 1.2,
                colors: [
                  Color(0x3D8B5CF6), // Soft Stitch Purple mesh glow
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, 0.2),
                radius: 1.5,
                colors: [
                  Color(0x2834D399), // Soft Stitch Mint mesh glow
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, 0.8),
                radius: 1.3,
                colors: [
                  Color(0x20FB923C), // Soft Stitch Orange mesh glow
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 2. Cinematic Karst Landscape Backdrop
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDfg2dp9ry6aHIrv4JHeegtgAeoKxtfPqfps3NrOjR23AqjuVwWWroH0bqiv280TXdhXdJ6kB0LvDLTXAHaaimh1S7KlUIhGd0KH64hjwwX15BOvanpGufgafC7FB3a5RqoRobYB_cO3EHjkZO2dKGhAbC-RiERcZrxNnY2T63yYzxFfttbVN2AoteXwtO-Ul1cg-NF51y5Dry-f1CDCxMUxXaf-iHp1Zzr49wnjlQV7lJug_glX_gJU8UFFwEFT4sSARQ-TscJrRdB',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.12),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Blurry Header Bar
              SliverAppBar(
                expandedHeight: 88.0,
                floating: false,
                pinned: true,
                backgroundColor: backgroundColor.withValues(alpha: 0.6),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(color: Colors.transparent),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: textPrimaryColor, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [primaryColor, secondaryColor],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'TripMate',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          letterSpacing: -1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 12.0),
                    child: Center(
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: textPrimaryColor.withValues(alpha: 0.12), width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAHv_wMKIY-_-fuY5MX_0fgt720aCkJF6IqOZh7Ee-UvfG2q_t_rHUFw3ufFKAIC0rW0StnBZPkR-7-WGrPMdJ-UR3mk_NJJVBa_mIyaVw2Dn6GHrVDVz7RlHlb0pv_gh816-8gkQb7udbrZwr_VdaV65AlLGb2LNEIQvk_c_soo9hGLsT4uj0TJlBAy3sLBxnNx5C9-E6quRqsjOfrouyKCo-2mqWi-ACFyUVCiyrbPAKws-vCq3rzcSLBnflNoRdcbuIns8WHFz0b',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Main Canvas
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Section
                    Text(
                      'Style Your Trip.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: textPrimaryColor,
                        shadows: isDark
                            ? [
                                Shadow(
                                  color: primaryColor.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                                Shadow(
                                  color: primaryColor.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover premium themes crafted by top vibe creators.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: textSecondaryColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Trending Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Trending Now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'See All',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const SizedBox(
                            height: 430,
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFFD0BCFF)),
                            ),
                          )
                        : SizedBox(
                            height: 430,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _liveThemes.length,
                              itemBuilder: (context, index) {
                                final item = _liveThemes[index];
                                final themeId = item['id'] as String;
                                final themeName = item['name'] as String;
                                final themeDesc = item['desc'] as String;
                                final themeTag = item['tag'] as String;
                                final themePrice = item['price'] as String;
                                final isPremium = themeTag == 'Premium';
                                final gradientColors = item['gradient'] as List<Color>;
                                final imageUrl = item['imageUrl'] as String;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: _GlassTouchCard(
                                    onTap: () {},
                                    isPremium: isPremium,
                                    primaryColor: primaryColor,
                                    textPrimaryColor: textPrimaryColor,
                                    isDark: isDark,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Mockup Image & UI preview container
                                        SizedBox(
                                          height: 220,
                                          child: Stack(
                                            children: [
                                              // Background visual network image
                                              Positioned.fill(
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Container(
                                                      color: Colors.black26,
                                                      child: const Center(child: CircularProgressIndicator()),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.black38),
                                                ),
                                              ),

                                              // Blend Overlay Gradient
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        gradientColors[0].withValues(alpha: 0.3),
                                                        gradientColors[1].withValues(alpha: 0.3)
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Dark gradient fade for text contrast - NOT const because of Colors elements
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black54,
                                                        Colors.black87,
                                                      ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Tag/Premium Badge
                                              Positioned(
                                                top: 14,
                                                right: 14,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54.withValues(alpha: 0.7),
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(
                                                      color: isPremium
                                                          ? primaryColor.withValues(alpha: 0.4)
                                                          : Colors.white24,
                                                      width: 1.2,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (isPremium) ...[
                                                        Icon(Icons.verified, color: primaryColor, size: 14),
                                                        const SizedBox(width: 4),
                                                      ],
                                                      Text(
                                                        themeTag.toUpperCase(),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w700,
                                                          letterSpacing: 1.0,
                                                          color: isPremium ? primaryColor : Colors.white70,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Mock UI preview overlays based on themeId
                                              Positioned(
                                                bottom: 16,
                                                left: 16,
                                                right: 16,
                                                child: _buildMockUiPreview(themeId, gradientColors),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Details Section
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    themeName,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: textPrimaryColor,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor.withValues(alpha: 0.08),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      themePrice,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w800,
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                themeDesc,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13.5,
                                                  color: textSecondaryColor,
                                                  height: 1.3,
                                                ),
                                              ),
                                              const SizedBox(height: 18),

                                              // CTA buttons
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => ThemePreviewScreen(
                                                              themeName: themeName,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      style: OutlinedButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        side: BorderSide(color: textPrimaryColor.withValues(alpha: 0.12)),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Xem Trước',
                                                        style: GoogleFonts.inter(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 13,
                                                          color: textPrimaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(16),
                                                        gradient: LinearGradient(
                                                          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                                                        ),
                                                        boxShadow: isPremium
                                                            ? [
                                                                BoxShadow(
                                                                  color: primaryColor.withValues(alpha: 0.35),
                                                                  blurRadius: 10,
                                                                  offset: const Offset(0, 4),
                                                                )
                                                              ]
                                                            : null,
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          final res = await ApiService.patch('/users/me', {'theme': themeId});
                                                          if (context.mounted) {
                                                            if (res != null) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text('🎉 Đã mua và áp dụng thành công theme $themeName!'),
                                                                  backgroundColor: primaryColor,
                                                                  behavior: SnackBarBehavior.floating,
                                                                ),
                                                              );
                                                            } else {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text('❌ Không thể giao dịch theme. Vui lòng kết nối server!'),
                                                                  backgroundColor: Colors.redAccent,
                                                                  behavior: SnackBarBehavior.floating,
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.transparent,
                                                          shadowColor: Colors.transparent,
                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Đổi Ngay 🚀',
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 36),

                    // Collections Grid Section
                    Text(
                      'Collections',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCollectionCard(
                      title: 'Vibe Creators',
                      subtitle: 'Curated by top influencers',
                      gradient: const [Color(0xFF8B5CF6), Color(0x008B5CF6)],
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDe7bElYKv_IFYAkEgdHHDg67c88YjI4JUUiJkdbuWEWCGSzVIMp-b9u95uNQndi_yoPqE19UT-d7rfyAzoW5u9R2mp0cNPPGiXf8NMs6CyfrVsUbr9BoTuLYFoAtJkvOcMw0XIc_Y3TSN99Y-DRCu5Lh1b3gNvN88NrMM3ase99SkmyaPsbVs9lDQnij-mGo49-B3EKgJhkzLOuizgMHJsBKEmyjpeDJz62gncToBNK_pSCSuncESFXD50meCsZ6ZL74feHdsmp0sA',
                      surfaceColor: surfaceColor,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                    ),
                    _buildCollectionCard(
                      title: 'Classic Squad',
                      subtitle: 'Nostalgic film & polaroid',
                      gradient: const [Color(0xFF34D399), Color(0x0034D399)],
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAzssXlFo6f58hzL924X1vsqxflySyEiBHCNaNYn6MpXL5vjNQhAhab3sZBthfTMmUnOJr5Nm1ZcO4isvsUQmcbBeVVBQwO8Tcim45tb7VObCLzUJIsjulWzT7PUv4G3oNoWv7TnyUdGFK3VnRfLMq6gfO4lTWU0S6acyYdAVVaWAhEzbjP_hvXkmKtklddSyrtk4NdLltGqt54C8GNPA8nhkyUYiK5ugsvAMThwXtLcIRvxApHk4jGWJdK5a2KX-KsDJ0ss4-fXrMp',
                      surfaceColor: surfaceColor,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                    ),
                    _buildCollectionCard(
                      title: 'Cyber Night',
                      subtitle: 'High-contrast dark modes',
                      gradient: const [Color(0xFFFF007F), Color(0x00FF007F)],
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBDoBZIhEqpc4_FgvCITjG6XMEyzUAfVz4owm_sXWub5SQg_RA1BOdyQcRXuGqHaFU2rmHoYZ4LR03VIUz4mgOtKNSwU5Fa_EGHT3-Cme8ymjn-kTke87p3vTuHll03Pcy_RbO9sQo8oZ3AkAjvPcG_C2x5i8Qgm5IBinXXZlRiYnhKtft4w-gEGqAWkaeoeNN_2Ni7TzFPcw9oQoZGP2OGpQ_MrUyBF1MsOvSGApGvG8ox0SBVcTfQwuCupFWjHDJ0hJAwkZ3lCe8N',
                      surfaceColor: surfaceColor,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                    ),

                    const SizedBox(height: 120), // Bottom padding for floating nav
                  ]),
                ),
              ),
            ],
          ),

          // Floating Translucent Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? secondaryColor.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
                    child: Container(
                      height: 76,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomNavItem(
                        icon: Icons.movie_filter,
                        label: 'Showcase',
                        isActive: false,
                        secondaryColor: secondaryColor,
                      ),
                      _buildBottomNavItem(
                        icon: Icons.palette,
                        label: 'Themes',
                        isActive: true,
                        secondaryColor: secondaryColor,
                      ),
                      _buildBottomNavItem(
                        icon: Icons.stadium,
                        label: 'Stickers',
                        isActive: false,
                        secondaryColor: secondaryColor,
                      ),
                      _buildBottomNavItem(
                        icon: Icons.local_mall,
                        label: 'Vault',
                        isActive: false,
                        secondaryColor: secondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }

  // Visual Mock Theme card overlay builders
  Widget _buildMockUiPreview(String id, List<Color> colors) {
    if (id == 'theme-1') {
      // Tokyo Neon pulsing preview
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.05);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top glowing chat bar mockup
              Container(
                width: 140,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: colors),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 60, height: 6, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Bottom UI container mockup
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 90, height: 8, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 6),
                        Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3))),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: colors),
                        boxShadow: [
                          BoxShadow(
                            color: colors[0].withValues(alpha: 0.6),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else if (id == 'theme-2') {
      // Đà Lạt Mist misty mockup UI
      return Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12, width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120, height: 10, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(5))),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: colors[0].withValues(alpha: 0.8)),
                const SizedBox(width: 8),
                CircleAvatar(radius: 12, backgroundColor: colors[0].withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                // BorderStyle.dashed is NOT defined in Flutter's BorderSide, use a clean solid instead
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors[0], width: 1.0),
                  ),
                  child: Center(child: Text('+', style: TextStyle(color: colors[0], fontSize: 12, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Beach Chaos rotating flight indicator preview
      return Center(
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.1415,
              child: Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: colors),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B1326),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: -_rotationController.value * 2 * 3.1415,
                      child: Icon(Icons.flight_takeoff, color: colors[0], size: 28),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildCollectionCard({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required String imageUrl,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: textPrimary.withValues(alpha: 0.08), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color secondaryColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: secondaryColor.withValues(alpha: 0.24)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: secondaryColor, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white38, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTouchCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isPremium;
  final Color primaryColor;
  final Color textPrimaryColor;
  final bool isDark;

  const _GlassTouchCard({
    required this.child,
    required this.onTap,
    required this.isPremium,
    required this.primaryColor,
    required this.textPrimaryColor,
    required this.isDark,
  });

  @override
  State<_GlassTouchCard> createState() => _GlassTouchCardState();
}

class _GlassTouchCardState extends State<_GlassTouchCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
            child: Container(
              width: 290,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: widget.isPremium
                      ? widget.primaryColor.withValues(alpha: 0.3)
                      : (widget.isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : widget.textPrimaryColor.withValues(alpha: 0.08)),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedTapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedTapButton({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedTapButton> createState() => _AnimatedTapButtonState();
}

class _AnimatedTapButtonState extends State<_AnimatedTapButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.94),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}
