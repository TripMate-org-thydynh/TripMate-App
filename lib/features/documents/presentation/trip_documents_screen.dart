import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../application/documents_providers.dart';
import '../data/documents_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// Màn kho tài liệu chuyến — danh sách file đã upload lên Supabase Storage.
class TripDocumentsScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;

  const TripDocumentsScreen({
    super.key,
    required this.tripId,
    required this.isDarkMode,
  });

  @override
  ConsumerState<TripDocumentsScreen> createState() =>
      _TripDocumentsScreenState();
}

class _TripDocumentsScreenState extends ConsumerState<TripDocumentsScreen> {
  bool _isDark(BuildContext context) =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color _bgOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.creamDark : GenZTokens.cream;
  Color _cardOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.paperDark : GenZTokens.paper;
  Color _lineOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.lineDark : GenZTokens.line;
  Color _fillOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.fillDark : GenZTokens.fill;
  Color _primaryOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.accentDark : GenZTokens.accent;
  Color _onAccentOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color _inkOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSecOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  IconData _mimeIcon(TripDocument doc) {
    if (doc.isImage) return PhosphorIcons.image(PhosphorIconsStyle.fill);
    if (doc.isPdf) return PhosphorIcons.filePdf(PhosphorIconsStyle.fill);
    if (doc.mimeType.contains('word')) {
      return PhosphorIcons.fileDoc(PhosphorIconsStyle.fill);
    }
    return PhosphorIcons.file(PhosphorIconsStyle.fill);
  }

  Color _mimeColor(TripDocument doc, bool isDark) {
    if (doc.isImage) return isDark ? GenZTokens.infoDark : GenZTokens.info;
    if (doc.isPdf) return isDark ? GenZTokens.dangerDark : GenZTokens.danger;
    if (doc.mimeType.contains('word')) {
      return isDark ? GenZTokens.infoDark : GenZTokens.info;
    }
    return GenZTokens.chart3;
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final cardBg = _cardOf(context);
    final line = _lineOf(context);
    final primary = _primaryOf(context);
    final onAccent = _onAccentOf(context);
    final textPri = _inkOf(context);
    final textSec = _textSecOf(context);
    final fill = _fillOf(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: line, width: 1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSec.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'documents.add'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPri,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'docs.paste_url_hint'.tr(),
              style: AppFonts.body(fontSize: 13, color: textSec),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: AppFonts.body(fontSize: 15, color: textPri),
              decoration: InputDecoration(
                hintText: 'documents.name_hint'.tr(),
                hintStyle: AppFonts.body(fontSize: 13, color: textSec),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: line, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
                filled: true,
                fillColor: fill,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              style: AppFonts.body(fontSize: 15, color: textPri),
              decoration: InputDecoration(
                hintText: 'documents.url_hint'.tr(),
                hintStyle: AppFonts.body(fontSize: 13, color: textSec),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: line, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
                filled: true,
                fillColor: fill,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final url = urlCtrl.text.trim();
                  if (name.isEmpty || url.isEmpty) return;
                  Navigator.pop(ctx);
                  // Infer mimeType from URL extension
                  String mimeType = 'application/octet-stream';
                  if (url.contains('.pdf')) {
                    mimeType = 'application/pdf';
                  } else if (url.contains('.jpg') || url.contains('.jpeg')) {
                    mimeType = 'image/jpeg';
                  } else if (url.contains('.png')) {
                    mimeType = 'image/png';
                  } else if (url.contains('.webp')) {
                    mimeType = 'image/webp';
                  }
                  await ref
                      .read(documentsProvider(widget.tripId).notifier)
                      .add(name: name, url: url, mimeType: mimeType);
                },
                child: Text(
                  'documents.save'.tr(),
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: onAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentsProvider(widget.tripId));
    final dark = _isDark(context);
    final textPri = _inkOf(context);
    final textSec = _textSecOf(context);
    final primary = _primaryOf(context);
    final onAccent = _onAccentOf(context);
    final line = _lineOf(context);
    final cardBg = _cardOf(context);
    final danger = dark ? GenZTokens.dangerDark : GenZTokens.danger;
    final info = dark ? GenZTokens.infoDark : GenZTokens.info;

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        iconTheme: IconThemeData(color: textPri),
        elevation: 0,
        title: Text(
          'documents.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: textPri),
            onPressed: () =>
                ref.read(documentsProvider(widget.tripId).notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.selectionClick();
          _showAddDialog();
        },
        backgroundColor: primary,
        foregroundColor: onAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        icon: Icon(PhosphorIcons.uploadSimple(), color: onAccent),
        label: Text(
          'documents.add'.tr(),
          style: AppFonts.heading(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: onAccent,
          ),
        ),
      ),
      body: docsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primary)),
        error: (e, _) => Center(
          child: Text(
            'documents.load_error'.tr(),
            style: AppFonts.heading(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textPri,
            ),
          ),
        ),
        data: (docs) {
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.folders(PhosphorIconsStyle.fill),
                    size: 72,
                    color: textSec.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'docs.empty'.tr(),
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textSec,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'docs.empty_sub'.tr(),
                    style: AppFonts.body(fontSize: 13, color: textSec),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final mimeColor = _mimeColor(doc, dark);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: line, width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: mimeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: mimeColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(_mimeIcon(doc), color: mimeColor, size: 22),
                  ),
                  title: Text(
                    doc.name,
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPri,
                    ),
                  ),
                  subtitle: Text(
                    '${doc.uploaderName}${doc.sizeLabel.isNotEmpty ? ' · ${doc.sizeLabel}' : ''}',
                    style: AppFonts.body(fontSize: 12, color: textSec),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.arrowSquareOut(),
                          color: info,
                          size: 20,
                        ),
                        onPressed: () async {
                          final uri = Uri.tryParse(doc.url);
                          if (uri != null) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.trash(),
                          color: danger,
                          size: 20,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: cardBg,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: line, width: 1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              title: Text(
                                'documents.delete_confirm'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: textPri,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    'general.cancel'.tr(),
                                    style: AppFonts.body(
                                      fontSize: 13,
                                      color: textSec,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    'general.delete'.tr(),
                                    style: AppFonts.body(
                                      fontSize: 13,
                                      color: danger,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(documentsProvider(widget.tripId).notifier)
                                .remove(doc.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
