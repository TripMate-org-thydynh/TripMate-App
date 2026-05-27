import '../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pages
import 'pages/subscription_checkout_screen.dart';
import 'pages/billing_history_screen.dart';
import 'pages/subscription_settings_screen.dart';
import 'pages/referral_rewards_screen.dart';
import 'pages/promo_code_screen.dart';
import 'pages/creator_revenue_dashboard_screen.dart';

class PremiumHubScreen extends StatelessWidget {
  const PremiumHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Brand Design System constants
    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final backgroundColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Luxury Glowing Header
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'TripMate Premium Space 💎',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF3F1B68), // Deep Dark Purple
                            backgroundColor, // Obsidian
                          ]
                        : [
                            const Color(0xFFF5EDFF), // Soft Purple
                            backgroundColor, // Warm Ivory
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: -30,
                      top: 40,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondaryColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: 20,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text('💎', style: TextStyle(fontSize: 38)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Options List
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header status card
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? primaryColor.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Elite Squad Active! 👑',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Đặc quyền xa xỉ bậc nhất đã mở khóa cho tài khoản của cưng.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'Dịch Vụ Đăng Ký 💳',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                _buildOptionCard(
                  title: 'Gói Cước & Nâng Cấp 👑',
                  desc: 'So sánh đặc quyền, bảng giá và kích hoạt Elite Squad',
                  icon: Icons.workspace_premium_outlined,
                  color: primaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubscriptionCheckoutScreen()),
                  ),
                ),
                _buildOptionCard(
                  title: 'Thiết Lập Gia Hạn ⚙',
                  desc: 'Quản lý phương thức nguồn tiền tự động gia hạn cước',
                  icon: Icons.settings_applications_outlined,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubscriptionSettingsScreen()),
                  ),
                ),
                _buildOptionCard(
                  title: 'Lịch Sử Invoices 🧾',
                  desc: 'Xem và tải về các hóa đơn giao dịch PDF của cưng',
                  icon: Icons.history_edu_outlined,
                  color: Colors.blueAccent,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BillingHistoryScreen()),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Không Gian Marketing & Tác Giả 🎨',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                _buildOptionCard(
                  title: 'Giới Thiệu Nhận XP 🎁',
                  desc: 'Mời thêm bạn cùng đi phượt để cùng hưởng cấp độ',
                  icon: Icons.card_giftcard_outlined,
                  color: Colors.orangeAccent,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReferralRewardsScreen()),
                  ),
                ),
                _buildOptionCard(
                  title: 'Nhập Mã Giảm Giá 🎫',
                  desc: 'Kích hoạt phiếu quà tặng du lịch & giảm giá voucher',
                  icon: Icons.confirmation_number_outlined,
                  color: Colors.greenAccent,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PromoCodeScreen()),
                  ),
                ),
                _buildOptionCard(
                  title: 'Thu Nhập Sáng Tạo 🎨',
                  desc: 'Dashboard thống kê chia sẻ doanh thu shop theme / sticker',
                  icon: Icons.monetization_on_outlined,
                  color: secondaryColor,
                  isDark: isDark,
                  surfaceColor: surfaceColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatorRevenueDashboardScreen()),
                  ),
                ),

                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color surfaceColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          subtitle: Text(
            desc,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey, height: 1.3),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ),
      ),
    );
  }
}
