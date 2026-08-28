import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/gen_z_widgets.dart';

class EmergencySosWidget extends StatefulWidget {
  const EmergencySosWidget({super.key});

  @override
  State<EmergencySosWidget> createState() => _EmergencySosWidgetState();
}

class _EmergencySosWidgetState extends State<EmergencySosWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  double _pressProgress = 0.0;
  Timer? _progressTimer;
  bool _isAlerting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startPressing() {
    _progressTimer?.cancel();
    setState(() {
      _pressProgress = 0.0;
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {
        _pressProgress += 0.02; // Accumulate over 1 second (50 ticks)
        if (_pressProgress >= 1.0) {
          _pressProgress = 1.0;
          _progressTimer?.cancel();
          _triggerSos();
        }
      });
    });
  }

  void _stopPressing() {
    _progressTimer?.cancel();
    if (!_isAlerting) {
      setState(() {
        _pressProgress = 0.0;
      });
    }
  }

  void _triggerSos() {
    setState(() {
      _isAlerting = true;
    });

    // Show a premium visual alert dialog overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: GenZTokens.red,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  border: Border.all(
                    color: GenZTokens.ink,
                    width: GenZTokens.borderWidth,
                  ),
                  boxShadow: GenZTokens.hardShadow(),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 72,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'dashboard.sos_broadcasted'.tr(),
                      style: AppFonts.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'dashboard.sos_broadcast_body'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF990000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isAlerting = false;
                          _pressProgress = 0.0;
                        });
                      },
                      child: Text(
                        'dashboard.sos_cancel'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
        boxShadow: GenZTokens.hardShadow(ink),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Glowing red pulse button
            GestureDetector(
              onTapDown: (_) => _startPressing(),
              onTapUp: (_) => _stopPressing(),
              onTapCancel: () => _stopPressing(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD8422B).withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  // Progress indicator ring
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(
                      value: _pressProgress,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  // Center solid SOS circle button — viền ink brutalist
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GenZTokens.red,
                      border: Border.all(
                        color: GenZTokens.ink,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "SOS",
                        style: AppFonts.mono(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            // Information texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "dashboard.emergency_sos".tr(),
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: -0.3,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isAlerting
                        ? "dashboard.sos_alerting".tr()
                        : "dashboard.hold_to_trigger".tr(),
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? GenZTokens.inkSoftDark
                          : GenZTokens.inkSoft,
                    ),
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
