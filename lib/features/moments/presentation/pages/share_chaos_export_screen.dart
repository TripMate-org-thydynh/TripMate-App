import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareChaosExportScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const ShareChaosExportScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<ShareChaosExportScreen> createState() => _ShareChaosExportScreenState();
}

class _ShareChaosExportScreenState extends State<ShareChaosExportScreen> {
  int _selectedCover = 0;
  int _selectedRatio = 0; // 0: 9:16 (Vertical), 1: 1:1 (Square), 2: 16:9 (Landscape)
  bool _voiceoverEnabled = true;
  bool _bgMusicEnabled = true;
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportPhase = '';

  final List<Map<String, String>> _covers = [
    {
      'title': 'Kyoto Drift 🔥',
      'tagline': 'Fast scooters, heavy rain, maximum chaos.',
      'url': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=600',
    },
    {
      'title': 'Coffee Addicts ☕',
      'tagline': '4 cafes in 3 hours. Heart rate at 180bpm.',
      'url': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=600',
    },
    {
      'title': 'Temples & Crowds ⛩️',
      'tagline': 'Waking up at 5am was totally worth it (not).',
      'url': 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=600',
    },
  ];

  void _startExport() {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportPhase = 'Assembling visual assets... 🎥';
    });

    // Simulate progress sequence
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _exportProgress = 0.25;
        _exportPhase = 'Injecting Matey AI voice commentary... 🗣️🤖';
      });
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _exportProgress = 0.60;
        _exportPhase = 'Applying Gen Z aesthetic filters & lofi beats... ⚡🎸';
      });
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _exportProgress = 0.90;
        _exportPhase = 'Polishing layout resolutions... 🌟';
      });
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() {
        _exportProgress = 1.0;
        _isExporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Export Complete! saved raw MP4 to your gallery! 🚀🔥'),
          backgroundColor: const Color(0xFFFF2E93),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark ? const Color(0xFF0B0F19) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF151926) : const Color(0xFFF3EFE9);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final neonPink = const Color(0xFFFF2E93);
    final neonCyan = const Color(0xFF00F5FF);
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);

    final currentCover = _covers[_selectedCover];

    // Determine preview aspect ratio parameters
    double aspect = 9 / 16;
    if (_selectedRatio == 1) aspect = 1 / 1;
    if (_selectedRatio == 2) aspect = 16 / 9;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradStart, bgGradEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Share the Chaos',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
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
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Convert your raw squad moments into aesthetic Reels or TikTok sequences.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Immersive Viewport Preview
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 280,
                          child: AspectRatio(
                            aspectRatio: aspect,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: neonPink.withValues(alpha: 0.6), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: neonPink.withValues(alpha: 0.15),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      currentCover['url']!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.broken_image, color: Colors.white));
                                      },
                                    ),
                                    // Gradient shading
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.black54, Colors.transparent, Colors.black87],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    // Visual Play arrow icon overlay
                                    const Center(
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white24,
                                        radius: 24,
                                        child: Icon(Icons.play_arrow, color: Colors.white, size: 28),
                                      ),
                                    ),
                                    // Caption Text Overlays (Handwritten caveat text)
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            currentCover['title']!.toUpperCase(),
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            currentCover['tagline']!,
                                            style: GoogleFonts.caveat(
                                              color: Colors.orangeAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // TikTok watermark badge
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '🎵 @tripmate_kyoto',
                                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 8),
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

                      const SizedBox(height: 24),

                      // Aspect Ratio Selection
                      Text(
                        'Aspect Ratio Presets',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildRatioButton(0, '📱 9:16', 'Reels / TikTok'),
                          const SizedBox(width: 10),
                          _buildRatioButton(1, '⬛ 1:1', 'Instagram Grid'),
                          const SizedBox(width: 10),
                          _buildRatioButton(2, '🖥️ 16:9', 'YouTube Vlog'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Cover Selection Carousel
                      Text(
                        'Select Video Style Template',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _covers.length,
                          itemBuilder: (context, index) {
                            final cov = _covers[index];
                            final isSel = _selectedCover == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCover = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 140,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSel ? primaryColor : cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSel ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    cov['title']!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSel ? Colors.white : textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Audio / Commentary Switches
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('🤖', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Matey AI Voiceover', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
                                        Text('Sarcastic narrations generated live.', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _voiceoverEnabled,
                                  activeThumbColor: neonCyan,
                                  onChanged: (val) {
                                    setState(() {
                                      _voiceoverEnabled = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('🎸', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Aesthetic Lofi Beats', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
                                        Text('Subtle background audio tracks.', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _bgMusicEnabled,
                                  activeThumbColor: neonPink,
                                  onChanged: (val) {
                                    setState(() {
                                      _bgMusicEnabled = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Export trigger and interactive loading progress
                      if (_isExporting)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _exportPhase,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _exportProgress,
                                  color: neonPink,
                                  backgroundColor: Colors.white24,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(_exportProgress * 100).toInt()}%',
                                  style: GoogleFonts.outfit(color: neonCyan, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _startExport,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [neonPink, neonPink.withValues(alpha: 0.8)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: neonPink.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Compile & Export Reels Now 🚀',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatioButton(int index, String label, String caption) {
    final isSelected = _selectedRatio == index;
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRatio = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8,
                  color: isSelected ? Colors.white70 : (isDark ? Colors.white30 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
