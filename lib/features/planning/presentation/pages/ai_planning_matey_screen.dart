import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../premium/presentation/paywall_sheet.dart';
import '../../../ai/data/ai_repository.dart';
import '../../../gamification/data/games_repository.dart';
import '../../../trips/application/trips_providers.dart';

/// Màn "AI Itinerary Planner".
///
/// Trước đây màn này KHÔNG gọi AI: `initState` đợi 3 giây cho giống đang nghĩ
/// rồi hiện 2 gợi ý in cứng ("Still Cafe", "The Hill Station" kèm "98% Crew
/// Match"), giống hệt nhau cho mọi tài khoản và mọi chuyến. Nay gọi thật
/// `POST /ai/request` với `ITINERARY_PLAN`.
class AIPlanningMateyScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AIPlanningMateyScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  ConsumerState<AIPlanningMateyScreen> createState() =>
      _AIPlanningMateyScreenState();
}

class _AIPlanningMateyScreenState extends ConsumerState<AIPlanningMateyScreen>
    with TickerProviderStateMixin {
  bool _isGenerating = false;
  final List<String> _selectedParams = [
    '3-Day Weekend Trip',
    'Deep Chill',
    'Nature Focus',
  ];

  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _allParams = [
    {
      'name': '3-Day Weekend Trip',
      'labelKey': 'ai.param_weekend_trip',
      'icon': PhosphorIcons.calendarBlank(),
    },
    {
      'name': 'Deep Chill',
      'labelKey': 'ai.param_deep_chill',
      'icon': PhosphorIcons.leaf(),
    },
    {
      'name': 'High Energy',
      'labelKey': 'ai.param_high_energy',
      'icon': PhosphorIcons.fire(),
    },
    {
      'name': 'Nature Focus',
      'labelKey': 'ai.param_nature_focus',
      'icon': PhosphorIcons.tent(),
    },
    {
      'name': 'City Exploration',
      'labelKey': 'ai.param_city_exploration',
      'icon': PhosphorIcons.buildings(),
    },
  ];

  String _displayParamName(String name) {
    final found = _allParams.firstWhere(
      (p) => p['name'] == name,
      orElse: () => {},
    );
    if (found.isNotEmpty && (found['labelKey'] as String? ?? '').isNotEmpty) {
      return (found['labelKey'] as String).tr();
    }
    return name;
  }

  /// Hoạt động do AI trả về — rỗng cho tới khi người dùng bấm nút.
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  /// Gọi AI lên lịch trình theo các tiêu chí đang chọn.
  Future<void> _generate() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final tripId = ref.read(activeTripIdProvider);
      // Bat buoc kem diem den: BE chi truyen nguyen `prompt` sang Gemini, khong
      // tu doc chuyen tu tripId. Thieu cho nay thi AI len lich cho mot noi
      // khong lien quan (dang o chuyen Da Lat ma no goi y Moc Chau).
      final trip = ref
          .read(tripsProvider)
          .maybeWhen(
            data: (t) => t.isEmpty ? null : t.first,
            orElse: () => null,
          );
      final place = (trip?.destination?.trim().isNotEmpty ?? false)
          ? trip!.destination!.trim()
          : trip?.name;
      final where = place == null ? '' : ' tại $place';
      final items = await ref
          .read(mateyChatProvider)
          .itineraryPlan(
            prompt: _selectedParams.isEmpty
                ? 'Một chuyến đi cho nhóm bạn trẻ Việt$where.'
                : 'Chuyến đi cho nhóm bạn trẻ Việt$where, tiêu chí: '
                      '${_selectedParams.join(", ")}.',
            tripId: tripId,
          );
      if (!mounted) return;
      setState(() {
        _suggestions = items;
        _isGenerating = false;
      });
      if (items.isEmpty) showGlobalSnack('ai.plan_empty'.tr(), isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      // Hết lượt AI trong tháng → paywall nêu đúng con số, không phải một lỗi
      // 403 mà người dùng không hiểu vì sao.
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showAddCustomVibeDialog() {
    final textCtrl = TextEditingController();
    final isDark = widget.isDarkMode;
    final inkColor = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final cardColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final lineColor = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accentColor = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccentColor = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(GenZTokens.radiusCard),
            ),
            border: Border.all(
              color: lineColor,
              width: GenZTokens.borderWidthThin,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ai.custom_vibe_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: inkColor,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                autofocus: true,
                style: AppFonts.body(fontSize: 15, color: inkColor),
                decoration: InputDecoration(
                  hintText: 'ai.custom_vibe_hint'.tr(),
                  hintStyle: AppFonts.body(
                    fontSize: 15,
                    color: isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                    borderSide: BorderSide(
                      color: lineColor,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                    borderSide: BorderSide(
                      color: lineColor,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                    borderSide: BorderSide(
                      color: accentColor,
                      width: GenZTokens.borderWidth,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  final trimmed = value.trim();
                  if (trimmed.isNotEmpty) {
                    setState(() {
                      _allParams.add({
                        'name': trimmed,
                        'labelKey': '',
                        'icon': PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                      });
                      _selectedParams.add(trimmed);
                    });
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: onAccentColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                    ),
                  ),
                  onPressed: () {
                    final trimmed = textCtrl.text.trim();
                    if (trimmed.isNotEmpty) {
                      setState(() {
                        _allParams.add({
                          'name': trimmed,
                          'labelKey': '',
                          'icon': PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                        });
                        _selectedParams.add(trimmed);
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(
                    'ai.custom_vibe_add'.tr(),
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onAccentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
    final lineColor = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fillColor = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final bgColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final cardBg = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textMuted = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // CUSTOM GLASS APP BAR
                _buildAppBar(cardBg, lineColor, textPrimary),
                const SizedBox(height: 8),

                // MAIN SCROLL BODY
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE: Matey is planning...
                          Text(
                            _isGenerating
                                ? 'ai.plan_working'.tr()
                                : _suggestions.isEmpty
                                ? 'ai.plan_idle'.tr()
                                : 'ai.plan_done'.tr(),
                            style: AppFonts.heading(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // TRIP INFO CARD: Đà Lạt Chill
                          _buildTripInfoCard(
                            accent,
                            lineColor,
                            fillColor,
                            cardBg,
                            textPrimary,
                            textMuted,
                          ),
                          const SizedBox(height: 24),

                          // VIBE PARAMS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ai.plan_params'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: _showAddCustomVibeDialog,
                                child: Text(
                                  'ai.plan_edit_params'.tr(),
                                  style: AppFonts.body(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allParams.map((param) {
                              final paramName = param['name'] as String;
                              final isSelected = _selectedParams.contains(
                                paramName,
                              );
                              final label =
                                  ((param['labelKey'] as String?)?.isNotEmpty ??
                                          false)
                                      ? (param['labelKey'] as String).tr()
                                      : paramName;
                              final icon =
                                  param['icon'] as PhosphorIconData? ??
                                  PhosphorIcons.sparkle(
                                    PhosphorIconsStyle.fill,
                                  );
                              return GestureDetector(
                                onTap: _isGenerating
                                    ? null
                                    : () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedParams.remove(
                                              paramName,
                                            );
                                          } else {
                                            _selectedParams.add(paramName);
                                          }
                                        });
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: GenZTokens.durationFast,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? accentSoft : cardBg,
                                    borderRadius: BorderRadius.circular(
                                      GenZTokens.radiusPill,
                                    ),
                                    border: Border.all(
                                      color: isSelected ? accent : lineColor,
                                      width: isSelected
                                          ? GenZTokens.borderWidth
                                          : GenZTokens.borderWidthThin,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        icon,
                                        size: 14,
                                        color: isSelected ? accent : textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        label,
                                        style: AppFonts.heading(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? accent : textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // DRAFTING SECTION
                          Row(
                            children: [
                              Text(
                                'ai.plan_section'.tr(),
                                style: AppFonts.heading(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (_isGenerating)
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (_, child) => Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accent.withValues(
                                        alpha:
                                            0.5 + 0.5 * _pulseController.value,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ITINERARY ITEMS
                          ..._suggestions.asMap().entries.map((entry) {
                            return _buildTimelineItem(
                              entry.value,
                              lineColor,
                              fillColor,
                              cardBg,
                              textPrimary,
                              textMuted,
                              entry.key,
                            );
                          }),

                          if (_suggestions.isEmpty && !_isGenerating)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(
                                  GenZTokens.radiusCard,
                                ),
                                border: Border.all(
                                  color: lineColor,
                                  width: GenZTokens.borderWidthThin,
                                ),
                              ),
                              child: Text(
                                'ai.plan_hint'.tr(),
                                textAlign: TextAlign.center,
                                style: AppFonts.body(
                                  fontSize: 13,
                                  color: textMuted,
                                  height: 1.45,
                                ),
                              ),
                            ),

                          // Third item placeholder (still loading)
                          if (_isGenerating)
                            _buildLoadingPlaceholder(
                              lineColor,
                              fillColor,
                              cardBg,
                            ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FLOATING BOTTOM ACTION
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingAction(
              accent,
              onAccent,
              lineColor,
              cardBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    Color cardBg,
    Color lineColor,
    Color textPrimary,
  ) {
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.9),
          border: Border(
            bottom: BorderSide(
              color: lineColor,
              width: GenZTokens.borderWidthThin,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                PhosphorIcons.caretLeft(),
                color: textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'trip.mate',
              style: AppFonts.heading(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Icon(PhosphorIcons.bell(), color: textPrimary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoCard(
    Color accent,
    Color lineColor,
    Color fillColor,
    Color cardBg,
    Color textPrimary,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: lineColor,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref
                    .watch(tripsProvider)
                    .maybeWhen(
                      data: (t) => t.isEmpty ? null : t.first.name,
                      orElse: () => null,
                    ) ??
                'ai.plan_no_trip'.tr(),
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.calendarBlank(), size: 14, color: textMuted),
                  const SizedBox(width: 4),
                  Text(
                    _selectedParams.isEmpty
                        ? 'ai.plan_no_filter'.tr()
                        : _displayParamName(_selectedParams.first),
                    style: AppFonts.body(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Vibe sliders
          _buildVibeSlider(
            'ai.param_deep_chill'.tr(),
            'ai.param_high_energy'.tr(),
            _selectedParams.contains('High Energy') ? 0.75 : 0.25,
            accent,
            fillColor,
            textMuted,
          ),
          const SizedBox(height: 8),
          _buildVibeSlider(
            'ai.param_nature_focus'.tr(),
            'ai.param_city_exploration'.tr(),
            _selectedParams.contains('City Exploration') ? 0.75 : 0.25,
            GenZTokens.chart1,
            fillColor,
            textMuted,
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildVibeSlider(
    String left,
    String right,
    double value,
    Color activeColor,
    Color trackColor,
    Color textMuted,
  ) {
    return Row(
      children: [
        Text(left, style: AppFonts.body(fontSize: 12, color: textMuted)),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(right, style: AppFonts.body(fontSize: 12, color: textMuted)),
      ],
    );
  }

  Widget _buildTimelineItem(
    Map<String, dynamic> item,
    Color lineColor,
    Color fillColor,
    Color cardBg,
    Color textPrimary,
    Color textMuted,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: lineColor,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag indicator
          Column(
            children: [
              Icon(
                PhosphorIcons.dotsSixVertical(),
                color: textMuted,
                size: 20,
              ),
              const SizedBox(height: 4),
              // Time bubble
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: lineColor,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  item['time'] as String,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['location'] as String,
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['reason'] as String,
                  style: AppFonts.body(
                    fontSize: 13,
                    color: textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: lineColor,
                            width: GenZTokens.borderWidthThin,
                          ),
                        ),
                        child: Text(
                          item['dayTitle'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
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
    );
  }

  Widget _buildLoadingPlaceholder(
    Color lineColor,
    Color fillColor,
    Color cardBg,
  ) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: lineColor,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.dotsSixVertical(),
              color: fillColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: fillColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAction(
    Color accent,
    Color onAccent,
    Color lineColor,
    Color cardBg,
  ) {
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: cardBg.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: lineColor,
              width: GenZTokens.borderWidthThin,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: _isGenerating ? null : _generate,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isGenerating
                      ? PhosphorIcons.circleNotch()
                      : PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                  color: onAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isGenerating
                      ? 'ai.plan_working'.tr()
                      : _suggestions.isEmpty
                      ? 'ai.plan_cta'.tr()
                      : 'ai.plan_cta_again'.tr(),
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
