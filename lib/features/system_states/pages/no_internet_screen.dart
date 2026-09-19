import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:tripmate/core/theme/gen_z_tokens.dart';

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
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
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
              style: AppFonts.heading(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: isDark
                ? GenZTokens.successDark
                : GenZTokens.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('errors.still_offline'),
              style: AppFonts.heading(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: isDark ? GenZTokens.dangerDark : GenZTokens.danger,
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
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        ),
        backgroundColor: surface,
        title: Row(
          children: [
            Icon(
              PhosphorIcons.gameController(PhosphorIconsStyle.fill),
              size: 24,
              color: accent,
            ),
            const SizedBox(width: 8),
            Text(
              tr('errors.dino_game'),
              style: AppFonts.heading(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: ink,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('errors.dino_sub'),
              style: AppFonts.body(fontSize: 13, height: 1.4, color: inkSoft),
            ),
            const SizedBox(height: GenZTokens.space4),
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
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
                          color: accent,
                        ),
                        const SizedBox(width: 10),
                        Icon(PhosphorIcons.plant(), size: 18, color: success),
                        const SizedBox(width: 6),
                        Icon(PhosphorIcons.plant(), size: 18, color: success),
                        const SizedBox(width: 10),
                        Icon(
                          PhosphorIcons.personSimpleRun(),
                          size: 22,
                          color: ink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '[ Score: 1,420 ]',
                      textAlign: TextAlign.center,
                      style: AppFonts.mono(
                        fontWeight: FontWeight.w600,
                        color: inkSoft,
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
            style: TextButton.styleFrom(foregroundColor: accent),
            child: Text(
              tr('common.close'),
              style: AppFonts.heading(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final paper = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isDark ? PhosphorIcons.sun() : PhosphorIcons.moon(),
                          color: ink,
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
                          color: GenZTokens.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: GenZTokens.danger.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 34 / 28,
                  color: ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tr('errors.offline_joke'),
                style: AppFonts.body(
                  fontSize: 15,
                  color: inkSoft,
                  height: 22 / 15,
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
                        color: paper,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: line, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(PhosphorIcons.users(), color: inkSoft, size: 24),
                          const Spacer(),
                          Text(
                            tr('errors.offline_status'),
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 18 / 13,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr('errors.offline'),
                            style: AppFonts.body(
                              fontSize: 12,
                              height: 16 / 12,
                              color: inkSoft,
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
                        color: paper,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: line, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            PhosphorIcons.cloudCheck(),
                            color: inkSoft,
                            size: 24,
                          ),
                          const Spacer(),
                          Text(
                            tr('errors.cache_safe'),
                            style: AppFonts.heading(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 18 / 13,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr('errors.saved_locally'),
                            style: AppFonts.body(
                              fontSize: 12,
                              height: 16 / 12,
                              color: inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Reconnect Action Button (Single Primary Accent Action)
              GestureDetector(
                onTap: _isConnecting ? null : _reconnect,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: accent,
                    boxShadow: GenZTokens.hardShadow(accent, isDark),
                  ),
                  child: Center(
                    child: _isConnecting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: onAccent,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.arrowsClockwise(),
                                color: onAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tr('errors.reconnect'),
                                style: AppFonts.heading(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: onAccent,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary dino game button (Neutral Fill / Line Outline)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _playDinoGame,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: fill,
                    side: BorderSide(color: line, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    tr('offline.play_dino'),
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w600,
                      color: ink,
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
    );
  }
}
