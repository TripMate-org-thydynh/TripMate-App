import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/itinerary_templates_repository.dart';
import '../domain/itinerary_template.dart';

/// Đăng lịch trình của chuyến hiện tại thành mẫu cho người khác nhân bản.
class PublishTemplateSheet extends ConsumerStatefulWidget {
  const PublishTemplateSheet({
    super.key,
    required this.tripId,
    required this.defaultTitle,
    required this.isDarkMode,
  });

  final String tripId;
  final String defaultTitle;
  final bool isDarkMode;

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required String defaultTitle,
    bool isDarkMode = false,
  }) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PublishTemplateSheet(
      tripId: tripId,
      defaultTitle: defaultTitle,
      isDarkMode: isDarkMode,
    ),
  );

  @override
  ConsumerState<PublishTemplateSheet> createState() =>
      _PublishTemplateSheetState();
}

class _PublishTemplateSheetState extends ConsumerState<PublishTemplateSheet> {
  late final _title = TextEditingController(text: widget.defaultTitle);
  final _desc = TextEditingController();
  final Set<String> _tags = {};
  bool _public = true;
  bool _notes = false;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  bool get _dark =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color get _surface => _dark ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => _dark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _ink => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        if (TemplateTags.isBudget(tag)) {
          _tags.removeWhere((t) => TemplateTags.isBudget(t));
        }
        if (_tags.length < 5) {
          _tags.add(tag);
        }
      }
    });
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final nav = Navigator.of(context);
    try {
      await ref
          .read(itineraryTemplatesRepositoryProvider)
          .publish(
            widget.tripId,
            title: _title.text.trim(),
            description: _desc.text,
            isPublic: _public,
            includeNotes: _notes,
            tags: _tags.toList(),
          );
      HapticFeedback.mediumImpact();
      ref.invalidate(myTemplatesProvider);
      ref.invalidate(publicTemplatesProvider);
      showGlobalSnack('templates.published'.tr());
      nav.pop();
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    labelStyle: AppFonts.body(fontSize: 13, color: _inkSoft),
    filled: true,
    fillColor: _fill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
      borderSide: BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
      borderSide: BorderSide(color: _line),
    ),
  );

  Widget _switch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    value: value,
    onChanged: onChanged,
    title: Text(
      title,
      style: AppFonts.heading(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: AppFonts.body(fontSize: 12, color: _inkSoft),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(GenZTokens.radiusCard),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'templates.publish_title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'templates.publish_hint'.tr(),
                  style: AppFonts.body(fontSize: 13, color: _inkSoft),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _title,
                  maxLength: 120,
                  style: AppFonts.body(fontSize: 15, color: _ink),
                  decoration: _input('templates.field_title'.tr()),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _desc,
                  maxLength: 1000,
                  minLines: 2,
                  maxLines: 4,
                  style: AppFonts.body(fontSize: 15, color: _ink),
                  decoration: _input('templates.field_description'.tr()),
                ),
                const SizedBox(height: 12),
                Text(
                  'templates.tags_label'.tr(),
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in TemplateTags.all)
                      FilterChip(
                        label: Text('templates.tag_$tag'.tr()),
                        selected: _tags.contains(tag),
                        showCheckmark: false,
                        onSelected: (_) => _toggleTag(tag),
                        labelStyle: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _tags.contains(tag)
                              ? Theme.of(context).colorScheme.onPrimary
                              : _inkSoft,
                        ),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: _fill,
                        side: BorderSide(
                          color: _tags.contains(tag)
                              ? Theme.of(context).colorScheme.primary
                              : _line,
                        ),
                        shape: const StadiumBorder(),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _switch(
                  'templates.public_switch'.tr(),
                  'templates.public_switch_hint'.tr(),
                  _public,
                  (v) => setState(() => _public = v),
                ),
                _switch(
                  'templates.notes_switch'.tr(),
                  'templates.notes_switch_hint'.tr(),
                  _notes,
                  (v) => setState(() => _notes = v),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusButton,
                        ),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'templates.publish_cta'.tr(),
                            style: AppFonts.heading(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
