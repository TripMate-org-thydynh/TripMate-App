import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

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
                        ? [const Color(0xFF3B82F6), const Color(0xFF1E3A8A)]
                        : [const Color(0xFFDBEAFE), const Color(0xFFBFDBFE)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '⏱️🚪',
                    style: TextStyle(fontSize: 54),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Hết Hạn Phiên Đăng Nhập! 🔒',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Để bảo mật tuyệt đối cho hầu bao và dữ liệu chat log lầy lội của nhóm cưng, phiên đăng nhập đã tự động khóa. Vui lòng bấm để xác thực lại danh tính nhé!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: Colors.grey[500],
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🚪 Đang chuyển hướng cưng về màn hình đăng nhập...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: Text(
                    'Đăng Nhập Lại ⚡',
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
