import 'package:flutter/material.dart';

class ChaosChallengesScreen extends StatelessWidget {
  const ChaosChallengesScreen({super.key});

  final List<Map<String, dynamic>> _challenges = const [
    {
      'title': 'Nói tiếng Nhật cả buổi tối 🇯🇵',
      'desc': 'Thách thức nói hoàn toàn bằng tiếng Nhật khi ăn tối ở Kyoto Ryokan.',
      'reward': '+500 XP',
      'danger': 'Hard 🔥',
    },
    {
      'title': 'Thần Tài Gánh Team 💸',
      'desc': 'Thực hiện 2 lần thanh toán nợ ngay lập tức trong Wallet.',
      'reward': '+300 XP',
      'danger': 'Medium ⚡',
    },
    {
      'title': 'Chụp hình troll Lê Minh 📸',
      'desc': 'Sử dụng Ghost Cam chộp được khoảnh khắc ngái ngủ của Lê Minh.',
      'reward': '+400 XP',
      'danger': 'Extreme 💀',
    },
  ];

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
        title: const Text('Thử Thách Hỗn Loạn ⚡', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Squad Chaos Challenges 🎢',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thách thức lòng can đảm và độ lầy lội của cả hội bạn!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Challenges List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                final item = _challenges[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['danger'] as String,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                item['reward'] as String,
                                style: const TextStyle(
                                  color: Colors.purpleAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc'] as String,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🎉 Đã chấp nhận thử thách! Hãy chụp hình chứng minh lên feed nhé!'),
                                    backgroundColor: Colors.purple,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Nhận thử thách ⚡', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
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
