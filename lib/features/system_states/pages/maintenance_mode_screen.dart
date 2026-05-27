import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenanceModeScreen extends StatelessWidget {
  const MaintenanceModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary, const Color(0xFFB45309)]
                        : [const Color(0xFFFDE68A), const Color(0xFFFCD34D)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🧹💨',
                    style: TextStyle(fontSize: 54),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Matey Đang Dọn Dẹp! 🧼🏗️',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hệ thống máy chủ TripMate đang được quét mạng nhện và tiếp thêm dầu nhớt để bứt tốc mượt mà hơn. Vui lòng quay lại sau vài phút nha cưng!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: Colors.grey[500],
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: Text(
                    'Quay Lại',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
