import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
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
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _ink =>
      widget.isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);
  Color get _card =>
      widget.isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);

  IconData _mimeIcon(TripDocument doc) {
    if (doc.isImage) return PhosphorIcons.image(PhosphorIconsStyle.fill);
    if (doc.isPdf) return PhosphorIcons.filePdf(PhosphorIconsStyle.fill);
    if (doc.mimeType.contains('word')) {
      return PhosphorIcons.fileDoc(PhosphorIconsStyle.fill);
    }
    return PhosphorIcons.file(PhosphorIconsStyle.fill);
  }

  Color _mimeColor(TripDocument doc) {
    if (doc.isImage) return const Color(0xFF3D8BFF);
    if (doc.isPdf) return const Color(0xFFFF4444);
    if (doc.mimeType.contains('word')) return const Color(0xFF3D8BFF);
    return const Color(0xFF8B4DE8);
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: _bgOf(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: _ink.withValues(alpha: 0.12)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _textSec.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'documents.add'.tr(),
                style: AppFonts.heading(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'docs.paste_url_hint'.tr(),
                style: AppFonts.body(fontSize: 13, color: _textSec),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: AppFonts.body(fontSize: 14, color: _ink),
                decoration: InputDecoration(
                  hintText: 'documents.name_hint'.tr(),
                  hintStyle: AppFonts.body(fontSize: 14, color: _textSec),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFF5822B),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: _card,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                style: AppFonts.body(fontSize: 14, color: _ink),
                decoration: InputDecoration(
                  hintText: 'documents.url_hint'.tr(),
                  hintStyle: AppFonts.body(fontSize: 14, color: _textSec),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFF5822B),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: _card,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5822B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Color(0xFF141210),
                        width: 2,
                      ),
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
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(documentsProvider(widget.tripId));

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        iconTheme: IconThemeData(color: _ink),
        elevation: 0,
        title: Text(
          'documents.title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: _ink),
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
        backgroundColor: const Color(0xFFF5822B),
        foregroundColor: Colors.white,
        icon: Icon(PhosphorIcons.uploadSimple()),
        label: Text(
          'documents.add'.tr(),
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: docsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: const Color(0xFFF5822B)),
        ),
        error: (e, _) => Center(
          child: Text(
            'documents.load_error'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
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
                    color: _textSec.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'docs.empty'.tr(),
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textSec,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'docs.empty_sub'.tr(),
                    style: AppFonts.body(fontSize: 14, color: _textSec),
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
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _ink.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _mimeColor(doc).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _mimeColor(doc).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      _mimeIcon(doc),
                      color: _mimeColor(doc),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    doc.name,
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  subtitle: Text(
                    '${doc.uploaderName}${doc.sizeLabel.isNotEmpty ? ' · ${doc.sizeLabel}' : ''}',
                    style: AppFonts.body(fontSize: 12, color: _textSec),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.arrowSquareOut(),
                          color: const Color(0xFF3D8BFF),
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
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: _bgOf(context),
                              title: Text(
                                'documents.delete_confirm'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    'general.cancel'.tr(),
                                    style: AppFonts.body(
                                      fontSize: 14,
                                      color: const Color(0xFFF5822B),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    'general.delete'.tr(),
                                    style: AppFonts.body(
                                      fontSize: 14,
                                      color: Colors.red,
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
