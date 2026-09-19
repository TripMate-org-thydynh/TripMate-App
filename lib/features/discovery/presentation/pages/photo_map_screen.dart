import 'package:flutter/material.dart';
import '../../../../core/services/media_uploader.dart';
import '../../../../core/widgets/state_views.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../moments/application/moments_providers.dart';
import '../../../moments/domain/moment.dart';
import '../../../../core/services/nominatim_service.dart';
import '../../../../core/map/map_tiles.dart';

class PhotoMapScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;

  const PhotoMapScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  @override
  ConsumerState<PhotoMapScreen> createState() => _PhotoMapScreenState();
}

class _PhotoMapScreenState extends ConsumerState<PhotoMapScreen> {
  final MapController _mapController = MapController();
  Moment? _selectedMoment;
  String? _selectedAddress;
  bool _isLoadingAddress = false;

  Color get _ink => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _inkSoft =>
      widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color get _bg => widget.isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface =>
      widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _line => widget.isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _fill => widget.isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _accent =>
      widget.isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;

  @override
  Widget build(BuildContext context) {
    final momentsAsync = ref.watch(momentsProvider(widget.tripId));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'photo.map_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _ink,
          ),
        ),
      ),
      body: momentsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
          ),
        ),
        error: (err, _) => AppErrorState(
          isDark: widget.isDarkMode,
          error: err,
          onRetry: () => ref.invalidate(momentsProvider(widget.tripId)),
        ),
        data: (moments) {
          // Chỉ ghim khoảnh khắc CÓ toạ độ thật.
          final displayMoments = moments
              .where((m) => m.latitude != null && m.longitude != null)
              .toList();

          if (displayMoments.isEmpty) {
            return AppEmptyState(
              isDark: widget.isDarkMode,
              icon: PhosphorIcons.mapTrifold(),
              title: 'moments.photo_map_empty_title'.tr(),
              body: 'moments.photo_map_empty_body'.tr(),
            );
          }

          final LatLng center = displayMoments.isNotEmpty
              ? LatLng(
                  displayMoments.first.latitude!,
                  displayMoments.first.longitude!,
                )
              : const LatLng(11.9406, 108.4452); // Default Da Lat

          return Stack(
            children: [
              // OpenStreetMap Canvas
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(initialCenter: center, initialZoom: 14.0),
                children: [
                  ...mapTileLayers(dark: widget.isDarkMode),
                  MarkerLayer(
                    markers: displayMoments.map((m) {
                      final point = LatLng(m.latitude!, m.longitude!);
                      final isSelected = _selectedMoment?.id == m.id;
                      return Marker(
                        point: point,
                        width: isSelected ? 64 : 52,
                        height: isSelected ? 64 : 52,
                        child: GestureDetector(
                          onTap: () => _onSelectMoment(m),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? _accent : _surface,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: GenZTokens.hardShadow(
                                _ink,
                                widget.isDarkMode,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: optimizedMedia(
                                  m.mediaUrl,
                                  width: 160,
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: _fill,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _accent,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, err) => Container(
                                  color: _fill,
                                  child: Icon(
                                    PhosphorIcons.image(),
                                    color: _inkSoft,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Bottom floating details card if a moment is selected
              if (_selectedMoment != null)
                Positioned(
                  bottom: GenZTokens.space5,
                  left: GenZTokens.space4,
                  right: GenZTokens.space4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      border: Border.all(
                        color: _line,
                        width: GenZTokens.borderWidthThin,
                      ),
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusCard,
                      ),
                      boxShadow: GenZTokens.hardShadow(_ink, widget.isDarkMode),
                    ),
                    padding: const EdgeInsets.all(GenZTokens.space4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header metadata (author & date)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage:
                                  _selectedMoment!.authorAvatar != null
                                  ? NetworkImage(_selectedMoment!.authorAvatar!)
                                  : null,
                              backgroundColor: _fill,
                              child: _selectedMoment!.authorAvatar == null
                                  ? Icon(
                                      PhosphorIcons.user(),
                                      size: 18,
                                      color: _inkSoft,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedMoment!.authorName,
                                    style: AppFonts.heading(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: _ink,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(_selectedMoment!.createdAt),
                                    style: AppFonts.mono(
                                      fontSize: 12,
                                      color: _inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(PhosphorIcons.x(), size: 20),
                              onPressed: () {
                                setState(() {
                                  _selectedMoment = null;
                                  _selectedAddress = null;
                                });
                              },
                              color: _inkSoft,
                            ),
                          ],
                        ),
                        const SizedBox(height: GenZTokens.space3),

                        // Image Preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            GenZTokens.radiusInput,
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(
                              imageUrl: optimizedMedia(
                                _selectedMoment!.mediaUrl,
                                width: 800,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: GenZTokens.space3),

                        // Caption
                        if (_selectedMoment!.caption != null &&
                            _selectedMoment!.caption!.isNotEmpty) ...[
                          Text(
                            _selectedMoment!.caption!,
                            style: AppFonts.body(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: GenZTokens.space2),
                        ],

                        // GPS location name/address
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                              color: _accent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _isLoadingAddress
                                    ? 'photo.resolving'.tr()
                                    : (_selectedAddress ??
                                          _selectedMoment!.placeName ??
                                          'photo.coords'.tr(
                                            namedArgs: {
                                              'lat': _selectedMoment!.latitude!
                                                  .toStringAsFixed(4),
                                              'lng': _selectedMoment!.longitude!
                                                  .toStringAsFixed(4),
                                            },
                                          )),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.mono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _inkSoft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onSelectMoment(Moment m) async {
    setState(() {
      _selectedMoment = m;
      _isLoadingAddress = true;
    });

    // Move camera to selected coordinates smoothly
    _mapController.move(LatLng(m.latitude!, m.longitude!), 15.0);

    // Call Nominatim API for reverse geocoding
    final addr = await ref
        .read(nominatimServiceProvider)
        .reverseGeocode(m.latitude!, m.longitude!);
    if (mounted && _selectedMoment?.id == m.id) {
      setState(() {
        _selectedAddress = addr;
        _isLoadingAddress = false;
      });
    }
  }
}
