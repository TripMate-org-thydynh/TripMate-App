import '../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pages
import 'pages/maintenance_mode_screen.dart';
import 'pages/app_update_required_screen.dart';
import 'pages/server_down_screen.dart';
import 'pages/session_expired_screen.dart';
import 'pages/permission_denied_screen.dart';

// Newly added Batch 11 Screens
import 'pages/activity_hub_no_chaos_screen.dart';
import 'pages/offline_mode_screen.dart';
import 'pages/memory_wall_empty_screen.dart';
import 'pages/no_internet_screen.dart';
import 'pages/no_friends_solo_arc_screen.dart';
import 'pages/sync_failed_screen.dart';
import 'pages/upload_failed_screen.dart';
import 'pages/ai_failed_crisis_screen.dart';

class SystemStatesHubScreen extends StatefulWidget {
  const SystemStatesHubScreen({super.key});

  @override
  State<SystemStatesHubScreen> createState() => _SystemStatesHubScreenState();
}

class _SystemStatesHubScreenState extends State<SystemStatesHubScreen> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    
    // Brand design system tokens
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final backgroundColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Không Gian Hệ Thống ⚙️',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: primaryColor,
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mascot Banner
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('🛠️', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Bảng Điều Khiển Trạng Thái Hệ Thống & Lỗi Kết Nối. Chạm vào bất kỳ thẻ nào để xem trước giao diện lỗi được Gen Z hóa cá tính!',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Text(
              'Trạng Thái Hệ Thống Mới (Batch 11) ✨',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildRouteCard(
              'Activity Hub - Vô Sự 💤',
              'Khi squad quá yên bình, không phát hiện emotional damage',
              secondaryColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityHubNoChaosScreen(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  ),
                ),
              ),
              isDark,
              surfaceColor,
            ),

            _buildRouteCard(
              'Chế Độ Offline - Tiếp Tục Du Hí 🔌',
              'Kích hoạt khi mất kết nối mạng nhưng an toàn với dữ liệu cục bộ',
              const Color(0xFF3B82F6),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OfflineModeScreen(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  ),
                ),
              ),
              isDark,
              surfaceColor,
            ),

            _buildRouteCard(
              'Bức Tường Kỷ Niệm Trống Trơn 📂',
              'Scrapbook trống, gợi ý chụp dìm hàng lũ bạn',
              primaryColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoryWallEmptyScreen(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  ),
                ),
              ),
              isDark,
              surfaceColor,
            ),

            _buildRouteCard(
              'Mất Kết Nối Wifi Left Squad 😭',
              'Lỗi ngắt kết nối mạng bất chợt kèm Dino Game offline',
              Colors.redAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoInternetScreen(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  ),
                ),
              ),
              isDark,
              surfaceColor,
            ),

            _buildRouteCard(
              'Thiếu Vắng Đồng Bọn 😭',
              'Solo traveler arc unlocked, kêu gọi lập squad ngáo ngơ',
              const Color(0xFFEC4899),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoFriendsSoloArcScreen(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  ),
                ),
              ),
              isDark,
              surfaceColor,
            ),

            _buildRouteCard(
              'Đồng Bộ Thất Bại 🌋',
              'Mất sync lịch trình và gợi ý resolve merge conflicts',
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SyncFailedScreen(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  ),
                ),
              ),
              isDark,
              surfaceColor,
            ),

            _buildRouteCard(
              'Tải Lên Bị Lỗi ⚠️',
              'Memory bị lạc giữa đường truyền, cho phép lưu local hoặc xếp hàng chờ',
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadFailedScreen(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  ),
                ),
              ),
              isDark,
              surfaceColor,
            ),

            _buildRouteCard(
              'Matey AI Khủng Hoảng Hiện Sinh 🤖',
              'Trí thông minh nhân tạo bị quá tải kèm bento fallback vibes',
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AiFailedCrisisScreen(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  ),
                ),
              ),
              isDark,
              surfaceColor,
            ),

            const SizedBox(height: 24),

            Text(
              'Giao Diện Quản Trị Hệ Thống Cũ 🔒',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildRouteCard('Chế Độ Bảo Trì 🧹', 'Bảo trì hệ thống máy chủ TripMate nâng cấp định kỳ', const Color(0xFFF59E0B), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceModeScreen()));
            }, isDark, surfaceColor),
            _buildRouteCard('Cần Lên Đời Phiên Bản 🚀', 'Cưỡng chế nâng cấp phiên bản app cũ kỹ', const Color(0xFF8B5CF6), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AppUpdateRequiredScreen()));
            }, isDark, surfaceColor),
            _buildRouteCard('Máy Chủ Không Phản Hồi 🌋', 'Lỗi sập server hoặc quá tải đường truyền', const Color(0xFFEF4444), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ServerDownScreen()));
            }, isDark, surfaceColor),
            _buildRouteCard('Phiên Đăng Nhập Hết Hạn 🚪', 'Hết hạn JWT token truy cập, buộc đăng nhập lại', const Color(0xFF3B82F6), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SessionExpiredScreen()));
            }, isDark, surfaceColor),
            _buildRouteCard('Quyền Bị Chặn 🛑', 'Không có quyền truy cập Location/Camera/Photos', const Color(0xFFEC4899), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PermissionDeniedScreen()));
            }, isDark, surfaceColor),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(String title, String desc, Color color, VoidCallback onTap, bool isDark, Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.warning_amber_outlined, color: color, size: 20),
          ),
          title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5)),
          subtitle: Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        ),
      ),
    );
  }
}
