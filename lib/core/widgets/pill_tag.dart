import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../theme/gen_z_tokens.dart';

/// Tag pill: nền fill, chữ inkSoft; khi [selected] thì nền accentSoft, chữ accent.
/// Bỏ chữ in hoa toàn bộ theo spec mục 6.
class PillTag extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;

  const PillTag({
    super.key,
    required this.text,
    this.color,
    this.icon,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final accentSoft = isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    final bg = selected ? accentSoft : (color ?? fill);
    final textIconColor = selected ? accent : inkSoft;
    final borderColor = selected ? Colors.transparent : line;

    final pill = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GenZTokens.space3,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
        border: Border.all(
          color: borderColor,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textIconColor),
            const SizedBox(width: GenZTokens.space1),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: textIconColor,
              ),
            ),
          ),
        ],
      ),
    );

    return onTap != null ? GestureDetector(onTap: onTap, child: pill) : pill;
  }
}
