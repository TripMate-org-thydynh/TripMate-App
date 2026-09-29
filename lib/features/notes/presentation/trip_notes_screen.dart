import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
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
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                        color: textSec.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    editing == null
                        ? 'notes.new'.tr()
                        : 'notes.edit_title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title field
                  TextField(
                    controller: titleCtrl,
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPri,
                    ),
                    decoration: InputDecoration(
                      hintText: 'notes.title_hint'.tr(),
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
                  // Content field
                  TextField(
                    controller: contentCtrl,
                    minLines: 3,
                    maxLines: 7,
                    style: AppFonts.body(fontSize: 15, color: textPri),
                    decoration: InputDecoration(
                      hintText: 'notes.body_hint'.tr(),
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
                  const SizedBox(height: 16),
                  // Color picker
                  Text(
                    'notes.color'.tr(),
                    style: AppFonts.heading(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSec,
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
                                color: selected ? primary : line,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: selected
                                ? Icon(
                                    PhosphorIcons.check(),
                                    size: 14,
                                    color: GenZTokens.ink,
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
                        backgroundColor: primary,
                        foregroundColor: onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                        editing == null
                            ? 'notes.save'.tr()
                            : 'common.update'.tr(),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider(widget.tripId));
    final dark = _isDark(context);
    final textPri = _inkOf(context);
    final textSec = _textSecOf(context);
    final primary = _primaryOf(context);
    final onAccent = _onAccentOf(context);
    final danger = dark ? GenZTokens.dangerDark : GenZTokens.danger;

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        iconTheme: IconThemeData(color: textPri),
        elevation: 0,
        title: Text(
          'notes.title'.tr(),
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
                ref.read(notesProvider(widget.tripId).notifier).refresh(),
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
        icon: Icon(
          PhosphorIcons.note(PhosphorIconsStyle.fill),
          color: onAccent,
        ),
        label: Text(
          'notes.add'.tr(),
          style: AppFonts.heading(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: onAccent,
          ),
        ),
      ),
      body: notesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.warningCircle(), size: 48, color: danger),
              const SizedBox(height: 12),
              Text(
                'notes.load_error'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPri,
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
                    color: textSec.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'notes.empty'.tr(),
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textSec,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'notes.empty_sub'.tr(),
                    style: AppFonts.body(fontSize: 13, color: textSec),
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
    final dark = _isDark(context);
    final textPri = _inkOf(context);
    final line = _lineOf(context);
    final cardBg = _cardOf(context);
    final danger = dark ? GenZTokens.dangerDark : GenZTokens.danger;

    return GestureDetector(
      onTap: () => _showAddDialog(editing: note),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: line, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(
              'notes.delete_confirm'.tr(),
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPri,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'general.cancel'.tr(),
                  style: AppFonts.body(
                    fontSize: 13,
                    color: _textSecOf(context),
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
                  style: AppFonts.body(fontSize: 13, color: danger),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: dark
              ? noteColor.withValues(alpha: 0.18)
              : noteColor.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dark ? noteColor.withValues(alpha: 0.35) : line,
            width: 1,
          ),
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
                  fontWeight: FontWeight.w700,
                  color: textPri,
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
                  color: textPri.withValues(alpha: 0.85),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (note.authorAvatarUrl != null)
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(note.authorAvatarUrl!),
                  )
                else
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: textPri.withValues(alpha: 0.15),
                    child: Text(
                      note.authorName.isNotEmpty
                          ? note.authorName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textPri,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    note.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 12,
                      color: textPri.withValues(alpha: 0.65),
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
