import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionSettingsScreen extends StatefulWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  State<SubscriptionSettingsScreen> createState() => _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState extends State<SubscriptionSettingsScreen> {
  bool _autoRenew = true;

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
          'Thiết Lập Gói Cước ⚙️',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple,
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Elite Squad — Premium 💎',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chu kỳ: 99.000đ / tháng\nNgày gia hạn kế tiếp: 20/06/2026',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Tùy chọn thanh toán',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              color: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Tự động gia hạn',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Gia hạn tự động bằng nguồn tiền đã đăng ký để tránh gián đoạn dịch vụ AI.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5),
                    ),
                    value: _autoRenew,
                    activeThumbColor: Colors.purpleAccent,
                    onChanged: (val) {
                      setState(() {
                        _autoRenew = val;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? '🔔 Đã kích hoạt gia hạn tự động!' : '🔕 Đã tắt tự động gia hạn!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(
                      'Thay đổi phương thức nguồn',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Visa **** 4242', style: GoogleFonts.plusJakartaSans(fontSize: 11.5)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('💳 Mở ví MoMo / Bank account để liên kết nguồn mới!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Cancel Plan option
            Center(
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface,
                      title: Text(
                        'Hủy Gói Elite Squad? 😢',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        'Cưng sẽ mất toàn bộ quyền xuất clip recap hành trình 4K và bộ nhãn dán dìm hàng độc quyền đấy nha!',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Giữ Lại 💖', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('💔 Đã hủy gói Elite Squad. Các đặc quyền vẫn giữ tới 20/06/2026.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Text('Hủy Gói', style: GoogleFonts.plusJakartaSans(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Hủy đăng ký Elite Squad',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
