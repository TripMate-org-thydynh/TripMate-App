import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/services/weather_service.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/trip_illustration.dart';
import '../../itinerary_templates/data/itinerary_templates_repository.dart';
import '../../itinerary_templates/presentation/template_detail_screen.dart';
import '../../trips/presentation/create_trip_sheet.dart';
import '../data/destinations_catalog.dart';

/// Trang giới thiệu một điểm đến: ảnh bìa, mô tả, mùa nên đi, thời tiết
/// hiện tại, lịch trình mẫu (nếu kho mẫu có) và đúng một CTA màu nhấn
/// "Lên chuyến đi <điểm>" mở form tạo chuyến đã điền sẵn điểm đến.
class DestinationScreen extends ConsumerWidget {
  const DestinationScreen({
    super.key,
    required this.destination,
    required this.isDarkMode,
  });

  final Destination destination;
  final bool isDarkMode;

  static Future<void> open(
    BuildContext context,
    Destination destination,
    bool isDarkMode,
  ) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) =>
            DestinationScreen(destination: destination, isDarkMode: isDarkMode),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = isDarkMode;
    final bg = d ? GenZTokens.creamDark : GenZTokens.cream;
    final paper = d ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = d ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = d ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = d ? GenZTokens.lineDark : GenZTokens.line;
    final accent = d ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = d ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    final weather = ref.watch(weatherFutureProvider(destination.coords));
    final templates = ref.watch(
      publicTemplatesProvider((
        query: destination.name,
        tag: null,
        sort: 'popular',
        days: null,
        budgetTo: null,
      )),
    );

    Widget card({required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line),
      ),
      child: child,
    );

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppFonts.heading(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: bg,
            foregroundColor: ink,
            elevation: 0,
            leadingWidth: 64,
            // Vòng tròn có nền để mũi tên không chìm vào ảnh bìa (≥44pt).
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: Material(
                  color: paper.withValues(alpha: 0.9),
                  shape: CircleBorder(side: BorderSide(color: line)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Tooltip(
                      message: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          PhosphorIcons.arrowLeft(),
                          color: ink,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: destination.coverAsset != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(destination.coverAsset!, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.5, 1],
                              colors: [bg.withValues(alpha: 0), bg],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.fromLTRB(24, 72, 24, 12),
                      child: ExcludeSemantics(
                        child: TripIllustrationView(TripIllustration.road),
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            sliver: SliverList.list(
              children: [
                Text(
                  destination.name,
                  style: AppFonts.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: ink,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  destination.blurb,
                  style: AppFonts.body(
                    fontSize: 15,
                    height: 1.45,
                    color: inkSoft,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              PhosphorIcons.calendarBlank(),
                              color: inkSoft,
                              size: 20,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'destinations.best_season'.tr(),
                              style: AppFonts.body(
                                fontSize: 12,
                                color: inkSoft,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              destination.season,
                              style: AppFonts.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              weather.valueOrNull?.icon ??
                                  PhosphorIcons.cloud(),
                              color: weather.valueOrNull?.color ?? inkSoft,
                              size: 20,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'destinations.weather_now'.tr(),
                              style: AppFonts.body(
                                fontSize: 12,
                                color: inkSoft,
                              ),
                            ),
                            const SizedBox(height: 2),
                            weather.when(
                              loading: () => Text(
                                'dashboard.weather_checking'.tr(),
                                style: AppFonts.body(
                                  fontSize: 13,
                                  color: inkSoft,
                                ),
                              ),
                              error: (_, _) => Text(
                                'weather.unavailable'.tr(),
                                style: AppFonts.body(
                                  fontSize: 13,
                                  color: inkSoft,
                                ),
                              ),
                              data: (w) => w == null
                                  ? Text(
                                      'weather.unavailable'.tr(),
                                      style: AppFonts.body(
                                        fontSize: 13,
                                        color: inkSoft,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${w.temp.toStringAsFixed(0)}°C',
                                          style: AppFonts.mono(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: ink,
                                          ),
                                        ),
                                        Text(
                                          w.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFonts.body(
                                            fontSize: 13,
                                            color: inkSoft,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ...templates.maybeWhen(
                  data: (list) => list.isEmpty
                      ? const <Widget>[]
                      : [
                          const SizedBox(height: 24),
                          label('destinations.sample_itineraries'.tr()),
                          for (final t in list.take(3))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: paper,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    GenZTokens.radiusCard,
                                  ),
                                  side: BorderSide(color: line),
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      GenZTokens.radiusCard,
                                    ),
                                  ),
                                  leading: Icon(
                                    PhosphorIcons.path(),
                                    color: inkSoft,
                                  ),
                                  title: Text(
                                    t.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.body(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: ink,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'destinations.template_days'.tr(
                                      namedArgs: {'days': '${t.dayCount}'},
                                    ),
                                    style: AppFonts.body(
                                      fontSize: 13,
                                      color: inkSoft,
                                    ),
                                  ),
                                  trailing: Icon(
                                    PhosphorIcons.caretRight(),
                                    color: inkSoft,
                                    size: 18,
                                  ),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TemplateDetailScreen(
                                        templateId: t.id,
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                  orElse: () => const <Widget>[],
                ),
                // Gợi ý tĩnh: luôn có, để trang không trống khi kho mẫu chưa
                // có lịch trình cho điểm này.
                const SizedBox(height: 24),
                label('destinations.highlights'.tr()),
                card(
                  child: Column(
                    children: [
                      for (final (i, spot) in destination.highlights.indexed)
                        Padding(
                          padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                          child: Row(
                            children: [
                              Text(
                                '0${i + 1}',
                                style: AppFonts.mono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: inkSoft,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  spot,
                                  style: AppFonts.body(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ink,
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => CreateTripSheet.show(
              context,
              isDarkMode,
              initialDestination: destination.name,
            ),
            icon: Icon(PhosphorIcons.airplaneTakeoff(), size: 18),
            label: Text(
              'destinations.plan_cta'.tr(
                namedArgs: {'place': destination.name},
              ),
              style: AppFonts.heading(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: onAccent,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
