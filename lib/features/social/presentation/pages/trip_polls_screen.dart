import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
  Color get _primary =>
      isDarkMode ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
  Color get _textPri => isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  void _vote(WidgetRef ref, String optionId) {
    HapticFeedback.mediumImpact();
    // Optimistic — UI cập nhật tức thì trong notifier, tự rollback nếu lỗi.
    ref.read(pollsProvider(tripId).notifier).vote(optionId);
  }

  Future<void> _createPoll(BuildContext context, WidgetRef ref) async {
    final qCtrl = TextEditingController();
    final optsCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tạo bình chọn',
          style: AppFonts.heading(fontWeight: FontWeight.w800, color: _textPri),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qCtrl,
              autofocus: true,
              style: AppFonts.body(color: _textPri),
              decoration: InputDecoration(
                hintText: 'Câu hỏi (vd: Ăn gì tối nay?)',
                hintStyle: AppFonts.body(color: _textSec),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: optsCtrl,
              minLines: 2,
              maxLines: 5,
              style: AppFonts.body(color: _textPri),
              decoration: InputDecoration(
                hintText: 'Mỗi lựa chọn 1 dòng\nLẩu\nNướng\nPizza',
                hintStyle: AppFonts.body(color: _textSec),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'general.cancel'.tr(),
              style: AppFonts.body(color: _textSec),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _primary),
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
          const SnackBar(
            content: Text('Cần câu hỏi và ít nhất 2 lựa chọn'),
            backgroundColor: Colors.redAccent,
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
    return Scaffold(
      backgroundColor: _bgOf(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        onPressed: () => _createPoll(context, ref),
        icon: const Icon(Icons.add),
        label: Text(
          'polls.create_poll'.tr(),
          style: AppFonts.heading(fontWeight: FontWeight.w800),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Bình chọn nhóm',
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _textPri,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _primary,
        onRefresh: () async => ref.invalidate(pollsProvider(tripId)),
        child: async.when(
          loading: () => _skeleton(),
          error: (e, _) => _error(context, ref, e),
          data: (polls) =>
              polls.isEmpty ? _empty() : _list(context, ref, polls),
        ),
      ),
    );
  }

  Widget _skeleton() => ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      3,
      (i) => Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );

  Widget _error(BuildContext context, WidgetRef ref, Object e) => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Không tải được bình chọn',
              style: AppFonts.heading(
                fontWeight: FontWeight.w800,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _primary),
              onPressed: () => ref.invalidate(pollsProvider(tripId)),
              icon: const Icon(Icons.refresh),
              label: Text('general.retry'.tr()),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _empty() => ListView(
    children: [
      const SizedBox(height: 130),
      Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withValues(alpha: 0.12),
              ),
              child: Icon(
                PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
                color: _primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có bình chọn nào',
              style: AppFonts.heading(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: _textPri,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tạo poll để cả nhóm quyết định nhanh!',
              style: AppFonts.body(fontSize: 14, color: _textSec),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _list(BuildContext context, WidgetRef ref, List<Poll> polls) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: polls.length,
      itemBuilder: (context, i) => _pollCard(context, ref, polls[i]),
    );
  }

  Widget _pollCard(BuildContext context, WidgetRef ref, Poll poll) {
    final total = poll.totalVotes;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textPri,
              letterSpacing: -0.3,
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
                      borderRadius: BorderRadius.circular(12),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => FractionallySizedBox(
                          widthFactor: v.clamp(0.0, 1.0),
                          child: Container(
                            height: 46,
                            color: _primary.withValues(alpha: 0.18),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black,
                          width: 2,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _textPri,
                              ),
                            ),
                          ),
                          Text(
                            '${(pct * 100).round()}%',
                            style: AppFonts.heading(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _primary,
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
            '$total lượt vote',
            style: AppFonts.body(fontSize: 12, color: _textSec),
          ),
        ],
      ),
    );
  }
}
