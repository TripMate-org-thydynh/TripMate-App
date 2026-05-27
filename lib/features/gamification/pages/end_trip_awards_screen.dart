import 'package:flutter/material.dart';

class EndTripAwardsScreen extends StatelessWidget {
  const EndTripAwardsScreen({super.key});

  final List<Map<String, dynamic>> _awards = const [
    {
      'title': 'Chúa Tể Hỗn Loạn 👑',
      'winner': 'Alex Nguyễn',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
      'reason': 'Người khởi xướng nhiều cuộc vui nhất và chi tiêu mạnh tay nhất!',
    },
    {
      'title': 'Thần Tiết Kiệm 💸',
      'winner': 'Trần Bình',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Binh',
      'reason': 'Người tối ưu hóa mọi khoản nợ nhóm đến đồng xu lẻ cuối cùng!',
    },
    {
      'title': 'Trưởng Đoàn Mẫu Mực 📋',
      'winner': 'Lê Minh',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Minh',
      'reason': 'Đầu tàu chỉ đường chuẩn xác, không đi lạc một mét nào!',
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
        title: const Text('Lễ Trao Giải Chuyến Đi 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'TripMate Awards Gala 🎭',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vinh danh những đóng góp xuất chúng (và lầy lội) của cả Squad!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Awards Cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _awards.length,
              itemBuilder: (context, index) {
                final item = _awards[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              const Icon(Icons.stars, color: Colors.amber),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(item['avatar'] as String),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['winner'] as String,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['reason'] as String,
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
