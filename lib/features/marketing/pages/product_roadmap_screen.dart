import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductRoadmapScreen extends StatelessWidget {
  const ProductRoadmapScreen({super.key});

  final List<Map<String, String>> _milestones = const [
    {
      'quarter': 'Q3 2026',
      'title': 'Bứt Tốc Game Lắc Hũ & Lắc Lì Xì 🧧🎮',
      'desc': 'Thêm các mini-game tài lộc may mắn khi cả nhóm đi du lịch Tết hoặc trung thu.',
      'status': 'PLANNING',
    },
    {
      'quarter': 'Q4 2026',
      'title': 'Trực Quan Hóa 3D Live Map AR 🗺️📍',
      'desc': 'Trực quan hóa vị trí bạn bè bằng thực tế ảo tăng cường AR khi cả nhóm lạc nhau ở ga tàu Tokyo.',
      'status': 'RESEARCHING',
    },
    {
      'quarter': 'Q1 2027',
      'title': 'Matey AI Độc Quyền Chat Voice 🎙️🤖',
      'desc': 'Matey tự động nói thầm roaster trêu đùa hội bạn qua tai nghe không dây.',
      'status': 'FUTURE',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Roadmap 🗺️',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LỘ TRÌNH PHÁT TRIỂN SẢN PHẨM 🧬',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.purpleAccent,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 20),

            // Timelines
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _milestones.length,
              itemBuilder: (context, index) {
                final ms = _milestones[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot and line
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.purpleAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (index < _milestones.length - 1)
                          Container(
                            width: 2,
                            height: 100,
                            color: Colors.purpleAccent.withValues(alpha: 0.3),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Milestone card details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ms['quarter']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purpleAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      ms['status']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purpleAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ms['title']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ms['desc']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
