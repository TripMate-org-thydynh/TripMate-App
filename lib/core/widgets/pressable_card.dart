import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/gen_z_tokens.dart';

/// Card brutalist có phản hồi chạm "nhấn chìm": khi nhấn thì dịch xuống 4px
/// và bỏ hard shadow (cảm giác vật lý bị ấn xuống), nhả ra bật lại (spring 120ms).
/// Dùng thay cho `GestureDetector(onTap, child: HardShadowBox(...))` ở các card bấm được.
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
    this.borderWidth = GenZTokens.borderWidth,
    this.radius = GenZTokens.radiusCard,
    this.padding,
    this.depth = 4,
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
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final border = widget.borderColor ?? ink;
    final shadow = widget.shadowColor ?? ink;

    return GestureDetector(
      onTapDown: (_) {
        _set(true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _set(false);
        widget.onTap?.call();
      },
      onTapCancel: () => _set(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, _pressed ? widget.depth : 0, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color ?? surface,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: border, width: widget.borderWidth),
          boxShadow: _pressed
              ? null
              : [
                  BoxShadow(
                    color: shadow,
                    offset: Offset(0, widget.depth),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}
