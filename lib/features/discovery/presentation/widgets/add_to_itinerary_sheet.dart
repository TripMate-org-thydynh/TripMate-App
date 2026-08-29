import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';
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
  String _activeTag = '🌿 Chill';

  late AnimationController _successController;
  late Animation<double> _scaleAnimation;

  final List<String> _tags = ['🌿 Chill', '🔥 Party', '🍜 Foodie', '📸 Iconic'];

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
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
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
  ///
  /// Trước đây bộ chọn ngày cứng là `[1, 2, 3]` bất kể chuyến dài bao nhiêu.
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
      // Lịch trình đã đổi — buộc màn lịch trình tải lại.
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
      // Nói thẳng là lưu hỏng, thay vì hiện dấu tick như trước.
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;

    final primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B);
    final secondaryColor = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFFFFD84D);
    final bgColor = isDark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
    final surfaceColor = isDark
        ? const Color(0xFF262019)
        : const Color(0xFFFFFDF5);
    final textColor = isDark
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);
    final subTextColor = isDark
        ? const Color(0xFFB8AE9C)
        : const Color(0xFF4A453E);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 0,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _showSuccess
                      ? _buildSuccessView(primaryColor, isDark, textColor)
                      : _buildFormView(
                          theme,
                          primaryColor,
                          secondaryColor,
                          surfaceColor,
                          textColor,
                          subTextColor,
                          isDark,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessView(Color primaryColor, bool isDark, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 50),
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1FA85C).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF1FA85C), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1FA85C).withValues(alpha: 0.25),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF1FA85C),
              size: 54,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Added to Trip! ✨',
          style: AppFonts.heading(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${widget.placeName} scheduled for Day $_selectedDay at $_selectedTime.',
          textAlign: TextAlign.center,
          style: AppFonts.body(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildFormView(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slide drag handle
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Header Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Find your vibe',
              style: AppFonts.heading(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Voice Search Placeholder Bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.search, color: subTextColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search spots, cafes, activities...',
                  style: AppFonts.body(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                height: 24,
                width: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.12),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Icon(Icons.mic, color: primaryColor, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tag Filters List (Horizontal)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _tags.map((tag) {
              final isActive = _activeTag == tag;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTag = tag;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? primaryColor.withValues(alpha: 0.15)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : Colors.white),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isActive
                            ? primaryColor
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black12),
                        width: isActive ? 1.5 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.2),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      tag,
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? primaryColor
                            : textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Section Title: Hidden Gems
        Row(
          children: [
            Icon(Icons.auto_awesome, color: primaryColor, size: 18),
            const SizedBox(width: 6),
            Text(
              'Hidden Gems',
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Detailed Cafe Card representing widget.placeName / The Hill Station
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Photo
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800&auto=format&fit=crop&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Darken overlay
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Tags Overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: secondaryColor,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Café & Deli',
                            style: AppFonts.heading(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: AppFonts.heading(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Card details + Schedule form parameters
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.placeName.isNotEmpty
                          ? widget.placeName
                          : 'The Hill Station',
                      style: AppFonts.heading(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.map_outlined, color: subTextColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          widget.placeAddress.isNotEmpty
                              ? widget.placeAddress
                              : 'Hội An, Vietnam',
                          style: AppFonts.body(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'A moody, atmospheric spot known for artisanal deli cuts, local craft beers, and a perfectly chilled vibe.',
                      style: AppFonts.body(
                        fontSize: 12,
                        color: subTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    const SizedBox(height: 10),

                    // Inline Schedule pickers
                    Text(
                      'Schedule Spot',
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Days selector
                    Row(
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
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withValues(alpha: 0.15)
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : Colors.black.withValues(
                                              alpha: 0.03,
                                            )),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Day $day',
                                style: AppFonts.heading(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? primaryColor
                                      : subTextColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Time option picker
                    SizedBox(
                      height: 34,
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
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? secondaryColor.withValues(alpha: 0.15)
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.04,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.03,
                                              )),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? secondaryColor
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  time,
                                  style: AppFonts.heading(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? secondaryColor
                                        : subTextColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Alter Ego Notes
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _notesController,
                        style: AppFonts.body(
                          fontSize: 11,
                          color: textColor,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Add aesthetic / photo notes... 📸✨',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Divider(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    const SizedBox(height: 10),

                    // Crew also down to go + Gradient Add to Trip button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Also down to go crew stack
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Also down to go',
                              style: AppFonts.heading(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                SizedBox(
                                  width: 48,
                                  height: 24,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        child: CircleAvatar(
                                          radius: 10,
                                          backgroundColor:
                                              Colors.amber.shade400,
                                          child: Text(
                                            'T',
                                            style: AppFonts.body(
                                              fontSize: 8,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        child: CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.blue.shade400,
                                          child: Text(
                                            'L',
                                            style: AppFonts.body(
                                              fontSize: 8,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 20,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDark
                                                ? const Color(0xFF262019)
                                                : Colors.white,
                                            border: Border.all(
                                              color: primaryColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '+2',
                                              style: AppFonts.body(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                color: primaryColor,
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
                          ],
                        ),

                        // Add to Trip Button (Kinetic Gradient)
                        GestureDetector(
                          onTap: _isSaving ? null : _saveToItinerary,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Add to Trip',
                                        style: AppFonts.heading(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section Title: More spots nearby
        Text(
          'More spots nearby',
          style: AppFonts.heading(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),

        // Nearby spot card: Morning Glory Original
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Spot image mockup
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1541188111-1e0d58224f24?w=200&auto=format&fit=crop&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Morning Glory Original',
                      style: AppFonts.heading(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Iconic central Vietnamese street food. \$\$',
                      style: AppFonts.body(
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk,
                          color: secondaryColor,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '8 min',
                          style: AppFonts.body(
                            fontSize: 10,
                            color: secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Add Circle Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Selected Morning Glory! 🍲 Customise day and time to add.",
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.02),
                  ),
                  child: Icon(Icons.add, color: subTextColor, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
