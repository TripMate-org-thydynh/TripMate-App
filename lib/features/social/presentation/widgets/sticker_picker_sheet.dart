import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../profile/pages/sticker_store_screen.dart';
import '../../data/custom_stickers_repository.dart';

/// Bảng chọn sticker trong chat: sticker cá nhân (tự làm từ ảnh) + sticker
/// emoji đã đổi bằng XP. Trả về nội dung tin nhắn qua [onPick]
/// (`custom:<id>` hoặc mã sticker `stk-…`).
class StickerPickerSheet extends ConsumerStatefulWidget {
  const StickerPickerSheet({
    super.key,
    required this.tripId,
    required this.onPick,
  });

  /// Cần để xin vé tải ảnh (vé tải lên luôn gắn với một chuyến).
  final String tripId;
  final void Function(String content) onPick;

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required void Function(String content) onPick,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: dark ? GenZTokens.paperDark : GenZTokens.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GenZTokens.radiusCard),
        ),
      ),
      builder: (_) => StickerPickerSheet(tripId: tripId, onPick: onPick),
    );
  }

  @override
  ConsumerState<StickerPickerSheet> createState() => _StickerPickerSheetState();
}

class _StickerPickerSheetState extends ConsumerState<StickerPickerSheet> {
  bool _creating = false;
  double _progress = 0;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _ink => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _soft => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _fill => _dark ? GenZTokens.fillDark : GenZTokens.fill;

  void _pick(String content) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    widget.onPick(content);
  }

  /// Chọn ảnh → tải lên → tạo sticker. Ảnh thu nhỏ 512 px: sticker hiện cỡ
  /// 120 px trong chat, lớn hơn chỉ tốn dung lượng.
  Future<void> _create() async {
    if (_creating) return;
    setState(() {
      _creating = true;
      _progress = 0;
    });
    try {
      final up = await ref
          .read(mediaUploaderProvider)
          .pickAndUpload(
            tripId: widget.tripId,
            source: ImageSource.gallery,
            maxWidth: 512,
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );
      if (up == null) return;
      await ref.read(customStickersRepositoryProvider).create(up.url);
      ref.invalidate(customStickersProvider);
      showGlobalSnack('stickers.created'.tr());
    } catch (e) {
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _confirmDelete(CustomSticker s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('stickers.delete_title'.tr()),
        content: Text('stickers.delete_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('general.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('stickers.delete'.tr()),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(customStickersRepositoryProvider).delete(s.id);
      ref.invalidate(customStickersProvider);
    } catch (e) {
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: GenZTokens.space2),
    child: Text(
      title,
      style: AppFonts.heading(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _ink,
      ),
    ),
  );

  Widget _grid(List<Widget> tiles) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 4,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    children: tiles,
  );

  Widget _addTile() => Semantics(
    button: true,
    label: 'stickers.create'.tr(),
    child: InkWell(
      borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
      onTap: _creating ? null : _create,
      child: Container(
        decoration: BoxDecoration(
          color: _fill,
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
          border: Border.all(color: _line),
        ),
        child: Center(
          child: _creating
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: _progress > 0 ? _progress : null,
                  ),
                )
              : Icon(PhosphorIcons.plus(), color: _ink, size: 26),
        ),
      ),
    ),
  );

  Widget _customTile(CustomSticker s) => Semantics(
    button: true,
    label: s.label ?? 'stickers.mine'.tr(),
    child: GestureDetector(
      onTap: () => _pick(s.wire),
      onLongPress: () => _confirmDelete(s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        child: CachedNetworkImage(
          imageUrl: s.mediaUrl,
          fit: BoxFit.cover,
          placeholder: (_, _) => ColoredBox(color: _fill),
          errorWidget: (_, _, _) => ColoredBox(
            color: _fill,
            child: Icon(PhosphorIcons.imageBroken(), color: _soft),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final custom = ref.watch(customStickersProvider);
    final owned = ref.watch(myStickersProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GenZTokens.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _section('stickers.mine'.tr()),
              _grid([_addTile(), ...?custom.valueOrNull?.map(_customTile)]),
              const SizedBox(height: 6),
              Text(
                'stickers.mine_hint'.tr(),
                style: AppFonts.body(fontSize: 12, color: _soft),
              ),
              const SizedBox(height: GenZTokens.space5),
              _section('stickers.owned'.tr()),
              owned.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => Text(
                  'errors.load_failed'.tr(),
                  style: AppFonts.body(fontSize: 13, color: _soft),
                ),
                data: (items) => items.isEmpty
                    ? TextButton.icon(
                        icon: Icon(PhosphorIcons.storefront(), color: _ink),
                        label: Text(
                          'xp.open_store'.tr(),
                          style: AppFonts.body(color: _ink),
                        ),
                        onPressed: () {
                          final dark = _dark;
                          // Lấy navigator trước khi đóng sheet: context của
                          // sheet không dùng được nữa sau khi pop.
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  StickerStoreScreen(isDarkMode: dark),
                            ),
                          );
                        },
                      )
                    : _grid([
                        for (final s in items)
                          GestureDetector(
                            onTap: () => _pick(s.id),
                            child: Center(
                              child: s.emoji != null
                                  ? Text(
                                      s.emoji!,
                                      style: const TextStyle(fontSize: 36),
                                    )
                                  : Icon(PhosphorIcons.sticker(), size: 32),
                            ),
                          ),
                      ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
