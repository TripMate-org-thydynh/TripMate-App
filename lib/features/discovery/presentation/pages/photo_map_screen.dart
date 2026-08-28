import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/network/error_message.dart';
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
  Color get _bg => widget.isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface => widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

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
        error: (err, stack) => Center(
          child: Text(
            'Lỗi tải bản đồ ảnh: ${friendlyError(err)}',
            style: AppFonts.body(color: _ink),
          ),
        ),
        data: (moments) {
          // Filter moments with GPS coordinates
          final gpsMoments = moments.where((m) => m.latitude != null && m.longitude != null).toList();

          // Fallback static mock moments with GPS if database is currently empty
          final displayMoments = gpsMoments.isNotEmpty
              ? gpsMoments
              : [
                  Moment(
                    id: 'mock-1',
                    mediaUrl: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=600',
                    type: 'PHOTO',
                    caption: 'Chụp hình sương sương Đà Lạt view đỉnh chóp ⛰️',
                    authorName: 'Thảo Ly',
                    authorAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB244M5yGCCxo4CnE1QbSwnOgbUvLW0EYlAQHgrIJaM_f_Nu4zoOioIRa_1hxA549ndJTO19XGaIGmsMVvXB0qfI2kQ28fTEAlImfIqK-8BkfrCrvA2yNCnpVqf2-SXr9-knPAtaoF5QKwxyZNaeD4lf569BT6Q0m_UTmBtw1Guj-hcrK4fYFSKLtDslymGQQxRESbhDogyXt8YneAyg--MnXiqhJBPMkTnWhIvNgcEeaN34P8fdWHmc1QttIe7PZi7wg0fbzf29Wq-',
                    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
                    latitude: 11.9406,
                    longitude: 108.4452,
                    placeName: 'Đà Lạt',
                  ),
                  Moment(
                    id: 'mock-2',
                    mediaUrl: 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=600',
                    type: 'PHOTO',
                    caption: 'Cafe chill tối siêu đẹp luôn mọi người ui ☕',
                    authorName: 'Minh Nhật',
                    authorAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB60ii0WkYusRAogyP7WxQ6KtCLjpi-fZazA3b7Hw_63SE76TTaTSYBlGn5gz8shuvpPAQIiS1UiyYmdWSciccncnq4y_m76yf0y7FTRLIYWSFqV6rjgfiwk7yPJT1DP-0RIcQ92w1a_TJZ281zFnle8zoP2y4vSggh1V1sYoi_mp4oIvRRWKhZeqIQ3rx4KJ2qUyQyZPN_fPGpu7_5Uv7xWk9Msa1Q5oU5bN8eEMtm6hEIIOo4lp4ye_DjDeIhgchKeWqQODMJtOT3',
                    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                    latitude: 11.9450,
                    longitude: 108.4380,
                    placeName: 'The Hill Station Cafe',
                  ),
                ];

          final LatLng center = displayMoments.isNotEmpty
              ? LatLng(displayMoments.first.latitude!, displayMoments.first.longitude!)
              : const LatLng(11.9406, 108.4452); // Default Da Lat

          return Stack(
            children: [
              // OpenStreetMap Canvas
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14.0,
                ),
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
                                imageUrl: m.mediaUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: GenZTokens.lilac,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 1.5),
                                  ),
                                ),
                                errorWidget: (context, url, err) => Container(
                                  color: GenZTokens.lilac,
                                  child: Icon(Icons.photo_outlined, color: _ink),
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
                      border: Border.all(color: _ink, width: GenZTokens.borderWidth),
                      borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
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
                              backgroundImage: _selectedMoment!.authorAvatar != null
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
                                    DateFormat('dd/MM/yyyy HH:mm').format(_selectedMoment!.createdAt),
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
                            imageUrl: _selectedMoment!.mediaUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Caption
                        if (_selectedMoment!.caption != null && _selectedMoment!.caption!.isNotEmpty) ...[
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
                            const Icon(Icons.location_on, color: GenZTokens.red, size: 16),
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
    final addr = await ref.read(nominatimServiceProvider).reverseGeocode(m.latitude!, m.longitude!);
    if (mounted && _selectedMoment?.id == m.id) {
      setState(() {
        _selectedAddress = addr;
        _isLoadingAddress = false;
      });
    }
  }
}
