import 'package:flutter/material.dart';

/// Text số đếm tăng dần từ 0 → [value] khi widget xuất hiện (một lần).
/// Dùng cho tiền, thống kê, điểm số. [format] tuỳ biến chuỗi hiển thị.
class CountUpText extends StatefulWidget {
  final num value;
  final TextStyle? style;
  final Duration duration;
  final String Function(num current)? format;
  final String prefix;
  final String suffix;

  const CountUpText(
    this.value, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.format,
    this.prefix = '',
    this.suffix = '',
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void didUpdateWidget(covariant CountUpText old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _c
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _fmt(num v) {
    if (widget.format != null) return widget.format!(v);
    // Số nguyên có phân tách nghìn theo dấu phẩy.
    final s = v.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '${widget.prefix}$s${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curve,
      builder: (context, _) {
        final current = widget.value * curve.value;
        return Text(_fmt(current), style: widget.style);
      },
    );
  }
}
