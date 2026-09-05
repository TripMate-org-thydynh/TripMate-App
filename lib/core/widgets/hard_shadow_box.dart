import 'package:flutter/material.dart';
import '../theme/gen_z_tokens.dart';

/// Hộp nền brutalist: viền ink dày + hard shadow lệch (0,4) blur 0.
/// Dùng làm khối nền cho mọi component tùy biến.
class HardShadowBox extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final double borderWidth;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;

  const HardShadowBox({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.borderWidth = GenZTokens.borderWidth,
    this.radius = GenZTokens.radiusCard,
    this.padding,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? ink, width: borderWidth),
        boxShadow: showShadow
            ? GenZTokens.hardShadow(shadowColor ?? ink)
            : null,
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}
