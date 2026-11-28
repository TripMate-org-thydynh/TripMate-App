import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/trip_cover_image.dart';
import '../../../itinerary_templates/presentation/template_explore_screen.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/media_uploader.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../moments/data/moments_repository.dart';
import '../../data/home_feed_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/gen_z_widgets.dart';
import '../../../../core/services/weather_service.dart';
import '../../../social/data/notifications_repository.dart';
import '../../../social/presentation/pages/notifications_screen.dart';

import '../widgets/weather_forecast_sheet.dart';
import '../widgets/home_search_section.dart';
import '../widgets/upcoming_reservations_widget.dart';
import '../widgets/friend_presence_panel.dart';
import '../widgets/daily_recap_widget.dart';
import '../widgets/today_brief_card.dart';
import '../widgets/quick_actions_panel.dart';
import '../../../moments/presentation/pages/memory_wall_screen.dart';
import '../../../trips/application/trips_providers.dart';
import '../../../trips/domain/trip.dart';
import '../../../trips/presentation/create_trip_sheet.dart';
import '../../../premium/presentation/trial_banner.dart';

/// Chuyến nổi bật ở home: đang đi → chuyến đó; không thì chuyến sắp đi gần
/// nhất; không có cả hai thì chuyến đầu danh sách. `null` khi chưa có chuyến.
Trip? featuredTrip(List<Trip> trips) {
  if (trips.isEmpty) return null;
  final now = DateTime.now();
  for (final t in trips) {
    if (!t.startDate.isAfter(now) && !t.endDate.isBefore(now)) return t;
  }
  final upcoming = trips.where((t) => t.startDate.isAfter(now)).toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  return upcoming.isNotEmpty ? upcoming.first : trips.first;
}

class HomeDashboardPage extends ConsumerStatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeDashboardPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ConsumerState<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends ConsumerState<HomeDashboardPage> {
  bool get isDarkMode => widget.isDarkMode;
  VoidCallback get onThemeToggle => widget.onThemeToggle;

  WeatherData? _weatherData;
  bool _isLoadingWeather = true;
  bool _requestedWeather = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadWeatherOnScroll);
  }

  void _loadWeatherOnScroll() {
    if (_requestedWeather || !_scroll.hasClients || _scroll.offset < 180) {
      return;
    }
    _requestedWeather = true;
    _fetchWeather();
  }

  (double, double) _coordsForTrip(Trip? trip) {
    final text = '${trip?.destination ?? ''} ${trip?.name ?? ''}'.toLowerCase();
    if (text.contains('hà nội') ||
        text.contains('ha noi') ||
        text.contains('hanoi')) {
      return (21.0285, 105.8542);
    }
    if (text.contains('đà nẵng') ||
        text.contains('da nang') ||
        text.contains('danang')) {
      return (16.0470, 108.2060);
    }
    if (text.contains('sài gòn') ||
        text.contains('sai gon') ||
        text.contains('hồ chí minh') ||
        text.contains('ho chi minh') ||
        text.contains('hcm') ||
        text.contains('tp.hcm')) {
      return (10.7769, 106.7009);
    }
    if (text.contains('phú quốc') || text.contains('phu quoc')) {
      return (10.2899, 103.9840);
    }
    if (text.contains('nha trang')) {
      return (12.2388, 109.1967);
    }
    if (text.contains('đà lạt') ||
        text.contains('da lat') ||
        text.contains('dalat')) {
      return (11.9406, 108.4452);
    }
    if (text.contains('sa pa') || text.contains('sapa')) {
      return (22.3364, 103.8438);
    }
    if (text.contains('hạ long') ||
        text.contains('ha long') ||
        text.contains('halong')) {
      return (20.9599, 107.0425);
    }
    if (text.contains('ninh bình') || text.contains('ninh binh')) {
      return (20.2506, 105.9745);
    }
    if (text.contains('hội an') || text.contains('hoi an')) {
      return (15.8801, 108.3380);
    }
    if (text.contains('huế') || text.contains('hue')) {
      return (16.4637, 107.5909);
    }
    if (text.contains('vũng tàu') || text.contains('vung tau')) {
      return (10.3460, 107.0843);
    }
    if (text.contains('quy nhơn') || text.contains('quy nhon')) {
      return (13.7830, 109.2197);
    }
    if (text.contains('cần thơ') || text.contains('can tho')) {
      return (10.0452, 105.7469);
    }
    if (text.contains('bangkok')) {
      return (13.7563, 100.5018);
    }
    if (text.contains('tokyo')) {
      return (35.6762, 139.6503);
    }
    if (text.contains('seoul')) {
      return (37.5665, 126.9780);
    }
    if (text.contains('singapore')) {
      return (1.3521, 103.8198);
    }
    return (11.9406, 108.4452);
  }

  Future<void> _fetchWeather() async {
    try {
      final tripsAsync = ref.read(tripsProvider);
      Trip? activeTrip;

      tripsAsync.whenData((trips) {
        if (trips.isNotEmpty) {
          activeTrip = featuredTrip(trips);
        }
      });

      final (lat, lng) = _coordsForTrip(activeTrip);

      final weather = await ref
          .read(weatherServiceProvider)
          .fetchWeather(lat, lng);
      if (mounted) {
        setState(() {
          _weatherData = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  /// Nhãn đếm ngược: chưa đi → "còn N ngày nữa đi"; đang đi → số ngày còn lại.
  void _openTrip(Trip trip) =>
      context.push('/dashboard/trip/${trip.id}', extra: trip);

  /// Ô tìm kiếm + chip, rồi dải "Chuyến đi của bạn" (khi có chuyến).
  Widget _buildSearchAndTrips() {
    final trips = ref
        .watch(tripsProvider)
        .maybeWhen(data: (t) => t, orElse: () => const <Trip>[]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSearchSection(
          trips: trips,
          isDarkMode: isDarkMode,
          onOpenTrip: _openTrip,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _paper => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _accent => isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _accentSoft =>
      isDarkMode ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color get _success =>
      isDarkMode ? GenZTokens.successDark : GenZTokens.success;
  Color get _warning =>
      isDarkMode ? GenZTokens.warningDark : GenZTokens.warning;
  Color get _danger => isDarkMode ? GenZTokens.dangerDark : GenZTokens.danger;
  Color get _bg => isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;

  // ─── Build ───────────────────────────────────────────────────────────────────

  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: _buildScroll(context),
    );
  }

  Widget _buildScroll(BuildContext context) {
    return CustomScrollView(
      controller: _scroll,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHero(context)),

        const SliverToBoxAdapter(child: TrialBanner()),

        // ── BẢN TIN HÔM NAY ──
        Consumer(
          builder: (context, ref, _) {
            final tripId = ref
                .watch(tripsProvider)
                .maybeWhen(
                  data: (trips) => featuredTrip(trips)?.id,
                  orElse: () => null,
                );
            if (tripId == null) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TodayBriefCard(tripId: tripId, isDarkMode: isDarkMode),
              ),
            );
          },
        ),

        // ── 3. QUICK ACTIONS 2×2 ──
        SliverToBoxAdapter(
          child: Column(
            children: [
              PopIn(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: QuickActionsPanel(
                    isDarkMode: isDarkMode,
                    onThemeToggle: onThemeToggle,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── 4. SQUAD FRIEND PRESENCE ──
        SliverToBoxAdapter(
          child: Column(
            children: [
              PopIn(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FriendPresencePanel(
                    isDarkMode: isDarkMode,
                    onThemeToggle: onThemeToggle,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── 5. WEATHER & UP NEXT GRID ──
        SliverToBoxAdapter(
          child: Column(
            children: [
              PopIn(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildWeatherAndUpNextGrid(context),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── 6. VÉ SẮP TỚI (feed liên chuyến) ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: UpcomingReservationsWidget(isDarkMode: isDarkMode),
          ),
        ),

        // ── 7. DAILY RECAP ──
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const DailyRecapWidget(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── 9. THE ROAST PANEL (Below fold) ──
        SliverToBoxAdapter(
          child: Column(
            children: [
              PopIn(
                index: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildRoastPanel(context),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── 10. SCRAPBOOK SECTION ──
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildScrapbookSection(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  // ─── WEATHER & UP NEXT ────────────────────────────────────────────────────

  Widget _buildWeatherAndUpNextGrid(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Weather Card (chạm để xem dự báo 16 ngày) ──
        Expanded(
          child: GestureDetector(
            onTap: _weatherData == null
                ? null
                : () => WeatherForecastSheet.show(
                    context,
                    _weatherData!,
                    isDarkMode,
                  ),
            child: HardShadowBox(
              color: _paper,
              padding: const EdgeInsets.all(16),
              borderWidth: GenZTokens.borderWidthThin,
              showShadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'dashboard.weather'.tr(),
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      Icon(
                        _weatherData?.icon ?? PhosphorIcons.sun(),
                        color: _weatherData?.color ?? _warning,
                        size: 26,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(PhosphorIcons.brain(), color: _inkSoft, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _isLoadingWeather
                              ? 'dashboard.weather_checking'.tr()
                              : (_weatherData?.details.isNotEmpty == true
                                    ? _weatherData!.details
                                    : 'weather.unavailable'.tr()),
                          style: AppFonts.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Chỉ hiện số liệu khi THẬT SỰ có dữ liệu. Trước đây gọi API
                  // thất bại vẫn hiện "22°C · mây rải rác" từ fallback cứng.
                  if (_isLoadingWeather) ...[
                    PillTag(
                      text: '-- °C',
                      icon: PhosphorIconsRegular.thermometer,
                      color: _fill,
                    ),
                    const SizedBox(height: 6),
                    PillTag(
                      text: 'dashboard.loading'.tr(),
                      icon: PhosphorIcons.cloud(),
                      color: _fill,
                    ),
                  ] else if (_weatherData != null) ...[
                    PillTag(
                      text: '${_weatherData!.temp.toStringAsFixed(0)}°C',
                      icon: PhosphorIcons.thermometer(),
                      color: _fill,
                    ),
                    const SizedBox(height: 6),
                    PillTag(
                      text: _weatherData!.description,
                      icon: _weatherData!.icon,
                      color: _fill,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ── Up Next Card ──
        // Đọc điểm lịch trình kế tiếp THẬT (/users/me/up-next). Trước đây thẻ
        // này hiện cứng "Night Market Chaos · Uber XL arriving soon · Nam not
        // ready" cho cả tài khoản chưa có chuyến nào.
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final async = ref.watch(upNextProvider);
              return HardShadowBox(
                color: _paper,
                padding: const EdgeInsets.all(16),
                borderWidth: GenZTokens.borderWidthThin,
                showShadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'dashboard.up_next'.tr(),
                            style: AppFonts.mono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: _inkSoft,
                            ),
                          ),
                        ),
                        async.maybeWhen(
                          data: (item) => item == null
                              ? const SizedBox.shrink()
                              : PillTag(
                                  text: 'dashboard.up_next_day'.tr(
                                    namedArgs: {'day': '${item.day}'},
                                  ),
                                  selected: true,
                                ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    async.when(
                      loading: () => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _inkSoft,
                            ),
                          ),
                        ),
                      ),
                      error: (_, _) => Text(
                        'errors.load_failed'.tr(),
                        style: AppFonts.body(fontSize: 12, color: _inkSoft),
                      ),
                      data: (item) => item == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dashboard.up_next_empty_title'.tr(),
                                  style: AppFonts.heading(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'dashboard.up_next_empty_body'.tr(),
                                  style: AppFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _inkSoft,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.placeName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.heading(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _bg,
                                    borderRadius: BorderRadius.circular(
                                      GenZTokens.radiusInput,
                                    ),
                                    border: Border.all(
                                      color: _line,
                                      width: GenZTokens.borderWidthThin,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        PhosphorIcons.clock(),
                                        color: _ink,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          item.startTime,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFonts.body(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _inkSoft,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.tripName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.mono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _inkSoft,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final snapshot = trips.hasValue
        ? const <Trip>[]
        : ref.watch(homeTripsSnapshotProvider).valueOrNull;
    final trip = featuredTrip(trips.valueOrNull ?? snapshot ?? const []);
    void openTemplates() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TemplateExploreScreen(isDarkMode: isDarkMode),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: MediaQuery.paddingOf(context).top),
        _buildHeader(context),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (trip != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  child: AspectRatio(
                    aspectRatio: 1.68,
                    child: TripCoverImage(
                      source: trip.coverImage,
                      fallbackColor: _accent,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  trip.name,
                  style: AppFonts.heading(
                    fontSize: 30,
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (trip.destination?.isNotEmpty == true)
                  Text(
                    trip.destination!,
                    style: AppFonts.body(fontSize: 15, color: _inkSoft),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => trips.hasValue
                      ? _openTrip(trip)
                      : context.push('/dashboard/trip/${trip.id}'),
                  icon: Icon(PhosphorIcons.arrowRight()),
                  label: Text('beta.openTrip'.tr()),
                ),
              ] else ...[
                Text(
                  'beta.welcome'.tr(),
                  style: AppFonts.heading(
                    fontSize: 31,
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'beta.welcomeBody'.tr(),
                  style: AppFonts.body(fontSize: 16, color: _inkSoft),
                ),
                const SizedBox(height: 18),
                if (trips.isLoading) const LinearProgressIndicator(),
                if (trips.hasError)
                  TextButton.icon(
                    onPressed: () => ref.read(tripsProvider.notifier).refresh(),
                    icon: Icon(PhosphorIcons.arrowClockwise()),
                    label: Text('beta.retryTrips'.tr()),
                  ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (trip == null)
                    FilledButton.tonalIcon(
                      onPressed: openTemplates,
                      icon: Icon(PhosphorIcons.mapTrifold()),
                      label: Text('beta.useTemplate'.tr()),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: openTemplates,
                      icon: Icon(PhosphorIcons.mapTrifold()),
                      label: Text('beta.useTemplate'.tr()),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => CreateTripSheet.show(context, isDarkMode),
                    icon: Icon(PhosphorIcons.plus()),
                    label: Text('trips.create'.tr()),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => CreateTripSheet.show(
                      context,
                      isDarkMode,
                      startWithInvite: true,
                    ),
                    icon: Icon(PhosphorIcons.link()),
                    label: Text('beta.enterInvite'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildSearchAndTrips(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand name — title spec (22, w700, -0.2)
          Expanded(
            child: Text(
              'trip.mate',
              style:
                  AppFonts.heading(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: _ink,
                  ).copyWith(
                    // Logo nằm trên ảnh bìa: bóng mảnh cùng tông nền để luôn đọc được.
                    shadows: [
                      Shadow(color: _bg.withValues(alpha: 0.6), blurRadius: 12),
                    ],
                  ),
            ),
          ),

          // Language toggle button — nen fill, vien 1px line, icon inkSoft
          GestureDetector(
            onTap: () {
              final newLocale = context.locale.languageCode == 'vi'
                  ? const Locale('en')
                  : const Locale('vi');
              context.setLocale(newLocale);
            },
            child: _InkCircleButton(
              isDarkMode: isDarkMode,
              color: _fill,
              child: Center(
                child: Text(
                  context.locale.languageCode.toUpperCase(),
                  style: AppFonts.heading(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _inkSoft,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Notification bell — badge so chua doc that.
          Consumer(
            builder: (context, ref, _) {
              final unread = ref.watch(unreadCountProvider);
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(isDarkMode: isDarkMode),
                  ),
                ),
                child: _InkCircleButton(
                  isDarkMode: isDarkMode,
                  color: _fill,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(PhosphorIcons.bell(), size: 20, color: _inkSoft),
                      if (unread > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: BoxDecoration(
                              color: _danger,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: _paper, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                style: AppFonts.mono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _paper,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Cụm avatar squad trên header.
  ///
  /// Trước đây là 3 ảnh stock hardcode + nhãn "+2" cố định, hiện cả với tài
  /// khoản chưa có chuyến nào. Nay lấy thành viên thật của chuyến gần nhất;
  /// chưa có chuyến thì ẩn hẳn.
  Widget _buildRoastPanel(BuildContext context) {
    // Đọc tổng hợp chi tiêu THẬT. Trước đây khối này hiện cứng
    // "TỔNG: 500K", câu roast bịa tên người và thanh tiến độ 80% — kể cả với
    // tài khoản chưa ghi khoản chi nào. Không có dữ liệu thì ẩn hẳn khối.
    return Consumer(
      builder: (context, ref, _) {
        final async = ref.watch(expenseSummaryProvider);
        return async.maybeWhen(
          data: (sum) {
            if (!sum.hasData) return const SizedBox.shrink();
            return StickerCard(
              color: _paper,
              headerText: 'dashboard.the_roast'.tr(),
              headerColor: _accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.flame(PhosphorIconsStyle.fill),
                        color: _danger,
                        size: 22,
                      ),
                      const Spacer(),
                      Flexible(
                        child: PillTag(
                          text: 'dashboard.total_expense'.tr(
                            namedArgs: {'amount': _fmtMoney(sum.totalAmount)},
                          ),
                          color: _accentSoft,
                        ),
                      ),
                    ],
                  ),
                  if (sum.topDebtorName != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? GenZTokens.creamDark
                            : GenZTokens.cream,
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusInput,
                        ),
                        border: Border.all(
                          color: _line,
                          width: GenZTokens.borderWidthThin,
                        ),
                      ),
                      child: Text(
                        'dashboard.roast_owes'.tr(
                          namedArgs: {
                            'name': sum.topDebtorName!,
                            'amount': _fmtMoney(sum.topDebtorAmount),
                          },
                        ),
                        style: AppFonts.body(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _ink,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'dashboard.group_progress'.tr(),
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _inkSoft,
                          ),
                        ),
                      ),
                      Text(
                        'dashboard.paid_label'.tr(
                          namedArgs: {'percent': '${sum.paidPercent}'},
                        ),
                        style: AppFonts.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedProgress(
                    total: sum.totalCount,
                    completed: sum.paidCount,
                    fillColor: _success,
                  ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  /// Rút gọn tiền cho nhãn chật: 3.000.000 → "3tr", 500000 → "500k".
  String _fmtMoney(double v) {
    if (v >= 1000000) {
      final m = v / 1000000;
      return '${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}${'dashboard.currency_tr'.tr()}';
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  // ─── SCRAPBOOK SECTION ───────────────────────────────────────────────────────

  Widget _buildScrapbookSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Row(
          children: [
            Text(
              'dashboard.scrapbook'.tr(),
              style: AppFonts.heading(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(PhosphorIcons.camera(), size: 20, color: _ink),
          ],
        ),
        const SizedBox(height: 16),

        // Scrapbook lấy kỷ niệm THẬT mới nhất trên mọi chuyến của user.
        // Trước đây khối này là 2 tấm polaroid cứng (ảnh Unsplash + tên bịa)
        // hiển thị y hệt nhau cho mọi tài khoản.
        Consumer(
          builder: (context, ref, _) {
            final async = ref.watch(recentMomentsProvider);
            return async.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) =>
                  _scrapbookPlaceholder('dashboard.scrapbook_error'.tr()),
              data: (moments) {
                if (moments.isEmpty) {
                  return _scrapbookPlaceholder(
                    'dashboard.scrapbook_empty'.tr(),
                  );
                }
                final shown = moments.take(2).toList();
                return Row(
                  children: [
                    for (var i = 0; i < shown.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(
                        child: Transform.rotate(
                          angle: i.isEven ? -0.06 : 0.05,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MemoryWallScreen(isDarkMode: isDarkMode),
                              ),
                            ),
                            child: _buildPolaroidCard(
                              context: context,
                              title: shown[i].title,
                              author: '- ${shown[i].authorName} -',
                              location: shown[i].location,
                              fallbackColor: _fill,
                              // Polaroid nhỏ trong scrapbook.
                              imageUrl: optimizedMedia(
                                shown[i].mediaUrl,
                                width: 320,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Chỉ có 1 kỷ niệm → chừa chỗ để tấm polaroid không bị kéo giãn.
                    if (shown.length == 1) ...[
                      const SizedBox(width: 16),
                      const Spacer(),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// Khung thay thế khi chưa có kỷ niệm nào hoặc tải lỗi.
  Widget _scrapbookPlaceholder(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.camera(),
            size: 28,
            color: _ink.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFonts.body(
              fontSize: 13,
              color: _ink.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidCard({
    required BuildContext context,
    required String title,
    required String author,
    required String location,
    required Color fallbackColor,
    required String imageUrl,
  }) {
    return HardShadowBox(
      color: _paper,
      radius: 10,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              // Giải mã đúng cỡ hiển thị, không giữ ảnh gốc 4000px trong RAM.
              memCacheWidth: 1080,
              imageUrl: imageUrl,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 130,
                color: fallbackColor,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(GenZTokens.ink),
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 130,
                color: fallbackColor,
                child: Center(
                  child: Icon(
                    PhosphorIcons.image(),
                    color: GenZTokens.ink,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppFonts.body(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(author, style: AppFonts.body(fontSize: 14, color: _inkSoft)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                size: 12,
                color: _danger,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  location.toUpperCase(),
                  style: AppFonts.mono(
                    fontSize: 12,
                    color: _inkSoft,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── HELPER WIDGETS ──────────────────────────────────────────────────────────

/// Nút tròn: nền fill, viền 1px line, không bóng đặc (spec mục 4).
class _InkCircleButton extends StatelessWidget {
  final bool isDarkMode;
  final Widget child;
  final Color? color;

  const _InkCircleButton({
    required this.isDarkMode,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? fill,
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: Center(child: child),
    );
  }
}
