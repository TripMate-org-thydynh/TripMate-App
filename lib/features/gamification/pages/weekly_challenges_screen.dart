import 'package:flutter/material.dart';

class WeeklyChallengesScreen extends StatelessWidget {
  const WeeklyChallengesScreen({super.key});

  final List<Map<String, dynamic>> _challenges = const [
    {
      'title': 'Kẻ Bắn Tỉa Ghost Cam 📸',
      'desc': 'Săn 3 bức hình dìm hàng của đồng đội bằng Ghost Cam trong các khoảnh khắc bất ngờ.',
      'progress': 1,
      'target': 3,
      'reward': '+400 XP',
    },
    {
      'title': 'Vua Tiết Kiệm Chi Tiêu 💸',
      'desc': 'Tổng chi tiêu của cưng trong tuần này duy trì dưới hạn mức cảnh báo 80%.',
      'progress': 75,
      'target': 80,
      'reward': '+300 XP',
      'isPercentage': true,
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
        title: const Text('Thử Thách Tuần 📆', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Squad Missions ⚔️',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mỗi tuần một loạt thử thách mới thách thức kỹ năng gắn kết du lịch của nhóm bạn!',
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
                final bool isPct = item['isPercentage'] == true;
                final double progressValue = isPct
                    ? (item['progress'] as int) / (item['target'] as int)
                    : (item['progress'] as int) / (item['target'] as int);

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
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
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
                          const SizedBox(height: 8),
                          Text(
                            item['desc'] as String,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                isPct
                                    ? '${item['progress']}% / ${item['target']}%'
                                    : '${item['progress']}/${item['target']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purpleAccent,
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
