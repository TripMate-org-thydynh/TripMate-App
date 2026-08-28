import 'package:flutter/material.dart';
import 'badge_detail_screen.dart';
import '../../../core/api_service.dart';

class BadgeCollectionScreen extends StatefulWidget {
  const BadgeCollectionScreen({super.key});

  @override
  State<BadgeCollectionScreen> createState() => _BadgeCollectionScreenState();
}

class _BadgeCollectionScreenState extends State<BadgeCollectionScreen> {
  final List<Map<String, dynamic>> _mockBadges = const [
    {
      'id': 'b1',
      'title': 'Siêu Cấp Phượt Thủ 🏆',
      'desc': 'Đi trên 5 chuyến đi cùng TripMate',
      'unlocked': true,
      'color': Colors.amber,
    },
    {
      'id': 'b2',
      'title': 'Thần Tài Gõ Đầu 💸',
      'desc': 'Bị chọn thanh toán wheel splitter game',
      'unlocked': true,
      'color': Colors.purpleAccent,
    },
    {
      'id': 'b3',
      'title': 'Thần Gió Nhật Bản 🚄',
      'desc': 'Có checkin tàu Shinkansen',
      'unlocked': false,
      'color': Colors.grey,
    },
  ];

  List<dynamic> _liveBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  Future<void> _fetchBadges() async {
    final response = await ApiService.get('/users/me/badges');
    if (mounted) {
      if (response is List) {
        setState(() {
          _liveBadges = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _liveBadges = List.from(_mockBadges);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141210)
          : const Color(0xFFFDF6D3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Travel Trophies 🏆',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh Hiệu & Cúp Du Lịch',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Khám phá các cột mốc danh hiệu cưng đã mở khóa trong suốt các chặng đường đi.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Badges Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _liveBadges.length,
                    itemBuilder: (context, index) {
                      final badge = _liveBadges[index];
                      final isUnlocked =
                          badge['unlockedAt'] != null ||
                          badge['unlocked'] == true;
                      final title = badge['title'] as String;
                      final desc = badge['desc'] as String;

                      // Map custom colors dynamically
                      final accentColor = badge['id'] == 'b1'
                          ? Colors.amber
                          : (badge['id'] == 'b2'
                                ? Colors.purpleAccent
                                : Colors.teal);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BadgeDetailScreen(
                                badgeName: title,
                                unlocked: isUnlocked,
                                isDarkMode: isDark,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF262019)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isUnlocked
                                  ? accentColor.withValues(alpha: 0.3)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: isUnlocked ? 1.0 : 0.4,
                                child: Icon(
                                  isUnlocked
                                      ? Icons.emoji_events
                                      : Icons.lock_outline,
                                  color: isUnlocked ? accentColor : Colors.grey,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                desc,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
