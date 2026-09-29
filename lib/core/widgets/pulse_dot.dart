import 'package:flutter/material.dart';
import '../theme/gen_z_tokens.dart';

/// Chấm trạng thái trực tiếp (online, live status).
/// Vòng lan toả mờ dần nhẹ nhàng, màu mặc định là semantic success.
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool bordered;

  const PulseDot({
    super.key,
    this.color = GenZTokens.success,
    this.size = 10,
    this.bordered = true,
  });

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return SizedBox(
      width: widget.size * 2.4,
      height: widget.size * 2.4,
      child: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = _c.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Vòng lan toả mờ
                Opacity(
                  opacity: (1 - t) * 0.45,
                  child: Container(
                    width: widget.size * (1 + t * 1.3),
                    height: widget.size * (1 + t * 1.3),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                child!,
              ],
            );
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: widget.bordered
                  ? Border.all(
                      color: ringColor,
                      width: 1.5,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
