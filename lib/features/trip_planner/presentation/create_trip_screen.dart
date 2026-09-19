import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/network/api_exception.dart';
import '../../trips/application/trips_providers.dart';
import '../../trips/presentation/join_trip_screen.dart';
import '../../premium/presentation/paywall_sheet.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final bool hideNavigationBar;

  /// Callback gọi sau khi tạo chuyến thành công — dashboard dùng để switch tab.
  final VoidCallback? onTripCreated;

  const CreateTripScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    this.hideNavigationBar = false,
    this.onTripCreated,
  });

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCoverId = 'cover-1';
  String? _vibe;

  // Phần tử thứ 2 là KEY i18n, không phải nhãn — dịch tại chỗ render bằng
  // `.tr()` để đổi ngôn ngữ trong app cập nhật ngay (const map thì không thể
  // gọi .tr() lúc khai báo).
  static final List<(String, String, IconData)> _vibes = [
    ('CHILL', 'trips.vibe_chill', PhosphorIcons.cloud()),
    ('PARTY', 'trips.vibe_party', PhosphorIcons.confetti()),
    ('ADVENTURE', 'trips.vibe_adventure', PhosphorIcons.mountains()),
    ('FOODIE', 'trips.vibe_foodie', PhosphorIcons.forkKnife()),
    ('CULTURE', 'trips.vibe_culture', PhosphorIcons.bank()),
    ('AESTHETIC', 'trips.vibe_aesthetic', PhosphorIcons.camera()),
  ];
  bool _showEmptyState = true;
  bool _busy = false; // Đang gọi API tạo trip

  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;

  bool _isDark(BuildContext context) =>
      widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

  Color _bgOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.creamDark : GenZTokens.cream;
  Color _surfaceOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.paperDark : GenZTokens.paper;
  Color _lineOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.lineDark : GenZTokens.line;
  Color _fillOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.fillDark : GenZTokens.fill;
  Color _accentOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  Color _onAccentOf(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  Color _accentSoftOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
  Color _textPriOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkDark : GenZTokens.ink;
  Color _textSecOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
  Color _dangerOf(BuildContext context) =>
      _isDark(context) ? GenZTokens.dangerDark : GenZTokens.danger;

  final List<Map<String, String>> _covers = const [
    {
      'id': 'cover-1',
      'title': 'tokyo drift',
      'image': 'assets/images/cover_tokyo_drift.webp',
    },
    {
      'id': 'cover-2',
      'title': 'island time',
      'image': 'assets/images/cover_island_time.webp',
    },
    {
      'id': 'cover-3',
      'title': 'alpine glow',
      'image': 'assets/images/cover_alpine_glow.webp',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Floating avatar animations
    _floatController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _floatController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Gọi API tạo trip và switch về tab Home khi xong.
  Future<void> _submitCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trips.name_empty'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trips.dates_required'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final selectedCover = _covers.firstWhere(
        (c) => c['id'] == _selectedCoverId,
        orElse: () => _covers.first,
      );
      final budget = double.tryParse(
        _budgetController.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      await ref
          .read(tripsProvider.notifier)
          .create(
            name: name,
            destination: _destinationController.text.trim().isEmpty
                ? null
                : _destinationController.text.trim(),
            startDate: _startDate!,
            endDate: _endDate!,
            coverImage: selectedCover['image'],
            budget: budget,
            vibe: _vibe,
            theme: selectedCover['id'],
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trips.created_ok'.tr(namedArgs: {'name': name})),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Reset form và switch về định hướng empty state
      setState(() {
        _nameController.clear();
        _destinationController.clear();
        _budgetController.clear();
        _vibe = null;
        _startDate = null;
        _endDate = null;
        _showEmptyState = true;
        _busy = false;
      });
      widget.onTripCreated?.call();
    } on ApiException catch (e) {
      if (!mounted) return;
      if (await PaywallSheet.maybeShow(context, e)) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: _dangerOf(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _busy = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trips.generic_error_retry'.tr()),
          backgroundColor: _dangerOf(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final bg = _bgOf(context);
    final surface = _surfaceOf(context);
    final line = _lineOf(context);
    final fill = _fillOf(context);
    final accent = _accentOf(context);
    final onAccent = _onAccentOf(context);
    final accentSoft = _accentSoftOf(context);
    final textPri = _textPriOf(context);
    final textSec = _textSecOf(context);

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: _showEmptyState
            ? _buildEmptyState(
                context,
                isDark,
                bg,
                surface,
                line,
                fill,
                accent,
                onAccent,
                accentSoft,
                textPri,
                textSec,
              )
            : _buildTripForm(
                context,
                isDark,
                bg,
                surface,
                line,
                fill,
                accent,
                onAccent,
                accentSoft,
                textPri,
                textSec,
              ),
      ),
      bottomNavigationBar: widget.hideNavigationBar
          ? null
          : _buildBottomNavigationBar(
              context,
              isDark,
              line,
              surface,
              accent,
              accentSoft,
              textPri,
              textSec,
            ),
    );
  }

  // SCREEN 29: EMPTY STATE - NO TRIPS
  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color bg,
    Color surface,
    Color line,
    Color fill,
    Color accent,
    Color onAccent,
    Color accentSoft,
    Color textPri,
    Color textSec,
  ) {
    return Container(
      key: const ValueKey('empty_state_view'),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCustomAppBar(context, isDark, bg, line, textPri, textSec),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    // Diamond Vibe Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: fill,
                        border: Border.all(color: line, width: 1),
                      ),
                      child: Icon(
                        PhosphorIcons.diamond(PhosphorIconsStyle.fill),
                        size: 38,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title "trip.mate"
                    Text(
                      'trip.mate',
                      style: AppFonts.heading(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: textPri,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Roast Subtitle: "time to make financially irresponsible memories."
                    Text(
                      'trips.roast_tagline'.tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPri,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Body text: "Your chaos squad is missing. No trips planned yet."
                    Text(
                      'trips.no_trips_body'.tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 14,
                        color: textSec,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // ACTION BUTTON: "start the chaos" (Single Accent CTA)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showEmptyState = false;
                        });
                      },
                      child: Container(
                        height: 48,
                        constraints: const BoxConstraints(minWidth: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                              color: onAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'trips.start_the_chaos'.tr(),
                              style: AppFonts.heading(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: onAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STANDARD TRIP CREATION FORM VIEW
  Widget _extraField(
    TextEditingController c,
    String hint,
    IconData icon,
    Color textPri,
    Color textSec,
    Color fill,
    Color line, {
    bool number = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: line, width: 1),
      ),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        // Lọc chữ khi ô ấy là ô số — keyboardType chỉ gợi ý bàn phím.
        inputFormatters: number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: AppFonts.body(color: textPri, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppFonts.body(
            color: textSec,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: textSec,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTripForm(
    BuildContext context,
    bool isDark,
    Color bg,
    Color surface,
    Color line,
    Color fill,
    Color accent,
    Color onAccent,
    Color accentSoft,
    Color textPri,
    Color textSec,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      key: const ValueKey('trip_form_view'),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCustomAppBar(context, isDark, bg, line, textPri, textSec),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    Text(
                      'trips.set_the_vibe'.tr(),
                      style: AppFonts.heading(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: textPri,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'trips.where_to_next_form'.tr(),
                      style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textSec,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Inputs Form
                    Column(
                      children: [
                        // Trip Name input
                        Container(
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: line, width: 1),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: AppFonts.heading(
                              color: textPri,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'trips.name_your_trip'.tr(),
                              hintStyle: AppFonts.body(
                                color: textSec,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Dates Split Row
                        Row(
                          children: [
                            // Start Date
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: fill,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: line, width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _startDate == null
                                            ? 'trips.start_date'.tr()
                                            : _formatDate(_startDate),
                                        style: AppFonts.body(
                                          color: _startDate == null
                                              ? textSec
                                              : textPri,
                                          fontSize: 13,
                                          fontWeight: _startDate == null
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        PhosphorIcons.calendar(),
                                        size: 18,
                                        color: textSec,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // End Date
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: fill,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: line, width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _endDate == null
                                            ? 'trips.end_date'.tr()
                                            : _formatDate(_endDate),
                                        style: AppFonts.body(
                                          color: _endDate == null
                                              ? textSec
                                              : textPri,
                                          fontSize: 13,
                                          fontWeight: _endDate == null
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        PhosphorIcons.calendarCheck(),
                                        size: 18,
                                        color: textSec,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Cinematic Cover Selection
                    Text(
                      'trips.cover_mood'.tr(),
                      style: AppFonts.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _covers.length,
                        itemBuilder: (context, index) {
                          final cover = _covers[index];
                          final isSelected = _selectedCoverId == cover['id'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCoverId = cover['id']!;
                              });
                            },
                            child: Semantics(
                              button: true,
                              selected: isSelected,
                              label: 'trips.cover_accessibility'.tr(
                                namedArgs: {'title': cover['title']!},
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? accent : line,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ExcludeSemantics(
                                            child: cover['image']!.startsWith('assets/')
                                                ? Image.asset(
                                                    cover['image']!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: cover['image']!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) =>
                                                        Container(
                                                          color: fill,
                                                          child: const Center(
                                                            child: SizedBox(
                                                              width: 20,
                                                              height: 20,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    errorWidget: (context, url, error) =>
                                                        Container(
                                                          color: fill,
                                                        ),
                                                  ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black87,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: accent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                PhosphorIcons.check(PhosphorIconsStyle.bold),
                                                color: onAccent,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          bottom: 12,
                                          left: 12,
                                          right: 12,
                                          child: Text(
                                            cover['title']!,
                                            style: AppFonts.heading(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Điểm đến
                    Text(
                      'trips.destination'.tr(),
                      style: AppFonts.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _extraField(
                      _destinationController,
                      'trips.destination_hint'.tr(),
                      PhosphorIcons.mapPin(),
                      textPri,
                      textSec,
                      fill,
                      line,
                    ),
                    const SizedBox(height: 24),

                    // Vibe chuyến đi
                    Text(
                      'trips.vibe'.tr(),
                      style: AppFonts.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _vibes.map((v) {
                        final sel = _vibe == v.$1;
                        return GestureDetector(
                          onTap: () => setState(() => _vibe = sel ? null : v.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: sel ? accentSoft : fill,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: sel ? accent : line,
                                width: sel ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  v.$3,
                                  size: 15,
                                  color: sel ? accent : textSec,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  v.$2.tr(),
                                  style: AppFonts.body(
                                    fontSize: 13,
                                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                                    color: sel ? accent : textPri,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Ngân sách dự kiến
                    Text(
                      'trips.budget_per_head'.tr(),
                      style: AppFonts.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: textPri,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _extraField(
                      _budgetController,
                      'trips.budget_hint'.tr(),
                      PhosphorIcons.wallet(),
                      textPri,
                      textSec,
                      fill,
                      line,
                      number: true,
                    ),
                    const SizedBox(height: 24),

                    // Invite Crew Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: line, width: 1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'trips.invite_the_crew'.tr(),
                              style: AppFonts.heading(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: textPri,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // QR Box & Floating profiles
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Middle QR Code
                                  Container(
                                    width: 140,
                                    height: 140,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: fill,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: line,
                                        width: 1,
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: line,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          PhosphorIcons.qrCode(),
                                          size: 54,
                                          color: textSec,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Avatar 1: Minh Nhật (Left-Floating)
                                  AnimatedBuilder(
                                    animation: _floatController1,
                                    builder: (context, child) {
                                      final offset =
                                          math.sin(
                                            _floatController1.value * math.pi * 2,
                                          ) *
                                          8;
                                      return Positioned(
                                        left: screenWidth * 0.08,
                                        top: 15 + offset,
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: surface,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(22),
                                            child: Semantics(
                                              label: 'trips.avatar_minh_nhat'.tr(),
                                              image: true,
                                              child: 'assets/images/avatar_minh_nhat.webp'
                                                      .startsWith('assets/')
                                                  ? Image.asset(
                                                      'assets/images/avatar_minh_nhat.webp',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl:
                                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvvXCbKfRu2mzCCcj60yFk9h01zv9Y9WCkOQodi1hFQWMDsFvlCdf6jjjGOJkkl8FtzL01xY7osHpDkE0cA4vAEJYAKtdufhxCA2V2Ezx3UxPouPfHiBWB9v8tBozIG4GJGcSYsBIre_8YrIPmbWDS42Vxclf6sWOOS4PnEmVECcbLfzVGsnFdNZ5w06zWYpaDAVxS8TEJNwVCIVCAhsfKriZh6Xnp_NuTNkK5Z1_Be50boL73EHsRRxcCJDOK7t5yH1MbugEcUzBo',
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) =>
                                                          ExcludeSemantics(
                                                            child: Container(
                                                              color: fill,
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (context, url, error) =>
                                                              Icon(PhosphorIcons.user(), color: textSec),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Avatar 2: Thảo Ly (Right-Floating)
                                  AnimatedBuilder(
                                    animation: _floatController2,
                                    builder: (context, child) {
                                      final offset =
                                          math.cos(
                                            _floatController2.value * math.pi * 2,
                                          ) *
                                          10;
                                      return Positioned(
                                        right: screenWidth * 0.06,
                                        top: 40 + offset,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: surface,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(25),
                                            child: Semantics(
                                              label: 'trips.avatar_thao_ly'.tr(),
                                              image: true,
                                              child: 'assets/images/avatar_thao_ly.webp'
                                                      .startsWith('assets/')
                                                  ? Image.asset(
                                                      'assets/images/avatar_thao_ly.webp',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl:
                                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAUx6IWymkdIblIS-PiUXn_mSj3uaQEevZF_NDNmvxyQC_lqIFJV6bEkhsaomN1IGAWDiV8r-WgtyFEellRP6Pp6INrq2wUdr89T0QFCJfhrJgE-QWeK3c9XJYUq4ig9xKwtBV33Y90QnVSQB1LRcpgjjd-PrgIir8pBrgu0QqwZh7gn8dhEKS81oVf2yzui-bPxwJBT1Foj69OGa6FipK7ET-Ss-NVPCk1xxqAXeCcJwff74QgE7lTc_idtIGq-AmuznOK7n3hAVJK',
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) =>
                                                          ExcludeSemantics(
                                                            child: Container(
                                                              color: fill,
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (context, url, error) =>
                                                              Icon(PhosphorIcons.user(), color: textSec),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Avatar 3: User (Bottom-Floating)
                                  AnimatedBuilder(
                                    animation: _floatController3,
                                    builder: (context, child) {
                                      final offset =
                                          math.sin(
                                            _floatController3.value * math.pi * 2,
                                          ) *
                                          6;
                                      return Positioned(
                                        left: screenWidth * 0.15,
                                        bottom: 15 + offset,
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: surface,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(19),
                                            child: Image.asset(
                                              'assets/images/avatar_user.webp',
                                              fit: BoxFit.cover,
                                              semanticLabel: 'trips.avatar_user'.tr(),
                                              errorBuilder:
                                                  (context, error, stackTrace) =>
                                                      Icon(PhosphorIcons.user(), color: textSec),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'trips.or_share_link'.tr(),
                              style: AppFonts.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Primary Action Button "initialize" (Single Accent CTA)
                    GestureDetector(
                      onTap: _busy ? null : _submitCreate,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _busy ? 0.7 : 1.0,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: accent,
                          ),
                          child: _busy
                              ? Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: onAccent,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'trips.initialize'.tr(),
                                      style: AppFonts.heading(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: onAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      PhosphorIcons.rocketLaunch(
                                        PhosphorIconsStyle.fill,
                                      ),
                                      color: onAccent,
                                      size: 18,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: widget.hideNavigationBar ? 32 : 100,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // APP BAR
  Widget _buildCustomAppBar(
    BuildContext context,
    bool isDark,
    Color bg,
    Color line,
    Color textPri,
    Color textSec,
  ) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: line, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: line,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/avatar_user.webp',
                fit: BoxFit.cover,
                semanticLabel: 'trips.avatar_user'.tr(),
                errorBuilder: (context, error, stackTrace) =>
                    Icon(PhosphorIcons.circleDashed(), size: 18, color: textSec),
              ),
            ),
          ),
          // Brand
          Text(
            'trip.mate',
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: textPri,
              letterSpacing: -1,
            ),
          ),
          // Actions
          Row(
            children: [
              IconButton(
                tooltip: 'theme.toggle'.tr(),
                icon: Icon(
                  isDark ? PhosphorIcons.sun() : PhosphorIcons.moon(),
                  color: textPri,
                  size: 20,
                ),
                onPressed: widget.onThemeToggle,
              ),
              const SizedBox(width: 4),
              // Lối vào luồng tham gia chuyến bằng mã mời / link chia sẻ.
              IconButton(
                tooltip: 'trips.join_by_code'.tr(),
                icon: Icon(
                  PhosphorIcons.ticket(),
                  color: textPri,
                  size: 20,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JoinTripScreen(isDarkMode: isDark),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar(
    BuildContext context,
    bool isDark,
    Color line,
    Color surface,
    Color accent,
    Color accentSoft,
    Color textPri,
    Color textSec,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: line, width: 1),
            boxShadow: GenZTokens.hardShadow(textPri, isDark),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                PhosphorIcons.plusCircle(PhosphorIconsStyle.fill),
                'add_circle',
                !_showEmptyState,
                accent,
                accentSoft,
                textSec,
                onTap: () {
                  setState(() {
                    _showEmptyState = false;
                  });
                },
              ),
              _buildNavItem(
                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                'auto_awesome',
                _showEmptyState,
                accent,
                accentSoft,
                textSec,
                onTap: () {
                  setState(() {
                    _showEmptyState = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    Color accent,
    Color accentSoft,
    Color textSec, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? accent : textSec,
          size: 22,
        ),
      ),
    );
  }
}
