import 'package:flutter/material.dart';
import '../theme/gen_z_tokens.dart';

/// Progress bar onboarding: các segment rời viền ink,
/// phần hoàn thành fill màu accent.
class SegmentedProgress extends StatelessWidget {
  final int total;
  final int completed;
  final Color? fillColor;
  final double height;
  final double gap;

  const SegmentedProgress({
    super.key,
    required this.total,
    required this.completed,
    this.fillColor,
    this.height = 10,
    this.gap = GenZTokens.space2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final fill = fillColor ?? Theme.of(context).colorScheme.primary;

    return Row(
      children: List.generate(total, (i) {
        final done = i < completed;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == total - 1 ? 0 : gap),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: height,
              decoration: BoxDecoration(
                color: done ? fill : Colors.transparent,
                borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                border: Border.all(
                  color: ink,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
