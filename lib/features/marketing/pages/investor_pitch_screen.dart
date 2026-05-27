import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvestorPitchScreen extends StatelessWidget {
  const InvestorPitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Investor Pitch Visuals 📊',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Core Pitch metrics
            Text(
              'Các Chỉ Số Tăng Trưởng Vượt Bậc 📈',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'TAM (Thị trường)',
                    '\$2.4B',
                    'Đông Nam Á 🌏',
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Tỷ Lệ Giữ Chân',
                    '84%',
                    'Top 5% App Du Lịch 🚀',
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Doanh Thu/User',
                    '45.000đ',
                    'Hàng tháng trung bình 💸',
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Tăng trưởng MoM',
                    '+32%',
                    'Người dùng hàng tháng 📈',
                    isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Growth Projection chart
            Text(
              'Dự Phóng Người Dùng 3 Năm (Triệu Lượt) 📊',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              child: CustomPaint(
                painter: _PitchChartPainter(isDark: isDark),
              ),
            ),

            const SizedBox(height: 28),

            // Key Strengths
            Text(
              'Vì Sao Lựa Chọn TripMate? 🔑',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildStrengthItem('1. Viral Design Loop', 'Tận dụng mini-game dìm hàng chia tiền lan truyền liên tục.', isDark),
            _buildStrengthItem('2. Matey AI Companion', 'Tương tác thông minh thấu hiểu cảm xúc cá nhân của cả nhóm.', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildStrengthItem(String title, String desc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.yellowAccent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 4),
                  Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter representing Pitch line chart projection
class _PitchChartPainter extends CustomPainter {
  final bool isDark;
  _PitchChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.purpleAccent.withValues(alpha: 0.3), Colors.purpleAccent.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height * 0.9)
      ..cubicTo(
        size.width * 0.3, size.height * 0.85,
        size.width * 0.6, size.height * 0.4,
        size.width, size.height * 0.05,
      );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw bars
    final barPaint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.grey[200]!
      ..strokeWidth = 1.5;
    for (int i = 1; i <= 4; i++) {
      canvas.drawLine(
        Offset(size.width * 0.2 * i, 0),
        Offset(size.width * 0.2 * i, size.height),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
