import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:tripmate/core/theme/gen_z_tokens.dart';

import '../../../core/theme/theme.dart';

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

  Future<void> _reconnect() async {
    setState(() {
      _isConnecting = true;
    });
    try {
      final results = await Connectivity().checkConnectivity();
      if (!mounted) return;
      final isOffline =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (!isOffline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('errors.back_online'),
              style: AppFonts.heading(fontWeight: FontWeight.bold),
            ),
            backgroundColor: TripMateTheme.darkSecondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('errors.still_offline'),
              style: AppFonts.heading(fontWeight: FontWeight.bold),
            ),
            backgroundColor: GenZTokens.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      // Bỏ qua lỗi bắt kết nối
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _playDinoGame() {
    final isDark = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? TripMateTheme.darkPrimary
        : TripMateTheme.lightPrimary;
    final textPrimary = isDark
        ? GenZTokens.inkDark
        : GenZTokens.ink;
    final textSecondary = isDark
        ? GenZTokens.inkSoftDark
        : GenZTokens.inkSoft;
    final surfaceColor = isDark
        ? GenZTokens.paperDark
        : GenZTokens.paper;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: surfaceColor,
        title: Row(
          children: [
            Icon(
              PhosphorIcons.gameController(PhosphorIconsStyle.fill),
              size: 28,
              color: primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              tr('errors.dino_game'),
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('errors.dino_sub'),
              style: AppFonts.body(
                fontSize: 13,
                height: 1.4,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: (isDark ? GenZTokens.inkDark : GenZTokens.ink)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? GenZTokens.inkDark : GenZTokens.ink)
                      .withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.gameController(),
                          size: 22,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          PhosphorIcons.plant(),
                          size: 18,
                          color: GenZTokens.green,
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          PhosphorIcons.plant(),
                          size: 18,
                          color: GenZTokens.green,
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          PhosphorIcons.personSimpleRun(),
                          size: 22,
                          color: textPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '[ Score: 1,420 ]',
                      textAlign: TextAlign.center,
                      style: AppFonts.mono(
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              tr('common.close'),
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark
        ? TripMateTheme.darkPrimary
        : TripMateTheme.lightPrimary;
    final secondaryColor = isDark
        ? TripMateTheme.darkSecondary
        : TripMateTheme.lightSecondary;
    final bgColor = isDark
        ? GenZTokens.creamDark
        : GenZTokens.cream;
    final surfaceColor = isDark
        ? GenZTokens.paperDark
        : GenZTokens.paper;
    final textPrimary = isDark
        ? GenZTokens.inkDark
        : GenZTokens.ink;
    final textSecondary = isDark
        ? GenZTokens.inkSoftDark
        : GenZTokens.inkSoft;
    final borderCol = isDark
        ? GenZTokens.inkDark.withValues(alpha: 0.12)
        : GenZTokens.ink.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background aurora overlays
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
                    color: GenZTokens.danger.withValues(alpha: 0.08),
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
                        icon: Icon(
                          PhosphorIcons.arrowLeft(),
                          color: textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isDark
                                  ? PhosphorIcons.sun()
                                  : PhosphorIcons.moon(),
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
                              color: GenZTokens.danger.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.wifiSlash(),
                                  color: GenZTokens.danger,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tr('errors.no_signal'),
                                  style: AppFonts.heading(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: GenZTokens.danger,
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
                    tr('errors.internet_died'),
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
                                PhosphorIcons.users(),
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
                                  fontSize: 12,
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
                                PhosphorIcons.cloudCheck(),
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
                                tr('errors.saved_locally'),
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                                  color: GenZTokens.ink,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIcons.arrowsClockwise(),
                                    color: GenZTokens.ink,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tr('errors.reconnect'),
                                    style: AppFonts.heading(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: GenZTokens.ink,
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
                        tr('offline.play_dino'),
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
