import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemePreviewScreen extends StatelessWidget {
  final String themeName;

  const ThemePreviewScreen({super.key, required this.themeName});

  @override
  Widget build(BuildContext context) {
    // Detect active colors depending on the selected theme type
    final List<Color> gradientColors;
    final String welcomeMessage;
    final String mockActivityText;

    if (themeName.contains('Tokyo')) {
      gradientColors = const [Color(0xFF8B5CF6), Color(0xFFFF007F), Color(0xFF00F0FF)];
      welcomeMessage = 'Đây là cách giao diện ứng dụng của cưng hiển thị khi áp dụng theme Tokyo Neon. Đẹp rực rỡ và tràn đầy cảm hứng đêm dài cyberpunk!';
      mockActivityText = 'Đang du hí tại quán mì Ramen đêm Shibuya 🍜';
    } else if (themeName.contains('Đà Lạt')) {
      gradientColors = const [Color(0xFF34D399), Color(0xFF1E293B), Color(0xFF0F172A)];
      welcomeMessage = 'Giao diện ngập tràn sắc thông xanh dịu mắt và sương mù lãng đãng của Đà Lạt. Giúp chuyến đi của nhóm thêm phần thư thái, chữa lành.';
      mockActivityText = 'Đang nhâm nhi cafe trứng giữa đồi thông mộng mơ ☕';
    } else {
      // Beach Chaos / Other
      gradientColors = const [Color(0xFFFB923C), Color(0xFF06B6D4), Color(0xFF0F172A)];
      welcomeMessage = 'Sự va chạm tuyệt vời giữa nắng vàng rực rỡ và sóng biển xanh ngọc. Tràn đầy năng lượng Gen Z nổi loạn và tươi mới!';
      mockActivityText = 'Đang lướt sóng đón hoàng hôn Nha Trang cực nhiệt 🏄‍♂️';
    }

    return Scaffold(
      body: Stack(
        children: [
          // Mock theme ambient background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Subtle mesh overlay shadow
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black38,
                  Colors.transparent,
                  Colors.black87,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26.withValues(alpha: 0.3),
                      border: Border.all(color: Colors.white12, width: 1.2),
                    ),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Title and badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: Text(
                      'THEME ACTIVE PREVIEW',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    themeName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    welcomeMessage,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // High-fidelity Glassmorphic Mock Chat Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30, width: 1.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Image.network(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAHv_wMKIY-_-fuY5MX_0fgt720aCkJF6IqOZh7Ee-UvfG2q_t_rHUFw3ufFKAIC0rW0StnBZPkR-7-WGrPMdJ-UR3mk_NJJVBa_mIyaVw2Dn6GHrVDVz7RlHlb0pv_gh816-8gkQb7udbrZwr_VdaV65AlLGb2LNEIQvk_c_soo9hGLsT4uj0TJlBAy3sLBxnNx5C9-E6quRqsjOfrouyKCo-2mqWi-ACFyUVCiyrbPAKws-vCq3rzcSLBnflNoRdcbuIns8WHFz0b',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Alex Nguyễn',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mockActivityText,
                                      style: GoogleFonts.inter(
                                        color: Colors.white70.withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '99+ XP',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '"Hội nhóm nhìn cưng xỉu, theme xịn làm màu sắc đổi chất lừ!" 💬',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lock / Use this theme button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🎉 Đã áp dụng theme $themeName!'),
                            backgroundColor: Colors.indigo,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        'Áp Dụng Theme Này 💫',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
