import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/itinerary_templates_repository.dart';
import '../domain/itinerary_template.dart';
import 'template_detail_screen.dart';

/// Khám phá lịch trình mẫu của cộng đồng + các mẫu mình đã đăng.
class TemplateExploreScreen extends ConsumerStatefulWidget {
  const TemplateExploreScreen({super.key, this.isDarkMode = false});
  final bool isDarkMode;

  @override
  ConsumerState<TemplateExploreScreen> createState() =>
      _TemplateExploreScreenState();
}

class _TemplateExploreScreenState extends ConsumerState<TemplateExploreScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _selectedTag;
  String _sort = 'popular';

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool get _dark =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _fill => _dark ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => _dark ? GenZTokens.lineDark : GenZTokens.line;
  Color get _ink => _dark ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft => _dark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: _ink),
          title: Text(
            'templates.title'.tr(),
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          bottom: TabBar(
            labelColor: _ink,
            unselectedLabelColor: _inkSoft,
            indicatorColor: accent,
            dividerColor: _line,
            labelStyle: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'templates.tab_explore'.tr()),
              Tab(text: 'templates.tab_mine'.tr()),
            ],
          ),
        ),
        body: TabBarView(children: [_explore(), _mine()]),
      ),
    );
  }

  Widget _explore() {
    final async = ref.watch(
      publicTemplatesProvider((query: _query, tag: _selectedTag, sort: _sort)),
    );
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(publicTemplatesProvider);
        ref.invalidate(featuredTemplatesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _search,
              style: AppFonts.body(fontSize: 15, color: _ink),
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 350),
                  () => setState(() => _query = v),
                );
              },
              decoration: InputDecoration(
                hintText: 'templates.search_hint'.tr(),
                hintStyle: AppFonts.body(fontSize: 15, color: _inkSoft),
                prefixIcon: Icon(
                  PhosphorIcons.magnifyingGlass(),
                  color: _inkSoft,
                ),
                filled: true,
                fillColor: _fill,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                  borderSide: BorderSide(color: _line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                  borderSide: BorderSide(color: _line),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _tagChips(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _sortChip('popular', 'templates.sort_popular'.tr()),
                  const SizedBox(width: 8),
                  _sortChip('new', 'templates.sort_new'.tr()),
                  const SizedBox(width: 8),
                  _sortChip('top', 'templates.sort_top'.tr()),
                ],
              ),
            ),
          ),
          _featuredSection(),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => AppErrorState(
              isDark: _dark,
              error: e,
              onRetry: () => ref.invalidate(publicTemplatesProvider),
            ),
            data: (list) => list.isEmpty
                ? AppEmptyState(
                    isDark: _dark,
                    icon: PhosphorIcons.mapTrifold(),
                    title: 'templates.empty_title'.tr(),
                    body: 'templates.empty_body'.tr(),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (int i = 0; i < list.length; i++) ...[
                          if (i > 0) const SizedBox(height: 14),
                          TemplateCard(
                            template: list[i],
                            isDark: _dark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TemplateDetailScreen(
                                  templateId: list[i].id,
                                  isDarkMode: widget.isDarkMode,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _featuredSection() {
    if (_query.isNotEmpty || _selectedTag != null) {
      return const SizedBox.shrink();
    }
    final async = ref.watch(featuredTemplatesProvider);
    return async.maybeWhen(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                    size: 16,
                    color: _dark ? GenZTokens.warningDark : GenZTokens.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'templates.featured'.tr(),
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 154,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _FeaturedCard(
                  template: list[i],
                  isDark: _dark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TemplateDetailScreen(
                        templateId: list[i].id,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _tagChips() {
    final accent = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: TemplateTags.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tag = TemplateTags.all[i];
          final selected = _selectedTag == tag;
          return FilterChip(
            label: Text('templates.tag_$tag'.tr()),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                if (_selectedTag == tag) {
                  _selectedTag = null;
                } else {
                  _selectedTag = tag;
                }
              });
            },
            labelStyle: AppFonts.body(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : _inkSoft,
            ),
            selectedColor: accent,
            backgroundColor: _fill,
            side: BorderSide(color: selected ? accent : _line),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  Widget _mine() {
    final async = ref.watch(myTemplatesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppErrorState(
        isDark: _dark,
        error: e,
        onRetry: () => ref.invalidate(myTemplatesProvider),
      ),
      data: (list) => list.isEmpty
          ? AppEmptyState(
              isDark: _dark,
              icon: PhosphorIcons.shareNetwork(),
              title: 'templates.mine_empty_title'.tr(),
              body: 'templates.mine_empty_body'.tr(),
            )
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(myTemplatesProvider),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (_, i) => TemplateCard(
                  template: list[i],
                  isDark: _dark,
                  showVisibility: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TemplateDetailScreen(
                        templateId: list[i].id,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _sortChip(String value, String label) {
    final on = _sort == value;
    final accent = Theme.of(context).colorScheme.primary;
    return ChoiceChip(
      label: Text(label),
      selected: on,
      showCheckmark: false,
      onSelected: (_) => setState(() => _sort = value),
      labelStyle: AppFonts.body(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: on ? Theme.of(context).colorScheme.onPrimary : _ink,
      ),
      selectedColor: accent,
      backgroundColor: _fill,
      side: BorderSide(color: on ? accent : _line),
      shape: const StadiumBorder(),
    );
  }
}

/// Thẻ nhỏ hiển thị mẫu nổi bật ở hàng cuộn ngang.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.template,
    required this.isDark,
    required this.onTap,
  });

  final ItineraryTemplate template;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final warning = isDark ? GenZTokens.warningDark : GenZTokens.warning;
    final t = template;
    final cover = t.coverImage;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(color: line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 86,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover != null && cover.startsWith('http'))
                      CachedNetworkImage(
                        imageUrl: cover,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => ColoredBox(color: fill),
                      )
                    else if (cover != null && cover.startsWith('assets/'))
                      Image.asset(cover, fit: BoxFit.cover)
                    else
                      ColoredBox(
                        color: fill,
                        child: Icon(
                          PhosphorIcons.mapTrifold(),
                          size: 28,
                          color: inkSoft,
                        ),
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.5, 1],
                          colors: [surface.withValues(alpha: 0), surface],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (t.ratingCount > 0)
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.star(PhosphorIconsStyle.fill),
                            size: 12,
                            color: warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.ratingAvg.toStringAsFixed(1),
                            style: AppFonts.mono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ink,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'templates.days'.tr(namedArgs: {'n': '${t.dayCount}'}),
                        style: AppFonts.body(fontSize: 11, color: inkSoft),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ một lịch trình mẫu: ảnh bìa tan xuống nền thẻ + tiêu đề + số liệu.
class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.template,
    required this.isDark,
    required this.onTap,
    this.showVisibility = false,
  });

  final ItineraryTemplate template;
  final bool isDark;
  final VoidCallback onTap;
  final bool showVisibility;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final warning = isDark ? GenZTokens.warningDark : GenZTokens.warning;
    final t = template;
    final cover = t.coverImage;

    Widget stat(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: inkSoft),
        const SizedBox(width: 4),
        Text(text, style: AppFonts.body(fontSize: 12, color: inkSoft)),
      ],
    );

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(color: line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 132,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover != null && cover.startsWith('http'))
                      CachedNetworkImage(
                        imageUrl: cover,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => ColoredBox(color: fill),
                      )
                    else if (cover != null && cover.startsWith('assets/'))
                      Image.asset(cover, fit: BoxFit.cover)
                    else
                      ColoredBox(
                        color: fill,
                        child: Icon(
                          PhosphorIcons.mapTrifold(),
                          size: 40,
                          color: inkSoft,
                        ),
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.5, 1],
                          colors: [surface.withValues(alpha: 0), surface],
                        ),
                      ),
                    ),
                    if (t.isFeatured)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusPill,
                            ),
                            border: Border.all(color: line),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                                size: 12,
                                color: warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'templates.featured_badge'.tr(),
                                style: AppFonts.body(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (showVisibility)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusPill,
                            ),
                            border: Border.all(color: line),
                          ),
                          child: stat(
                            t.isPublic
                                ? PhosphorIcons.globe()
                                : PhosphorIcons.lock(),
                            t.isPublic
                                ? 'templates.public'.tr()
                                : 'templates.private'.tr(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    if (t.destination?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      stat(PhosphorIcons.mapPin(), t.destination!),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        if (t.ratingCount > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIcons.star(PhosphorIconsStyle.fill),
                                size: 14,
                                color: warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${t.ratingAvg.toStringAsFixed(1)} (${t.ratingCount})',
                                style: AppFonts.mono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: ink,
                                ),
                              ),
                            ],
                          ),
                        stat(
                          PhosphorIcons.calendarBlank(),
                          'templates.days'.tr(
                            namedArgs: {'n': '${t.dayCount}'},
                          ),
                        ),
                        stat(
                          PhosphorIcons.mapPinLine(),
                          'templates.stops'.tr(
                            namedArgs: {'n': '${t.stopCount}'},
                          ),
                        ),
                        stat(
                          PhosphorIcons.copy(),
                          'templates.uses'.tr(
                            namedArgs: {'n': '${t.useCount}'},
                          ),
                        ),
                        stat(PhosphorIcons.user(), t.authorName),
                      ],
                    ),
                    if (t.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final tag in t.tags.take(3))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: fill,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
