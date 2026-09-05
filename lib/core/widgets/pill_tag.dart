import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../theme/gen_z_tokens.dart';

/// Tag pill brutalist: radius 999, nền accent nhạt, viền ink 2px,
/// chữ mono UPPERCASE.
class PillTag extends StatelessWidget {
  final String text;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  const PillTag({
    super.key,
    required this.text,
    this.color,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final bg = color ?? Theme.of(context).colorScheme.secondary;
    final isAccentBg =
        bg == GenZTokens.yellow ||
        bg == GenZTokens.pink ||
        bg == GenZTokens.lilac ||
        bg == GenZTokens.orange ||
        bg == GenZTokens.magenta ||
        bg == GenZTokens.blue ||
        bg == GenZTokens.green;
    final textIconColor = isAccentBg ? GenZTokens.ink : ink;

    final pill = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GenZTokens.space3,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textIconColor),
            const SizedBox(width: GenZTokens.space1),
          ],
          // Chữ phải co lại được: nhãn dịch sang ngôn ngữ khác có thể dài hơn
          // nhiều so với bản gốc và làm tràn thẻ cha (RenderFlex overflow).
          Flexible(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.mono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: textIconColor,
                shadows: bg == GenZTokens.yellow
                    ? GenZTokens.textOutline(
                        Colors.black.withValues(alpha: 0.2),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );

    return onTap != null ? GestureDetector(onTap: onTap, child: pill) : pill;
  }
}
