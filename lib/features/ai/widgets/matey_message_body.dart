import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

/// Thân bong bóng trả lời của Matey: hiểu một tập markdown nhỏ.
///
/// - `![tên](https://...)` → ảnh (bo góc, chạm để mở trang ảnh)
/// - `[chữ](https://...)` và link trần `https://...` → chạm để mở
/// - `**đậm**`, dòng bắt đầu bằng `- ` / `* ` → gạch đầu dòng
///
/// Tự viết thay vì thêm gói markdown: chỉ cần chừng này, và câu trả lời
/// đang chảy từng mẩu — cú pháp chưa gõ xong (`![Hồ Xu`) cứ hiện như chữ
/// thường, mẩu sau tới là tự thành ảnh.
class MateyMessageBody extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color linkColor;

  const MateyMessageBody({
    super.key,
    required this.text,
    required this.textColor,
    required this.linkColor,
  });

  static final _image = RegExp(r'!\[([^\]]*)\]\((https://[^\s)]+)\)');
  static final _inline = RegExp(
    r'\*\*(.+?)\*\*|\[([^\]]+)\]\((https?://[^\s)]+)\)|(https?://[^\s)\]]+)',
  );

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final buffer = <String>[];

    void flushText() {
      if (buffer.isEmpty) return;
      for (final line in buffer) {
        children.add(_line(line));
      }
      buffer.clear();
    }

    for (final line in text.split('\n')) {
      final images = _image.allMatches(line).toList();
      if (images.isEmpty) {
        buffer.add(line);
        continue;
      }
      // Chữ quanh ảnh trên cùng dòng vẫn giữ, ảnh tách thành khối riêng.
      var last = 0;
      for (final m in images) {
        final before = line.substring(last, m.start).trim();
        if (before.isNotEmpty) buffer.add(before);
        flushText();
        children.add(_imageBlock(context, m.group(1) ?? '', m.group(2)!));
        last = m.end;
      }
      final after = line.substring(last).trim();
      if (after.isNotEmpty) buffer.add(after);
    }
    flushText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  TextStyle get _base => AppFonts.body(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textColor,
  );

  Widget _line(String raw) {
    final bullet = RegExp(r'^\s*[-*•]\s+').firstMatch(raw);
    final content = bullet == null ? raw : raw.substring(bullet.end);
    final rich = Text.rich(TextSpan(children: _spans(content)), style: _base);
    if (bullet == null) return rich;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: _base),
          Expanded(child: rich),
        ],
      ),
    );
  }

  List<InlineSpan> _spans(String s) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _inline.allMatches(s)) {
      if (m.start > last) spans.add(TextSpan(text: s.substring(last, m.start)));
      if (m.group(1) != null) {
        spans.add(
          TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      } else {
        final label = m.group(2) ?? m.group(4)!;
        final url = m.group(3) ?? m.group(4)!;
        spans.add(
          TextSpan(
            text: m.group(2) != null ? label : _shortUrl(url),
            style: TextStyle(
              color: linkColor,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => _open(url),
          ),
        );
      }
      last = m.end;
    }
    if (last < s.length) spans.add(TextSpan(text: s.substring(last)));
    return spans;
  }

  /// Link dài làm vỡ bong bóng: chỉ hiện tên miền + đoạn đầu đường dẫn.
  static String _shortUrl(String url) {
    final u = Uri.tryParse(url);
    if (u == null) return url;
    final host = u.host.replaceFirst('www.', '');
    final path = u.path.length > 24 ? '${u.path.substring(0, 24)}…' : u.path;
    return '$host$path';
  }

  static Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _imageBlock(BuildContext context, String alt, String url) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GenZTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _open(url),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => ColoredBox(color: fill),
                  // Link ảnh hỏng (trang nguồn đổi ảnh) thì hiện ô trống có
                  // biểu tượng, không để lỗi đỏ giữa câu trả lời.
                  errorWidget: (_, _, _) => ColoredBox(
                    color: fill,
                    child: Center(
                      child: Icon(
                        PhosphorIconsRegular.imageBroken,
                        color: inkSoft,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (alt.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                alt,
                style: AppFonts.body(fontSize: 12, color: inkSoft),
              ),
            ),
        ],
      ),
    );
  }
}
