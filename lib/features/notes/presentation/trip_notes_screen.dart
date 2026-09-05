import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../application/notes_providers.dart';
import '../data/notes_repository.dart';

/// Màn Ghi chú nhóm — sticky note style, mỗi note 1 màu pastel.
class TripNotesScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;

  const TripNotesScreen({
    super.key,
    required this.tripId,
    required this.isDarkMode,
  });

  @override
  ConsumerState<TripNotesScreen> createState() => _TripNotesScreenState();
}

class _TripNotesScreenState extends ConsumerState<TripNotesScreen> {
  static const _colors = [
    '#FFD84D', // yellow
    '#FF7E7E', // coral
    '#7EE8A2', // mint
    '#7EC8E3', // sky
    '#CF9FFF', // lavender
    '#FFB347', // peach
  ];

  int _selectedColorIndex = 0;

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _ink =>
      widget.isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);
  Color get _card =>
      widget.isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);

  Color _parseHex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  void _showAddDialog({TripNote? editing}) {
    final contentCtrl = TextEditingController(text: editing?.content ?? '');
    final titleCtrl = TextEditingController(text: editing?.title ?? '');
    int colorIndex = editing != null
        ? _colors.indexOf(editing.color).clamp(0, _colors.length - 1)
        : _selectedColorIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: _bgOf(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(color: _ink.withValues(alpha: 0.12)),
              ),
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
                  // Handle
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
                    editing == null ? 'notes.new'.tr() : 'notes.edit_title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title field
                  TextField(
                    controller: titleCtrl,
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                    decoration: InputDecoration(
                      hintText: 'notes.title_hint'.tr(),
                      hintStyle: AppFonts.body(fontSize: 14, color: _textSec),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _ink.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFF5822B),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: _card,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Content field
                  TextField(
                    controller: contentCtrl,
                    minLines: 3,
                    maxLines: 7,
                    style: AppFonts.body(fontSize: 14, color: _ink),
                    decoration: InputDecoration(
                      hintText: 'notes.body_hint'.tr(),
                      hintStyle: AppFonts.body(fontSize: 14, color: _textSec),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _ink.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFF5822B),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: _card,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Color picker
                  Text(
                    'notes.color'.tr(),
                    style: AppFonts.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textSec,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_colors.length, (i) {
                      final c = _parseHex(_colors[i]);
                      final selected = i == colorIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setModalState(() => colorIndex = i),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? _ink : Colors.transparent,
                                width: selected ? 3 : 0,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: _ink,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: selected
                                ? Icon(
                                    PhosphorIcons.check(),
                                    size: 14,
                                    color: _ink,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Submit
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
                        final content = contentCtrl.text.trim();
                        if (content.isEmpty) return;
                        Navigator.pop(ctx);
                        final notifier = ref.read(
                          notesProvider(widget.tripId).notifier,
                        );
                        if (editing == null) {
                          await notifier.add(
                            content: content,
                            title: titleCtrl.text.trim().isEmpty
                                ? null
                                : titleCtrl.text.trim(),
                            color: _colors[colorIndex],
                          );
                        } else {
                          await notifier.edit(
                            editing.id,
                            content: content,
                            title: titleCtrl.text.trim().isEmpty
                                ? null
                                : titleCtrl.text.trim(),
                            color: _colors[colorIndex],
                          );
                        }
                        setState(() => _selectedColorIndex = colorIndex);
                      },
                      child: Text(
                        editing == null ? 'notes.save'.tr() : 'common.update'.tr(),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider(widget.tripId));

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        iconTheme: IconThemeData(color: _ink),
        elevation: 0,
        title: Text(
          'notes.title'.tr(),
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
                ref.read(notesProvider(widget.tripId).notifier).refresh(),
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
        icon: Icon(PhosphorIcons.note(PhosphorIconsStyle.fill)),
        label: Text(
          'notes.add'.tr(),
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: notesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: const Color(0xFFF5822B)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.warningCircle(), size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'notes.load_error'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.notepad(PhosphorIconsStyle.fill),
                    size: 72,
                    color: _textSec.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'notes.empty'.tr(),
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textSec,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'notes.empty_sub'.tr(),
                    style: AppFonts.body(fontSize: 14, color: _textSec),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: notes.length,
            itemBuilder: (context, i) {
              final note = notes[i];
              final noteColor = _parseHex(note.color);
              return _buildNoteCard(note, noteColor);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(TripNote note, Color noteColor) {
    return GestureDetector(
      onTap: () => _showAddDialog(editing: note),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _bgOf(context),
            title: Text(
              'notes.delete_confirm'.tr(),
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'general.cancel'.tr(),
                  style: AppFonts.body(
                    fontSize: 14,
                    color: const Color(0xFFF5822B),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(notesProvider(widget.tripId).notifier)
                      .remove(note.id);
                },
                child: Text(
                  'general.delete'.tr(),
                  style: AppFonts.body(fontSize: 14, color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF141210), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF141210),
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null && note.title!.isNotEmpty) ...[
              Text(
                note.title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF141210),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Expanded(
              child: Text(
                note.content,
                overflow: TextOverflow.fade,
                style: AppFonts.body(
                  fontSize: 13,
                  color: const Color(0xFF141210).withValues(alpha: 0.85),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (note.authorAvatarUrl != null)
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(note.authorAvatarUrl!),
                  )
                else
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: const Color(
                      0xFF141210,
                    ).withValues(alpha: 0.2),
                    child: Text(
                      note.authorName.isNotEmpty
                          ? note.authorName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141210),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    note.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 10,
                      color: const Color(0xFF141210).withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
