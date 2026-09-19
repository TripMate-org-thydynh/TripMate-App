import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/gen_z_tokens.dart';
import '../../application/polls_providers.dart';
import '../../data/polls_repository.dart';
import '../../domain/poll.dart';

/// Bình chọn nhóm — wired thật vào BE (`/trips/:tripId/polls`).
/// Vote realtime tối giản: bấm chọn → POST vote → refresh.
class TripPollsScreen extends ConsumerWidget {
  final String tripId;
  final bool isDarkMode;

  const TripPollsScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  bool _isDark(BuildContext context) =>
      isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color _bgOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.creamDark : GenZTokens.cream;
  Color _surfaceOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.paperDark : GenZTokens.paper;
  Color _lineOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.lineDark : GenZTokens.line;
  Color _fillOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.fillDark : GenZTokens.fill;
  Color _primaryOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.accentDark : GenZTokens.accent;
  Color _onAccentOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color _accentSoftOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color _textPriOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSecOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  void _vote(WidgetRef ref, String optionId) {
    HapticFeedback.mediumImpact();
    // Optimistic — UI cập nhật tức thì trong notifier, tự rollback nếu lỗi.
    ref.read(pollsProvider(tripId).notifier).vote(optionId);
  }

  Future<void> _createPoll(BuildContext context, WidgetRef ref) async {
    final qCtrl = TextEditingController();
    final optsCtrl = TextEditingController();
    final dark = _isDark(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);
    final line = _lineOf(context);
    final primary = _primaryOf(context);
    final onAccent = _onAccentOf(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surfaceOf(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: line, width: 1),
        ),
        title: Text(
          'polls.create'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qCtrl,
              autofocus: true,
              style: AppFonts.body(color: textPri),
              decoration: InputDecoration(
                hintText: 'polls.question_hint'.tr(),
                hintStyle: AppFonts.body(color: textSec),
                filled: true,
                fillColor: _fillOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: line, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: line, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: optsCtrl,
              minLines: 2,
              maxLines: 5,
              style: AppFonts.body(color: textPri),
              decoration: InputDecoration(
                hintText: 'polls.options_hint'.tr(),
                hintStyle: AppFonts.body(color: textSec),
                filled: true,
                fillColor: _fillOf(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: line, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: line, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(color: textSec),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('polls.create'.tr()),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final question = qCtrl.text.trim();
    final options = optsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => {'text': e})
        .toList();
    if (question.isEmpty || options.length < 2) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('polls.need_options'.tr()),
            backgroundColor: dark ? GenZTokens.dangerDark : GenZTokens.danger,
          ),
        );
      }
      return;
    }
    HapticFeedback.mediumImpact();
    await ref
        .read(pollsRepositoryProvider)
        .create(tripId, question: question, options: options);
    ref.invalidate(pollsProvider(tripId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pollsProvider(tripId));
    final primary = _primaryOf(context);
    final onAccent = _onAccentOf(context);
    final textPri = _textPriOf(context);

    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: onAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onPressed: () => _createPoll(context, ref),
        icon: Icon(PhosphorIcons.plus()),
        label: Text(
          'polls.create_poll'.tr(),
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: onAccent,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'polls.title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textPri,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: () async => ref.invalidate(pollsProvider(tripId)),
        child: async.when(
          loading: () => _skeleton(context),
          error: (e, _) => _error(context, ref, e),
          data: (polls) =>
              polls.isEmpty ? _empty(context) : _list(context, ref, polls),
        ),
      ),
    );
  }

  Widget _skeleton(BuildContext context) {
    final fill = _fillOf(context);
    final line = _lineOf(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: List.generate(
        3,
        (i) => Container(
          height: 160,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: line, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _error(BuildContext context, WidgetRef ref, Object e) {
    final dark = _isDark(context);
    final textPri = _textPriOf(context);
    final primary = _primaryOf(context);
    final onAccent = _onAccentOf(context);

    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(
                PhosphorIcons.cloudSlash(),
                color: dark ? GenZTokens.dangerDark : GenZTokens.danger,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'polls.load_failed'.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => ref.invalidate(pollsProvider(tripId)),
                icon: Icon(PhosphorIcons.arrowsClockwise()),
                label: Text('general.retry'.tr()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context) {
    final primary = _primaryOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);
    final fill = _fillOf(context);
    final line = _lineOf(context);

    return ListView(
      children: [
        const SizedBox(height: 130),
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill,
                  border: Border.all(color: line, width: 1),
                ),
                child: Icon(
                  PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
                  color: primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'polls.empty'.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textPri,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'polls.empty_sub'.tr(),
                style: AppFonts.body(fontSize: 13, color: textSec),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, List<Poll> polls) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: polls.length,
      itemBuilder: (context, i) => _pollCard(context, ref, polls[i]),
    );
  }

  Widget _pollCard(BuildContext context, WidgetRef ref, Poll poll) {
    final total = poll.totalVotes;
    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final fill = _fillOf(context);
    final accentSoft = _accentSoftOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: line,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPri,
            ),
          ),
          const SizedBox(height: 14),
          ...poll.options.map((o) {
            final pct = total == 0 ? 0.0 : o.voteCount / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _vote(ref, o.id),
                child: Stack(
                  children: [
                    // Progress fill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 46,
                        color: fill,
                        alignment: Alignment.centerLeft,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: pct),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => FractionallySizedBox(
                            widthFactor: v.clamp(0.0, 1.0),
                            child: Container(
                              height: 46,
                              color: accentSoft,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: line,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (o.emoji != null) ...[
                            Text(
                              o.emoji!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              o.text,
                              style: AppFonts.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textPri,
                              ),
                            ),
                          ),
                          Text(
                            '${(pct * 100).round()}%',
                            style: AppFonts.heading(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPri,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            'polls.vote_count'.tr(namedArgs: {'n': '$total'}),
            style: AppFonts.body(fontSize: 12, color: textSec),
          ),
        ],
      ),
    );
  }
}
