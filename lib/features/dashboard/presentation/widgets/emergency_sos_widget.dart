import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencySosWidget extends StatefulWidget {
  const EmergencySosWidget({super.key});

  @override
  State<EmergencySosWidget> createState() => _EmergencySosWidgetState();
}

class _EmergencySosWidgetState extends State<EmergencySosWidget> with SingleTickerProviderStateMixin {
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
                  color: const Color(0xFF990000),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 30,
                    )
                  ],
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
                      "SOS BROADCASTED!",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Broadcasting your GPS location:\n11.94006 N, 108.43731 E\nto all 6 squad members.",
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
                      child: const Text(
                        "Cancel Alert",
                        style: TextStyle(fontWeight: FontWeight.bold),
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF22131C) : const Color(0xFFFDF2F4),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
          width: 1.5,
        ),
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
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
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
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  // Center solid SOS circle button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEF4444),
                    ),
                    child: const Center(
                      child: Text(
                        "SOS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isAlerting ? "dashboard.sos_alerting".tr() : "dashboard.hold_to_trigger".tr(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFFCA5A5).withValues(alpha: 0.7) : const Color(0xFF991B1B).withValues(alpha: 0.7),
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
