import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../theme/gen_z_tokens.dart';

/// Nút chính: nền accent, chữ onAccent, bán kính 10, cao tối thiểu 48,
/// đổi màu nhẹ khi nhấn (không lún, không bóng đặc).
class ChunkyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool expanded;
  final EdgeInsetsGeometry padding;
  final double radius;

  const ChunkyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.textColor,
    this.icon,
    this.expanded = false,
    this.padding = GenZTokens.buttonPadding,
    this.radius = GenZTokens.radiusButton,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    final bg = widget.color ?? primary;
    final fg = widget.textColor ?? (widget.color != null ? onPrimary : onPrimary);
    final enabled = widget.onPressed != null;

    final effectiveBg = !enabled
        ? bg.withValues(alpha: isDark ? 0.35 : 0.5)
        : _pressed
            ? (isDark
                ? Color.lerp(bg, Colors.white, 0.12)!
                : Color.lerp(bg, Colors.black, 0.1)!)
            : bg;

    Widget content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: fg),
          const SizedBox(width: GenZTokens.space2),
        ],
        DefaultTextStyle.merge(
          style: AppFonts.heading(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
          child: widget.child,
        ),
      ],
    );

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onPressed?.call();
      },
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 48),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: content,
      ),
    );
  }
}
