import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'place_detail_screen.dart';

class LiveMapSquadTrackingScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const LiveMapSquadTrackingScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<LiveMapSquadTrackingScreen> createState() => _LiveMapSquadTrackingScreenState();
}

class _LiveMapSquadTrackingScreenState extends State<LiveMapSquadTrackingScreen> {
  int _selectedSpotIndex = 0;

  final List<Map<String, dynamic>> _magicSpots = [
    {
      'title': 'The Hill Station Cafe',
      'rating': '4.9',
      'vibe': 'Specialty Cafe',
      'description': 'Vintage vibe, great pour-overs. French colonial style.',
      'distance': '200m away',
      'status': 'Nam Trung is here',
      'emoji': '☕',
      'lat': 120.0,
      'lng': 90.0,
    },
    {
      'title': 'Secret Pine Viewpoint',
      'rating': '4.8',
      'vibe': 'Hidden Location',
      'description': 'Perfect sunset photo op. Winding scenic forest roads.',
      'distance': '800m away',
      'status': 'Trending Spot',
      'emoji': '📸',
      'lat': 260.0,
      'lng': 180.0,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xDD171F33) : Colors.white.withValues(alpha: 0.95);
    final glassBorder = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full Screen custom painted road grid map canvas
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF040914) : const Color(0xFFF3EFE9),
              child: CustomPaint(
                painter: LiveMapPainter(isDark: isDark, primaryColor: primaryColor, secondaryColor: secondaryColor),
              ),
            ),
          ),

          // 2. Animated floating squad coordinates pin bubbles
          _buildMapPin(top: 100, left: 60, name: 'Nam Trung', emoji: '☕', color: Colors.greenAccent, isMe: false),
          _buildMapPin(top: 240, left: 160, name: 'Thảo Ly (Me)', emoji: '📸', color: primaryColor, isMe: true),
          _buildMapPin(top: 160, left: 280, name: 'Minh Nhật', emoji: '🚶‍♀️', color: secondaryColor, isMe: false),
          _buildMapPin(top: 330, left: 80, name: 'Phú Khang', emoji: '😴', color: Colors.amberAccent, isMe: false),

          // Magic Places indicators on the canvas
          ..._magicSpots.asMap().entries.map((entry) {
            final idx = entry.key;
            final spot = entry.value;
            final isSelected = _selectedSpotIndex == idx;
            return Positioned(
              top: spot['lat'] as double,
              left: spot['lng'] as double,
              child: GestureDetector(
                onTap: () => setState(() => _selectedSpotIndex = idx),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.black87,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: isSelected ? 0.5 : 0.1),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Text(spot['emoji'], style: const TextStyle(fontSize: 16)),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8)],
                        ),
                        child: Text(
                          spot['title'],
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          }),

          // 3. Floating top app navigation indicators
          Positioned(
            top: 48,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: glassBorder),
                        ),
                        child: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 18),
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: glassBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Đà Lạt • Squad Tracking',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onThemeToggle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: glassBorder),
                        ),
                        child: Icon(
                          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          color: textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Custom bottom sheet detail drawer floating panel (Nearby Magic)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _magicSpots[_selectedSpotIndex]['vibe'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                _magicSpots[_selectedSpotIndex]['rating'],
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _magicSpots[_selectedSpotIndex]['title'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _magicSpots[_selectedSpotIndex]['description'],
                        style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _magicSpots[_selectedSpotIndex]['distance'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                              Text(
                                _magicSpots[_selectedSpotIndex]['status'],
                                style: TextStyle(fontSize: 10, color: textSecondary),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaceDetailScreen(
                                    isDarkMode: widget.isDarkMode,
                                    onThemeToggle: widget.onThemeToggle,
                                    placeName: _magicSpots[_selectedSpotIndex]['title'],
                                    placeDescription: _magicSpots[_selectedSpotIndex]['description'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 10)],
                              ),
                              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMapPin({
    required double top,
    required double left,
    required String name,
    required String emoji,
    required Color color,
    required bool isMe,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF8B5CF6) : Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 2),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.25),
                  border: Border.all(color: color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              Text(emoji, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class LiveMapPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  LiveMapPainter({required this.isDark, required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 40) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // Modern glowing schematic road pathways
    final roadPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 14.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(0, 120);
    path1.quadraticBezierTo(size.width / 2, 70, size.width, 220);
    path1.moveTo(100, 0);
    path1.lineTo(130, size.height);

    path1.moveTo(0, 380);
    path1.quadraticBezierTo(size.width / 3, 340, size.width, 450);

    canvas.drawPath(path1, roadPaint);

    final streetPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.09) : Colors.black.withValues(alpha: 0.07)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    path2.moveTo(270, 0);
    path2.quadraticBezierTo(220, 280, 320, size.height);

    canvas.drawPath(path2, streetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
