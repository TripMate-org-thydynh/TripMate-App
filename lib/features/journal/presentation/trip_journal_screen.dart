import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../application/journal_providers.dart';

/// Màn nhật ký du lịch — feed kiểu tạp chí với mood emoji.
class TripJournalScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;

  const TripJournalScreen({
    super.key,
    required this.tripId,
    required this.isDarkMode,
  });

  @override
  ConsumerState<TripJournalScreen> createState() => _TripJournalScreenState();
}

class _TripJournalScreenState extends ConsumerState<TripJournalScreen> {
  static const _moods = [
    'HAPPY',
    'CHILL',
    'TIRED',
    'WOW',
    'SAD',
    'EXCITED',
    'ANNOYED',
  ];
  static const _moodEmoji = {
    'HAPPY': '😄',
    'CHILL': '😌',
    'TIRED': '😴',
    'WOW': '🤩',
    'SAD': '😢',
    'EXCITED': '🥳',
    'ANNOYED': '😤',
  };
  static const _moodLabel = {
    'HAPPY': 'journal.mood_happy',
    'CHILL': 'journal.mood_chill',
    'TIRED': 'journal.mood_tired',
    'WOW': 'journal.mood_wow',
    'SAD': 'journal.mood_sad',
    'EXCITED': 'journal.mood_excited',
    'ANNOYED': 'journal.mood_annoyed',
  };
  static const _moodColors = {
    'HAPPY': Color(0xFFFFD84D),
    'CHILL': Color(0xFF7EC8E3),
    'TIRED': Color(0xFFB8AE9C),
    'WOW': Color(0xFFF5822B),
    'SAD': Color(0xFF7EE8A2),
    'EXCITED': Color(0xFFCF9FFF),
    'ANNOYED': Color(0xFFFF7E7E),
  };

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _ink =>
      widget.isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);
  Color get _card =>
      widget.isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);

  void _showAddDialog() {
    final bodyCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    String selectedMood = 'CHILL';
    DateTime selectedDate = DateTime.now();

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
              child: SingleChildScrollView(
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
                      'journal.write_title'.tr(),
                      style: AppFonts.heading(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date picker
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFFF5822B),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (date != null) {
                          setModalState(() => selectedDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _ink.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIcons.calendarBlank(
                                PhosphorIconsStyle.fill,
                              ),
                              color: const Color(0xFFF5822B),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: AppFonts.body(fontSize: 14, color: _ink),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    TextField(
                      controller: titleCtrl,
                      style: AppFonts.heading(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                      decoration: InputDecoration(
                        hintText: 'journal.title_hint'.tr(),
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
                    // Body
                    TextField(
                      controller: bodyCtrl,
                      minLines: 4,
                      maxLines: 10,
                      style: AppFonts.body(fontSize: 14, color: _ink),
                      decoration: InputDecoration(
                        hintText:
                            'journal.body_hint'.tr(),
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
                    const SizedBox(height: 16),
                    // Mood picker
                    Text(
                      'journal.mood_today'.tr(),
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textSec,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _moods.map((mood) {
                        final selected = mood == selectedMood;
                        final color =
                            _moodColors[mood] ?? const Color(0xFFF5822B);
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedMood = mood),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color
                                  : color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: selected
                                    ? color
                                    : color.withValues(alpha: 0.3),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              '${_moodEmoji[mood]} ${_moodLabel[mood]!.tr()}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: selected
                                    ? (color.computeLuminance() > 0.5
                                          ? const Color(0xFF141210)
                                          : Colors.white)
                                    : color,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
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
                          final body = bodyCtrl.text.trim();
                          if (body.isEmpty) return;
                          Navigator.pop(ctx);
                          await ref
                              .read(journalProvider(widget.tripId).notifier)
                              .add(
                                body: body,
                                mood: selectedMood,
                                entryDate: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(selectedDate),
                                title: titleCtrl.text.trim().isEmpty
                                    ? null
                                    : titleCtrl.text.trim(),
                              );
                        },
                        child: Text(
                          'journal.save'.tr(),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalProvider(widget.tripId));

    return Scaffold(
      backgroundColor: _bgOf(context),
      appBar: AppBar(
        backgroundColor: _bgOf(context),
        iconTheme: IconThemeData(color: _ink),
        elevation: 0,
        title: Text(
          'journal.title'.tr(),
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
                ref.read(journalProvider(widget.tripId).notifier).refresh(),
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
        icon: Icon(PhosphorIcons.pencil()),
        label: Text(
          'journal.write_short'.tr(),
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: entriesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: const Color(0xFFF5822B)),
        ),
        error: (e, _) => Center(
          child: Text(
            'journal.load_failed'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.bookOpen(PhosphorIconsStyle.fill),
                    size: 72,
                    color: _textSec.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'journal.empty'.tr(),
                    style: AppFonts.heading(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textSec,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'journal.empty_sub'.tr(),
                    style: AppFonts.body(fontSize: 14, color: _textSec),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final entry = entries[i];
              final moodColor =
                  _moodColors[entry.mood] ?? const Color(0xFFF5822B);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _ink.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Colored header bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: moodColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Date
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: moodColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  DateFormat('dd/MM').format(entry.entryDate),
                                  style: AppFonts.heading(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: moodColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_moodEmoji[entry.mood]} ${_moodLabel[entry.mood]!.tr()}',
                                style: AppFonts.heading(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textSec,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  PhosphorIcons.trash(),
                                  color: Colors.red.withValues(alpha: 0.7),
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: _bgOf(context),
                                      title: Text(
                                        'journal.delete_confirm'.tr(),
                                        style: AppFonts.heading(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _ink,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(
                                            'general.cancel'.tr(),
                                            style: AppFonts.body(
                                              fontSize: 14,
                                              color: const Color(0xFFF5822B),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
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
                                        .read(
                                          journalProvider(
                                            widget.tripId,
                                          ).notifier,
                                        )
                                        .remove(entry.id);
                                  }
                                },
                              ),
                            ],
                          ),
                          if (entry.title != null &&
                              entry.title!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              entry.title!,
                              style: AppFonts.heading(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            entry.body,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(fontSize: 14, color: _ink),
                          ),
                          if (entry.photos.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: entry.photos.length,
                                itemBuilder: (context, pi) {
                                  final photo = entry.photos[pi];
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(photo.mediaUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (entry.authorAvatarUrl != null)
                                CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(
                                    entry.authorAvatarUrl!,
                                  ),
                                )
                              else
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: moodColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  child: Text(
                                    entry.authorName.isNotEmpty
                                        ? entry.authorName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: moodColor,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Text(
                                entry.authorName,
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: _textSec,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
