import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/widgets/trip_cover_image.dart';
import '../../../destinations/data/destinations_catalog.dart';
import '../../../destinations/presentation/destination_screen.dart';
import '../../../trips/domain/trip.dart';
import '../../../trips/presentation/create_trip_sheet.dart';

/// Ô "Đi đâu tiếp?" + chip điểm đến ở đầu trang chủ.
///
/// App không bán phòng/vé: ô này là điểm bắt đầu một chuyến nhóm. Khi gõ,
/// hiện 2 nhóm — chuyến đã có (lọc trên trips đã tải sẵn, không gọi API) và
/// điểm đến cố định. Không khớp gì thì đưa nút tạo chuyến với điểm đến đã gõ.
class HomeSearchSection extends StatefulWidget {
  const HomeSearchSection({
    super.key,
    required this.trips,
    required this.isDarkMode,
    required this.onOpenTrip,
  });

  final List<Trip> trips;
  final bool isDarkMode;
  final ValueChanged<Trip> onOpenTrip;

  @override
  State<HomeSearchSection> createState() => _HomeSearchSectionState();
}

class _HomeSearchSectionState extends State<HomeSearchSection> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _q = '';

  bool get _d => widget.isDarkMode;
  Color get _ink => _d ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft => _d ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _paper => _d ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _fill => _d ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _line => _d ? GenZTokens.lineDark : GenZTokens.line;

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    setState(() => _q = '');
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.trim();
    final fq = foldVietnamese(q);
    final tripHits = q.isEmpty
        ? const <Trip>[]
        : widget.trips
              .where(
                (t) =>
                    foldVietnamese(t.name).contains(fq) ||
                    foldVietnamese(t.destination ?? '').contains(fq),
              )
              .take(4)
              .toList();
    final destHits = q.isEmpty
        ? const <Destination>[]
        : destinationsCatalog.where((d) => d.matches(q)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('home_search_field'),
            controller: _ctrl,
            focusNode: _focus,
            onChanged: (v) => setState(() => _q = v),
            textInputAction: TextInputAction.search,
            style: AppFonts.body(fontSize: 15, color: _ink),
            decoration: InputDecoration(
              hintText: 'home_search.hint'.tr(),
              hintStyle: AppFonts.body(fontSize: 15, color: _inkSoft),
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), color: _inkSoft),
              suffixIcon: q.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'home_search.clear'.tr(),
                      icon: Icon(PhosphorIcons.x(), color: _inkSoft, size: 18),
                      onPressed: _clear,
                    ),
              filled: true,
              fillColor: _fill,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                borderSide: BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                borderSide: BorderSide(color: _ink, width: 2),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: q.isEmpty
                ? _chips(context)
                : _results(context, q, tripHits, destHits),
          ),
        ],
      ),
    );
  }

  Widget _chips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: destinationsCatalog.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final dest = destinationsCatalog[i];
            return ActionChip(
              label: Text(dest.name),
              labelStyle: AppFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
              avatar: Icon(PhosphorIcons.mapPin(), size: 14, color: _inkSoft),
              backgroundColor: _paper,
              side: BorderSide(color: _line),
              shape: const StadiumBorder(),
              onPressed: () =>
                  DestinationScreen.open(context, dest, widget.isDarkMode),
            );
          },
        ),
      ),
    );
  }

  Widget _groupTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      text,
      style: AppFonts.body(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _inkSoft,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _results(
    BuildContext context,
    String q,
    List<Trip> trips,
    List<Destination> dests,
  ) {
    final empty = trips.isEmpty && dests.isEmpty;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line),
      ),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trips.isNotEmpty) ...[
            _groupTitle('home_search.your_trips'.tr()),
            for (final t in trips)
              ListTile(
                dense: true,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: TripCoverImage(source: t.coverImage),
                  ),
                ),
                title: Text(
                  t.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                subtitle: (t.destination ?? '').isEmpty
                    ? null
                    : Text(
                        t.destination!,
                        style: AppFonts.body(fontSize: 13, color: _inkSoft),
                      ),
                onTap: () {
                  _clear();
                  widget.onOpenTrip(t);
                },
              ),
          ],
          if (dests.isNotEmpty) ...[
            _groupTitle('home_search.destinations'.tr()),
            for (final dest in dests)
              ListTile(
                dense: true,
                leading: Icon(PhosphorIcons.mapPin(), color: _inkSoft),
                title: Text(
                  dest.name,
                  style: AppFonts.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                trailing: Icon(PhosphorIcons.caretRight(), color: _inkSoft, size: 16),
                onTap: () {
                  _clear();
                  DestinationScreen.open(context, dest, widget.isDarkMode);
                },
              ),
          ],
          if (empty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'home_search.no_results'.tr(),
                    style: AppFonts.body(fontSize: 13, color: _inkSoft),
                  ),
                  const SizedBox(height: 8),
                  // Nút viền (không màu nhấn): màu nhấn của home thuộc CTA tạo chuyến.
                  OutlinedButton.icon(
                    onPressed: () {
                      final place = q;
                      _clear();
                      CreateTripSheet.show(
                        context,
                        widget.isDarkMode,
                        initialDestination: place,
                      );
                    },
                    icon: Icon(PhosphorIcons.plus(), size: 16, color: _ink),
                    label: Text(
                      'home_search.create_for'.tr(namedArgs: {'place': q}),
                      style: AppFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _line, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "Chuyến đi của bạn" — danh sách ngang các chuyến thật.
class HomeTripsStrip extends StatelessWidget {
  const HomeTripsStrip({
    super.key,
    required this.trips,
    required this.isDarkMode,
    required this.onOpenTrip,
  });

  final List<Trip> trips;
  final bool isDarkMode;
  final ValueChanged<Trip> onOpenTrip;

  @override
  Widget build(BuildContext context) {
    final ink = isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final paper = isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
    final fmt = DateFormat('dd/MM');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'home_search.your_trips_title'.tr(),
            style: AppFonts.heading(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 178,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: trips.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final t = trips[i];
              return Material(
                color: paper,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  side: BorderSide(color: line),
                ),
                child: InkWell(
                  onTap: () => onOpenTrip(t),
                  child: SizedBox(
                    width: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: TripCoverImage(source: t.coverImage),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                          child: Text(
                            t.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ink,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                          child: Text(
                            '${fmt.format(t.startDate)} – ${fmt.format(t.endDate)}',
                            style: AppFonts.mono(fontSize: 12, color: inkSoft),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
