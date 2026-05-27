import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServerDownScreen extends StatefulWidget {
  const ServerDownScreen({super.key});

  @override
  State<ServerDownScreen> createState() => _ServerDownScreenState();
}

class _ServerDownScreenState extends State<ServerDownScreen> {
  bool _isRetrying = false;

  void _retryConnection() {
    setState(() {
      _isRetrying = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isRetrying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌋 Hệ thống máy chủ vẫn chưa phản hồi. Đội ngũ dev đang gõ phím cứu hộ!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

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
                        ? [const Color(0xFFEF4444), const Color(0xFF991B1B)]
                        : [const Color(0xFFFEE2E2), const Color(0xFFFCA5A5)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🌋💥',
                    style: TextStyle(fontSize: 54),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Máy Chủ Gặp Sự Cố! 📡🔥',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Không thể kết nối đến máy chủ TripMate lúc này. Có vẻ ai đó trong squad đã vô tình làm đổ cốc trà sữa lên CPU của chúng tôi! Chúng tôi đang khắc phục cực tốc!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: Colors.grey[500],
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    child: Text('Trở lại', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isRetrying ? null : _retryConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    icon: _isRetrying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, color: Colors.white, size: 18),
                    label: Text(
                      'Thử Lại 🔄',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
