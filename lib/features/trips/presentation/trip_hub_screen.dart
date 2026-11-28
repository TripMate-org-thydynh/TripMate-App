import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/capabilities_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../dashboard/presentation/pages/live_trip_page.dart';
import '../../itinerary_templates/presentation/publish_template_sheet.dart';
import '../../../core/utils/app_share.dart';
import '../../../core/widgets/gen_z_widgets.dart';
import '../../../core/widgets/trip_cover_image.dart';
import '../../checkins/presentation/trip_checkins_screen.dart';
import '../../documents/presentation/trip_documents_screen.dart';
import '../../expense_tracker/presentation/pages/trip_balances_screen.dart';
import '../../fund/presentation/trip_fund_screen.dart';
import '../../invites/presentation/trip_invites_screen.dart';
import '../../journal/presentation/trip_journal_screen.dart';
import '../../moments/presentation/pages/trip_moments_feed_screen.dart';
import '../../moments/presentation/pages/trip_pictureboard_screen.dart';
import '../../notes/presentation/trip_notes_screen.dart';
import '../../packing/presentation/trip_packing_screen.dart';
import '../../reservations/presentation/trip_reservations_screen.dart';
import '../../social/presentation/pages/trip_chat_live_screen.dart';
import '../../social/presentation/pages/trip_polls_screen.dart';
import '../../todos/presentation/trip_todos_screen.dart';
import '../../trip_planner/presentation/trip_itinerary_screen.dart';
import '../../trip_planner/presentation/trip_map_screen.dart';
import '../../trip_planner/presentation/trip_wishlist_screen.dart';
import '../../vacay/presentation/vacay_screen.dart';
import '../application/trips_providers.dart';
import '../data/trips_repository.dart';
import '../domain/trip.dart';
import '../domain/trip_vibe.dart';
import 'edit_trip_sheet.dart';
import 'trip_pdf_export.dart';

/// Trang chủ 1 chuyến — gom mọi vertical về một chỗ (kiến trúc sạch).
class TripHubScreen extends ConsumerStatefulWidget {
  final Trip trip;
  final bool isDarkMode;
  const TripHubScreen({super.key, required this.trip, this.isDarkMode = false});

  @override
  ConsumerState<TripHubScreen> createState() => _TripHubScreenState();
}

class _TripHubScreenState extends ConsumerState<TripHubScreen> {
  late Trip _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  Future<void> _refreshTripDetail() async {
    try {
      final fresh = await ref.read(tripsRepositoryProvider).fetchTrip(_trip.id);
      if (mounted) {
        setState(() => _trip = fresh);
      }
    } catch (_) {}
  }

  bool get isDarkMode => widget.isDarkMode;

  Color _bgOf(BuildContext context) =>
      isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;

  Color get _surface => isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _ink => isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textPri => _ink;
  Color get _textSec =>
      isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _accent => isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _danger => isDarkMode ? GenZTokens.dangerDark : GenZTokens.danger;

  // Rút gọn tiền: 3.000.000 → "3tr", 500000 → "500k".
  String _fmtMoney(double v) {
    if (v >= 1000000) {
      final m = v / 1000000;
      return '${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}tr';
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  Future<void> _showMembersSheet() async {
    await _refreshTripDetail();
    if (!mounted) return;
    final currentUserId = ref.read(authProvider).user?['id']?.toString() ?? '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final members = _trip.members;
            final myMember = members
                .where((m) => m.id == currentUserId)
                .firstOrNull;
            final isCreator =
                myMember != null &&
                (myMember.role == 'OWNER' ||
                    myMember.role == 'CREATOR' ||
                    myMember.role == 'ADMIN');

            return Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(GenZTokens.radiusCard),
                ),
                border: Border.all(
                  color: _line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _line,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'trips.members_title'.tr(),
                        style: AppFonts.heading(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (members.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'trips.no_member_details'.tr(),
                            style: AppFonts.body(fontSize: 14, color: _textSec),
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 320),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: members.length,
                            separatorBuilder: (_, _) =>
                                Divider(color: _line, height: 1),
                            itemBuilder: (_, idx) {
                              final m = members[idx];
                              final isMe = m.id == currentUserId;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: _fill,
                                  child: Text(
                                    m.name.isNotEmpty
                                        ? m.name[0].toUpperCase()
                                        : '?',
                                    style: AppFonts.heading(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _accent,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  isMe
                                      ? 'trips.member_you'.tr(
                                          namedArgs: {'name': m.name},
                                        )
                                      : m.name,
                                  style: AppFonts.heading(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _ink,
                                  ),
                                ),
                                subtitle: Text(
                                  m.role,
                                  style: AppFonts.mono(
                                    fontSize: 12,
                                    color: _textSec,
                                  ),
                                ),
                                trailing: isCreator && !isMe && m.id.isNotEmpty
                                    ? IconButton(
                                        tooltip: 'trips.remove_member'.tr(),
                                        icon: Icon(
                                          PhosphorIcons.userMinus(),
                                          color: _danger,
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          try {
                                            await ref
                                                .read(tripsProvider.notifier)
                                                .removeMember(_trip.id, m.id);
                                            await _refreshTripDetail();
                                            setSheetState(() {});
                                          } catch (_) {}
                                        },
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      if (!isCreator) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              Navigator.pop(sheetCtx);
                              try {
                                await ref
                                    .read(tripsProvider.notifier)
                                    .leaveTrip(_trip.id);
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              } catch (_) {}
                            },
                            icon: Icon(
                              PhosphorIcons.signOut(),
                              color: _danger,
                              size: 18,
                            ),
                            label: Text(
                              'trips.leave_trip_btn'.tr(),
                              style: AppFonts.heading(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _danger,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: _danger),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  GenZTokens.radiusButton,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final publishPolicy = ref.watch(capabilityProvider('publishTemplate'));
    return Scaffold(
      backgroundColor: _bgOf(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _bgOf(context),
            title: Text('beta.overview'.tr()),
            pinned: true,
            expandedHeight: 180,
            iconTheme: IconThemeData(color: _textPri),
            actions: [
              IconButton(
                tooltip: 'trips.members_tooltip'.tr(),
                icon: Icon(PhosphorIcons.users(), color: _textPri),
                onPressed: _showMembersSheet,
              ),
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
                    final list = ref.read(tripsProvider).valueOrNull;
                    final updated = list
                        ?.where((t) => t.id == trip.id)
                        .firstOrNull;
                    if (updated != null) {
                      setState(() => _trip = updated);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('trips.updated'.tr()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
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
                  color: _textPri,
                ),
              ),
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
                          padding: EdgeInsets.fromLTRB(
                            20,
                            MediaQuery.paddingOf(context).top + 8,
                            20,
                            20,
                          ),
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
                  Text(
                    (DateTime.now().isBefore(trip.startDate)
                            ? 'beta.beforeTrip'
                            : DateTime.now().isAfter(trip.endDate)
                            ? 'beta.afterTrip'
                            : 'beta.duringTrip')
                        .tr(),
                    style: AppFonts.body(fontSize: 16, color: _textSec),
                  ),
                  const SizedBox(height: 14),
                  if (trip.inviteCode.isNotEmpty &&
                      DateTime.now().isBefore(trip.startDate))
                    FilledButton.icon(
                      onPressed: () => AppShare.shareText(
                        context,
                        'trips.share_body'.tr(
                          namedArgs: {
                            'name': trip.name,
                            'code': trip.inviteCode,
                          },
                        ),
                      ),
                      icon: Icon(PhosphorIcons.shareNetwork()),
                      label: Text('trips.hub_invite_squad'.tr()),
                    ),
                  const SizedBox(height: 12),
                  if (DateTime.now().isAfter(trip.endDate) &&
                      !publishPolicy.hidden)
                    OutlinedButton.icon(
                      icon: Icon(PhosphorIcons.shareNetwork()),
                      onPressed: publishPolicy.canWrite
                          ? () => PublishTemplateSheet.show(
                              context,
                              tripId: trip.id,
                              defaultTitle: trip.name,
                              isDarkMode: isDarkMode,
                            )
                          : () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(publishPolicy.label(context)),
                              ),
                            ),
                      label: Text('templates.publish_action'.tr()),
                    ),
                  ...[
                    (
                      PhosphorIcons.calendarBlank(),
                      'itinerary.title'.tr(),
                      'hub.itinerary_sub'.tr(),
                      TripItineraryScreen(
                        tripId: trip.id,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    (
                      PhosphorIcons.scales(),
                      'expense.split_title'.tr(),
                      'hub.balances'.tr(),
                      TripBalancesScreen(
                        tripId: trip.id,
                        tripName: trip.name,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    (
                      PhosphorIcons.camera(),
                      'moments.title'.tr(),
                      'hub.moments'.tr(),
                      TripPictureboardScreen(
                        tripId: trip.id,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ].map(
                    (action) => ListTile(
                      leading: Icon(action.$1, color: _accent),
                      title: Text(action.$2),
                      subtitle: Text(action.$3),
                      trailing: Icon(PhosphorIcons.caretRight()),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => action.$4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
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
                        onTap: _showMembersSheet,
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
                    'beta.moreTools'.tr(),
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _textPri,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Builder(
                    builder: (context) {
                      final textScaler = MediaQuery.textScalerOf(context);
                      final tileExtent = max(136.0, textScaler.scale(50) + 86);
                      return GridView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: tileExtent,
                        ),
                        children: [
                          _tile(
                            context,
                            PhosphorIcons.usersThree(),
                            'Crew',
                            'live.updates'.tr(),
                            () => LiveTripPage(
                              trip: trip,
                              isDarkMode: isDarkMode,
                              onThemeToggle: () => ref
                                  .read(themeProvider.notifier)
                                  .toggleTheme(),
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
                            'beta.momentFeed'.tr(),
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
                            PhosphorIcons.suitcaseRolling(
                              PhosphorIconsStyle.fill,
                            ),
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
                      );
                    },
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
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
        boxShadow: GenZTokens.hardShadow(_ink, isDarkMode),
      ),
      child: Column(
        children: [
          // Cao cố định để 3 thẻ (số to / mã mời chữ nhỏ) cao bằng nhau.
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
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
            ),
          ),
          Text(label, style: AppFonts.body(fontSize: 12, color: _textSec)),
        ],
      ),
    );
    return Expanded(
      child: onTap == null ? card : GestureDetector(onTap: onTap, child: card),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Widget Function()? builder,
  ) {
    final trip = _trip;
    return PressableCard(
      onTap: () {
        HapticFeedback.selectionClick();
        if (builder == null) {
          AppShare.shareText(
            context,
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
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _fill,
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              border: Border.all(
                color: _line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Icon(icon, color: _accent, size: 20),
          ),
          const Spacer(),
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
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(fontSize: 12, color: _textSec),
          ),
        ],
      ),
    );
  }
}
