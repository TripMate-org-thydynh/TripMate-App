import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import '../theme/gen_z_tokens.dart';

/// Nút brutalist: nền accent, viền ink 2.5px, hard shadow.
/// Khi nhấn: dịch xuống 4px + bỏ shadow (hiệu ứng "nhấn chìm", spring 120ms).
class ChunkyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final IconData? icon;
  final bool expanded;
  final EdgeInsetsGeometry padding;
  final double radius;

  const ChunkyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final bg = widget.color ?? Theme.of(context).colorScheme.primary;
    final enabled = widget.onPressed != null;

    Widget content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: GenZTokens.ink),
          const SizedBox(width: GenZTokens.space2),
        ],
        DefaultTextStyle.merge(
          style: AppFonts.heading(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: GenZTokens.ink,
          ),
          child: widget.child,
        ),
      ],
    );

    return GestureDetector(
      onTapDown: (_) {
        _setPressed(true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _setPressed(false);
        widget.onPressed?.call();
      },
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: enabled ? bg : bg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
          boxShadow: _pressed || !enabled ? null : GenZTokens.hardShadow(ink),
        ),
        child: content,
      ),
    );
  }
}
