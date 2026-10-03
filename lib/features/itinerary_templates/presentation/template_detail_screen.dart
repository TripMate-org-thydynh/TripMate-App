import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/faded_image.dart';
import '../../../core/widgets/report_sheet.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/data/profile_provider.dart';
import '../data/itinerary_templates_repository.dart';
import '../domain/itinerary_template.dart';
import 'use_template_sheet.dart';

/// Xem trước một lịch trình mẫu trước khi nhân bản.
class TemplateDetailScreen extends ConsumerWidget {
  const TemplateDetailScreen({
    super.key,
    required this.templateId,
    this.isDarkMode = false,
  });

  final String templateId;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = dark ? GenZTokens.inkDark : GenZTokens.ink;
    final async = ref.watch(templateDetailProvider(templateId));

    return Scaffold(
      backgroundColor: bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        actions: [
          if (async.valueOrNull case final t?)
            if (t.authorId == ref.watch(profileDataProvider).profile?['id'])
              _ownerMenu(context, ref, t)
            else
              // Mẫu công khai là nội dung người dùng tạo: Play bắt buộc có
              // cách báo cáo ngay tại chỗ.
              IconButton(
                tooltip: 'report.title'.tr(),
                icon: Icon(PhosphorIcons.flag(), color: ink),
                onPressed: () => ReportSheet.show(
                  context,
                  target: ReportTarget.template,
                  targetId: t.id,
                ),
              ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(
          isDark: dark,
          error: e,
          onRetry: () => ref.invalidate(templateDetailProvider(templateId)),
        ),
        data: (t) => _body(context, ref, t, dark),
      ),
      bottomNavigationBar: async.valueOrNull == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: () => UseTemplateSheet.show(
                    context,
                    async.value!,
                    isDarkMode: isDarkMode,
                  ),
                  icon: Icon(PhosphorIcons.copy(), size: 18),
                  label: Text('templates.use_this'.tr()),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, ItineraryTemplate t, bool dark) {
    final bg = dark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = dark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = dark ? GenZTokens.lineDark : GenZTokens.line;
    final ink = dark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = Theme.of(context).colorScheme.primary;
    final warning = dark ? GenZTokens.warningDark : GenZTokens.warning;
    final topInset = MediaQuery.paddingOf(context).top;
    final days = t.byDay.keys.toList()..sort();

    return Stack(
      children: [
        FadedImage(
          imageUrl: t.coverImage,
          fadeTo: bg,
          height: topInset + 260,
          glowExtent: 240,
          topFade: true,
        ),
        ListView(
          padding: EdgeInsets.fromLTRB(16, topInset + 190, 16, 24),
          children: [
            Text(
              t.title,
              style: AppFonts.heading(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: ink,
                letterSpacing: -0.5,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            if (t.ratingCount > 0) ...[
              Row(
                children: [
                  Icon(
                    PhosphorIcons.star(PhosphorIconsStyle.fill),
                    size: 16,
                    color: warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t.ratingAvg.toStringAsFixed(1),
                    style: AppFonts.mono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'templates.rating_count'.tr(namedArgs: {'n': '${t.ratingCount}'}),
                    style: AppFonts.body(fontSize: 13, color: inkSoft),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              [
                if (t.destination?.isNotEmpty ?? false) t.destination!,
                'templates.days'.tr(namedArgs: {'n': '${t.dayCount}'}),
                'templates.stops'.tr(namedArgs: {'n': '${t.stopCount}'}),
                'templates.uses'.tr(namedArgs: {'n': '${t.useCount}'}),
              ].join(' · '),
              style: AppFonts.body(fontSize: 13, color: inkSoft),
            ),
            const SizedBox(height: 4),
            Text(
              'templates.by'.tr(namedArgs: {'name': t.authorName}),
              style: AppFonts.body(fontSize: 13, color: inkSoft),
            ),
            if (t.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final tag in t.tags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: dark ? GenZTokens.fillDark : GenZTokens.fill,
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusPill,
                        ),
                        border: Border.all(color: line),
                      ),
                      child: Text(
                        'templates.tag_$tag'.tr(),
                        style: AppFonts.body(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: inkSoft,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            if (t.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 14),
              Text(
                t.description!,
                style: AppFonts.body(fontSize: 15, color: ink, height: 1.45),
              ),
            ],
            const SizedBox(height: 20),
            for (final d in days) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  'common.day_n'.tr(namedArgs: {'n': '$d'}),
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  border: Border.all(color: line),
                ),
                child: Column(
                  children: [
                    for (final (i, it) in t.byDay[d]!.indexed) ...[
                      if (i > 0) Divider(height: 1, color: line),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 52,
                              child: Text(
                                it.startTime,
                                style: AppFonts.mono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    it.placeName,
                                    style: AppFonts.heading(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: ink,
                                    ),
                                  ),
                                  if (it.placeAddress?.isNotEmpty ?? false)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        it.placeAddress!,
                                        style: AppFonts.body(
                                          fontSize: 12,
                                          color: inkSoft,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'itinerary.minutes'.tr(
                                        namedArgs: {
                                          'n': '${it.durationMinutes}',
                                        },
                                      ),
                                      style: AppFonts.body(
                                        fontSize: 12,
                                        color: inkSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            _ratingEvaluationBlock(context, ref, t, dark),
            _ratingsSection(context, ref, t.id, dark),
          ],
        ),
      ],
    );
  }

  Widget _ratingEvaluationBlock(
    BuildContext context,
    WidgetRef ref,
    ItineraryTemplate t,
    bool dark,
  ) {
    final currentUserId = ref.watch(profileDataProvider).profile?['id'];
    final isAuthor = t.authorId.isNotEmpty && t.authorId == currentUserId;
    if (isAuthor) return const SizedBox.shrink();

    final myStateAsync = ref.watch(templateMyStateProvider(t.id));
    final inkSoft = dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = dark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = dark ? GenZTokens.lineDark : GenZTokens.line;

    return myStateAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (myState) {
        if (myState.used) {
          return _RatingInputBox(
            templateId: t.id,
            isDarkMode: dark,
            initialStars: myState.myStars,
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(color: line),
          ),
          child: Row(
            children: [
              Icon(PhosphorIcons.info(), size: 18, color: inkSoft),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'templates.rate_need_used'.tr(),
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: inkSoft,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ratingsSection(
    BuildContext context,
    WidgetRef ref,
    String templateId,
    bool dark,
  ) {
    final async = ref.watch(templateRatingsProvider(templateId));
    return async.maybeWhen(
      data: (ratings) {
        if (ratings.isEmpty) return const SizedBox.shrink();
        final surface = dark ? GenZTokens.paperDark : GenZTokens.paper;
        final line = dark ? GenZTokens.lineDark : GenZTokens.line;
        final ink = dark ? GenZTokens.inkDark : GenZTokens.ink;
        final inkSoft = dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
        final warning = dark ? GenZTokens.warningDark : GenZTokens.warning;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                'templates.reviews_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(color: line),
              ),
              child: Column(
                children: [
                  for (final (i, r) in ratings.indexed) ...[
                    if (i > 0) Divider(height: 1, color: line),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    dark ? GenZTokens.fillDark : GenZTokens.fill,
                                backgroundImage: r.user.avatarUrl != null &&
                                        r.user.avatarUrl!.isNotEmpty
                                    ? CachedNetworkImageProvider(r.user.avatarUrl!)
                                    : null,
                                child: r.user.avatarUrl == null ||
                                        r.user.avatarUrl!.isEmpty
                                    ? Icon(
                                        PhosphorIcons.user(),
                                        size: 14,
                                        color: inkSoft,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r.user.name,
                                  style: AppFonts.heading(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ink,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  for (int s = 1; s <= 5; s++)
                                    Icon(
                                      s <= r.stars
                                          ? PhosphorIcons.star(
                                              PhosphorIconsStyle.fill,
                                            )
                                          : PhosphorIcons.star(),
                                      size: 13,
                                      color: s <= r.stars ? warning : inkSoft,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (r.comment != null && r.comment!.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              r.comment!,
                              style: AppFonts.body(fontSize: 13, color: ink),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _ownerMenu(BuildContext context, WidgetRef ref, ItineraryTemplate t) {
    final repo = ref.read(itineraryTemplatesRepositoryProvider);
    Future<void> run(Future<void> Function() op, String ok) async {
      try {
        await op();
        ref.invalidate(templateDetailProvider(t.id));
        ref.invalidate(myTemplatesProvider);
        ref.invalidate(publicTemplatesProvider);
        showGlobalSnack(ok.tr());
      } catch (e) {
        showGlobalSnack(
          e is ApiException ? e.message : 'errors.unknown_error'.tr(),
          isError: true,
        );
      }
    }

    return PopupMenuButton<String>(
      icon: Icon(PhosphorIcons.dotsThreeVertical()),
      onSelected: (v) async {
        switch (v) {
          case 'visibility':
            await run(
              () => repo.setPublic(t.id, !t.isPublic),
              t.isPublic ? 'templates.now_private' : 'templates.now_public',
            );
          case 'delete':
            await run(() => repo.remove(t.id), 'templates.deleted');
            if (context.mounted) Navigator.pop(context);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'visibility',
          child: Text(
            t.isPublic
                ? 'templates.make_private'.tr()
                : 'templates.make_public'.tr(),
          ),
        ),
        PopupMenuItem(value: 'delete', child: Text('templates.delete'.tr())),
      ],
    );
  }
}

class _RatingInputBox extends ConsumerStatefulWidget {
  const _RatingInputBox({
    required this.templateId,
    required this.isDarkMode,
    this.initialStars,
  });

  final String templateId;
  final bool isDarkMode;
  final int? initialStars;

  @override
  ConsumerState<_RatingInputBox> createState() => _RatingInputBoxState();
}

class _RatingInputBoxState extends ConsumerState<_RatingInputBox> {
  late int _stars = widget.initialStars ?? 0;
  final _comment = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars < 1 || _stars > 5) return;
    setState(() => _submitting = true);
    try {
      await ref.read(itineraryTemplatesRepositoryProvider).rate(
        widget.templateId,
        stars: _stars,
        comment: _comment.text,
      );
      HapticFeedback.lightImpact();
      ref.invalidate(templateDetailProvider(widget.templateId));
      ref.invalidate(templateMyStateProvider(widget.templateId));
      ref.invalidate(templateRatingsProvider(widget.templateId));
      ref.invalidate(publicTemplatesProvider);
      showGlobalSnack('templates.rate_success'.tr());
    } catch (e) {
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDarkMode;
    final surface = dark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = dark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = dark ? GenZTokens.fillDark : GenZTokens.fill;
    final ink = dark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final warning = dark ? GenZTokens.warningDark : GenZTokens.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'templates.rate_title'.tr(),
            style: AppFonts.heading(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: _submitting ? null : () => setState(() => _stars = i),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      i <= _stars
                          ? PhosphorIcons.star(PhosphorIconsStyle.fill)
                          : PhosphorIcons.star(),
                      size: 30,
                      color: i <= _stars ? warning : inkSoft,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comment,
            maxLength: 500,
            maxLines: 2,
            style: AppFonts.body(fontSize: 14, color: ink),
            decoration: InputDecoration(
              hintText: 'templates.rate_comment_hint'.tr(),
              hintStyle: AppFonts.body(fontSize: 14, color: inkSoft),
              filled: true,
              fillColor: fill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                borderSide: BorderSide(color: line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                borderSide: BorderSide(color: line),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: (_stars > 0 && !_submitting) ? _submit : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'templates.rate_submit'.tr(),
                      style: AppFonts.heading(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
