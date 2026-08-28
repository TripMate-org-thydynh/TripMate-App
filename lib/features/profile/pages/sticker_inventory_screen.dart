import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../core/app_messenger.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api_service.dart';

class StickerInventoryScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const StickerInventoryScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<StickerInventoryScreen> createState() => _StickerInventoryScreenState();
}

class _StickerInventoryScreenState extends State<StickerInventoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  List<dynamic> _ownedStickers = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _ownedPacks = const [
    {
      'icon': Icons.local_cafe,
      'rarity': 'Rare',
      'rarityColor': Color(0xFF64B5F6),
      'name': 'Cafe Addiction',
      'desc': 'Fuel for the 6AM airport run.',
    },
    {
      'icon': Icons.payments,
      'rarity': 'Epic',
      'rarityColor': Color(0xFFC9B8FF),
      'name': 'Financial Damage',
      'desc': 'For splitting the exorbitant dinner bill.',
    },
    {
      'icon': Icons.star,
      'rarity': 'Legendary',
      'rarityColor': Color(0xFFFFD700),
      'name': 'Main Character',
      'desc': "It's your trip, they just live in it.",
    },
    {
      'icon': Icons.map_outlined,
      'rarity': 'Common',
      'rarityColor': Color(0xFF1FA85C),
      'name': 'Lost Again',
      'desc': 'Send when GPS fails entirely.',
    },
  ];

  final List<String> _recentStickers = const [
    '🔥',
    '✨',
    '💀',
    '🥂',
    '💸',
    '✈️',
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    try {
      final response = await ApiService.get('/users/me/stickers');
      if (mounted) {
        setState(() {
          if (response is List) {
            _ownedStickers = response;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF0F0FF);
    final surface = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.8);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.55);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Ambient
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'trip.mate',
                        style: AppFonts.heading(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFC9B8FF),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onThemeToggle,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                          ),
                          child: Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 20,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Title
                        Text(
                          'Sticker Inventory',
                          style: AppFonts.heading(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'reaction energy fully stocked',
                          style: AppFonts.body(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Equipped Pack
                        Text(
                          'Equipped Pack',
                          style: AppFonts.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFD700,
                                ).withValues(alpha: isDark ? 0.12 : 0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withValues(alpha: 0.1),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Sticker preview grid
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Color(0xFFFFD700),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '👑',
                                        style: TextStyle(fontSize: 36),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: const Color(
                                                  0xFFFFD700,
                                                ).withValues(alpha: 0.2),
                                              ),
                                              child: Text(
                                                'Legendary',
                                                style: AppFonts.heading(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFFFFD700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: const Color(
                                                  0xFF1FA85C,
                                                ).withValues(alpha: 0.2),
                                              ),
                                              child: Text(
                                                'Active',
                                                style: AppFonts.heading(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFF1FA85C,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Chaos Squad',
                                          style: AppFonts.heading(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'chaos sticker collection upgraded. Perfect for when the group chat plans inevitably fall apart.',
                                          style: AppFonts.body(
                                            fontSize: 11,
                                            color: textSecondary,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Owned Collections
                        Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: Color(0xFFC9B8FF),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Owned Collections',
                              style: AppFonts.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        ...List.generate(_ownedPacks.length, (i) {
                          final pack = _ownedPacks[i];
                          final rarityColor = pack['rarityColor'] as Color;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 20,
                                  sigmaY: 20,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: rarityColor.withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                        child: Icon(
                                          pack['icon'] as IconData,
                                          color: rarityColor,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    color: rarityColor
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    pack['rarity'] as String,
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: rarityColor,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              pack['name'] as String,
                                              style: AppFonts.heading(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: textPrimary,
                                              ),
                                            ),
                                            Text(
                                              pack['desc'] as String,
                                              style: AppFonts.body(
                                                fontSize: 11,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: textSecondary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 28),

                        // Owned Stickers
                        Row(
                          children: [
                            const Icon(
                              Icons.face_retouching_natural_outlined,
                              size: 18,
                              color: Color(0xFFFFB783),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nhãn dán sở hữu (${_ownedStickers.length})',
                              style: AppFonts.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.purple,
                                ),
                              )
                            : _ownedStickers.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      'Bạn chưa mua nhãn dán nào. Hãy ghé Cửa hàng Sticker nhé!',
                                      style: AppFonts.body(
                                        fontSize: 12,
                                        color: textSecondary,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: 0.9,
                                          ),
                                      itemCount: _ownedStickers.length,
                                      itemBuilder: (context, index) {
                                        final item = _ownedStickers[index];
                                        final label =
                                            item['label'] as String? ??
                                            'Sticker';
                                        final count = item['count'] ?? 1;
                                        final emoji = label.split(' ').last;

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF262019)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: borderColor,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                emoji,
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                label,
                                                style: AppFonts.body(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: textPrimary,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Số lượng: $count',
                                                style: AppFonts.body(
                                                  fontSize: 9,
                                                  color: Colors.purpleAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                        const SizedBox(height: 20),

                        // Recently Used
                        Row(
                          children: [
                            const Icon(
                              Icons.history,
                              size: 18,
                              color: Color(0xFFC9B8FF),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recently Used',
                              style: AppFonts.heading(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 72,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recentStickers.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final sticker = _recentStickers[i];
                              return GestureDetector(
                                onTap: () => showGlobalSnack(
                                  'Tính năng đang được hoàn thiện 🚧',
                                ),
                                child: AnimatedBuilder(
                                  animation: _floatController,
                                  builder: (context, child) =>
                                      Transform.scale(scale: 1.0, child: child),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: surface,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: borderColor,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            sticker,
                                            style: const TextStyle(
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Bottom nav
                _buildBottomNav(isDark: isDark, surface: surface),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav({required bool isDark, required Color surface}) {
    final icons = [
      Icons.explore_outlined,
      Icons.group_outlined,
      Icons.add_circle,
      Icons.map_outlined,
      Icons.person,
    ];
    const activeIdx = 4;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (i) {
              final isActive = i == activeIdx;
              return GestureDetector(
                onTap: () =>
                    showGlobalSnack('Tính năng đang được hoàn thiện 🚧'),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? const Color(0xFF1FA85C).withValues(alpha: 0.18)
                        : Colors.transparent,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF1FA85C,
                              ).withValues(alpha: 0.25),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icons[i],
                    size: 24,
                    color: isActive
                        ? const Color(0xFF1FA85C)
                        : isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
