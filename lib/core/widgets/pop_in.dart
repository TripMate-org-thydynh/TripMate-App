import 'package:flutter/material.dart';
import '../theme/gen_z_tokens.dart';

/// Hiệu ứng xuất hiện: fade + trượt lên nhẹ (Curves.easeOutCubic, không nảy),
/// có delay theo [index] để tạo nhịp so le (staggered) khi một danh sách card cùng load.
/// Tuân thủ spec mục 7: không bounce, chuyển động mượt mà.
class PopIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration stagger;

  const PopIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: GenZTokens.durationBase),
    this.stagger = const Duration(milliseconds: 50),
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
    curve: Curves.easeOutCubic,
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
            offset: Offset(0, (1 - t) * 12),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
