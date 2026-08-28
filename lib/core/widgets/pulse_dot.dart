import 'package:flutter/material.dart';
import '../theme/gen_z_tokens.dart';

/// Chấm trạng thái "online" pulse liên tục nhẹ: vòng ngoài lan toả + mờ dần.
/// Dùng cho friend presence, live status. Loop nhẹ, không gây rối.
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool bordered;

  const PulseDot({
    super.key,
    this.color = GenZTokens.green,
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
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
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
                // Vòng lan toả
                Opacity(
                  opacity: (1 - t) * 0.5,
                  child: Container(
                    width: widget.size * (1 + t * 1.4),
                    height: widget.size * (1 + t * 1.4),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.5),
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
                  ? Border.all(color: ink, width: 1.5)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
