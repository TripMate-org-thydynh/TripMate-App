import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/gen_z_tokens.dart';

/// Ảnh bìa chuyến — nhận cả **asset path** lẫn **URL**.
/// Tuân thủ quy chuẩn spec mục 8: tỷ lệ cố định (16:9 cho ảnh bìa, 4:3 cho danh sách, 1:1 cho ô lưới),
/// scrim thống nhất ở 40% dưới của ảnh.
class TripCoverImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;

  /// Màu nền khi không có ảnh / ảnh lỗi. Mặc định dùng fill/fillDark.
  final Color? fallbackColor;

  /// Tỷ lệ khung hình cố định (ảnh bìa 16:9, danh sách 4:3, ô lưới 1:1).
  /// Null nếu widget cha đã ràng buộc kích thước (ví dụ SizedBox, Stack fit expand).
  final double? aspectRatio;

  /// Bật scrim gradient thống nhất (từ transparent tới #000000 alpha 0.55 ở 40% dưới).
  final bool withScrim;

  /// Nhãn ngữ nghĩa cho trình đọc màn hình.
  final String? semanticLabel;

  /// Nếu là true, bỏ qua ngữ nghĩa hoàn toàn.
  final bool excludeSemantics;

  const TripCoverImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.fallbackColor,
    this.aspectRatio,
    this.withScrim = false,
    this.semanticLabel,
    this.excludeSemantics = false,
  });

  /// Gradient scrim chuẩn theo spec mục 8:
  /// dọc từ transparent tới #000000 alpha 0.55 ở 40% dưới của ảnh.
  static const LinearGradient unifiedScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.6, 1.0],
    colors: [
      Colors.transparent,
      Colors.transparent,
      Color(0x8C000000),
    ],
  );

  bool get _isAsset => source != null && source!.startsWith('assets/');
  bool get _isUrl =>
      source != null &&
      (source!.startsWith('http://') || source!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = fallbackColor ?? (isDark ? GenZTokens.fillDark : GenZTokens.fill);

    final src = source;
    Widget imageContent;

    if (src == null || src.isEmpty) {
      imageContent = ColoredBox(color: bg);
    } else if (_isAsset) {
      imageContent = Image.asset(
        src,
        fit: fit,
        errorBuilder: (_, _, _) => ColoredBox(color: bg),
      );
    } else if (_isUrl) {
      imageContent = CachedNetworkImage(
        imageUrl: src,
        fit: fit,
        placeholder: (_, _) => ColoredBox(color: bg),
        errorWidget: (_, _, _) => ColoredBox(color: bg),
      );
    } else {
      imageContent = ColoredBox(color: bg);
    }

    Widget content = withScrim
        ? Stack(
            fit: StackFit.passthrough,
            children: [
              imageContent,
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: unifiedScrim),
                ),
              ),
            ],
          )
        : imageContent;

    if (aspectRatio != null) {
      content = AspectRatio(aspectRatio: aspectRatio!, child: content);
    }

    if (excludeSemantics || semanticLabel == null) {
      return ExcludeSemantics(child: content);
    }

    return Semantics(
      label: semanticLabel,
      image: true,
      child: content,
    );
  }
}
