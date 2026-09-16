import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/media_uploader.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../profile/data/xp_repository.dart';
import '../../../premium/presentation/paywall_sheet.dart';
import '../../application/moments_providers.dart';
import '../../data/moments_repository.dart';

/// Đăng một khoảnh khắc kèm ảnh.
///
/// Màn này **chưa từng tồn tại**: `MomentsRepository.create()` đã viết sẵn từ
/// lâu nhưng không nơi nào trong app gọi tới, nên Memory Wall, Photo Map,
/// scrapbook và số khoảnh khắc trong Trip Wrapped đều phụ thuộc dữ liệu mà
/// chính app không tạo ra được.
class PostMomentScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;

  const PostMomentScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  @override
  ConsumerState<PostMomentScreen> createState() => _PostMomentScreenState();
}

class _PostMomentScreenState extends ConsumerState<PostMomentScreen> {
  final TextEditingController _caption = TextEditingController();
  File? _picked;
  String? _pickedType;
  double _progress = 0;
  bool _busy = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (_busy) return;
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() {
      _picked = File(file.path);
      _pickedType = file.mimeType ?? 'image/jpeg';
      _progress = 0;
    });
  }

  Future<void> _post() async {
    final file = _picked;
    if (file == null || _busy) return;
    setState(() {
      _busy = true;
      _progress = 0;
    });

    try {
      final uploaded = await ref
          .read(mediaUploaderProvider)
          .uploadFile(
            tripId: widget.tripId,
            file: file,
            contentType: _pickedType ?? 'image/jpeg',
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );

      final caption = _caption.text.trim();
      await ref
          .read(momentsRepositoryProvider)
          .create(
            tripId: widget.tripId,
            mediaUrl: uploaded.url,
            type: 'PHOTO',
            caption: caption.isEmpty ? null : caption,
          );

      if (!mounted) return;
      // Bảng tin, scrapbook và ví XP (đăng ảnh được +40 XP) đều đổi.
      ref.invalidate(momentsProvider(widget.tripId));
      ref.invalidate(recentMomentsProvider);
      ref.invalidate(xpWalletProvider);
      HapticFeedback.mediumImpact();
      showGlobalSnack('moments.posted'.tr());
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      // Chuyến đã đầy 100 khoảnh khắc: mở paywall nói đúng con số vừa chạm,
      // thay vì một lỗi 403 trần trụi.
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'moments.post_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GenZTokens.space5),
        children: [
          // Khung ảnh
          Container(
            height: 260,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: _picked == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIcons.image(), size: 40, color: inkSoft),
                        const SizedBox(height: 8),
                        Text(
                          'moments.pick_hint'.tr(),
                          style: AppFonts.body(fontSize: 13, color: inkSoft),
                        ),
                      ],
                    ),
                  )
                : Image.file(_picked!, fit: BoxFit.cover),
          ),
          const SizedBox(height: GenZTokens.space4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  icon: Icon(PhosphorIcons.camera(), size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: line,
                      width: GenZTokens.borderWidthThin,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  label: Text(
                    'moments.take_photo'.tr(),
                    style: AppFonts.heading(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: GenZTokens.space3),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  icon: Icon(PhosphorIcons.images(), size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: line,
                      width: GenZTokens.borderWidthThin,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  label: Text(
                    'moments.from_gallery'.tr(),
                    style: AppFonts.heading(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GenZTokens.space5),
          TextField(
            controller: _caption,
            enabled: !_busy,
            minLines: 2,
            maxLines: 4,
            style: AppFonts.body(fontSize: 15, color: ink),
            decoration: InputDecoration(
              hintText: 'moments.caption_hint'.tr(),
              filled: true,
              fillColor: surface,
              contentPadding: const EdgeInsets.all(GenZTokens.space4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                borderSide: BorderSide(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                borderSide: BorderSide(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                borderSide: BorderSide(
                  color: accent,
                  width: GenZTokens.borderWidthFocus,
                ),
              ),
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: GenZTokens.space4),
            // Tiến trình THẬT của lần tải lên, không phải thanh chạy giả.
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                minHeight: 8,
                backgroundColor: fill,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'moments.uploading'.tr(args: ['${(_progress * 100).round()}']),
              style: AppFonts.body(fontSize: 12, color: inkSoft),
            ),
          ],
          const SizedBox(height: GenZTokens.space5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _picked == null || _busy ? null : _post,
              icon: Icon(
                PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.fill),
                size: 18,
                color: _picked == null || _busy ? inkSoft : onAccent,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                disabledBackgroundColor: fill,
                disabledForegroundColor: inkSoft,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              label: Text(
                'moments.post'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _picked == null || _busy ? inkSoft : onAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
