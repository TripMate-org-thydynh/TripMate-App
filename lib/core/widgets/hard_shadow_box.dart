import 'package:flutter/material.dart';
import '../theme/gen_z_tokens.dart';

/// Hộp bề mặt nổi (sheet, dialog, menu): viền line 1px,
/// bóng mờ nhẹ ở light mode, không bóng ở dark mode (spec mục 4).
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
    this.borderWidth = GenZTokens.borderWidthThin,
    this.radius = GenZTokens.radiusCard,
    this.padding,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? line,
          width: borderWidth,
        ),
        boxShadow: showShadow
            ? GenZTokens.hardShadow(shadowColor ?? ink, isDark)
            : null,
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}
