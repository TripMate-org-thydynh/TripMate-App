import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamIntroductionScreen extends StatelessWidget {
  const TeamIntroductionScreen({super.key});

  final List<Map<String, String>> _members = const [
    {
      'name': 'Alex Nguyễn 👑',
      'role': 'Co-Founder & CEO',
      'vibe': 'Adventure Addict 🏍️',
      'bio': 'Chuyên gia đi lạc nhưng luôn tự tin dẫn đoàn. Từng phượt qua 15 nước.',
    },
    {
      'name': 'Minh Nhật 🎨',
      'role': 'Co-Founder & Lead Designer',
      'vibe': 'Pixel Perfect 📱',
      'bio': 'Người thiết kế các giao diện glassmorphism siêu chất chơi cho TripMate.',
    },
    {
      'name': 'Hoàng Yến 🌸',
      'role': 'Co-Founder & CTO',
      'vibe': 'Algorithm Master 💻',
      'bio': 'Gương mặt mẫu mực gánh vác toàn bộ hạ tầng logic AI và máy chủ của hệ thống.',
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
          'Đội Ngũ Sáng Lập 🛡️',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final m = _members[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Polaroid profile mock
                Container(
                  width: 72,
                  height: 90,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.purple.withValues(alpha: 0.15),
                          child: const Center(
                            child: Text('📸', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CEO',
                        style: GoogleFonts.caveat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['name']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m['role']!,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m['vibe']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(height: 16),
                      Text(
                        m['bio']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? Colors.grey[350] : Colors.grey[650],
                          height: 1.35,
                        ),
                      ),
                    ],
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
