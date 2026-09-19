import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../trip_planner/data/itinerary_repository.dart';
import '../../../gamification/data/games_repository.dart';
import '../../../trips/application/trips_providers.dart';

/// Sheet thêm một địa điểm vào lịch trình chuyến.
///
/// Trước đây hàm lưu chỉ là `Future.delayed(1s)` kèm chú thích "Simulate NestJS
/// POST request", rồi hiện dấu tick và đóng — người dùng thấy "Successfully
/// added to Itinerary! 🎉" nhưng không có gì được ghi. Nay gọi
/// `POST /trips/:id/itinerary` thật và báo lỗi nếu hỏng.
class AddToItinerarySheet extends ConsumerStatefulWidget {
  final String placeName;
  final String placeAddress;
  final bool isDarkMode;

  /// Chuyến sẽ thêm vào. `null` thì lấy chuyến đang hoạt động.
  final String? tripId;

  /// Gọi sau khi đã lưu THÀNH CÔNG.
  final Function(Map<String, dynamic> itineraryData) onAdded;

  const AddToItinerarySheet({
    super.key,
    required this.placeName,
    required this.placeAddress,
    required this.isDarkMode,
    required this.onAdded,
    this.tripId,
  });

  @override
  ConsumerState<AddToItinerarySheet> createState() =>
      _AddToItinerarySheetState();
}

class _AddToItinerarySheetState extends ConsumerState<AddToItinerarySheet>
    with SingleTickerProviderStateMixin {
  int _selectedDay = 1;
  String _selectedTime = '10:30 AM';
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;
  bool _showSuccess = false;

  /// Nhãn phân loại gửi kèm khi lưu (BE nhận field `category`).
  final String _activeTag = 'CHILL';

  late AnimationController _successController;
  late Animation<double> _scaleAnimation;

  final List<String> _timeOptions = [
    '08:00 AM',
    '09:30 AM',
    '10:30 AM',
    '12:00 PM',
    '02:00 PM',
    '03:30 PM',
    '05:00 PM',
    '07:00 PM',
    '08:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _successController.dispose();
    super.dispose();
  }

  /// Chuyến đang chọn — ưu tiên tham số, không có thì lấy chuyến hiện hành.
  String? get _tripId => widget.tripId ?? ref.read(activeTripIdProvider);

  /// Số ngày của chuyến, để danh sách ngày không vượt quá độ dài thật.
  int get _tripDays {
    final id = _tripId;
    if (id == null) return 3;
    return ref
        .read(tripsProvider)
        .maybeWhen(
          data: (trips) {
            for (final t in trips) {
              if (t.id != id) continue;
              final n = t.endDate.difference(t.startDate).inDays + 1;
              return n > 0 ? n : 1;
            }
            return 3;
          },
          orElse: () => 3,
        );
  }

  /// '10:30 AM' -> '10:30', '07:00 PM' -> '19:00' (BE nhận giờ 24h).
  static String _to24h(String label) {
    final parts = label.split(' ');
    if (parts.length != 2) return label;
    final hm = parts[0].split(':');
    var h = int.tryParse(hm[0]) ?? 0;
    final m = hm.length > 1 ? hm[1] : '00';
    final isPm = parts[1].toUpperCase() == 'PM';
    if (isPm && h != 12) h += 12;
    if (!isPm && h == 12) h = 0;
    return '${h.toString().padLeft(2, '0')}:$m';
  }

  Future<void> _saveToItinerary() async {
    final tripId = _tripId;
    if (tripId == null) {
      showGlobalSnack('games.need_trip_body'.tr(), isError: true);
      return;
    }
    setState(() => _isSaving = true);

    try {
      await ref
          .read(itineraryRepositoryProvider)
          .create(
            tripId,
            day: _selectedDay,
            startTime: _to24h(_selectedTime),
            placeName: widget.placeName,
            placeAddress: widget.placeAddress,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            category: _activeTag,
          );
      if (!mounted) return;
      ref.invalidate(tripItineraryProvider(tripId));
      setState(() {
        _isSaving = false;
        _showSuccess = true;
      });
      _successController.forward();

      widget.onAdded({
        'day': _selectedDay,
        'startTime': _selectedTime,
        'placeName': widget.placeName,
        'placeAddress': widget.placeAddress,
        'notes': _notesController.text,
      });

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final sheetBg = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border.all(color: line, width: GenZTokens.borderWidthThin),
            boxShadow: GenZTokens.hardShadow(ink, isDark),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GenZTokens.space4,
                  vertical: GenZTokens.space4,
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: _showSuccess
                      ? _buildSuccessView(isDark)
                      : _buildFormView(isDark),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessView(bool isDark) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final successColor = isDark ? GenZTokens.successDark : GenZTokens.success;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: successColor.withValues(alpha: 0.12),
              border: Border.all(
                color: successColor,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Icon(
              PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              color: successColor,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'itinerary.added_success'.tr(),
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'itinerary.scheduled_desc'.tr(
            namedArgs: {
              'place': widget.placeName,
              'day': '$_selectedDay',
              'time': _selectedTime,
            },
          ),
          textAlign: TextAlign.center,
          style: AppFonts.body(fontSize: 14, color: inkSoft),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildFormView(bool isDark) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final accentSoft = isDark
        ? GenZTokens.accentSoftDark
        : GenZTokens.accentSoft;
    final onAccentSoft = isDark
        ? GenZTokens.onAccentSoftDark
        : GenZTokens.onAccentSoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slide drag handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: GenZTokens.space4),

        // Header Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ai.vibe_add'.tr(),
              style: AppFonts.heading(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill,
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Icon(PhosphorIcons.x(), size: 16, color: inkSoft),
              ),
            ),
          ],
        ),
        const SizedBox(height: GenZTokens.space4),

        // Detailed Card representing place
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(color: line, width: GenZTokens.borderWidthThin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover placeholder
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                  color: fill,
                ),
                child: Center(
                  child: Icon(
                    PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                    size: 36,
                    color: accent,
                  ),
                ),
              ),

              // Card details + Schedule form parameters
              Padding(
                padding: const EdgeInsets.all(GenZTokens.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.placeName,
                      style: AppFonts.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    if (widget.placeAddress.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.mapPin(),
                            color: inkSoft,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.placeAddress,
                              style: AppFonts.body(
                                fontSize: 13,
                                color: inkSoft,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: GenZTokens.space3),
                    Divider(color: line),
                    const SizedBox(height: GenZTokens.space2),

                    // Inline Schedule pickers
                    Text(
                      'itinerary.schedule_spot'.tr(),
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: GenZTokens.space2),

                    // Days selector
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_tripDays, (i) => i + 1).map((
                          day,
                        ) {
                          final isSelected = _selectedDay == day;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDay = day;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? accentSoft : fill,
                                  borderRadius: BorderRadius.circular(
                                    GenZTokens.radiusButton,
                                  ),
                                  border: Border.all(
                                    color: isSelected ? accent : line,
                                    width: GenZTokens.borderWidthThin,
                                  ),
                                ),
                                child: Text(
                                  'common.day_n'.tr(namedArgs: {'n': '$day'}),
                                  style: AppFonts.heading(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? onAccentSoft : inkSoft,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: GenZTokens.space3),

                    // Time option picker
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _timeOptions.length,
                        itemBuilder: (context, index) {
                          final time = _timeOptions[index];
                          final isSelected = _selectedTime == time;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTime = time;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? accentSoft : fill,
                                  borderRadius: BorderRadius.circular(
                                    GenZTokens.radiusButton,
                                  ),
                                  border: Border.all(
                                    color: isSelected ? accent : line,
                                    width: GenZTokens.borderWidthThin,
                                  ),
                                ),
                                child: Text(
                                  time,
                                  style: AppFonts.heading(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? onAccentSoft : inkSoft,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: GenZTokens.space3),

                    // Alter Ego Notes
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusInput,
                        ),
                        border: Border.all(
                          color: line,
                          width: GenZTokens.borderWidthThin,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _notesController,
                        style: AppFonts.body(fontSize: 14, color: ink),
                        decoration: InputDecoration(
                          hintText: 'itinerary.notes_hint'.tr(),
                          hintStyle: AppFonts.body(
                            color: inkSoft,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: GenZTokens.space4),
                    Divider(color: line),
                    const SizedBox(height: GenZTokens.space3),

                    // Add to Trip Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveToItinerary,
                        icon: _isSaving
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    onAccent,
                                  ),
                                ),
                              )
                            : Icon(
                                PhosphorIcons.plus(),
                                color: onAccent,
                                size: 18,
                              ),
                        label: Text(
                          'itinerary.add_to_trip'.tr(),
                          style: AppFonts.heading(
                            color: onAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: onAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusButton,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: GenZTokens.space4),
      ],
    );
  }
}
