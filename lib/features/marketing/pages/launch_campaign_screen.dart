import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LaunchCampaignScreen extends StatelessWidget {
  const LaunchCampaignScreen({super.key});

  final List<Map<String, String>> _campaigns = const [
    {
      'title': 'Chiến Dịch "Điên Có Đội, Quậy Có Hội" 🎒🍿',
      'channel': 'TikTok Hashtag Challenge',
      'metric': 'KPI: 10M+ Views',
      'desc': 'Trào lưu quay video dìm hàng lúc đi phượt bằng tính năng Ghost Cam và lồng tiếng troll cực hài hước.',
    },
    {
      'title': 'Chiến Dịch "Kẻ Hủy Diệt Ví Tiền" 🧾🔥',
      'channel': 'Facebook & Instagram Shorts',
      'metric': 'KPI: 2.5M+ Reach',
      'desc': 'Tạo meme chia sẻ hình chụp các hóa đơn ăn uống kèm lời roast siêu muối của Matey AI.',
    },
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
          'Launch Campaign Visuals 🚀',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                ),
              ),
              child: Column(
                children: [
                  const Text('📢', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'KẾ HOẠCH BÙNG NỔ THỊ TRƯỜNG 🎋',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chuỗi chiến dịch marketing lan truyền (viral) tận dụng tâm lý "tương tác hỗn loạn" của Gen Z.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Các chiến dịch cốt lõi',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _campaigns.length,
              itemBuilder: (context, index) {
                final camp = _campaigns[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              camp['channel']!,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.pinkAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                          Text(
                            camp['metric']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        camp['title']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        camp['desc']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: isDark ? Colors.grey[350] : Colors.grey[650],
                          height: 1.4,
                        ),
                      ),
                    ],
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
