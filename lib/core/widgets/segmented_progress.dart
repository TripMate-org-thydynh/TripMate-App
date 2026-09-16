import 'package:flutter/material.dart';
import '../theme/gen_z_tokens.dart';

/// Thanh tiến trình phân đoạn: rãnh nền chìm (fill/fillDark),
/// phần hoàn thành dùng màu nhấn (accent), viền mảnh 1px.
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
    this.height = 8,
    this.gap = GenZTokens.space2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final trackColor = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final fill = fillColor ?? Theme.of(context).colorScheme.primary;

    return Row(
      children: List.generate(total, (i) {
        final done = i < completed;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == total - 1 ? 0 : gap),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: GenZTokens.durationFast),
              curve: Curves.easeOutCubic,
              height: height,
              decoration: BoxDecoration(
                color: done ? fill : trackColor,
                borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                border: Border.all(
                  color: done ? fill : line,
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
