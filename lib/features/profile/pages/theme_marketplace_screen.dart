import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../core/app_messenger.dart';
import 'theme_preview_screen.dart';
import '../../../core/api_service.dart';
import '../../../core/widgets/gen_z_widgets.dart';

class ThemeMarketplaceScreen extends StatefulWidget {
  final bool? isDarkMode;
  final VoidCallback? onThemeToggle;

  const ThemeMarketplaceScreen({
    super.key,
    this.isDarkMode,
    this.onThemeToggle,
  });

  @override
  State<ThemeMarketplaceScreen> createState() => _ThemeMarketplaceScreenState();
}

class _ThemeMarketplaceScreenState extends State<ThemeMarketplaceScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  int _activeTabIdx = 1;

  final List<Map<String, dynamic>> _stickers = const [
    {
      'id': 'sticker-1',
      'name': 'Kiếp Nạn 82 ⛈️',
      'desc': 'Chuyến đi bất ổn bão táp.',
      'price': '100 XP',
      'image': 'assets/images/sticker_kiep_nan_82.webp',
    },
    {
      'id': 'sticker-2',
      'name': 'Squad Bất Ổn 🗺️',
      'desc': 'Lạc lối cùng đồng bọn.',
      'price': '150 XP',
      'image': 'assets/images/sticker_squad_bat_on.webp',
    },
    {
      'id': 'sticker-3',
      'name': 'Overthink Packer 🧳',
      'desc': 'Xếp đồ dư thừa quá mức.',
      'price': '120 XP',
      'image': 'assets/images/sticker_overthinking_packer.webp',
    },
    {
      'id': 'sticker-4',
      'name': 'Let Him Cook 🍳',
      'desc': 'Chảo cháy trollface siêu bựa.',
      'price': '200 XP',
      'image': 'assets/images/sticker_burnt_egg.webp',
    },
    {
      'id': 'sticker-5',
      'name': 'Overthinker 🧠',
      'desc': 'Chúa tể lo âu bộ não phồng to.',
      'price': '180 XP',
      'image': 'assets/images/sticker_brain_explode.webp',
    },
    {
      'id': 'sticker-6',
      'name': 'Khóc Thét 😿',
      'desc': 'Meme mèo khóc ôm bánh mì cực bựa.',
      'price': '130 XP',
      'image': 'assets/images/sticker_sad_cat_bread.webp',
    },
    {
      'id': 'sticker-7',
      'name': 'Balo Cột Sống 🎒',
      'desc': 'Doge ngáo đeo balo khổng lồ gánh tạ.',
      'price': '140 XP',
      'image': 'assets/images/sticker_doge_backpack.webp',
    },
    {
      'id': 'sticker-8',
      'name': 'Ví Hết Cứu 💸',
      'desc': 'Ví rách bay bướm khóc ròng rã.',
      'price': '160 XP',
      'image': 'assets/images/sticker_no_money.webp',
    },
    {
      'id': 'sticker-9',
      'name': 'Tôm Flexing 💪',
      'desc': 'Tôm lực điền đeo kính mát cool ngầu.',
      'price': '220 XP',
      'image': 'assets/images/sticker_flex_shrimp.webp',
    },
    {
      'id': 'sticker-10',
      'name': 'Báo Thủ Du Lịch 🐆',
      'desc': 'Báo nhà báo bạn, báo luôn cả tour.',
      'price': '170 XP',
      'image': 'assets/images/sticker_bao_thu.webp',
    },
    {
      'id': 'sticker-11',
      'name': 'Hết Cứu / Cooked 🍚',
      'desc': 'Nồi cơm điện đầu hàng bốc khói khét.',
      'price': '190 XP',
      'image': 'assets/images/sticker_het_cuu.webp',
    },
    {
      'id': 'sticker-12',
      'name': 'Mãi Keo dính chặt 🧪',
      'desc': 'Dính keo cứng ngắc cùng bạn thân.',
      'price': '150 XP',
      'image': 'assets/images/sticker_mai_keo.webp',
    },
    {
      'id': 'sticker-13',
      'name': 'Ăn Hại Vô Cực 🍗',
      'desc': 'Lười ôm đùi gà cười ngạo nghễ.',
      'price': '110 XP',
      'image': 'assets/images/sticker_an_hai.webp',
    },
    {
      'id': 'sticker-14',
      'name': 'Đúng Nhận Sai Cãi 🔮',
      'desc': 'Bổ quả cau ra meme trollface bựa.',
      'price': '160 XP',
      'image': 'assets/images/sticker_dung_nhan_sai_cai.webp',
    },
    {
      'id': 'sticker-15',
      'name': 'Chằm Zn 😩',
      'desc': 'Viên kẽm khóc lóc trầm cảm xó tường.',
      'price': '120 XP',
      'image': 'assets/images/sticker_cham_zn.webp',
    },
    {
      'id': 'sticker-16',
      'name': 'Hảo Hán Cat 🐱',
      'desc': 'Mèo hiệp sĩ đeo kính ngầu lòi.',
      'price': '180 XP',
      'image': 'assets/images/sticker_hao_han.webp',
    },
    {
      'id': 'sticker-17',
      'name': 'Hết Nước Chấm 🌶️',
      'desc': 'Bát nước chấm rỗng tuếch thèm thuồng.',
      'price': '130 XP',
      'image': 'assets/images/sticker_het_nuoc_cham.webp',
    },
    {
      'id': 'sticker-18',
      'name': 'Ú Òa / Mono 🤡',
      'desc': 'Chú hề ú òa nhảy khỏi hộp quà.',
      'price': '140 XP',
      'image': 'assets/images/sticker_u_oa.webp',
    },
    {
      'id': 'sticker-19',
      'name': 'Cạn Lời 😐',
      'desc': 'Mặt bất lực đảo mắt khinh bỉ.',
      'price': '100 XP',
      'image': 'assets/images/sticker_can_loi.webp',
    },
  ];

  final List<Map<String, dynamic>> _themes = const [
    {
      'id': 'theme-1',
      'name': 'Tokyo Neon',
      'desc': 'Cyberpunk vibes for night owls.',
      'tag': 'Premium',
      'price': '500 XP',
      'gradient': [Color(0xFFFF007F), Color(0xFF00F0FF)],
      'imageUrl': 'assets/images/cover_theme_tokyo_neon.webp',
    },
    {
      'id': 'theme-2',
      'name': 'Đà Lạt Mist',
      'desc': 'Soft greens & foggy mornings.',
      'tag': 'Standard',
      'price': '300 XP',
      'gradient': [Color(0xFF1FA85C), Color(0xFF131B2E)],
      'imageUrl': 'assets/images/cover_theme_dalat_mist.webp',
    },
    {
      'id': 'theme-3',
      'name': 'Beach Chaos',
      'desc': 'Vibrant orange & electric cyan.',
      'tag': 'Standard',
      'price': '400 XP',
      'gradient': [Color(0xFFFB923C), Color(0xFF3D8BFF)],
      'imageUrl': 'assets/images/cover_theme_beach_chaos.webp',
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
                'imageUrl': 'assets/images/cover_theme_tokyo_neon.webp',
              },
            );

            return {
              ...localMatch,
              'name': localMatch['name'] ?? backendItem['name'],
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final paper = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;

    // Stitch Token Integration
    final primaryColor = isDark ? GenZTokens.lilac : GenZTokens.purple;
    final secondaryColor = GenZTokens.green;
    final textPrimaryColor = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondaryColor = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Neo-Brutalist AppBar
              SliverAppBar(
                expandedHeight: 88.0,
                floating: false,
                pinned: true,
                backgroundColor: bg,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(color: Colors.transparent),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bg,
                          border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: ink,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [ink, ink],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'TripMate',
                        style: AppFonts.heading(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          letterSpacing: -1.5,
                          color: ink,
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
                          border: Border.all(color: ink, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: Image.asset(
                            'assets/images/avatar_user.webp',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Main Canvas
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Hero Section
                    Text(
                      _activeTabIdx == 2 ? 'Slap Some Vibes.' : 'Style Your Trip.',
                      style: AppFonts.heading(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _activeTabIdx == 2
                          ? 'Collect chaotic stickers to style your squad chat and itinerary.'
                          : 'Discover premium themes crafted by top vibe creators.',
                      style: AppFonts.body(
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
                          _activeTabIdx == 2 ? 'Chaotic Stickers' : 'Trending Now',
                          style: AppFonts.heading(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        if (_activeTabIdx == 1)
                          GestureDetector(
                            onTap: () => showGlobalSnack(
                              'Tính năng đang được hoàn thiện 🚧',
                            ),
                            child: Text(
                              'See All',
                              style: AppFonts.body(
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
                        ? SizedBox(
                            height: 430,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          )
                        : _buildMainContent(
                            activeTabIdx: _activeTabIdx,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            textPrimaryColor: textPrimaryColor,
                            textSecondaryColor: textSecondaryColor,
                            isDark: isDark,
                            paper: paper,
                            ink: ink,
                          ),
                    const SizedBox(height: 36),

                    // Collections Grid Section
                    Text(
                      'Collections',
                      style: AppFonts.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCollectionCard(
                      title: 'Vibe Creators',
                      subtitle: 'Curated by top influencers',
                      gradient: const [Color(0xFFF5822B), Color(0x008B5CF6)],
                      imageUrl: 'assets/images/cover_collection_vibe.webp',
                      surfaceColor: paper,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                      ink: ink,
                    ),
                    _buildCollectionCard(
                      title: 'Classic Squad',
                      subtitle: 'Nostalgic film & polaroid',
                      gradient: const [Color(0xFF1FA85C), Color(0x0034D399)],
                      imageUrl: 'assets/images/cover_collection_classic.webp',
                      surfaceColor: paper,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                      ink: ink,
                    ),
                    _buildCollectionCard(
                      title: 'Cyber Night',
                      subtitle: 'High-contrast dark modes',
                      gradient: const [Color(0xFFFF007F), Color(0x00FF007F)],
                      imageUrl: 'assets/images/cover_collection_cyber.webp',
                      surfaceColor: paper,
                      textPrimary: textPrimaryColor,
                      textSecondary: textSecondaryColor,
                      ink: ink,
                    ),

                    const SizedBox(
                      height: 120,
                    ), // Bottom padding for floating nav
                  ]),
                ),
              ),
            ],
          ),

          // Floating Brutalist Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: paper,
                  border: Border.all(
                    color: ink,
                    width: GenZTokens.borderWidth,
                  ),
                  boxShadow: GenZTokens.hardShadow(ink),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 76,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBottomNavItem(
                          icon: Icons.movie_filter,
                          label: 'Showcase',
                          isActive: _activeTabIdx == 0,
                          onTap: () => setState(() => _activeTabIdx = 0),
                          secondaryColor: secondaryColor,
                          ink: ink,
                          isDark: isDark,
                        ),
                        _buildBottomNavItem(
                          icon: Icons.palette,
                          label: 'Themes',
                          isActive: _activeTabIdx == 1,
                          onTap: () => setState(() => _activeTabIdx = 1),
                          secondaryColor: secondaryColor,
                          ink: ink,
                          isDark: isDark,
                        ),
                        _buildBottomNavItem(
                          icon: Icons.stadium,
                          label: 'Stickers',
                          isActive: _activeTabIdx == 2,
                          onTap: () => setState(() => _activeTabIdx = 2),
                          secondaryColor: secondaryColor,
                          ink: ink,
                          isDark: isDark,
                        ),
                        _buildBottomNavItem(
                          icon: Icons.local_mall,
                          label: 'Vault',
                          isActive: _activeTabIdx == 3,
                          onTap: () => setState(() => _activeTabIdx = 3),
                          secondaryColor: secondaryColor,
                          ink: ink,
                          isDark: isDark,
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
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
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
                        Container(
                          width: 90,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 50,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
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
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
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
            Container(
              width: 120,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colors[0].withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colors[0].withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                // BorderStyle.dashed is NOT defined in Flutter's BorderSide, use a clean solid instead
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors[0], width: 1.0),
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: colors[0],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                    color: Color(0xFF1A1712),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: -_rotationController.value * 2 * 3.1415,
                      child: Icon(
                        Icons.flight_takeoff,
                        color: colors[0],
                        size: 28,
                      ),
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

  Widget _buildEmptyStateCard({
    required String title,
    required String subtitle,
    required Color ink,
    required Color paper,
    required Color textColor,
  }) {
    return Container(
      height: 240,
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
        boxShadow: GenZTokens.hardShadow(ink),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bubble_chart_outlined, color: textColor.withValues(alpha: 0.4), size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppFonts.heading(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent({
    required int activeTabIdx,
    required Color primaryColor,
    required Color secondaryColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required bool isDark,
    required Color paper,
    required Color ink,
  }) {
    if (activeTabIdx == 0) {
      return _buildEmptyStateCard(
        title: 'Showcase Coming Soon! 🎬',
        subtitle: 'Watch awesome squad highlights and memories here.',
        ink: ink,
        paper: paper,
        textColor: textSecondaryColor,
      );
    } else if (activeTabIdx == 2) {
      return SizedBox(
        height: 430,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _stickers.length,
          itemBuilder: (context, index) {
            final sticker = _stickers[index];
            final stickerName = sticker['name']!;
            final stickerDesc = sticker['desc']!;
            final stickerPrice = sticker['price']!;
            final stickerImage = sticker['image']!;

            return Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: _GlassTouchCard(
                onTap: () {},
                isPremium: false,
                primaryColor: primaryColor,
                textPrimaryColor: textPrimaryColor,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sticker Preview Box
                    Container(
                      height: 220,
                      width: 300,
                      color: isDark ? const Color(0xFF1E1914) : const Color(0xFFFFFDF8),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Image.asset(
                          stickerImage,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    ),
                    // Details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stickerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.heading(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: secondaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: secondaryColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  stickerPrice,
                                  style: AppFonts.mono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: secondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stickerDesc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              fontSize: 13.5,
                              color: textSecondaryColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Action Button
                          PressableCard(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🎉 Đã mua và mở khóa sticker $stickerName thành công!',
                                  ),
                                  backgroundColor: secondaryColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            color: secondaryColor,
                            borderColor: ink,
                            shadowColor: ink,
                            borderWidth: GenZTokens.borderWidthThin,
                            radius: GenZTokens.radiusButton,
                            depth: 3,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Text(
                                'SỞ HỮU NGAY 🌟',
                                style: AppFonts.heading(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: GenZTokens.ink,
                                ),
                              ),
                            ),
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
      );
    } else if (activeTabIdx == 3) {
      return _buildEmptyStateCard(
        title: 'Vault is empty! 🧳',
        subtitle: 'Collect stickers and themes to fill your locker.',
        ink: ink,
        paper: paper,
        textColor: textSecondaryColor,
      );
    } else {
      // Default: Tab Themes (activeTabIdx == 1)
      return SizedBox(
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
            final gradientColors =
                item['gradient'] as List<Color>;
            final imageUrl = item['imageUrl'] as String;

            return Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: _GlassTouchCard(
                onTap: () => showGlobalSnack(
                  'Tính năng đang được hoàn thiện 🚧',
                ),
                isPremium: isPremium,
                primaryColor: primaryColor,
                textPrimaryColor: textPrimaryColor,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Mockup Image & UI preview container
                    SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          // Background visual image (Asset or Network)
                          Positioned.fill(
                            child: imageUrl.startsWith('assets/')
                                ? Image.asset(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress ==
                                              null) {
                                            return child;
                                          }
                                          return Container(
                                            color: Colors.black26,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Container(
                                          color: Colors.black38,
                                        ),
                                  ),
                          ),

                          // Blend Overlay Gradient
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: gradientColors[0]
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ),

                          // Dark gradient fade for text contrast
                          Positioned.fill(
                            child: Container(
                              decoration:
                                  const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black54,
                                        Colors.black87,
                                      ],
                                      begin: Alignment
                                          .topCenter,
                                      end: Alignment
                                          .bottomCenter,
                                    ),
                                  ),
                            ),
                          ),

                          // Tag/Premium Badge
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                              decoration: BoxDecoration(
                                color: Colors.black54
                                    .withValues(alpha: 0.7),
                                borderRadius:
                                    BorderRadius.circular(
                                      16,
                                    ),
                                border: Border.all(
                                  color: isPremium
                                      ? primaryColor
                                            .withValues(
                                              alpha: 0.4,
                                            )
                                      : Colors.white24,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  if (isPremium) ...[
                                    Icon(
                                      Icons.verified,
                                      color: primaryColor,
                                      size: 14,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                  Text(
                                    themeTag.toUpperCase(),
                                    style:
                                        AppFonts.body(
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                          letterSpacing:
                                              1.0,
                                          color: isPremium
                                              ? primaryColor
                                              : Colors
                                                    .white70,
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
                            child: _buildMockUiPreview(
                              themeId,
                              gradientColors,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Details Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  themeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppFonts.heading(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            textPrimaryColor,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                decoration: BoxDecoration(
                                  color: primaryColor
                                      .withValues(
                                        alpha: 0.12,
                                      ),
                                  borderRadius:
                                      BorderRadius.circular(
                                        8,
                                      ),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  themePrice,
                                  style: AppFonts.mono(
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            themeDesc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
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
                                child: PressableCard(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ThemePreviewScreen(
                                              initialTheme:
                                                  themeName,
                                            ),
                                      ),
                                    );
                                  },
                                  color: paper,
                                  borderColor: ink,
                                  shadowColor: ink,
                                  borderWidth: GenZTokens.borderWidthThin,
                                  radius: GenZTokens.radiusButton,
                                  depth: 3,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Xem Trước',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.heading(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: ink,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PressableCard(
                                  onTap: () async {
                                    final res =
                                        await ApiService.patch(
                                          '/users/me',
                                          {
                                            'theme':
                                                themeId,
                                          },
                                        );
                                    if (context.mounted) {
                                      if (res != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '🎉 Đã áp dụng theme $themeName!',
                                            ),
                                            backgroundColor:
                                                primaryColor,
                                            behavior:
                                                SnackBarBehavior
                                                    .floating,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '❌ Không thể giao dịch. Vui lòng thử lại!',
                                            ),
                                            backgroundColor:
                                                Colors
                                                    .redAccent,
                                            behavior:
                                                SnackBarBehavior
                                                    .floating,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  color: primaryColor,
                                  borderColor: ink,
                                  shadowColor: ink,
                                  borderWidth: GenZTokens.borderWidthThin,
                                  radius: GenZTokens.radiusButton,
                                  depth: 3,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Đổi Ngay 🚀',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFonts.heading(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: GenZTokens.ink,
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
    required Color ink,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
          boxShadow: GenZTokens.hardShadow(ink),
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
                    child: imageUrl.startsWith('assets/')
                        ? Image.asset(imageUrl, fit: BoxFit.cover)
                        : Image.network(imageUrl, fit: BoxFit.cover),
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
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppFonts.body(
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
    required VoidCallback onTap,
    required Color secondaryColor,
    required Color ink,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isActive
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
                      ),
                      child: Icon(icon, color: GenZTokens.ink, size: 20),
                    )
                  : Icon(icon, color: isDark ? Colors.white38 : Colors.black38, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppFonts.body(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? (isDark ? GenZTokens.inkDark : GenZTokens.ink)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
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
    final ink = widget.isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final paper = widget.isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(
              color: ink,
              width: GenZTokens.borderWidth,
            ),
            boxShadow: GenZTokens.hardShadow(ink),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.child,
        ),
      ),
    );
  }
}

class _AnimatedTapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedTapButton({required this.child, required this.onTap});

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
