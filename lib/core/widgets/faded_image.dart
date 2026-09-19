import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Ảnh tràn viền tan dần xuống màu nền, kèm vệt màu loang lấy từ chính ảnh.
///
/// Ba lớp, từ dưới lên:
/// 1. **Vệt loang** — bản sao ảnh làm nhoè mạnh, cao hơn ảnh thêm [glowExtent],
///    tan dần vào [fadeTo]. Màu của ảnh vì thế "chảy" xuống phần nội dung.
/// 2. **Ảnh sắc** — mờ dần (alpha) ở nửa dưới để hoà vào vệt loang, không có
///    đường cắt.
/// 3. **Mờ đỉnh** ([topFade]) — một dải màu nền mỏng ở mép trên để header/icon
///    đặt đè lên vẫn đọc được.
class FadedImage extends StatelessWidget {
  const FadedImage({
    super.key,
    required this.imageUrl,
    required this.fadeTo,
    required this.height,
    this.glowExtent = 280,
    this.fadeStart = 0.62,
    this.topFade = false,
  });

  /// URL hoặc đường dẫn `assets/...`. Rỗng → chỉ tô [fadeTo].
  final String? imageUrl;
  final Color fadeTo;

  /// Chiều cao phần ảnh sắc.
  final double height;

  /// Vệt loang kéo xuống dưới ảnh thêm bao nhiêu.
  final double glowExtent;

  /// Vị trí (0..1 theo chiều cao ảnh) ảnh sắc bắt đầu mờ.
  final double fadeStart;
  final bool topFade;

  Widget _image(String url) => url.startsWith('assets/')
      ? Image.asset(url, fit: BoxFit.cover)
      : CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 250),
          placeholder: (_, _) => const SizedBox.shrink(),
          errorWidget: (_, _, _) => const SizedBox.shrink(),
        );

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final total = height + glowExtent;
    if (url == null || url.isEmpty) return SizedBox(height: total);

    return SizedBox(
      height: total,
      width: double.infinity,
      child: ExcludeSemantics(
        child: Stack(
          children: [
            // 1. Vệt loang
            Positioned.fill(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 60,
                    sigmaY: 60,
                    tileMode: TileMode.mirror,
                  ),
                  child: SizedBox.expand(child: _image(url)),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, height / total, 1],
                    colors: [
                      fadeTo.withValues(alpha: 0.35),
                      fadeTo.withValues(alpha: 0.5),
                      fadeTo,
                    ],
                  ),
                ),
              ),
            ),
            // 2. Ảnh sắc, mờ dần vào vệt loang
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [fadeStart, 1],
                  colors: const [Colors.white, Color(0x00FFFFFF)],
                ).createShader(rect),
                child: _image(url),
              ),
            ),
            // 3. Mờ đỉnh cho header
            if (topFade)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: height * 0.28,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        fadeTo.withValues(alpha: 0.6),
                        fadeTo.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
