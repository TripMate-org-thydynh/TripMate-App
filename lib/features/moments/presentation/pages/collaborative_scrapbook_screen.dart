import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollaborativeScrapbookScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const CollaborativeScrapbookScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<CollaborativeScrapbookScreen> createState() => _CollaborativeScrapbookScreenState();
}

class _CanvasItem {
  final String id;
  final String type; // 'polaroid', 'note', 'sticker'
  String text;
  String author;
  String? location;
  String? url;
  Color? color;
  double angle;
  Offset position;

  _CanvasItem({
    required this.id,
    required this.type,
    required this.text,
    required this.author,
    this.location,
    this.url,
    this.color,
    required this.angle,
    required this.position,
  });
}

class _CollaborativeScrapbookScreenState extends State<CollaborativeScrapbookScreen> with SingleTickerProviderStateMixin {
  final List<_CanvasItem> _canvasItems = [];
  bool _isBrushMode = false;
  Color _selectedBrushColor = const Color(0xFFFF2E93);
  final List<List<Offset>> _drawStrokes = [];
  final List<Offset> _currentStroke = [];
  final List<Color> _strokeColors = [];
  
  bool _showStickers = false;
  bool _showLayerSheet = false;
  
  // Collaborative Cursors (Simulating real-time presence)
  Offset _cursorMinh = const Offset(120, 160);
  Offset _cursorLinh = const Offset(240, 280);
  double _cursorMinhAngle = 0.0;
  double _cursorLinhAngle = 0.0;

  final List<String> _stickerTray = ['✨', '✈️', '🔥', '🍜', '🛵', '🏮', '🍻', '🍵', '💀', '💅'];
  
  late AnimationController _presenceController;

  @override
  void initState() {
    super.initState();
    // Pre-populate items
    _canvasItems.add(_CanvasItem(
      id: '1',
      type: 'polaroid',
      text: 'Chợ Đêm Vibe 🍢',
      author: 'Phú Khang',
      location: 'Da Lat Night Market',
      url: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
      angle: -0.06,
      position: const Offset(20, 30),
    ));

    _canvasItems.add(_CanvasItem(
      id: '2',
      type: 'polaroid',
      text: 'Chạy booooo! 🛵💨',
      author: 'Thảo Ly',
      location: 'Đồi Đa Phú',
      url: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=400',
      angle: 0.05,
      position: const Offset(170, 130),
    ));

    _canvasItems.add(_CanvasItem(
      id: '3',
      type: 'note',
      text: 'Who drank all the peach tea? 😡🍑',
      author: 'Alex',
      color: const Color(0xFFFFB300),
      angle: -0.02,
      position: const Offset(30, 260),
    ));

    // Collaborative cursor movements simulation
    _presenceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      final t = _presenceController.value * 2 * pi;
      setState(() {
        _cursorMinh = Offset(
          140 + 60 * sin(t * 1.5),
          180 + 40 * cos(t),
        );
        _cursorMinhAngle = sin(t * 2) * 0.2;

        _cursorLinh = Offset(
          200 + 70 * cos(t * 0.8),
          260 + 50 * sin(t * 1.2),
        );
        _cursorLinhAngle = cos(t * 2) * 0.2;
      });
    });
    _presenceController.repeat();
  }

  @override
  void dispose() {
    _presenceController.dispose();
    super.dispose();
  }

  void _spawnSticker(String emoji) {
    final random = Random();
    final double rx = 50.0 + random.nextInt(150);
    final double ry = 80.0 + random.nextInt(200);
    final double rAngle = (random.nextDouble() * 0.4) - 0.2;

    setState(() {
      _canvasItems.add(_CanvasItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'sticker',
        text: emoji,
        author: 'Duy',
        angle: rAngle,
        position: Offset(rx, ry),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Spawned sticker $emoji on canvas!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: const Color(0xFFFF2E93),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _spawnRandomPolaroid() {
    final random = Random();
    final double rx = 30.0 + random.nextInt(120);
    final double ry = 50.0 + random.nextInt(150);
    final double rAngle = (random.nextDouble() * 0.2) - 0.1;
    final List<String> imageUrls = [
      'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400',
      'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=400',
      'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
    ];
    final titles = ['Kyoto Cafe Vibe 🍵', 'Lost in Streets 🏮', 'Glow Station 🚉'];
    final idx = random.nextInt(imageUrls.length);

    setState(() {
      _canvasItems.add(_CanvasItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'polaroid',
        text: titles[idx],
        author: 'Minh',
        location: 'Kyoto Spot',
        url: imageUrls[idx],
        angle: rAngle,
        position: Offset(rx, ry),
      ));
    });
  }

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    Color selectedColor = const Color(0xFF00F5FF);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode 
                        ? const Color(0xFF1E293B).withValues(alpha: 0.8) 
                        : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: widget.isDarkMode 
                          ? Colors.white.withValues(alpha: 0.1) 
                          : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Brainstorm Note 📝',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controller,
                          maxLines: 3,
                          maxLength: 60,
                          style: GoogleFonts.inter(
                            color: widget.isDarkMode ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type squad memory or inside jokes...',
                            hintStyle: GoogleFonts.inter(
                              color: widget.isDarkMode ? Colors.white38 : Colors.black38,
                            ),
                            filled: true,
                            fillColor: widget.isDarkMode 
                              ? Colors.black.withValues(alpha: 0.2) 
                              : Colors.black.withValues(alpha: 0.03),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Color Accent:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildDialogColorDot(const Color(0xFF00F5FF), selectedColor, (col) {
                              setDialogState(() => selectedColor = col);
                            }),
                            _buildDialogColorDot(const Color(0xFFFF2E93), selectedColor, (col) {
                              setDialogState(() => selectedColor = col);
                            }),
                            _buildDialogColorDot(const Color(0xFFFFB300), selectedColor, (col) {
                              setDialogState(() => selectedColor = col);
                            }),
                            _buildDialogColorDot(const Color(0xFF45FFA4), selectedColor, (col) {
                              setDialogState(() => selectedColor = col);
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  color: widget.isDarkMode ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (controller.text.trim().isNotEmpty) {
                                  final random = Random();
                                  setState(() {
                                    _canvasItems.add(_CanvasItem(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      type: 'note',
                                      text: controller.text.trim(),
                                      author: 'Linh',
                                      color: selectedColor,
                                      angle: (random.nextDouble() * 0.2) - 0.1,
                                      position: const Offset(100, 150),
                                    ));
                                  });
                                }
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedColor,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'Stick It',
                                style: GoogleFonts.plusJakartaSans(
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogColorDot(Color col, Color activeCol, Function(Color) onTap) {
    final active = col == activeCol;
    return GestureDetector(
      onTap: () => onTap(col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: col,
          shape: BoxShape.circle,
          border: active ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: active ? [
            BoxShadow(color: col.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1),
          ] : null,
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
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: col,
          shape: BoxShape.circle,
          border: isSel ? Border.all(color: widget.isDarkMode ? Colors.white : Colors.black, width: 2) : null,
          boxShadow: isSel ? [
            BoxShadow(color: col.withValues(alpha: 0.4), blurRadius: 6),
          ] : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0F0B1E) : const Color(0xFFFAF7FF);
    final bgGradEnd = isDark ? const Color(0xFF06060F) : const Color(0xFFEDE9F5);
    
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E1533);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF16152B) : Colors.white;

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final neonAmber = const Color(0xFFFFB300);
    final neonGreen = const Color(0xFF45FFA4);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgGradStart, bgGradEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Blurry Top Header (Archiving Title & Toggles)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'trip.mate',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'the chaos deserves archiving.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.groups, color: neonPink),
                          onPressed: () {
                            setState(() {
                              _showLayerSheet = !_showLayerSheet;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            color: textPrimary,
                          ),
                          onPressed: widget.onThemeToggle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Presence Tracker Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.greenAccent, blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '6 members archiving chaos...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Live Status Ticker (Mini player / typing indicator)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? const Color(0xFF1F1B3E).withValues(alpha: 0.4) 
                            : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.near_me, size: 12, color: neonCyan),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Minh editing...  •  Linh typing...  •  Duy active',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: neonPink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: neonPink.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Financial Ruin - Squad Remix',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Brush Color Selector (When brush mode active)
              if (_isBrushMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Select Glow Ink:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildBrushColorDot(neonPink),
                      _buildBrushColorDot(neonCyan),
                      _buildBrushColorDot(neonAmber),
                      _buildBrushColorDot(neonGreen),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _drawStrokes.clear();
                            _strokeColors.clear();
                          });
                        },
                        icon: const Icon(Icons.delete_sweep, size: 14, color: Colors.redAccent),
                        label: Text(
                          'Clear Ink',
                          style: GoogleFonts.inter(fontSize: 10, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),

              // Interactive Creative Canvas Box
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0C091A) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.08) 
                          : Colors.black.withValues(alpha: 0.08),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: neonPink.withValues(alpha: isDark ? 0.05 : 0.02),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: GestureDetector(
                        onPanStart: _isBrushMode
                            ? (details) {
                                RenderBox box = context.findRenderObject() as RenderBox;
                                Offset local = box.globalToLocal(details.globalPosition);
                                local = Offset(local.dx - 20, local.dy - 120);
                                setState(() {
                                  _currentStroke.add(local);
                                });
                              }
                            : null,
                        onPanUpdate: _isBrushMode
                            ? (details) {
                                RenderBox box = context.findRenderObject() as RenderBox;
                                Offset local = box.globalToLocal(details.globalPosition);
                                local = Offset(local.dx - 20, local.dy - 120);
                                setState(() {
                                  _currentStroke.add(local);
                                });
                              }
                            : null,
                        onPanEnd: _isBrushMode
                            ? (details) {
                                setState(() {
                                  _drawStrokes.add(List.from(_currentStroke));
                                  _strokeColors.add(_selectedBrushColor);
                                  _currentStroke.clear();
                                });
                              }
                            : null,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Canvas Grid Pattern
                            Positioned.fill(
                              child: CustomPaint(
                                painter: GridPainter(isDark: isDark),
                              ),
                            ),

                            // Background watermark "making memories permanent."
                            Center(
                              child: Opacity(
                                opacity: isDark ? 0.07 : 0.04,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.photo_library, size: 80, color: Colors.deepPurple),
                                    const SizedBox(height: 8),
                                    Text(
                                      'making memories permanent.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Neon Paint Drawings
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: MultiStrokePainter(
                                    strokes: _drawStrokes,
                                    colors: _strokeColors,
                                    currentStroke: _currentStroke,
                                    currentColor: _selectedBrushColor,
                                  ),
                                ),
                              ),
                            ),

                            // Render Canvas Drag-able Items
                            ..._canvasItems.map((item) {
                              return Positioned(
                                left: item.position.dx,
                                top: item.position.dy,
                                child: GestureDetector(
                                  onPanUpdate: _isBrushMode 
                                      ? null 
                                      : (details) {
                                          setState(() {
                                            item.position += details.delta;
                                          });
                                        },
                                  child: Transform.rotate(
                                    angle: item.angle,
                                    child: _buildCanvasComponent(item, cardBg, textPrimary, textSecondary),
                                  ),
                                ),
                              );
                            }),

                            // Realtime cursors simulation overlay
                            Positioned(
                              left: _cursorMinh.dx,
                              top: _cursorMinh.dy,
                              child: Transform.rotate(
                                angle: _cursorMinhAngle,
                                child: _buildLiveCursor('Minh', neonCyan),
                              ),
                            ),

                            Positioned(
                              left: _cursorLinh.dx,
                              top: _cursorLinh.dy,
                              child: Transform.rotate(
                                angle: _cursorLinhAngle,
                                child: _buildLiveCursor('Linh', neonPink),
                              ),
                            ),

                            if (_isBrushMode)
                              Positioned(
                                top: 12,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '✏️ Neon Brush Mode Active - Paint freely!',
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Sliding Sticker Tray Overlay
              if (_showStickers) _buildStickersDrawer(cardBg, textPrimary),

              // Presence details bottom sheet / panel
              if (_showLayerSheet) _buildPresencePanel(cardBg, textPrimary, textSecondary),

              // Bottom Creative Toolbox Dock
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark 
                      ? const Color(0xFF141226).withValues(alpha: 0.8) 
                      : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark 
                        ? Colors.white.withValues(alpha: 0.1) 
                        : Colors.black.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDockIcon(
                            icon: Icons.add_photo_alternate,
                            tooltip: 'Add Polaroid',
                            onTap: _spawnRandomPolaroid,
                          ),
                          _buildDockIcon(
                            icon: Icons.mood,
                            tooltip: 'Sticker Drawer',
                            onTap: () {
                              setState(() {
                                _showStickers = !_showStickers;
                              });
                            },
                          ),
                          // Mega Neon Draw Button (offsetted, styled primary-container)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isBrushMode = !_isBrushMode;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: _isBrushMode ? neonPink : Colors.deepPurple,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isBrushMode ? neonPink : Colors.deepPurple).withValues(alpha: 0.4),
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.draw,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          _buildDockIcon(
                            icon: Icons.text_fields,
                            tooltip: 'Add Note',
                            onTap: _showAddNoteDialog,
                          ),
                          _buildDockIcon(
                            icon: Icons.layers,
                            tooltip: 'Clear Layout',
                            onTap: () {
                              setState(() {
                                _canvasItems.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockIcon({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    final isDark = widget.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF221F3D) : const Color(0xFFF3EDF7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.black87,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasComponent(_CanvasItem item, Color cardBg, Color textPrimary, Color textSecondary) {
    if (item.type == 'polaroid') {
      return Container(
        width: 140,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.url ?? 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=400',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, err, stack) => Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.text,
              style: GoogleFonts.caveat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.location ?? '',
                    style: GoogleFonts.caveat(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '- ${item.author}',
                  style: GoogleFonts.caveat(
                    fontSize: 9,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (item.type == 'note') {
      final accent = item.color ?? const Color(0xFF00F5FF);
      return Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.text,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '- ${item.author}',
                style: GoogleFonts.caveat(
                  fontSize: 11,
                  color: textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (item.type == 'sticker') {
      return Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          item.text,
          style: const TextStyle(fontSize: 36),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLiveCursor(String name, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.near_me,
          size: 16,
          color: color,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickersDrawer(Color cardBg, Color textPrimary) {
    return Container(
      height: 90,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDarkMode ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
            child: Text(
              'Tap Sticker to Spawn: ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _stickerTray.length,
              itemBuilder: (context, index) {
                final sticker = _stickerTray[index];
                return GestureDetector(
                  onTap: () => _spawnSticker(sticker),
                  child: Container(
                    margin: const EdgeInsets.only(right: 14),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.isDarkMode 
                        ? Colors.black26 
                        : Colors.black.withValues(alpha: 0.03),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        sticker,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresencePanel(Color cardBg, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.isDarkMode ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collaborative Members',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  setState(() {
                    _showLayerSheet = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMemberRow('Minh Nhật', 'Editing Board', const Color(0xFF00F5FF), true),
          const SizedBox(height: 6),
          _buildMemberRow('Thảo Ly', 'Browsing Gallery', const Color(0xFF45FFA4), true),
          const SizedBox(height: 6),
          _buildMemberRow('Phú Khang', 'Viewing Timeline', const Color(0xFFFFB300), true),
          const SizedBox(height: 6),
          _buildMemberRow('Alex Crew', 'Away', Colors.grey, false),
        ],
      ),
    );
  }

  Widget _buildMemberRow(String name, String action, Color color, bool online) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: online ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            action,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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
        ? Colors.white.withValues(alpha: 0.03) 
        : Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    double gridSpace = 30.0;
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

class MultiStrokePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Color> colors;
  final List<Offset> currentStroke;
  final Color currentColor;

  MultiStrokePainter({
    required this.strokes,
    required this.colors,
    required this.currentStroke,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw past strokes
    for (int index = 0; index < strokes.length; index++) {
      final stroke = strokes[index];
      final color = colors[index];
      final paint = Paint()
        ..color = color
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      // Neon glowing shadow effect
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 12.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      _drawSingleStroke(canvas, stroke, shadowPaint);
      _drawSingleStroke(canvas, stroke, paint);
    }

    // Draw current active stroke
    if (currentStroke.isNotEmpty) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
        
      final shadowPaint = Paint()
        ..color = currentColor.withValues(alpha: 0.3)
        ..strokeWidth = 12.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      _drawSingleStroke(canvas, currentStroke, shadowPaint);
      _drawSingleStroke(canvas, currentStroke, paint);
    }
  }

  void _drawSingleStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MultiStrokePainter oldDelegate) => true;
}
