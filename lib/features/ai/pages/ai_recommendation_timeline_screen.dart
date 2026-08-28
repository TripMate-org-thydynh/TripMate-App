import 'package:flutter/material.dart';

class AiRecommendationTimelineScreen extends StatelessWidget {
  const AiRecommendationTimelineScreen({super.key});

  final List<Map<String, String>> _timeline = const [
    {
      'time': '08:00 AM',
      'location': 'Cafe The Hill Station ☕',
      'reason': 'AI Vibe Match đạt 92% với tính cách chill của cả nhóm.',
    },
    {
      'time': '02:00 PM',
      'location': 'Đền Fushimi Inari ⛩️',
      'reason': 'Thời tiết mát mẻ nhất trong ngày, tránh nắng gắt.',
    },
  ];

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
        title: const Text(
          'Hành Trình Gợi Ý Bằng AI 🕒',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Recommendation Timeline 🗺️',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Dòng thời gian các điểm đến được gợi ý tối ưu tự động dựa trên vị trí và sở thích nhóm.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _timeline.length,
              itemBuilder: (context, index) {
                final item = _timeline[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    color: isDark ? const Color(0xFF262019) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Text(
                        item['time']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      title: Text(
                        item['location']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['reason']!),
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
