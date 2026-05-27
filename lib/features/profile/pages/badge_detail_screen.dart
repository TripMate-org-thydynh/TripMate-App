import 'package:flutter/material.dart';

class BadgeDetailScreen extends StatelessWidget {
  final String title;
  final String desc;
  final bool unlocked;

  const BadgeDetailScreen({
    super.key,
    required this.title,
    required this.desc,
    required this.unlocked,
  });

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
        title: const Text('Chi Tiết Danh Hiệu 🏆', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing badge icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amberAccent.withValues(alpha: 0.2),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: unlocked ? Colors.amber : Colors.grey[700],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      unlocked ? Icons.stars : Icons.lock_outline,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Status tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: unlocked ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unlocked ? 'Đã mở khóa 🎉' : 'Chưa mở khóa 🔒',
                  style: TextStyle(
                    color: unlocked ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
