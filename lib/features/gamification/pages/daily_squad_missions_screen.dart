import 'package:flutter/material.dart';

class DailySquadMissionsScreen extends StatefulWidget {
  const DailySquadMissionsScreen({super.key});

  @override
  State<DailySquadMissionsScreen> createState() => _DailySquadMissionsScreenState();
}

class _DailySquadMissionsScreenState extends State<DailySquadMissionsScreen> {
  final List<Map<String, dynamic>> _missions = [
    {
      'title': 'Ghi nhận 2 khoản thiệt hại 💸',
      'desc': 'Cả nhóm đăng tối thiểu 2 hóa đơn chi tiêu lên Expense Tracker.',
      'progress': 1,
      'target': 2,
      'reward': '+200 XP',
    },
    {
      'title': 'Chia sẻ 3 khoảnh khắc dìm 📸',
      'desc': 'Đăng 3 bức ảnh hoặc video ngắn lên Memory Wall.',
      'progress': 3,
      'target': 3,
      'reward': '+300 XP',
    },
    {
      'title': 'Bắt đầu 1 ván bài sinh tử 🃏',
      'desc': 'Khởi động 1 lượt chơi Truth or Dare hoặc Spin Wheel.',
      'progress': 0,
      'target': 1,
      'reward': '+150 XP',
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
        title: const Text('Nhiệm Vụ Squad Hằng Ngày 📆', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cooperative Daily Missions 🤝',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cùng nhau hoàn thành nhiệm vụ để nhân đôi điểm thưởng XP cho cả đội!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Missions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _missions.length,
              itemBuilder: (context, index) {
                final item = _missions[index];
                final double progressValue = (item['progress'] as int) / (item['target'] as int);
                final isCompleted = progressValue >= 1.0;

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
                                '${item['progress']}/${item['target']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.green : Colors.purpleAccent,
                                ),
                              ),
                            ],
                          ),
                          if (isCompleted) ...[
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Hoàn thành! Nhân đôi XP thành công 🎉',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
