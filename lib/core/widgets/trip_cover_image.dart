import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/gen_z_tokens.dart';

/// Ảnh bìa chuyến — nhận cả **asset path** lẫn **URL**.
///
/// Ảnh bìa do người dùng chọn lúc tạo chuyến được lưu dưới dạng đường dẫn asset
/// (`assets/images/cover_tokyo_drift.webp`), nhưng nơi hiển thị lại dùng
/// `CachedNetworkImage` vốn chỉ hiểu URL — nên ảnh bìa luôn im lặng rơi về nền
/// xanh trơn. Widget này chọn đúng loại theo giá trị nhận được.
class TripCoverImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;

  /// Màu nền khi không có ảnh / ảnh lỗi.
  final Color fallbackColor;

  const TripCoverImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.fallbackColor = GenZTokens.green,
  });

  bool get _isAsset => source != null && source!.startsWith('assets/');
  bool get _isUrl =>
      source != null &&
      (source!.startsWith('http://') || source!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final src = source;
    if (src == null || src.isEmpty) {
      return ColoredBox(color: fallbackColor);
    }

    if (_isAsset) {
      return Image.asset(
        src,
        fit: fit,
        errorBuilder: (_, _, _) => ColoredBox(color: fallbackColor),
      );
    }

    if (_isUrl) {
      return CachedNetworkImage(
        imageUrl: src,
        fit: fit,
        placeholder: (_, _) => ColoredBox(color: fallbackColor),
        errorWidget: (_, _, _) => ColoredBox(color: fallbackColor),
      );
    }

    // Giá trị lạ (BE trả khoá nội bộ chẳng hạn) — không đoán, dùng nền màu.
    return ColoredBox(color: fallbackColor);
  }
}
