import 'package:flutter/material.dart';

class SharedTripsHistoryScreen extends StatelessWidget {
  const SharedTripsHistoryScreen({super.key});

  final List<Map<String, dynamic>> _sharedTrips = const [
    {
      'title': 'Phú Quốc Escape 🌊',
      'date': 'Jan 15 - Jan 18, 2026',
      'members': 'Minh Nhật, Alex Nguyễn, Trần Bình',
    },
    {
      'title': 'Đà Lạt Săn Mây 🌲',
      'date': 'Dec 10 - Dec 13, 2025',
      'members': 'Minh Nhật, Lê Minh, Hoàng Yến',
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
        title: const Text('Lịch Sử Chuyến Đi Chung 🕒', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shared Trips History 🎒',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Xem lại các chuyến đi cưng đã đồng hành cùng bạn bè chí cốt.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sharedTrips.length,
              itemBuilder: (context, index) {
                final item = _sharedTrips[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.map_outlined, color: Colors.purpleAccent),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(item['date'] as String),
                          const SizedBox(height: 2),
                          Text('Đồng đội: ${item['members']}'),
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
