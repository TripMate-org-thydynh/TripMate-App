import 'package:flutter/material.dart';

class AiChatHistoryScreen extends StatelessWidget {
  const AiChatHistoryScreen({super.key});

  final List<Map<String, String>> _history = const [
    {
      'query': 'Gợi ý quán cafe đẹp nhất Kyoto?',
      'reply': 'The Hill Station Cafe với view đồi núi thơ mộng cực chill.',
      'date': 'May 26, 2026',
    },
    {
      'query': 'Kiểm tra hạn mức chi tiêu của nhóm?',
      'reply': 'Cảnh báo! Nhóm đã tiêu quá 80% hạn mức thức ăn nhanh.',
      'date': 'May 25, 2026',
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
        title: const Text('Lịch Sử Trò Chuyện AI 🕒', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Past AI Chats',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Xem lại các cuộc trò chuyện và câu hỏi cưng đã trao đổi với Matey AI.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.message_outlined, color: Colors.purpleAccent, size: 20),
                              Text(
                                item['date']!,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Hỏi: ${item['query']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Matey: ${item['reply']}',
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.grey[750],
                              fontSize: 13,
                              height: 1.4,
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
