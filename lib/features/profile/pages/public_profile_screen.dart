import 'package:flutter/material.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userName;
  final String avatarUrl;

  const PublicProfileScreen({
    super.key,
    required this.userName,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Xem Profile Bạn Bè 👀', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Center Profile info
            CircleAvatar(
              radius: 54,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '@tripmate_buddy',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Là cạ cứng du lịch thích chinh phục các cung đường dài, cực kỳ uy tín và thân thiện! 🏕️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Statistics row
            Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('12', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Chuyến đi', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('3.2k', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Điểm XP', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('98%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Độ uy tín', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
