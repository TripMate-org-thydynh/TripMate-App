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
  int _selectedRatio = 0; // 0: 9:16, 1: 1:1, 2: 16:9
  String _selectedTemplate = 'Tokyo Neon';
  bool _voiceoverEnabled = true;
  bool _bgMusicEnabled = true;

  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportPhase = '';

  final List<Map<String, dynamic>> _templates = [
    {
      'name': 'Tokyo Neon',
      'glowColor': const Color(0xFF00E5FF),
      'image': 'https://images.unsplash.com/photo-1540959733332-eab4deceeaf7?w=300&auto=format&fit=crop&q=80',
    },
    {
      'name': 'VHS Nostalgia',
      'glowColor': const Color(0xFFFF2E93),
      'image': 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=300&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Chaos Energy',
      'glowColor': const Color(0xFF68FCBF),
      'image': 'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=300&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Cinematic',
      'glowColor': const Color(0xFF8B5CF6),
      'image': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=300&auto=format&fit=crop&q=80',
    },
  ];

  void _startExport() {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportPhase = 'Assembling chaotic frames... 🎬';
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _exportProgress = 0.35;
        _exportPhase = 'Generating AI Matey audio roast commentary... 🎙️🤖';
      });
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _exportProgress = 0.70;
        _exportPhase = 'Applying lofi vaporwave effects... ⚡🎆';
      });
    });

    Future.delayed(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      setState(() {
        _exportProgress = 1.0;
        _isExporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video exported successfully! Added to your gallery 🎞️🚀'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFFF2E93),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final neonPink = const Color(0xFFFF2E93);
    
    final bgColor = isDark ? const Color(0xFF040914) : const Color(0xFFFCFAF6);
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF171F33) : Colors.white;

    final glassBorder = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    // Aspect ratio mappings
    double aspect = 9 / 16;
    if (_selectedRatio == 1) aspect = 1 / 1;
    if (_selectedRatio == 2) aspect = 16 / 9;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Soft atmospheric light gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.3,
                  colors: isDark
                      ? [const Color(0xFF3F1B68).withValues(alpha: 0.2), Colors.transparent]
                      : [const Color(0xFFF5EDFF).withValues(alpha: 0.5), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Share Trip',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading and description
                        Text(
                          '6 idiots. 1 unforgettable Đà Lạt trip.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select your favorite aesthetic aspect ratios & presets below:',
                          style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
                        ),
                        const SizedBox(height: 18),

                        // Main Preview Box with animated aspect ratio matching
                        Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            height: 250,
                            child: AspectRatio(
                              aspectRatio: aspect,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: _templates.firstWhere((t) => t['name'] == _selectedTemplate)['glowColor'] as Color,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_templates.firstWhere((t) => t['name'] == _selectedTemplate)['glowColor'] as Color).withValues(alpha: 0.3),
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
                                        _templates.firstWhere((t) => t['name'] == _selectedTemplate)['image'] as String,
                                        fit: BoxFit.cover,
                                      ),
                                      // Dark fading gradient Protect Text
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.black38, Colors.transparent, Colors.black87],
                                          ),
                                        ),
                                      ),
                                      // Centered Play Button overlay
                                      const Center(
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.white24,
                                          child: Icon(Icons.play_arrow, color: Colors.white, size: 28),
                                        ),
                                      ),
                                      // Pinned description overlays
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'ĐÀ LẠT VIBES',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '6 idiots. 1 unforgettable trip.',
                                              style: GoogleFonts.caveat(
                                                color: Colors.orangeAccent,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
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

                        // Aspect Ratio selectors
                        Text(
                          'Aspect Ratio Presets',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRatioBtn(0, Icons.smartphone, '9:16', 'TikTok / Reels', primaryColor, textPrimary, isDark),
                            const SizedBox(width: 10),
                            _buildRatioBtn(1, Icons.crop_square, '1:1', 'Instagram', primaryColor, textPrimary, isDark),
                            const SizedBox(width: 10),
                            _buildRatioBtn(2, Icons.crop_16_9, '16:9', 'Vlog', primaryColor, textPrimary, isDark),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Template Selector Grid
                        Text(
                          'Aesthetic Templates',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _templates.length,
                            itemBuilder: (context, index) {
                              final item = _templates[index];
                              final isSelected = _selectedTemplate == item['name'];
                              final activeColor = item['glowColor'] as Color;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTemplate = item['name']),
                                child: Container(
                                  width: 90,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? activeColor : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: activeColor.withValues(alpha: 0.3),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(item['image'] as String, fit: BoxFit.cover),
                                        Container(color: Colors.black26),
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          right: 8,
                                          child: Text(
                                            item['name'] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Export configurations options
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: glassBorder),
                          ),
                          child: Column(
                            children: [
                              _buildSettingsRow('🤖', 'Matey AI Audio Commentary', _voiceoverEnabled, (v) => setState(() => _voiceoverEnabled = v), textPrimary, textSecondary),
                              const Divider(height: 24),
                              _buildSettingsRow('🎸', 'Vaporwave Lofi Beats', _bgMusicEnabled, (v) => setState(() => _bgMusicEnabled = v), textPrimary, textSecondary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Action Buttons (Kinetic layout)
                        if (_isExporting) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: glassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_exportPhase, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary)),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(value: _exportProgress, backgroundColor: isDark ? Colors.white10 : Colors.black12, minHeight: 6, color: neonPink),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          GestureDetector(
                            onTap: _startExport,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  colors: [neonPink, const Color(0xFF6D3BD7)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: neonPink.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.share, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Share to TikTok',
                                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _startExport,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: glassBorder),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.video_library, color: textPrimary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Post to Reels',
                                      style: GoogleFonts.plusJakartaSans(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioBtn(int index, IconData icon, String title, String subtitle, Color activeBg, Color textPrimary, bool isDark) {
    final isSelected = _selectedRatio == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRatio = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : (isDark ? const Color(0xFF171F33) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : textPrimary, size: 20),
              const SizedBox(height: 4),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : textPrimary)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 8, color: isSelected ? Colors.white70 : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(String emoji, String title, bool value, ValueChanged<bool> onChanged, Color textPrimary, Color textSecondary) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary)),
              Text('Live mock content commentary overlay.', style: GoogleFonts.inter(fontSize: 10, color: textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF00E5FF),
        ),
      ],
    );
  }
}
