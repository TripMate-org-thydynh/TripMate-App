import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../theme/gen_z_tokens.dart';
import 'hard_shadow_box.dart';

/// Card sticker: viền ink + hard shadow, xuất hiện với pop-scale 0.96→1 + fade.
/// Có thể chọn được (tick tròn góc phải bật scale khi [selected]).
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
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..forward();

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final accent = Theme.of(context).colorScheme.primary;

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
              color: widget.headerColor ?? accent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(widget.radius - GenZTokens.borderWidth),
              ),
              border: Border(
                bottom: BorderSide(
                  color: ink,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
            ),
            child: Text(
              widget.headerText!.toUpperCase(),
              style: TripMateMono.style(context),
            ),
          ),
        Padding(padding: widget.padding, child: widget.child),
      ],
    );

    Widget card = HardShadowBox(
      color: widget.color,
      radius: widget.radius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          widget.radius - GenZTokens.borderWidth,
        ),
        child: body,
      ),
    );

    if (widget.selectable) {
      card = Stack(
        clipBehavior: Clip.none,
        children: [
          card,
          Positioned(
            top: -8,
            right: -8,
            child: AnimatedScale(
              scale: widget.selected ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ink,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: const Icon(Icons.check, size: 16, color: GenZTokens.ink),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.onTap != null) {
      card = GestureDetector(onTap: widget.onTap, child: card);
    }

    return FadeTransition(
      opacity: _pop,
      child: ScaleTransition(
        scale: Tween(
          begin: 0.96,
          end: 1.0,
        ).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOutBack)),
        child: card,
      ),
    );
  }
}

/// Style mono nhỏ dùng cho header card / tag.
class TripMateMono {
  static TextStyle style(BuildContext context) {
    return AppFonts.mono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0,
      color: GenZTokens.ink,
    );
  }
}
