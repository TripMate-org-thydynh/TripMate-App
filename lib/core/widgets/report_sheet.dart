import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_messenger.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../theme/app_fonts.dart';
import '../theme/gen_z_tokens.dart';

/// Loại nội dung báo cáo — khớp enum `ReportTarget` ở BE.
enum ReportTarget { template, moment, chatMessage, user }

extension on ReportTarget {
  String get wire => switch (this) {
    ReportTarget.template => 'TEMPLATE',
    ReportTarget.moment => 'MOMENT',
    ReportTarget.chatMessage => 'CHAT_MESSAGE',
    ReportTarget.user => 'USER',
  };
}

/// Sheet báo cáo vi phạm dùng chung (chính sách nội dung người dùng tạo của
/// Google Play). Gửi `POST /reports`; server tự ẩn mẫu công khai khi đủ số
/// báo cáo và đưa vào hàng chờ admin.
class ReportSheet extends ConsumerStatefulWidget {
  const ReportSheet({super.key, required this.target, required this.targetId});

  final ReportTarget target;
  final String targetId;

  static Future<void> show(
    BuildContext context, {
    required ReportTarget target,
    required String targetId,
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
      builder: (_) => ReportSheet(target: target, targetId: targetId),
    );
  }

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  static const _reasons = [
    'SPAM',
    'SEXUAL',
    'VIOLENCE',
    'HATE',
    'HARASSMENT',
    'ILLEGAL',
    'OTHER',
  ];
  String? _reason;
  final _note = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(apiClientProvider).postData('/reports', {
        'targetType': widget.target.wire,
        'targetId': widget.targetId,
        'reason': reason,
        if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      showGlobalSnack('report.thanks'.tr());
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? GenZTokens.inkDark : GenZTokens.ink;
    final soft = dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = dark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = dark ? GenZTokens.fillDark : GenZTokens.fill;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          GenZTokens.space5,
          GenZTokens.space5,
          GenZTokens.space5,
          GenZTokens.space4 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'report.title'.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'report.subtitle'.tr(),
                style: AppFonts.body(fontSize: 13, color: soft),
              ),
              const SizedBox(height: GenZTokens.space3),
              RadioGroup<String>(
                groupValue: _reason,
                onChanged: (v) => setState(() => _reason = v),
                child: Column(
                  children: [
                    for (final r in _reasons)
                      RadioListTile<String>(
                        value: r,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          'report.reason_${r.toLowerCase()}'.tr(),
                          style: AppFonts.body(fontSize: 15, color: ink),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: GenZTokens.space2),
              TextField(
                controller: _note,
                maxLength: 500,
                maxLines: 3,
                minLines: 1,
                style: AppFonts.body(fontSize: 15, color: ink),
                decoration: InputDecoration(
                  hintText: 'report.note_hint'.tr(),
                  hintStyle: AppFonts.body(fontSize: 15, color: soft),
                  filled: true,
                  fillColor: fill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusInput,
                    ),
                    borderSide: BorderSide(color: line),
                  ),
                ),
              ),
              const SizedBox(height: GenZTokens.space3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _reason == null || _sending ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                  child: Text('report.submit'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
