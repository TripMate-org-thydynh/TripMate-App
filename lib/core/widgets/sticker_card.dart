import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../theme/gen_z_tokens.dart';

/// Thẻ phẳng viền 1px: nền paper, viền line, bán kính 14, không bóng.
/// Khi [selected]: viền accent 1.5px. Bỏ pop-scale mạnh, chuyển sang fade nhẹ.
class StickerCard extends StatefulWidget {
  final Widget child;
  final Color? color;
  final Color? headerColor;
  final String? headerText;
  final VoidCallback? onTap;
  final bool selectable;
  final bool selected;
  final EdgeInsetsGeometry padding;
  final double radius;

  const StickerCard({
    super.key,
    required this.child,
    this.color,
    this.headerColor,
    this.headerText,
    this.onTap,
    this.selectable = false,
    this.selected = false,
    this.padding = const EdgeInsets.all(GenZTokens.space4),
    this.radius = GenZTokens.radiusCard,
  });

  @override
  State<StickerCard> createState() => _StickerCardState();
}

class _StickerCardState extends State<StickerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: GenZTokens.durationFast),
  )..forward();

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    final borderColor = widget.selected ? accent : line;
    final borderWidth = widget.selected
        ? GenZTokens.borderWidth
        : GenZTokens.borderWidthThin;

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.headerText != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GenZTokens.space4,
              vertical: GenZTokens.space2,
            ),
            decoration: BoxDecoration(
              color: widget.headerColor ?? fill,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(widget.radius - borderWidth),
              ),
              border: Border(
                bottom: BorderSide(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
            ),
            child: Text(
              widget.headerText!,
              style: TripMateMono.style(context),
            ),
          ),
        Padding(padding: widget.padding, child: widget.child),
      ],
    );

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.color ?? surface,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius - borderWidth),
        child: body,
      ),
    );

    if (widget.selectable) {
      card = Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: -6,
            right: -6,
            child: AnimatedScale(
              scale: widget.selected ? 1 : 0,
              duration: const Duration(milliseconds: GenZTokens.durationFast),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  PhosphorIcons.check(PhosphorIconsStyle.bold),
                  size: 14,
                  color: onAccent,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.onTap != null) {
      card = GestureDetector(onTap: widget.onTap, child: card);
    }

    return FadeTransition(opacity: _fade, child: card);
  }
}

/// Style mono nhỏ dùng cho header card / tag.
class TripMateMono {
  static TextStyle style(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppFonts.mono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
    );
  }
}
