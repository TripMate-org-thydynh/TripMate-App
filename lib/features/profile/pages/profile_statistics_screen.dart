import 'package:flutter/material.dart';

class ProfileStatisticsScreen extends StatelessWidget {
  const ProfileStatisticsScreen({super.key});

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
        title: const Text('Thống Kê Thẻ Phượt Thủ 📊', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildStatRow('Hành trình hoàn thành:', '12 chuyến đi', isDark),
                    const Divider(height: 24),
                    _buildStatRow('Quãng đường di chuyển:', '4,200 km', isDark),
                    const Divider(height: 24),
                    _buildStatRow('Tổng điểm thưởng XP:', '1,250 XP', isDark),
                    const Divider(height: 24),
                    _buildStatRow('Độ uy tín Squad:', '98% 🛡️', isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String val, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
      ],
    );
  }
}
