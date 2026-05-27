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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF06B6D4) : const Color(0xFFEBA83A);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full screen custom map grid
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6),
              child: CustomPaint(
                painter: LiveMapPainter(isDark: isDark, colorScheme: colorScheme),
              ),
            ),
          ),

          // 2. Map Pinned Overlay Items
          _buildMapPin(top: 80, left: 70, name: "Nam Trung", emoji: "☕", color: Colors.greenAccent),
          _buildMapPin(top: 240, left: 180, name: "Thảo Ly (Me)", emoji: "📸", color: primaryColor, isMe: true),
          _buildMapPin(top: 150, left: 260, name: "Minh Nhật", emoji: "🚶‍♀️", color: Colors.greenAccent),
          _buildMapPin(top: 320, left: 90, name: "Phú Khang", emoji: "😴", color: Colors.amberAccent),

          // Magical spots markers
          ..._magicSpots.asMap().entries.map((entry) {
            final idx = entry.key;
            final spot = entry.value;
            final isSelected = _selectedSpotIndex == idx;
            return Positioned(
              top: spot['lat'] as double,
              left: spot['lng'] as double,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSpotIndex = idx;
                  });
                },
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
                            color: primaryColor.withValues(alpha: isSelected ? 0.4 : 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        spot['emoji'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
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

          // 3. Elegant floating header bar
          Positioned(
            top: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87, size: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đà Lạt • Squad Tracking',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onThemeToggle,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.white : Colors.black87, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // 4. Custom bottom sheet detail drawer
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
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
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _magicSpots[_selectedSpotIndex]['description'],
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                          Text(
                            _magicSpots[_selectedSpotIndex]['status'],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                          ),
                          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
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
    bool isMe = false,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(color: color, width: 2),
                ),
              ),
              Text(emoji, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class LiveMapPainter extends CustomPainter {
  final bool isDark;
  final ColorScheme colorScheme;

  LiveMapPainter({required this.isDark, required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    // Draw grid coordinates
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 40) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    // Abstract roads
    final roadPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 12.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(0, 100);
    path1.quadraticBezierTo(size.width / 2, 80, size.width, 240);
    path1.moveTo(100, 0);
    path1.lineTo(120, size.height);

    path1.moveTo(0, 400);
    path1.quadraticBezierTo(size.width / 3, 360, size.width, 480);

    canvas.drawPath(path1, roadPaint);

    // Accent secondary street overlays
    final streetPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    path2.moveTo(250, 0);
    path2.quadraticBezierTo(200, 300, 300, size.height);

    canvas.drawPath(path2, streetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
