import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import 'memory_archive_screen.dart';
import 'ai_memory_sorting_screen.dart';
import 'favorite_memories_screen.dart';
import 'shared_album_screen.dart';
import 'share_chaos_export_screen.dart';
import 'collaborative_scrapbook_editor_screen.dart';
import 'memory_timeline_screen.dart';
import 'ai_caption_generator_screen.dart';

class MemoryWallScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MemoryWallScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MemoryWallScreen> createState() => _MemoryWallScreenState();
}

class _MemoryWallScreenState extends State<MemoryWallScreen> {
  final List<Widget> _floatingEmojis = [];

  void _addFloatingEmoji(String emoji, double startX) {
    final key = UniqueKey();
    setState(() {
      _floatingEmojis.add(
        FloatingEmojiWidget(
          key: key,
          emoji: emoji,
          startX: startX,
          onFinished: () {
            setState(() {
              _floatingEmojis.removeWhere((w) => w.key == key);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    
    // TripMate color tokens
    final bgGradStart = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final bgGradEnd = isDark ? const Color(0xFF171F33) : const Color(0xFFF3EFE9);
    final primary = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);
    final surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;

    final mintColor = const Color(0xFF34D399);

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
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Scrapbook Content Layout
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: surfaceColor.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: textPrimary.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hà Giang Loop 🏍️',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Oct 14, 2023 • Squad Album',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Dark/Light Theme Toggle
                        GestureDetector(
                          onTap: widget.onThemeToggle,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: surfaceColor.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: textPrimary.withValues(alpha: 0.1),
                                  width: 1),
                            ),
                            child: Icon(
                              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                              color: textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tall Scrapbook scrollable canvas
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        height: 1040,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            // Polaroid 1 (Quan Ba Pass)
                            Positioned(
                              top: 20,
                              left: 16,
                              child: _buildPolaroid(
                                context: context,
                                imageUrl: 'https://images.unsplash.com/photo-1623091426177-38e21c322d7d?w=600',
                                time: '09:42 AM',
                                caption: 'Climbing Heaven\'s Gate ⛰️',
                                rotation: -0.04,
                                badge: _buildStickerBadge("location_on Quan Ba", mintColor),
                              ),
                            ),

                            // Polaroid 2 (Video Loop Path)
                            Positioned(
                              top: 60,
                              right: 16,
                              child: _buildPolaroid(
                                context: context,
                                imageUrl: 'https://images.unsplash.com/photo-1596422846543-75c6fc18a52b?w=600',
                                time: '14:20 PM',
                                caption: 'Chasing the Loop loops 🏍️💨',
                                rotation: 0.05,
                                isVideo: true,
                                videoDuration: '00:15',
                              ),
                            ),

                            // AI Memory Vibe
                            Positioned(
                              top: 400,
                              left: 24,
                              right: 24,
                              child: _buildAIMemoryVibeCard(
                                context: context,
                                text: 'That morning climb out of Ha Giang: high adrenaline, numb hands, and absolute silence...',
                              ),
                            ),

                            // Sticky Quote Paper note
                            Positioned(
                              top: 560,
                              left: 16,
                              child: _buildStickyNote(
                                context: context,
                                quote: '"I think I lost feeling in my legs but... worth it."',
                                author: 'Alex',
                                rotation: -0.06,
                              ),
                            ),

                            // Polaroid 3 (Campfire party)
                            Positioned(
                              top: 590,
                              right: 16,
                              child: _buildPolaroid(
                                context: context,
                                imageUrl: 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=600',
                                time: '22:43 PM',
                                caption: 'Under local starry skies ✨🏕️',
                                rotation: 0.03,
                              ),
                            ),

                            // Telemetry progress card
                            Positioned(
                              top: 880,
                              left: 20,
                              right: 20,
                              child: _buildTelemetryCard(
                                context: context,
                                progressText: "Route Progress: 120 / 350 km",
                                progressPercent: 120 / 350,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Floating Emojis overlay stack
              ..._floatingEmojis,

              // Bottom floating reaction pill & Menu Hub button
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: surfaceColor.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: textPrimary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildReactionButton("🔥", context),
                            _buildReactionButton("😂", context),
                            _buildReactionButton("💀", context),
                            _buildReactionButton("💯", context),
                            const SizedBox(width: 8),
                            Container(
                              height: 20,
                              width: 1,
                              color: textSecondary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(width: 8),
                            // Hub sheet opener button
                            GestureDetector(
                              onTap: () => _showHubMenu(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome_mosaic_outlined, color: primary, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Hub Hub 🔮",
                                      style: GoogleFonts.outfit(
                                        color: primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
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

  // Floating reaction spawner
  Widget _buildReactionButton(String emoji, BuildContext context) {
    return GestureDetector(
      onTap: () {
        final double width = MediaQuery.of(context).size.width;
        final double randomX = (width * 0.1) + (Random().nextDouble() * (width * 0.7));
        _addFloatingEmoji(emoji, randomX);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  // Floating Location sticker inside a polaroid or canvas
  Widget _buildStickerBadge(String label, Color color) {
    return Transform.rotate(
      angle: 0.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: color, size: 10),
            const SizedBox(width: 2),
            Text(
              label.replaceAll("location_on ", ""),
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black87,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom physical polaroid builder
  Widget _buildPolaroid({
    required BuildContext context,
    required String imageUrl,
    required String time,
    required String caption,
    double rotation = 0.0,
    Widget? badge,
    bool isVideo = false,
    String? videoDuration,
  }) {
    final isDark = widget.isDarkMode;
    final frameColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);

    return Transform.rotate(
      angle: rotation,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 172,
            padding: const EdgeInsets.all(8).copyWith(bottom: 24),
            decoration: BoxDecoration(
              color: frameColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.4), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inner Image box
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        imageUrl,
                        height: 156,
                        width: 156,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 156,
                            width: 156,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                  isDark ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    size: 28,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "general.load_image_failed".tr(),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 156,
                            width: 156,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                                  : const Color(0xFFF1F5F9),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Video player overlay
                    if (isVideo) ...[
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.2),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ),
                      // REC badge
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "REC $videoDuration",
                                style: GoogleFonts.shareTechMono(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Date timestamp tag inside the photo
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          time,
                          style: GoogleFonts.shareTechMono(
                            color: const Color(0xFFFFB300),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Caption title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    caption,
                    style: GoogleFonts.caveat(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Sticker badge positioned on top
          if (badge != null)
            Positioned(
              top: -8,
              right: -8,
              child: badge,
            ),
        ],
      ),
    );
  }

  // Frosted AI memory card
  Widget _buildAIMemoryVibeCard({
    required BuildContext context,
    required String text,
  }) {
    final isDark = widget.isDarkMode;
    final primary = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondary = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.5),
            secondary.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.25 : 0.1),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF171F33) : Colors.white).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "AI Memory Vibe",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Realistic Quote Sticky note
  Widget _buildStickyNote({
    required BuildContext context,
    required String quote,
    required String author,
    double rotation = 0.0,
  }) {
    final isDark = widget.isDarkMode;
    const yellowPaperColor = Color(0xFFF4E4BC);
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: yellowPaperColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
              blurRadius: 10,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Floating clear tape effect
            Positioned(
              top: -20,
              left: 40,
              child: Transform.rotate(
                angle: -0.05,
                child: Container(
                  width: 50,
                  height: 14,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  quote,
                  style: GoogleFonts.caveat(
                    color: const Color(0xFF3A2818),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "- $author",
                    style: GoogleFonts.caveat(
                      color: const Color(0xFF3A2818).withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Telemetry Progress Card builder
  Widget _buildTelemetryCard({
    required BuildContext context,
    required String progressText,
    required double progressPercent,
  }) {
    final isDark = widget.isDarkMode;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textPrimary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_outlined, color: Color(0xFFFB923C), size: 16),
              const SizedBox(width: 6),
              Text(
                "Route Progress",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Loop Path Segment Illustration
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(14, (index) {
                        final double waveHeight = sin(index * 0.8) * 12;
                        return Transform.translate(
                          offset: Offset(0, waveHeight),
                          child: Container(
                            width: 3.5,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Active motorcycle location marker
                  Positioned(
                    left: 70,
                    top: 25 + sin(3.5 * 0.8) * 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF34D399), blurRadius: 8, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bar metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressText,
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${(progressPercent * 100).toInt()}% Done",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress Gradient Track
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: textPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progressPercent,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF34D399)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Frosted bottom sheet Hub menu
  void _showHubMenu(BuildContext context) {
    final isDark = widget.isDarkMode;
    final surface = isDark ? const Color(0xFF171F33) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: surface.withValues(alpha: 0.9),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20).copyWith(
                bottom: 24 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: textPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Memory Wall Hub 🔮',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.0,
                    children: [
                      _buildFeatureTile(
                        context,
                        icon: Icons.photo_library_outlined,
                        title: 'Shared Album',
                        desc: 'Curated group rolls',
                        color: const Color(0xFF00F5FF),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => SharedAlbumScreen(isDarkMode: isDark, onThemeToggle: widget.onThemeToggle)));
                        },
                      ),
                      _buildFeatureTile(
                        context,
                        icon: Icons.edit_note_outlined,
                        title: 'Scrapbook Canvas',
                        desc: 'Layered polaroids',
                        color: const Color(0xFFFF2E93),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => CollaborativeScrapbookEditorScreen(isDarkMode: isDark, onThemeToggle: widget.onThemeToggle)));
                        },
                      ),
                      _buildFeatureTile(
                        context,
                        icon: Icons.auto_awesome_outlined,
                        title: 'AI Caption Studio',
                        desc: 'Witty quote roasts',
                        color: const Color(0xFFFFB300),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => AICaptionGeneratorScreen(isDarkMode: isDark, onThemeToggle: widget.onThemeToggle)));
                        },
                      ),
                      _buildFeatureTile(
                        context,
                        icon: Icons.share_outlined,
                        title: 'Export Chaos',
                        desc: 'TikTok / Reels clips',
                        color: Colors.lightGreenAccent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => ShareChaosExportScreen(isDarkMode: isDark, onThemeToggle: widget.onThemeToggle)));
                        },
                      ),
                      _buildFeatureTile(
                        context,
                        icon: Icons.timeline_outlined,
                        title: 'Timeline Story',
                        desc: 'Chronological Dots',
                        color: primaryColor,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => MemoryTimelineScreen(isDarkMode: isDark, onThemeToggle: widget.onThemeToggle)));
                        },
                      ),
                      _buildFeatureTile(
                        context,
                        icon: Icons.favorite_border,
                        title: 'Favorite Feeds',
                        desc: 'Highly aesthetic pins',
                        color: Colors.redAccent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => FavoriteMemoriesScreen(isDarkMode: isDark, onThemeToggle: widget.onThemeToggle)));
                        },
                      ),
                      _buildFeatureTile(
                        context,
                        icon: Icons.archive_outlined,
                        title: 'Memory Archive',
                        desc: 'Sort media history',
                        color: Colors.blueAccent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => MemoryArchiveScreen(isDarkMode: isDark, onThemeToggle: widget.onThemeToggle)));
                        },
                      ),
                      _buildFeatureTile(
                        context,
                        icon: Icons.auto_mode_outlined,
                        title: 'AI Auto-Sorter',
                        desc: 'Tag & organize chaos',
                        color: Colors.tealAccent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => AIMemorySortingScreen(isDarkMode: isDark, onThemeToggle: widget.onThemeToggle)));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Feature menu grid builder
  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.02),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              radius: 16,
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.plusJakartaSans(fontSize: 8, color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Micro-animated Floating Emoji Reaction
class FloatingEmojiWidget extends StatefulWidget {
  final String emoji;
  final double startX;
  final VoidCallback onFinished;

  const FloatingEmojiWidget({
    super.key,
    required this.emoji,
    required this.startX,
    required this.onFinished,
  });

  @override
  State<FloatingEmojiWidget> createState() => _FloatingEmojiWidgetState();
}

class _FloatingEmojiWidgetState extends State<FloatingEmojiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late double _swayOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    _yAnimation = Tween<double>(begin: 0.0, end: -300.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_controller);

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Random slight swaying values
    _swayOffset = (DateTime.now().millisecond % 50) - 25;

    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double sway = sin(_controller.value * pi * 3.5) * _swayOffset;
        return Positioned(
          bottom: 100 - _yAnimation.value,
          left: widget.startX + sway,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );
  }
}
