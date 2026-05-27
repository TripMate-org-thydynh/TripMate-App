import 'package:flutter/material.dart';

class TripBingoScreen extends StatefulWidget {
  const TripBingoScreen({super.key});

  @override
  State<TripBingoScreen> createState() => _TripBingoScreenState();
}

class _TripBingoScreenState extends State<TripBingoScreen> {
  final List<Map<String, dynamic>> _bingoTiles = [
    {'title': 'Dậy sớm ngắm bình minh 🌅', 'checked': true},
    {'title': 'Thử món ăn kỳ lạ nhất 🍲', 'checked': false},
    {'title': 'Chụp ảnh dìm cả hội 📸', 'checked': true},
    {'title': 'Đi lạc quá 30 phút 🗺️', 'checked': false},
    {'title': 'Chiêu đãi cả nhóm cốc cafe ☕', 'checked': true},
    {'title': 'Mua quà lưu niệm độc đáo 🎁', 'checked': false},
    {'title': 'Thức đêm chơi Boardgame 🃏', 'checked': false},
    {'title': 'Hát karaoke trên xe cộ 🎤', 'checked': true},
    {'title': 'Checkin tàu cao tốc 🚄', 'checked': false},
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
        title: const Text('Trip Bingo 🎯', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Squad Travel Bingo 🎲',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tích đủ đường thẳng để mở khóa danh hiệu siêu phượt thủ!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // 3x3 Grid of Bingo Tiles
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _bingoTiles.length,
              itemBuilder: (context, index) {
                final tile = _bingoTiles[index];
                final isChecked = tile['checked'] as bool;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _bingoTiles[index]['checked'] = !isChecked;
                    });
                    if (!isChecked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Nhiệm vụ đã hoàn thành! Tiếp tục cố gắng nhé!'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isChecked
                          ? Colors.purple.withValues(alpha: 0.2)
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isChecked ? Colors.purpleAccent : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            tile['title'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (isChecked)
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(Icons.check_circle, color: Colors.purpleAccent, size: 18),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
