import 'package:flutter/material.dart';
import '../../../../core/services/media_uploader.dart';
import '../../../../core/widgets/state_views.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../moments/application/moments_providers.dart';
import '../../../moments/domain/moment.dart';
import '../../../../core/services/nominatim_service.dart';

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
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

  @override
  Widget build(BuildContext context) {
    final momentsAsync = ref.watch(momentsProvider(widget.tripId));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        title: Text(
          'Photo Map 🗺️📸',
          style: AppFonts.heading(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: _ink,
          ),
        ),
      ),
      body: momentsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: _ink)),
        error: (err, _) => AppErrorState(
          isDark: widget.isDarkMode,
          error: err,
          onRetry: () => ref.invalidate(momentsProvider(widget.tripId)),
        ),
        data: (moments) {
          // Chỉ ghim khoảnh khắc CÓ toạ độ thật.
          //
          // Trước đây nhánh rỗng đổ vào 2 khoảnh khắc bịa (Thảo Ly ở Đà Lạt,
          // Minh Nhật ở The Hill Station Cafe) kèm ảnh Unsplash — nên chuyến
          // chưa đăng ảnh nào vẫn thấy bản đồ có người, tưởng là dữ liệu mình.
          final displayMoments = moments
              .where((m) => m.latitude != null && m.longitude != null)
              .toList();

          if (displayMoments.isEmpty) {
            return AppEmptyState(
              isDark: widget.isDarkMode,
              icon: Icons.map_outlined,
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
                  TileLayer(
                    urlTemplate: widget.isDarkMode
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png' // Sleek Dark Mode map tiles
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.tripmate.app',
                  ),
                  MarkerLayer(
                    markers: displayMoments.map((m) {
                      final point = LatLng(m.latitude!, m.longitude!);
                      final isSelected = _selectedMoment?.id == m.id;
                      return Marker(
                        point: point,
                        width: isSelected ? 66 : 56,
                        height: isSelected ? 66 : 56,
                        child: GestureDetector(
                          onTap: () => _onSelectMoment(m),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? GenZTokens.yellow : _ink,
                                width: isSelected ? 3.5 : 2.5,
                              ),
                              boxShadow: GenZTokens.hardShadow(_ink),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                // Marker bé xíu — không cần tải ảnh gốc.
                                imageUrl: optimizedMedia(
                                  m.mediaUrl,
                                  width: 160,
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: GenZTokens.lilac,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, err) => Container(
                                  color: GenZTokens.lilac,
                                  child: Icon(
                                    Icons.photo_outlined,
                                    color: _ink,
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
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      border: Border.all(
                        color: _ink,
                        width: GenZTokens.borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusCard,
                      ),
                      boxShadow: GenZTokens.hardShadow(_ink),
                    ),
                    padding: const EdgeInsets.all(16),
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
                              backgroundColor: GenZTokens.lilac,
                              child: _selectedMoment!.authorAvatar == null
                                  ? const Icon(Icons.person, size: 18)
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
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: _ink,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(_selectedMoment!.createdAt),
                                    style: AppFonts.mono(
                                      fontSize: 10,
                                      color: widget.isDarkMode
                                          ? GenZTokens.inkSoftDark
                                          : GenZTokens.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _selectedMoment = null;
                                  _selectedAddress = null;
                                });
                              },
                              color: _ink,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Image Preview with Brutalist look
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: optimizedMedia(
                              _selectedMoment!.mediaUrl,
                              width: 800,
                            ),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Caption
                        if (_selectedMoment!.caption != null &&
                            _selectedMoment!.caption!.isNotEmpty) ...[
                          Text(
                            _selectedMoment!.caption!,
                            style: AppFonts.body(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // GPS location name/address
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: GenZTokens.red,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _isLoadingAddress
                                    ? 'Đang lấy địa chỉ...'
                                    : (_selectedAddress ??
                                          _selectedMoment!.placeName ??
                                          'Tọa độ: ${_selectedMoment!.latitude!.toStringAsFixed(4)}, ${_selectedMoment!.longitude!.toStringAsFixed(4)}'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.mono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: widget.isDarkMode
                                      ? GenZTokens.inkSoftDark
                                      : GenZTokens.inkSoft,
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
