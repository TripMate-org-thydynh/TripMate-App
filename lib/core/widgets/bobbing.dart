import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Chuyển động nhẹ nhàng cho trạng thái trực tiếp (friend presence, live status).
/// Không dùng lạm dụng ở phần trang trí tĩnh (spec mục 6 & 7).
class Bobbing extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration period;
  final double phase;
  final bool rotate;
  final bool enabled;

  const Bobbing({
    super.key,
    required this.child,
    this.amplitude = 2,
    this.period = const Duration(milliseconds: 2600),
    this.phase = 0,
    this.rotate = false,
    this.enabled = true,
  });

  @override
  State<Bobbing> createState() => _BobbingState();
}

class _BobbingState extends State<Bobbing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _c.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Bobbing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.enabled && _c.isAnimating) {
      _c.stop();
      _c.reset();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final a = math.sin(_c.value * math.pi * 2 + widget.phase);
        final dy = a * widget.amplitude;
        Widget w = Transform.translate(offset: Offset(0, dy), child: child);
        if (widget.rotate) {
          w = Transform.rotate(angle: a * 0.03, child: w);
        }
        return w;
      },
      child: widget.child,
    );
  }
}
