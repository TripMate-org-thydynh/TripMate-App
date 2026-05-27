import 'package:flutter/material.dart';

class AiSuggestionFeedScreen extends StatelessWidget {
  const AiSuggestionFeedScreen({super.key});

  final List<Map<String, String>> _suggestions = const [
    {
      'title': 'Thời tiết mưa nhẹ chiều nay 🌧️',
      'desc': 'Gợi ý: Ghé bảo tàng nghệ thuật Kyoto Kyoto Museum để tránh ướt áo nhé cưng.',
      'type': 'Weather replan',
    },
    {
      'title': 'Kinkaku-ji đang thưa khách ⛩️',
      'desc': 'AI phân tích dữ liệu trực tiếp cho thấy dòng người đang giảm. Ghé ngay lúc này thôi!',
      'type': 'Crowd limit advice',
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
        title: const Text('Gợi Ý Thông Minh AI 💡', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Squad Suggestion Feed',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dòng cấp ý kiến tự động bằng AI giúp cả Squad tối ưu chuyến đi từng giây từng phút.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['type']!,
                              style: const TextStyle(
                                color: Colors.purpleAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc']!,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                              height: 1.45,
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
