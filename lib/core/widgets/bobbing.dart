import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Trôi/nảy nhẹ liên tục (float) — cho avatar, sticker, icon. Biên độ nhỏ,
/// mỗi phần tử một [phase] để cả nhóm nhấp nhô so le tự nhiên (không đồng loạt).
class Bobbing extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration period;
  final double phase;
  final bool rotate;

  const Bobbing({
    super.key,
    required this.child,
    this.amplitude = 4,
    this.period = const Duration(milliseconds: 2600),
    this.phase = 0,
    this.rotate = false,
  });

  @override
  State<Bobbing> createState() => _BobbingState();
}

class _BobbingState extends State<Bobbing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final a = math.sin(_c.value * math.pi * 2 + widget.phase);
        final dy = a * widget.amplitude;
        Widget w = Transform.translate(offset: Offset(0, dy), child: child);
        if (widget.rotate) {
          w = Transform.rotate(angle: a * 0.05, child: w);
        }
        return w;
      },
      child: widget.child,
    );
  }
}
