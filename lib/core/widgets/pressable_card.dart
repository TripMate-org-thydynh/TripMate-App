import 'package:flutter/material.dart';
import '../theme/gen_z_tokens.dart';

/// Card tương tác phản hồi nhẹ: độ lún 1px, không nảy (Curves.easeOutCubic),
/// bỏ haptic ở thao tác thường (spec mục 6 & 7).
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final double borderWidth;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double depth;

  const PressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.borderWidth = GenZTokens.borderWidthThin,
    this.radius = GenZTokens.radiusCard,
    this.padding,
    this.depth = 1,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final border = widget.borderColor ?? line;
    final shadow = widget.shadowColor ?? (isDark ? GenZTokens.inkDark : GenZTokens.ink);

    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) {
        _set(false);
        widget.onTap?.call();
      },
      onTapCancel: () => _set(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: GenZTokens.durationFast),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _pressed ? widget.depth : 0, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color ?? surface,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: border, width: widget.borderWidth),
          boxShadow: _pressed ? null : GenZTokens.hardShadow(shadow, isDark),
        ),
        child: widget.child,
      ),
    );
  }
}
