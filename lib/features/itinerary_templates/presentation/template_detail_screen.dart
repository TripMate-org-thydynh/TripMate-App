import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/faded_image.dart';
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
              _ownerMenu(context, ref, t),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(
          isDark: dark,
          error: e,
          onRetry: () => ref.invalidate(templateDetailProvider(templateId)),
        ),
        data: (t) => _body(context, t, dark),
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

  Widget _body(BuildContext context, ItineraryTemplate t, bool dark) {
    final bg = dark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = dark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = dark ? GenZTokens.lineDark : GenZTokens.line;
    final ink = dark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = Theme.of(context).colorScheme.primary;
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
          ],
        ),
      ],
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
