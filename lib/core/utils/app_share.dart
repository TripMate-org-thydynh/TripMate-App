import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// iPadOS requires a non-zero `sharePositionOrigin` for `UIActivityViewController`
/// popover presentation. Without it, calling `Share.share*` on iPad crashes.
class AppShare {
  AppShare._();

  static const Rect _fallbackOrigin = Rect.fromLTWH(0, 0, 100, 100);

  static Rect shareOrigin(BuildContext? context) {
    if (context == null) return _fallbackOrigin;
    try {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.width > 0 && box.size.height > 0) {
        final offset = box.localToGlobal(Offset.zero);
        return offset & box.size;
      }
    } catch (_) {}
    return _fallbackOrigin;
  }

  static Future<ShareResult> shareText(
    BuildContext context,
    String text, {
    String? subject,
  }) {
    return Share.share(
      text,
      subject: subject,
      sharePositionOrigin: shareOrigin(context),
    );
  }

  static Future<ShareResult> shareFiles(
    BuildContext context,
    List<XFile> files, {
    String? text,
    String? subject,
  }) {
    return Share.shareXFiles(
      files,
      text: text,
      subject: subject,
      sharePositionOrigin: shareOrigin(context),
    );
  }
}
