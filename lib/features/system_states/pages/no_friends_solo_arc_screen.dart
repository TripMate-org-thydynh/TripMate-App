import '../../../core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoFriendsSoloArcScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const NoFriendsSoloArcScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<NoFriendsSoloArcScreen> createState() => _NoFriendsSoloArcScreenState();
}

class _NoFriendsSoloArcScreenState extends State<NoFriendsSoloArcScreen> {
  void _inviteFriends() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      backgroundColor: widget.isDarkMode ? TripMateTheme.darkSurface : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã mời nhóm bạn thân 🥳',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gửi mã này cho những "chiến thần đi lạc" để cùng nhau thiết lập Itinerary náo nhiệt nhất!',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: (widget.isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDarkMode ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText(
                    'SQUAD-CHILL-99',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: widget.isDarkMode ? TripMateTheme.darkSecondary : TripMateTheme.lightPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Đã sao chép mã mời vào khay nhớ tạm!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _shareQR() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: widget.isDarkMode ? TripMateTheme.darkSurface : Colors.white,
        title: Center(
          child: Text(
            'My Squad QR Code',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 140, color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quét để gia nhập hội du hí của tôi!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final bgColor = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background glows
          if (isDark)
            Positioned(
              bottom: 100,
              right: -50,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withValues(alpha: 0.1),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu, color: textPrimary),
                        onPressed: () {},
                      ),
                      Text(
                        'trip.mate',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: -1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          color: primaryColor,
                        ),
                        onPressed: widget.onThemeToggle,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Graphic Container: Solo travelers unlocked
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  isDark ? const Color(0xFF4F46E5) : const Color(0xFFC084FC),
                                  secondaryColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: secondaryColor.withValues(alpha: 0.3),
                                  blurRadius: 24,
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '👋🏽🧗🏽‍♂️',
                                style: TextStyle(fontSize: 60),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          Text(
                            'your chaos squad\nis missing 😭',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              height: 1.25,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'solo traveler arc unlocked. invite your travel idiots.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: textSecondary,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // primary CTA button
                          GestureDetector(
                            onTap: _inviteFriends,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  colors: [
                                    isDark ? primaryColor : const Color(0xFF4F46E5),
                                    secondaryColor,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: secondaryColor.withValues(alpha: 0.35),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.group_add, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Invite Your Squad',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // secondary CTA button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _shareQR,
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Share My QR'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Mock navigation (group icon is highlighted and offset)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(top: BorderSide(color: borderCol)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBottomIcon(Icons.explore_outlined, false, textSecondary, primaryColor),
                      
                      // highlighted active squad tab
                      Transform.translate(
                        offset: const Offset(0, -14),
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: secondaryColor.withValues(alpha: 0.2),
                            border: Border.all(color: secondaryColor.withValues(alpha: 0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Icon(Icons.group, color: secondaryColor, size: 28),
                        ),
                      ),

                      _buildBottomIcon(Icons.add_circle_outline, false, textSecondary, primaryColor),
                      _buildBottomIcon(Icons.map_outlined, false, textSecondary, primaryColor),
                      _buildBottomIcon(Icons.person_outline, false, textSecondary, primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, bool isActive, Color inactiveCol, Color activeCol) {
    return Icon(
      icon,
      color: isActive ? activeCol : inactiveCol.withValues(alpha: 0.6),
      size: 24,
    );
  }
}
