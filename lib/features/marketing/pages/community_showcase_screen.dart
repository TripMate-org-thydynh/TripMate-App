import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityShowcaseScreen extends StatelessWidget {
  const CommunityShowcaseScreen({super.key});

  final List<Map<String, String>> _squads = const [
    {
      'name': 'Hội Quậy Phá Phú Quốc 🦈🌊',
      'creator': 'Phú Khang',
      'members': '6 thành viên',
      'vibe': 'Đạt 98% Chaos Energy Vibe! 🤪',
      'quote': '"Lần đầu tiên đi chơi mà không đứa nào cãi nhau chuyện chia tiền phòng. Tình nghĩa anh em vẫn bền chặt!"',
    },
    {
      'name': 'Hội Săn Mây Đà Lạt 🌲⛅',
      'creator': 'Hoàng Yến',
      'members': '4 thành viên',
      'vibe': 'Chill Out Vibe ☕',
      'quote': '"Nhờ Matey gợi ý lịch trình săn mây lúc 5h sáng mà nhóm mình có trọn bộ ảnh sống ảo triệu view cực đỉnh!"',
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
          'Cộng Đồng Squads 🌏',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _squads.length,
        itemBuilder: (context, index) {
          final sq = _squads[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
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
                    Expanded(
                      child: Text(
                        sq['name']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Elite Squad',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Sáng lập bởi: ${sq['creator']}  •  Sĩ số: ${sq['members']}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  sq['vibe']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
                const Divider(height: 20),
                Text(
                  sq['quote']!,
                  style: GoogleFonts.caveat(
                    fontSize: 15,
                    color: isDark ? Colors.grey[300] : Colors.grey[750],
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
