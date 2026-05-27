import 'package:flutter/material.dart';

class SquadLeaderboardScreen extends StatefulWidget {
  const SquadLeaderboardScreen({super.key});

  @override
  State<SquadLeaderboardScreen> createState() => _SquadLeaderboardScreenState();
}

class _SquadLeaderboardScreenState extends State<SquadLeaderboardScreen> {
  bool _sortByChaos = false;

  final List<Map<String, dynamic>> _rankings = [
    {
      'name': 'Alex Nguyễn',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
      'xp': 3240,
      'chaos': 92,
      'badge': 'Chúa Tể Hỗn Loạn 👑',
    },
    {
      'name': 'Minh Nhật',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nhat',
      'xp': 2850,
      'chaos': 78,
      'badge': 'Phượt Thủ Chuyên Nghiệp 🚀',
    },
    {
      'name': 'Trần Bình',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Binh',
      'xp': 1950,
      'chaos': 42,
      'badge': 'Thần Tiết Kiệm 💸',
    },
    {
      'name': 'Lê Minh',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Minh',
      'xp': 1800,
      'chaos': 35,
      'badge': 'Trưởng Đoàn Mẫu Mực 📋',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sortedList = List<Map<String, dynamic>>.from(_rankings);
    if (_sortByChaos) {
      sortedList.sort((a, b) => (b['chaos'] as int).compareTo(a['chaos'] as int));
    } else {
      sortedList.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bảng Xếp Hạng Squad 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Podium Visualizer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd Place
                if (sortedList.length > 1)
                  _buildPodiumSpot(sortedList[1], 2, Colors.grey[400]!, 100),
                const SizedBox(width: 12),
                // 1st Place
                if (sortedList.isNotEmpty)
                  _buildPodiumSpot(sortedList[0], 1, Colors.amber[600]!, 130),
                const SizedBox(width: 12),
                // 3rd Place
                if (sortedList.length > 2)
                  _buildPodiumSpot(sortedList[2], 3, Colors.brown[400]!, 85),
              ],
            ),

            const SizedBox(height: 36),

            // Ranking Toggle Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bảng xếp hạng chi tiết',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    _buildSortPill('Điểm XP 🚀', !_sortByChaos),
                    const SizedBox(width: 8),
                    _buildSortPill('Hỗn Loạn ⚡', _sortByChaos),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ranking Feed List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedList.length,
              itemBuilder: (context, index) {
                final item = sortedList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(item['avatar'] as String),
                          ),
                        ],
                      ),
                      title: Text(
                        item['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['badge'] as String),
                      trailing: Text(
                        _sortByChaos ? '${item['chaos']} ⚡' : '${item['xp']} XP',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purpleAccent,
                        ),
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

  Widget _buildPodiumSpot(Map<String, dynamic> item, int rank, Color color, double height) {
    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 36 : 28,
          backgroundImage: NetworkImage(item['avatar'] as String),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    item['name']!.split(' ').last,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortPill(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortByChaos = label.contains('Hỗn Loạn');
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.purple,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
