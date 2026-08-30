import '../../../core/theme/theme.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';

class NoInternetScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const NoInternetScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isConnecting = false;

  void _reconnect() {
    setState(() {
      _isConnecting = true;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚡ Đã nối mạng thành công! Squad items đã cập nhật.',
            style: AppFonts.heading(fontWeight: FontWeight.bold),
          ),
          backgroundColor: TripMateTheme.darkSecondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    });
  }

  void _playDinoGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: widget.isDarkMode
            ? TripMateTheme.darkSurface
            : Colors.white,
        title: Row(
          children: [
            const Text('🦖', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(
              tr('errors.dino_game'),
              style: AppFonts.heading(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nhảy qua các bụi xương rồng để ghi điểm trong khi đợi mạng hồi sinh!',
              style: AppFonts.body(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: (widget.isDarkMode ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDarkMode ? Colors.white10 : Colors.black12,
                ),
              ),
              child: const Center(
                child: Text(
                  '🦖   🌵   🌵   🏃‍♂️💨\n\n[ Score: 1,420 ]',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: AppFonts.heading(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark
        ? TripMateTheme.darkPrimary
        : TripMateTheme.lightPrimary;
    final secondaryColor = isDark
        ? TripMateTheme.darkSecondary
        : TripMateTheme.lightSecondary;
    final bgColor = isDark
        ? TripMateTheme.darkBackground
        : TripMateTheme.lightBackground;
    final surfaceColor = isDark
        ? TripMateTheme.darkSurface
        : TripMateTheme.lightSurface;
    final textPrimary = isDark
        ? TripMateTheme.darkTextPrimary
        : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark
        ? TripMateTheme.darkTextSecondary
        : TripMateTheme.lightTextSecondary;
    final borderCol = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background aurora overlays (Irresponsible glowing aesthetic)
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.08),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isDark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              color: primaryColor,
                            ),
                            onPressed: widget.onThemeToggle,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.wifi_off,
                                  color: Colors.redAccent,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tr('errors.no_signal'),
                                  style: AppFonts.heading(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Headline block
                  Text(
                    'bro the\ninternet died 😭',
                    style: AppFonts.heading(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tr('errors.offline_joke'),
                    style: AppFonts.body(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bento grids check status
                  Row(
                    children: [
                      // Grid Item 1: Squad Offline Status
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 130,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderCol),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.group_off,
                                color: primaryColor,
                                size: 24,
                              ),
                              const Spacer(),
                              Text(
                                tr('errors.offline_status'),
                                style: AppFonts.heading(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tr('errors.offline'),
                                style: AppFonts.body(
                                  fontSize: 10.5,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Grid Item 2: Cached Memories Safe
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          height: 130,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderCol),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.cloud_done,
                                color: secondaryColor,
                                size: 24,
                              ),
                              const Spacer(),
                              Text(
                                tr('errors.cache_safe'),
                                style: AppFonts.heading(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Saved locally',
                                style: AppFonts.body(
                                  fontSize: 10.5,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Next Up Tokyo Shibuya Crossing card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderCol),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flight_takeoff,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Up',
                                style: AppFonts.body(
                                  fontSize: 11,
                                  color: textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tokyo Shibuya Crossing',
                                style: AppFonts.heading(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.cloud_off, color: textSecondary, size: 16),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Reconnect Action Button
                  GestureDetector(
                    onTap: _isConnecting ? null : _reconnect,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isConnecting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reconnect',
                                    style: AppFonts.heading(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary dino game button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _playDinoGame,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: primaryColor.withValues(alpha: 0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        'Play Offline Dino Game',
                        style: AppFonts.heading(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
