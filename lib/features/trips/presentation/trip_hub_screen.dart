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
      Theme.of(context).scaffoldBackgroundColor;

  /// Accent lay tu theme dang chon.
  ///
  /// Truoc day viet cung `Color(0xFFF5822B)` — accent cua rieng preset *grape*,
  /// nen doi theme khong an o man nay.
  Color _primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  Color get _ink =>
      isDarkMode ? const Color(0xFFFDF6D3) : const Color(0xFF141210);
  Color get _textPri => _ink;
  Color get _textSec =>
      isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

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
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  // Có ảnh bìa → nền tối, chữ phải trắng mới đọc được.
                  color: (trip.coverImage?.isNotEmpty ?? false)
                      ? Colors.white
                      : _textPri,
                ),
              ),
              // Ảnh bìa chuyến (nếu có) phủ toàn header, phía dưới là lớp tối
              // để chữ tiêu đề luôn đọc được. Chưa chọn bìa thì về khối cam đặc
              // kèm hoạ tiết máy bay như cũ.
              background: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF141210), width: 2.5),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TripCoverImage(
                      source: trip.coverImage,
                      fallbackColor: _primaryOf(context),
                    ),
                    if (trip.coverImage == null || trip.coverImage!.isEmpty)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Icon(
                            PhosphorIcons.airplaneTilt(PhosphorIconsStyle.fill),
                            color: const Color(
                              0xFF141210,
                            ).withValues(alpha: 0.25),
                            size: 80,
                          ),
                        ),
                      )
                    else
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC141210)],
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
                            color: const Color(0xFFF5822B),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              trip.destination!,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.body(
                                fontSize: 14,
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
                            color: const Color(0xFF1FA85C),
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
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: v.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: v.color, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(v.icon, size: 15, color: v.color),
                              const SizedBox(width: 6),
                              Text(
                                'Vibe: ${v.label}',
                                style: AppFonts.heading(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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
                        const Color(0xFFF5822B),
                        () => TripBalancesScreen(
                          tripId: trip.id,
                          tripName: trip.name,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
                        'hub.polls'.tr(),
                        'hub.polls_sub'.tr(),
                        const Color(0xFF8B4DE8),
                        () => TripPollsScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        'Wishlist',
                        'hub.wishlist_sub'.tr(),
                        const Color(0xFF1FA85C),
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
                        const Color(0xFF3D8BFF),
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
                        const Color(0xFF1FA85C),
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
                        const Color(0xFFD6248C),
                        () => TripMomentsFeedScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
                        'Squad Chat',
                        'hub.chat_sub'.tr(),
                        const Color(0xFF6366F1),
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
                        const Color(0xFF06B6D4),
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
                        const Color(0xFF8B4DE8),
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
                        const Color(0xFF8B4DE8),
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
                        const Color(0xFFFFD84D),
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
                        const Color(0xFF1FA85C),
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
                        // Truoc day o day dung 'hub.reservations' ("Kho ve &
                        // Booking") — do la phu de cua tile Dat cho, khong phai
                        // cua Tai lieu.
                        'hub.documents_sub'.tr(),
                        const Color(0xFF3D8BFF),
                        () => TripDocumentsScreen(
                          tripId: trip.id,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.bookOpen(PhosphorIconsStyle.fill),
                        'trips.hub_journal'.tr(),
                        // Truoc day dung 'hub.moments_sub' ("Anh & Ky niem
                        // nhom") — phu de cua tile Khoanh khac.
                        'hub.journal_sub'.tr(),
                        const Color(0xFFCF9FFF),
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
                        const Color(0xFFF5822B),
                        () => VacayScreen(isDarkMode: isDarkMode),
                      ),
                      _tile(
                        context,
                        PhosphorIcons.link(PhosphorIconsStyle.fill),
                        'invites.limited_code'.tr(),
                        'invites.manage'.tr(),
                        const Color(0xFFFF7E7E),
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
                        const Color(0xFFFFD84D),
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
          color: isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ink, width: 2),
          boxShadow: [BoxShadow(color: _ink, offset: const Offset(0, 3))],
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
                      color: _primaryOf(context),
                    )
                  : AppFonts.heading(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _textPri,
                    ),
            ),
            Text(label, style: AppFonts.body(fontSize: 11, color: _textSec)),
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
    Color color,
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
      color: isDarkMode ? const Color(0xFF262019) : const Color(0xFFFFFDF5),
      radius: 18,
      borderWidth: 2,
      depth: 3,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF141210), width: 2),
            ),
            // Chữ/icon trên accent sáng (vàng, lilac) phải là ink
            child: Icon(
              icon,
              color: color.computeLuminance() > 0.5
                  ? const Color(0xFF141210)
                  : const Color(0xFFFFFDF5),
              size: 20,
            ),
          ),
          // Bọc Flexible + ellipsis: tile không được tràn dù đổi tỉ lệ lưới hay
          // gặp nhãn dài sau khi dịch sang ngôn ngữ khác.
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _textPri,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(fontSize: 11, color: _textSec),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
