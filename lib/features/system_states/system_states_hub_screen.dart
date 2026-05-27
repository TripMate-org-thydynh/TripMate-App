import '../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'pages/maintenance_mode_screen.dart';
import 'pages/app_update_required_screen.dart';
import 'pages/server_down_screen.dart';
import 'pages/session_expired_screen.dart';
import 'pages/permission_denied_screen.dart';

class SystemStatesHubScreen extends StatefulWidget {
  const SystemStatesHubScreen({super.key});

  @override
  State<SystemStatesHubScreen> createState() => _SystemStatesHubScreenState();
}

class _SystemStatesHubScreenState extends State<SystemStatesHubScreen> {
  String? _activeSimulatedState; // null, OFFLINE, EMPTY_MEMORIES, UPLOAD_FAIL, AI_FAIL

  void _triggerSimulation(String stateKey) {
    setState(() {
      _activeSimulatedState = stateKey;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Đã giả lập trạng thái hệ thống: $stateKey!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.indigo,
        action: SnackBarAction(
          label: 'Khôi phục',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _activeSimulatedState = null;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Brand design system tokens
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final backgroundColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;

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
      ),
      body: _activeSimulatedState != null
          ? _buildSimulatedStateBody(isDark, backgroundColor, surfaceColor, primaryColor)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cute Mascot Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, const Color(0xFF10B981)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('🛠️', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Bảng Điều Khiển Trạng Thái Hệ Thống. Cưng có thể chạm vào để xem trước các cảnh báo hoặc giả lập lỗi kết nối mạng.',
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
                    'Màn Hình Cảnh Báo Hệ Thống 🔒',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildRouteCard('Chế Độ Bảo Trì 🧹', 'Bảo trì hệ thống máy chủ TripMate nâng cấp định kỳ', isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary, () {
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

                  const SizedBox(height: 24),

                  Text(
                    'Giả Lập Trạng Thái Tức Thời 💻',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildSimulationButton('OFFLINE', 'Mất Mạng 🔌', Colors.orange, isDark, surfaceColor)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSimulationButton('EMPTY_MEMORIES', 'Trống Trơn 📂', Colors.blue, isDark, surfaceColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSimulationButton('UPLOAD_FAIL', 'Lỗi Tải Lên ⚠️', Colors.red, isDark, surfaceColor)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSimulationButton('AI_FAIL', 'AI Hỏng 🤖', Colors.purple, isDark, surfaceColor)),
                    ],
                  ),
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
            color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
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

  Widget _buildSimulationButton(String stateKey, String label, Color color, bool isDark, Color surfaceColor) {
    return ElevatedButton(
      onPressed: () => _triggerSimulation(stateKey),
      style: ElevatedButton.styleFrom(
        backgroundColor: surfaceColor,
        foregroundColor: color,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildSimulatedStateBody(bool isDark, Color backgroundColor, Color surfaceColor, Color primaryColor) {
    String emoji = '🔌';
    String title = 'Mất Kết Nối Mạng!';
    String desc = 'Vui lòng kiểm tra Wifi hoặc 4G của cưng. TripMate đang tạm thời chạy offline để cưng đọc lịch trình cũ.';
    Color color = Colors.orange;

    switch (_activeSimulatedState) {
      case 'EMPTY_MEMORIES':
        emoji = '📂';
        title = 'Chưa Có Kỷ Niệm Nào!';
        desc = 'Khu vườn kỷ niệm Kyoto / Dalat đang trống trơn. Chụp ngay vài tấm hình Ghost Cam dìm hàng lũ bạn để bắt đầu nhé!';
        color = Colors.blue;
        break;
      case 'UPLOAD_FAIL':
        emoji = '⚠️';
        title = 'Tải Lên Bị Lỗi!';
        desc = 'Tệp hình ảnh hoặc clip recap dung lượng quá nặng hoặc kết nối không ổn định. Hãy chạm thử lại nhé!';
        color = Colors.red;
        break;
      case 'AI_FAIL':
        emoji = '🤖';
        title = 'Matey AI Đuối Sức!';
        desc = 'Máy chủ phân tích ý kiến Companion đang tạm thời quá tải vì cưng ép xung bứt tốc dữ dội quá. Hãy thở đều và thử lại nhé!';
        color = Colors.purple;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.grey[500],
                height: 1.45,
              ),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _activeSimulatedState = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: Text('Khôi phục Hub', style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _activeSimulatedState = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: Text(
                    'Đồng Ý',
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
    );
  }
}
