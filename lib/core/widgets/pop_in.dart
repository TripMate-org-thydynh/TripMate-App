import 'package:flutter/material.dart';

/// Hiệu ứng xuất hiện "pop": scale 0.94→1 + fade + trượt lên nhẹ, có delay theo
/// [index] để tạo hiệu ứng so le (staggered) khi một danh sách card cùng load.
/// Chạy một lần, không loop — giữ nhịp sinh động mà không gây rối.
class PopIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration stagger;

  const PopIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 360),
    this.stagger = const Duration(milliseconds: 70),
  });

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.stagger * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final t = _curve.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
