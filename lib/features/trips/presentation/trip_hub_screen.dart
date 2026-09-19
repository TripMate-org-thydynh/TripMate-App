import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/trip_cover_image.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/trip.dart';
import '../domain/trip_vibe.dart';
import 'edit_trip_sheet.dart';
import '../../../core/widgets/gen_z_widgets.dart';
import '../../expense_tracker/presentation/pages/trip_balances_screen.dart';
import '../../fund/presentation/trip_fund_screen.dart';
import '../../social/presentation/pages/trip_polls_screen.dart';
import '../../trip_planner/presentation/trip_wishlist_screen.dart';
import '../../trip_planner/presentation/trip_itinerary_screen.dart';
import '../../moments/presentation/pages/trip_moments_feed_screen.dart';
import '../../social/presentation/pages/trip_chat_live_screen.dart';
import '../../packing/presentation/trip_packing_screen.dart';
import '../../reservations/presentation/trip_reservations_screen.dart';
import '../../trip_planner/presentation/trip_map_screen.dart';
import '../../todos/presentation/trip_todos_screen.dart';
import '../../notes/presentation/trip_notes_screen.dart';
import '../../checkins/presentation/trip_checkins_screen.dart';
import '../../documents/presentation/trip_documents_screen.dart';
import '../../journal/presentation/trip_journal_screen.dart';
import '../../invites/presentation/trip_invites_screen.dart';
import '../../vacay/presentation/vacay_screen.dart';
import 'trip_pdf_export.dart';

/// Trang chủ 1 chuyến — gom mọi vertical về một chỗ (kiến trúc sạch).
class TripHubScreen extends StatelessWidget {
  final Trip trip;
  final bool isDarkMode;
  const TripHubScreen({super.key, required this.trip, this.isDarkMode = false});

  Color _bgOf(BuildContext context) =>
      isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;

  Color get _surface =>
      isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textPri => _ink;
  Color get _textSec =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _accent => isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;

  // Rút gọn tiền: 3.000.000 → "3tr", 500000 → "500k".
  String _fmtMoney(double v) {
    if (v >= 1000000) {
      final m = v / 1000000;
      return '${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}tr';
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgOf(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _bgOf(context),
            pinned: true,
            expandedHeight: 180,
            iconTheme: IconThemeData(color: _textPri),
            actions: [
              IconButton(
                tooltip: 'trips.edit'.tr(),
                icon: Icon(PhosphorIcons.pencilSimple(), color: _textPri),
                onPressed: () async {
                  final ok = await EditTripSheet.show(
                    context,
                    trip,
                    isDarkMode,
                  );
                  if (ok == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('trips.updated'.tr()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Text(
                trip.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  // Ảnh tan xuống màu nền ở mép dưới → chữ thường đọc được.
                  color: _textPri,
                ),
              ),
              // Ảnh bìa chuyến phủ header, tan dần xuống màu nền (concept A/B).
              background: SizedBox.expand(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TripCoverImage(
                      source: trip.coverImage,
                      fallbackColor: _accent,
                    ),
                    if (trip.coverImage == null || trip.coverImage!.isEmpty)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Icon(
                            PhosphorIcons.airplaneTilt(PhosphorIconsStyle.fill),
                            color: _ink.withValues(alpha: 0.15),
                            size: 80,
                          ),
                        ),
                      )
                    else
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.4, 0.78, 1.0],
                            colors: [
                              _bgOf(context).withValues(alpha: 0),
                              _bgOf(context).withValues(alpha: 0.75),
                              _bgOf(context),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _stat(
                        context,
                        '${trip.durationDays}',
                        'common.day_unit'.tr(),
                      ),
                      const SizedBox(width: 12),
                      _stat(
                        context,
                        '${trip.memberCount}',
                        'trips.members_unit'.tr(),
                      ),
                      const SizedBox(width: 12),
                      _stat(
                        context,
                        trip.inviteCode,
                        'trips.invite_code_lower'.tr(),
                        mono: true,
                      ),
                    ],
                  ),
                  if ((trip.destination != null &&
                          trip.destination!.isNotEmpty) ||
                      trip.budget != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (trip.destination != null &&
                            trip.destination!.isNotEmpty) ...[
                          Icon(
                            PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                            size: 16,
                            color: _accent,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              trip.destination!,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                          ),
                        ],
                        if (trip.budget != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            PhosphorIcons.wallet(PhosphorIconsStyle.fill),
                            size: 16,
                            color: isDarkMode
                                ? GenZTokens.successDark
                                : GenZTokens.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_fmtMoney(trip.budget!)} ${trip.currency}',
                            style: AppFonts.body(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (TripVibe.of(trip.vibe) != null) ...[
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final v = TripVibe.of(trip.vibe)!;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: v.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusPill,
                            ),
                            border: Border.all(
                              color: v.color.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(v.icon, size: 14, color: v.color),
                              const SizedBox(width: 5),
                              Text(
                                'trips.vibe_display'.tr(
                                  namedArgs: {'vibe': v.label},
                                ),
                                style: AppFonts.heading(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'trips.manage'.tr(),
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _textPri,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _tile(
                        context,
                        PhosphorIcons.scales(PhosphorIconsStyle.fill),
                        'expense.split_title'.tr(),
                        'hub.balances'.tr(),
                        () => TripBalancesScreen(
                          tripId: trip.id,
                          tripName: trip.name,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.piggyBank(PhosphorIconsStyle.fill),
                        'fund.title'.tr(),
                        'hub.fund_sub'.tr(),
                        () => TripFundScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
                        'hub.polls'.tr(),
                        'hub.polls_sub'.tr(),
                        () => TripPollsScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        'trips.hub_wishlist'.tr(),
                        'hub.wishlist_sub'.tr(),
                        () => TripWishlistScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
                        'itinerary.title'.tr(),
                        'hub.itinerary_sub'.tr(),
                        () => TripItineraryScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
                        'hub.map'.tr(),
                        'hub.map_sub'.tr(),
                        () => TripMapScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.camera(PhosphorIconsStyle.fill),
                        'moments.title'.tr(),
                        'hub.moments'.tr(),
                        () => TripMomentsFeedScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
                        'trips.hub_squad_chat'.tr(),
                        'hub.chat_sub'.tr(),
                        () => TripChatLiveScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.suitcaseRolling(PhosphorIconsStyle.fill),
                        'packing.title'.tr(),
                        'hub.packing_sub'.tr(),
                        () => TripPackingScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.listChecks(PhosphorIconsStyle.fill),
                        'hub.todos'.tr(),
                        'hub.todos_sub'.tr(),
                        () => TripTodosScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.ticket(PhosphorIconsStyle.fill),
                        'reservations.title'.tr(),
                        'hub.reservations_sub'.tr(),
                        () => TripReservationsScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.note(PhosphorIconsStyle.fill),
                        'hub.notes'.tr(),
                        'hub.notes_sub'.tr(),
                        () => TripNotesScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.checkSquare(PhosphorIconsStyle.fill),
                        'checkins.title'.tr(),
                        'hub.checkins_sub'.tr(),
                        () => TripCheckinsScreen(
                          tripId: trip.id,
                          tripDays: trip.durationDays,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.file(PhosphorIconsStyle.fill),
                        'trips.hub_documents'.tr(),
                        'hub.documents_sub'.tr(),
                        () => TripDocumentsScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.bookOpen(PhosphorIconsStyle.fill),
                        'trips.hub_journal'.tr(),
                        'hub.journal_sub'.tr(),
                        () => TripJournalScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                        'trips.hub_leave_days'.tr(),
                        'hub.vacay'.tr(),
                        () => VacayScreen(isDarkMode: isDarkMode),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.link(PhosphorIconsStyle.fill),
                        'invites.limited_code'.tr(),
                        'invites.manage'.tr(),
                        () => TripInvitesScreen(
                          tripId: trip.id,
                          tripName: trip.name,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.shareNetwork(PhosphorIconsStyle.fill),
                        'trips.hub_invite_squad'.tr(),
                        'trips.code_label'.tr(
                          namedArgs: {'code': trip.inviteCode},
                        ),
                        null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ExportPdfButton(trip: trip, isDarkMode: isDarkMode),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    String value,
    String label, {
    bool mono = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
          boxShadow: GenZTokens.hardShadow(_ink, isDarkMode),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: mono
                  ? AppFonts.mono(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    )
                  : AppFonts.heading(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _textPri,
                    ),
            ),
            Text(label, style: AppFonts.body(fontSize: 12, color: _textSec)),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Widget Function()? builder,
  ) {
    return PressableCard(
      onTap: () {
        HapticFeedback.selectionClick();
        if (builder == null) {
          Share.share(
            'trips.share_body'.tr(
              namedArgs: {'name': trip.name, 'code': trip.inviteCode},
            ),
            subject: 'invites.share_subject'.tr(namedArgs: {'trip': trip.name}),
          );
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => builder()));
      },
      color: _surface,
      radius: GenZTokens.radiusCard,
      borderWidth: GenZTokens.borderWidthThin,
      depth: 1,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _fill,
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
            ),
            child: Icon(
              icon,
              color: _accent,
              size: 20,
            ),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPri,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(fontSize: 12, color: _textSec),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
