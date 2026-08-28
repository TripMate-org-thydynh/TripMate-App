import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../moments/data/moments_repository.dart';
import '../../data/home_feed_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/gen_z_widgets.dart';
import '../../../../core/services/weather_service.dart';
import '../../../social/data/notifications_repository.dart';
import '../../../social/presentation/pages/notifications_screen.dart';

import '../widgets/social_chaos_marquee.dart';
import '../widgets/weather_forecast_sheet.dart';
import '../widgets/upcoming_reservations_widget.dart';
import '../widgets/friend_presence_panel.dart';
import '../widgets/daily_recap_widget.dart';
import '../widgets/quick_actions_panel.dart';
import '../../../moments/presentation/pages/memory_wall_screen.dart';
import '../../../trips/application/trips_providers.dart';
import '../../../trips/domain/trip.dart';
import '../../../trips/domain/trip_vibe.dart';
import '../../../trips/presentation/trip_hub_screen.dart';
import '../../../trips/presentation/create_trip_sheet.dart';

class HomeDashboardPage extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToLiveMode;
  final VoidCallback onNavigateToActivityHub;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeDashboardPage({
    super.key,
    required this.onNavigateToLiveMode,
    required this.onNavigateToActivityHub,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ConsumerState<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends ConsumerState<HomeDashboardPage> {
  bool get isDarkMode => widget.isDarkMode;
  VoidCallback get onThemeToggle => widget.onThemeToggle;
  VoidCallback get onNavigateToLiveMode => widget.onNavigateToLiveMode;
  VoidCallback get onNavigateToActivityHub => widget.onNavigateToActivityHub;

  WeatherData? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeather();
    });
  }

  Future<void> _fetchWeather() async {
    try {
      final tripsAsync = ref.read(tripsProvider);
      double lat = 11.9406;
      double lng = 108.4452;
      String tripName = '';

      tripsAsync.whenData((trips) {
        if (trips.isNotEmpty) {
          tripName = trips.first.name;
        }
      });

      final name = tripName.toLowerCase();
      if (name.contains('hà nội') || name.contains('ha noi')) {
        lat = 21.0285;
        lng = 105.8542;
      } else if (name.contains('đà nẵng') || name.contains('da nang')) {
        lat = 16.0470;
        lng = 108.2060;
      } else if (name.contains('sài gòn') || name.contains('hồ chí minh') || name.contains('hcm')) {
        lat = 10.7769;
        lng = 106.7009;
      }

      final weather = await ref.read(weatherServiceProvider).fetchWeather(lat, lng);
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

  // ─── Color helpers ───────────────────────────────────────────────────────────

  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _paper => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _bg => isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── 1. HEADER ──
        SliverToBoxAdapter(child: _buildHeader(context)),

        // ── 2. SOCIAL CHAOS MARQUEE ──
        const SliverToBoxAdapter(
          child: Column(
            children: [
              SocialChaosMarquee(),
              SizedBox(height: 20),
            ],
          ),
        ),

        // ── 3. TRIP COVER CARD ──
        SliverToBoxAdapter(
          child: Column(
            children: [
              PopIn(index: 0, child: _buildTripCoverCard(context)),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // ── 4. QUICK ACTIONS 2×2 ──
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

        // ── 5. SQUAD FRIEND PRESENCE ──
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

        // ── 6. WEATHER & UP NEXT GRID ──
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

        // ── 6b. VÉ SẮP TỚI (feed liên chuyến) ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: UpcomingReservationsWidget(isDarkMode: isDarkMode),
          ),
        ),

        // ── 7. THE ROAST PANEL ──
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

        // Đã gỡ 2 khối "Squad Mood" và "Emergency SOS": cả hai không có nguồn dữ
        // liệu nào ở backend — Squad Mood luôn hiện "CHAOTIC 85%" cứng, còn SOS
        // quảng cáo phát toạ độ GPS cố định trong khi app không xin quyền vị trí.
        // Khôi phục khi có API thật đằng sau.

        // ── 9. DAILY RECAP ──
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
                      _weatherData?.icon ?? Icons.wb_sunny_outlined,
                      color: _weatherData?.color ?? GenZTokens.yellow,
                      size: 26,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.psychology_outlined, color: _inkSoft, size: 12),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _isLoadingWeather
                            ? 'dashboard.weather_checking'.tr()
                            : (_weatherData?.details.isNotEmpty == true
                                  ? _weatherData!.details
                                  : 'weather.unavailable'.tr()),
                        style: AppFonts.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PillTag(
                  text: _isLoadingWeather ? '-- °C' : '${_weatherData?.temp.toStringAsFixed(0)}°C',
                  icon: Icons.thermostat_outlined,
                  color: GenZTokens.lilac,
                ),
                const SizedBox(height: 6),
                PillTag(
                  text: _isLoadingWeather ? 'dashboard.loading'.tr() : '${_weatherData?.description}',
                  icon: _weatherData?.icon ?? Icons.wb_cloudy_outlined,
                  color: _weatherData?.color ?? GenZTokens.yellow,
                ),
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
                              fontSize: 11,
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
                                  color: GenZTokens.pink,
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
                        style: AppFonts.body(fontSize: 11, color: _inkSoft),
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
                                    fontSize: 10,
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
                                      color: _ink,
                                      width: GenZTokens.borderWidthThin,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_outlined,
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
                                            fontSize: 10,
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
                                    fontSize: 9,
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand name — display đen đậm
          Expanded(
            child: Text(
              'trip.mate',
              style: AppFonts.heading(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
                color: _ink,
              ),
            ),
          ),

          // Squad avatar cluster (+2 overflow)
          _buildSquadCluster(),
          const SizedBox(width: 12),

          // Language toggle button — viên tròn brutalist
          GestureDetector(
            onTap: () {
              final newLocale = context.locale.languageCode == 'vi'
                  ? const Locale('en')
                  : const Locale('vi');
              context.setLocale(newLocale);
            },
            child: _InkCircleButton(
              isDarkMode: isDarkMode,
              color: GenZTokens.lilac,
              child: Center(
                child: Text(
                  context.locale.languageCode.toUpperCase(),
                  style: AppFonts.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: GenZTokens.ink,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Notification bell — badge số chưa đọc thật.
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: GenZTokens.ink,
                      ),
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
                              color: GenZTokens.red,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: GenZTokens.ink,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                unread > 9 ? '9+' : '$unread',
                                style: AppFonts.mono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: GenZTokens.paper,
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
  Widget _buildSquadCluster() {
    return Consumer(
      builder: (context, ref, _) {
        final members = ref.watch(tripsProvider).maybeWhen(
          data: (trips) => trips.isEmpty ? const [] : trips.first.members,
          orElse: () => const [],
        );
        if (members.isEmpty) return const SizedBox.shrink();

        const maxShown = 2;
        final shown = members.take(maxShown).toList();
        final overflow = members.length - shown.length;
        final width = shown.length * 20.0 + (overflow > 0 ? 32.0 : 12.0);

        return SizedBox(
          width: width,
          height: 32,
          child: Stack(
            children: [
              for (int i = 0; i < shown.length; i++)
                Positioned(
                  left: i * 20.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GenZTokens.lilac,
                      border: Border.all(color: _ink, width: 2),
                    ),
                    child: ClipOval(
                      child: shown[i].avatarUrl == null
                          ? Center(
                              child: Text(
                                shown[i].name.isNotEmpty
                                    ? shown[i].name[0].toUpperCase()
                                    : '?',
                                style: AppFonts.mono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: GenZTokens.ink,
                                ),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: shown[i].avatarUrl!,
                              fit: BoxFit.cover,
                              placeholder: (c, url) => Container(color: _bg),
                              errorWidget: (c, url, e) => const Icon(
                                Icons.person,
                                size: 16,
                                color: GenZTokens.ink,
                              ),
                            ),
                    ),
                  ),
                ),
              if (overflow > 0)
                Positioned(
                  left: shown.length * 20.0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                      border: Border.all(color: _ink, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '+$overflow',
                        style: AppFonts.mono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: GenZTokens.ink,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── TRIP COVER CARD ─────────────────────────────────────────────────────────

  // Thẻ chuyến ở home — đọc chuyến THẬT của user (tripsProvider), không hardcode.
  Widget _buildTripCoverCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Consumer(
        builder: (context, ref, _) {
          final tripsAsync = ref.watch(tripsProvider);
          return tripsAsync.when(
            loading: () => _tripCoverShell(child: const Center(
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => _tripCoverEmpty(context),
            data: (trips) => trips.isEmpty
                ? _tripCoverEmpty(context)
                : _tripCoverReal(context, trips.first),
          );
        },
      ),
    );
  }

  Widget _tripCoverShell({required Widget child, VoidCallback? onTap}) {
    return PressableCard(
      onTap: onTap,
      color: _paper,
      radius: GenZTokens.radiusCard,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          GenZTokens.radiusCard - GenZTokens.borderWidth,
        ),
        child: SizedBox(height: 280, child: child),
      ),
    );
  }

  Widget _tripCoverReal(BuildContext context, Trip t) {
    final daysLeft = t.endDate.difference(DateTime.now()).inDays;
    final daysLabel = daysLeft > 0
        ? 'dashboard.days_left'.tr(namedArgs: {'days': '$daysLeft'})
        : (daysLeft == 0
              ? 'dashboard.days_today'.tr()
              : 'dashboard.days_ended'.tr());
    return _tripCoverShell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripHubScreen(trip: t, isDarkMode: isDarkMode),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (t.coverImage != null && t.coverImage!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: t.coverImage!,
              fit: BoxFit.cover,
              placeholder: (c, u) => Container(color: GenZTokens.green),
              errorWidget: (c, u, e) => Container(color: GenZTokens.green),
            )
          else
            Container(color: GenZTokens.green),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: PillTag(
              text: 'dashboard.member_count'.tr(
                namedArgs: {'count': '${t.memberCount}'},
              ),
              icon: Icons.group,
              color: GenZTokens.yellow,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    PillTag(
                      text: daysLabel,
                      icon: Icons.schedule_rounded,
                      color: GenZTokens.lilac,
                    ),
                    const SizedBox(width: 8),
                    PillTag(
                      text: t.inviteCode,
                      icon: Icons.tag,
                      color: GenZTokens.pink,
                    ),
                    if (TripVibe.of(t.vibe) != null) ...[
                      const SizedBox(width: 8),
                      PillTag(
                        text: TripVibe.of(t.vibe)!.label,
                        icon: TripVibe.of(t.vibe)!.icon,
                        color: GenZTokens.green,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  t.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: GenZTokens.paper,
                    letterSpacing: -0.8,
                    height: 1.05,
                  ),
                ),
                if (t.destination != null && t.destination!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 15, color: GenZTokens.paper),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          t.destination!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: GenZTokens.paper,
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
    );
  }

  // Chưa có chuyến → CTA tạo chuyến đầu tiên.
  Widget _tripCoverEmpty(BuildContext context) {
    return _tripCoverShell(
      onTap: () => CreateTripSheet.show(context, isDarkMode),
      child: Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.airplane_ticket, size: 40, color: GenZTokens.ink),
            const SizedBox(height: 12),
            Text(
              'dashboard.no_trips_title'.tr(),
              style: AppFonts.heading(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: GenZTokens.ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'dashboard.no_trips_subtitle'.tr(),
              style: AppFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GenZTokens.ink,
              ),
            ),
            const SizedBox(height: 16),
            PillTag(
              text: 'dashboard.create_trip'.tr(),
              icon: Icons.add,
              color: GenZTokens.paper,
            ),
          ],
        ),
      ),
    );
  }

  // ─── ROAST PANEL ─────────────────────────────────────────────────────────────

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
              headerColor: GenZTokens.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: GenZTokens.red,
                        size: 22,
                      ),
                      const Spacer(),
                      Flexible(
                        child: PillTag(
                          text: 'dashboard.total_expense'.tr(
                            namedArgs: {'amount': _fmtMoney(sum.totalAmount)},
                          ),
                          color: GenZTokens.pink,
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
                          color: _ink,
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
                          color: GenZTokens.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedProgress(
                    total: sum.totalCount,
                    completed: sum.paidCount,
                    fillColor: GenZTokens.green,
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
      return '${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}tr';
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
            Icon(Icons.camera_alt_outlined, size: 20, color: _ink),
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
              error: (_, _) => _scrapbookPlaceholder(
                'dashboard.scrapbook_error'.tr(),
              ),
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
                                builder: (_) => MemoryWallScreen(
                                  isDarkMode: isDarkMode,
                                  onThemeToggle: onThemeToggle,
                                ),
                              ),
                            ),
                            child: _buildPolaroidCard(
                              context: context,
                              title: shown[i].title,
                              author: '- ${shown[i].authorName} -',
                              location: shown[i].location,
                              fallbackColor: i.isEven
                                  ? GenZTokens.orange
                                  : GenZTokens.blue,
                              imageUrl: shown[i].mediaUrl,
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
        border: Border.all(color: _ink.withValues(alpha: 0.25), width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.photo_camera_outlined,
              size: 28, color: _ink.withValues(alpha: 0.5)),
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
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
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
            style: GoogleFonts.caveat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            author,
            style: GoogleFonts.caveat(fontSize: 14, color: _inkSoft),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 10, color: GenZTokens.red),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  location.toUpperCase(),
                  style: AppFonts.mono(
                    fontSize: 8,
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

/// Viên tròn brutalist thay cho glass circle: nền accent/paper, viền ink,
/// hard shadow nhỏ.
class _InkCircleButton extends StatelessWidget {
  final bool isDarkMode;
  final Widget child;
  final Color color;

  const _InkCircleButton({
    required this.isDarkMode,
    required this.child,
    this.color = GenZTokens.paper,
  });

  @override
  Widget build(BuildContext context) {
    final ink = isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
        boxShadow: [
          BoxShadow(color: ink, offset: const Offset(0, 3), blurRadius: 0),
        ],
      ),
      child: Center(child: child),
    );
  }
}
