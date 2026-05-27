import 'package:flutter/material.dart';

class SeasonalEventsScreen extends StatelessWidget {
  const SeasonalEventsScreen({super.key});

  final List<Map<String, dynamic>> _events = const [
    {
      'title': 'Kyoto Matsuri Vibe 🌸',
      'desc': 'Chụp hình tập thể trong trang phục Kimono truyền thống tại đền thờ Fushimi Inari.',
      'reward': '+1000 XP & Huy hiệu Độc Quyền',
      'timeLeft': 'Còn 4 ngày',
    },
    {
      'title': 'Dalat Pine Hunting 🌲',
      'desc': 'Săn mây lúc 5h sáng tại đồi chè Cầu Đất cùng cả hội bạn thân.',
      'reward': '+800 XP & Voucher cafe 20%',
      'timeLeft': 'Hết hạn',
      'expired': true,
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
        title: const Text('Sự Kiện Mùa Giải 🎉', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seasonal Travel Events 🎏',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Nhận các thử thách đặc biệt giới hạn thời gian theo mùa để nhận cúp phượt thủ độc quyền!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Events List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final item = _events[index];
                final bool isExpired = item['expired'] == true;

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
                                  color: isExpired
                                      ? Colors.grey.withValues(alpha: 0.12)
                                      : Colors.pinkAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['timeLeft'] as String,
                                  style: TextStyle(
                                    color: isExpired ? Colors.grey : Colors.pinkAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                item['reward'] as String,
                                style: TextStyle(
                                  color: isExpired ? Colors.grey : Colors.purpleAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isExpired ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc'] as String,
                            style: TextStyle(
                              color: isExpired ? Colors.grey[500] : (isDark ? Colors.grey[400] : Colors.grey[600]),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!isExpired)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🎉 Bạn đã đăng ký tham gia sự kiện mùa giải Kyoto!'),
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
                                child: const Text('Tham gia sự kiện 🎏', style: TextStyle(fontWeight: FontWeight.bold)),
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
