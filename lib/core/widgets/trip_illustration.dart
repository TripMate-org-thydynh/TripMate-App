import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Flat travel illustrations (unDraw, free licence, recoloured to TripMate tokens).
/// Light assets use terracotta #B4543A + ink #1C1A17; dark mode swaps them at runtime.
enum TripIllustration { road, squad, travelers }

class TripIllustrationView extends StatelessWidget {
  const TripIllustrationView(this.kind, {super.key, this.height});

  final TripIllustration kind;
  final double? height;

  static final Map<String, Future<String>> _cache = {};

  String get _path => 'assets/images/ill_${kind.name}.svg';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final raw = _cache.putIfAbsent(_path, () => rootBundle.loadString(_path));
    return SizedBox(
      height: height,
      child: FutureBuilder<String>(
        future: raw,
        builder: (context, snap) {
          if (!snap.hasData) return const SizedBox.shrink();
          var svg = snap.data!;
          if (dark) {
            svg = svg
                .replaceAll('#B4543A', '#5C9A90')
                .replaceAll('#1C1A17', '#9A948B')
                .replaceAll('#E3DDD2', '#2E3235');
          }
          return SvgPicture.string(svg, fit: BoxFit.contain);
        },
      ),
    );
  }
}
