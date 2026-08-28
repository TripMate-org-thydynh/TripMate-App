import 'dart:math';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollaborativeScrapbookEditorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const CollaborativeScrapbookEditorScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<CollaborativeScrapbookEditorScreen> createState() =>
      _CollaborativeScrapbookEditorScreenState();
}

class _CollaborativeScrapbookEditorScreenState
    extends State<CollaborativeScrapbookEditorScreen> {
  final List<Map<String, dynamic>> _canvasItems = [
    {
      'id': '1',
      'type': 'polaroid',
      'title': 'Chợ Đêm Vibe 🍢',
      'author': '- Phú Khang -',
      'location': '📍 Da Lat Night Market',
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
      'angle': -0.06,
      'x': 30.0,
      'y': 40.0,
    },
    {
      'id': '2',
      'type': 'polaroid',
      'title': 'Chạy booooo! 🛵💨',
      'author': '- Thảo Ly -',
      'location': '📍 Đồi Đa Phú',
      'url':
          'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=400',
      'angle': 0.05,
      'x': 180.0,
      'y': 150.0,
    },
    {
      'id': '3',
      'type': 'note',
      'text': 'Who drank all the peach tea? 😡🍑',
      'author': '- Alex -',
      'color': const Color(0xFFFFB300),
      'angle': -0.02,
      'x': 50.0,
      'y': 320.0,
    },
  ];

  bool _isBrushMode = false;
  Color _selectedBrushColor = const Color(0xFFFF2E93);
  final List<Offset> _simulatedStroke = [];

  final List<String> _stickerTray = [
    '🔥',
    '🍻',
    '🌿',
    '🍵',
    '💀',
    '🤡',
    '💅',
    '🚀',
    '💖',
    '🍿',
  ];

  void _spawnSticker(String emoji) {
    final random = Random();
    final double rx = 50.0 + random.nextInt(150);
    final double ry = 80.0 + random.nextInt(200);
    final double rAngle = (random.nextDouble() * 0.2) - 0.1;

    setState(() {
      _canvasItems.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'sticker',
        'text': emoji,
        'angle': rAngle,
        'x': rx,
        'y': ry,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Spawned sticker $emoji on canvas! Drag or customize it! ✨',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFFF2E93),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _spawnCustomNote() {
    final random = Random();
    final double rx = 60.0 + random.nextInt(140);
    final double ry = 100.0 + random.nextInt(200);

    setState(() {
      _canvasItems.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'note',
        'text': 'We got lost in Kyoto Station again! 😭🗺️',
        'author': '- Crew -',
        'color': const Color(0xFF00F5FF),
        'angle': 0.03,
        'x': rx,
        'y': ry,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark
        ? const Color(0xFF1A1712)
        : const Color(0xFFFDF6D3);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final neonAmber = const Color(0xFFFFB300);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: bgGradStart),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                color: textPrimary,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Scrapbook Editor',
                              style: AppFonts.body(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: textPrimary,
                          ),
                          onPressed: widget.onThemeToggle,
                        ),
                      ],
                    ),
                  ),

                  // Collaborative tag
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Collaborative Session Live • 4 mates active',
                          style: AppFonts.heading(
                            fontSize: 11,
                            color: textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Toolbox buttons (Note addition, Brush mode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildToolButton(
                          icon: Icons.note_add_outlined,
                          label: 'Add Note',
                          active: false,
                          color: neonCyan,
                          onTap: _spawnCustomNote,
                        ),
                        const SizedBox(width: 10),
                        _buildToolButton(
                          icon: Icons.brush_outlined,
                          label: 'Neon Draw',
                          active: _isBrushMode,
                          color: neonPink,
                          onTap: () {
                            setState(() {
                              _isBrushMode = !_isBrushMode;
                            });
                          },
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Saved Scrapbook canvas layout & synced to DB! 🎨🗄️',
                                ),
                                backgroundColor: neonPink,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 14,
                          ),
                          label: const Text('Save Board'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: neonPink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Neon Brush Colors selector if brush active
                  if (_isBrushMode)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        top: 12,
                        right: 24,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Select Neon Pen:',
                            style: AppFonts.body(
                              color: textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildBrushColorDot(neonPink),
                          _buildBrushColorDot(neonCyan),
                          _buildBrushColorDot(neonAmber),
                          _buildBrushColorDot(Colors.white),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Creative Canvas Box
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131A26) : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.05,
                            ),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: GestureDetector(
                          onPanUpdate: _isBrushMode
                              ? (details) {
                                  RenderBox box =
                                      context.findRenderObject() as RenderBox;
                                  Offset local = box.globalToLocal(
                                    details.globalPosition,
                                  );
                                  setState(() {
                                    _simulatedStroke.add(local);
                                  });
                                }
                              : null,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Grid background mimic
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: GridPainter(isDark: isDark),
                                ),
                              ),

                              // Render dynamic list of items on canvas
                              ..._canvasItems.map((item) {
                                if (item['type'] == 'polaroid') {
                                  return _buildCanvasPolaroid(
                                    item,
                                    textPrimary,
                                    cardBg,
                                  );
                                } else if (item['type'] == 'note') {
                                  return _buildCanvasNote(item, textPrimary);
                                } else if (item['type'] == 'sticker') {
                                  return _buildCanvasSticker(item);
                                }
                                return const SizedBox.shrink();
                              }),

                              // Render custom drawings
                              if (_simulatedStroke.isNotEmpty)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: StrokePainter(
                                      points: _simulatedStroke,
                                      color: _selectedBrushColor,
                                    ),
                                  ),
                                ),

                              // Drawing instruction banner
                              if (_isBrushMode)
                                Positioned(
                                  top: 12,
                                  left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '🎨 Drag finger to paint neon patterns',
                                      style: AppFonts.body(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sticker Tray Dock (Bottom Horizontal Drawer)
                  Container(
                    height: 72,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 4,
                          ),
                          child: Text(
                            'Tap Sticker to Spawn: ',
                            style: AppFonts.body(
                              color: textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _stickerTray.length,
                            itemBuilder: (context, index) {
                              final emoji = _stickerTray[index];
                              return GestureDetector(
                                onTap: () => _spawnSticker(emoji),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = widget.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? color
              : (isDark ? const Color(0xFF262019) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? Colors.transparent
                : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrushColorDot(Color col) {
    final isSel = _selectedBrushColor == col;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBrushColor = col;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: col,
          shape: BoxShape.circle,
          border: isSel ? Border.all(color: Colors.white, width: 2) : null,
        ),
      ),
    );
  }

  Widget _buildCanvasPolaroid(
    Map<String, dynamic> item,
    Color textCol,
    Color cardBg,
  ) {
    return Positioned(
      left: item['x'] as double,
      top: item['y'] as double,
      child: Transform.rotate(
        angle: item['angle'] as double,
        child: Container(
          width: 130,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item['url'] as String,
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 90,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 90,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['title'] as String,
                style: GoogleFonts.caveat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item['author'] as String,
                style: GoogleFonts.caveat(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasNote(Map<String, dynamic> item, Color textCol) {
    final noteColor = item['color'] as Color;
    return Positioned(
      left: item['x'] as double,
      top: item['y'] as double,
      child: Transform.rotate(
        angle: item['angle'] as double,
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: noteColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: noteColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(color: noteColor.withValues(alpha: 0.1), blurRadius: 0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['text'] as String,
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  item['author'] as String,
                  style: GoogleFonts.caveat(
                    fontSize: 12,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasSticker(Map<String, dynamic> item) {
    return Positioned(
      left: item['x'] as double,
      top: item['y'] as double,
      child: Transform.rotate(
        angle: item['angle'] as double,
        child: Text(
          item['text'] as String,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final bool isDark;
  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    double gridSpace = 25.0;
    for (double i = 0; i < size.width; i += gridSpace) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double j = 0; j < size.height; j += gridSpace) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StrokePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  StrokePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) => true;
}
