import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../trips/application/trips_providers.dart';
import '../data/games_repository.dart';

class RandomDareGeneratorScreen extends ConsumerStatefulWidget {
  const RandomDareGeneratorScreen({super.key});

  @override
  ConsumerState<RandomDareGeneratorScreen> createState() =>
      _RandomDareGeneratorScreenState();
}

class _RandomDareGeneratorScreenState
    extends ConsumerState<RandomDareGeneratorScreen> {
  /// Danh sách thử thách theo mức độ.
  ///
  /// Phải là **getter**, không phải `static` field: một field tĩnh chỉ khởi tạo
  /// một lần nên sẽ giữ nguyên bản dịch của ngôn ngữ lúc mở app đầu tiên —
  /// người dùng đổi VI/EN thì danh sách vẫn kẹt ở ngôn ngữ cũ.
  Map<String, List<String>> get _daresByLevel => {
    'chill': [
      'dares.d1'.tr(),
      'dares.d2'.tr(),
      'dares.d3'.tr(),
      'dares.d4'.tr(),
      'dares.d5'.tr(),
    ],
    'chaos': [
      'dares.d6'.tr(),
      'dares.d7'.tr(),
      'dares.d8'.tr(),
      'dares.d9'.tr(),
      'dares.d10'.tr(),
    ],
    'extreme': [
      'dares.d11'.tr(),
      'dares.d12'.tr(),
      'dares.d13'.tr(),
      'dares.d14'.tr(),
      'dares.d15'.tr(),
    ],
  };

  String _selectedLevel = 'chill';
  late String _currentDare = 'games.dare_press_red'.tr();
  bool _isGenerating = false;
  double _shakeX = 0.0;
  double _shakeY = 0.0;

  /// Tên một thành viên thật trong chuyến, hoặc `null` nếu chưa có chuyến.
  ///
  /// Trước đây fallback là 'Lê Minh' — một người không hề tồn tại, khiến thử
  /// thách vô nghĩa với nhóm chưa có thành viên nào.
  String? _randomFriend(WidgetRef ref) {
    return ref
        .read(tripsProvider)
        .maybeWhen(
          data: (trips) {
            if (trips.isEmpty || trips.first.members.isEmpty) return null;
            final members = trips.first.members;
            return members[Random().nextInt(members.length)].name;
          },
          orElse: () => null,
        );
  }

  Future<void> _generateDare() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
    });

    final random = Random();
    final friend = _randomFriend(ref);
    // Chưa biết thành viên nào thì bỏ các thử thách cần đích danh một người.
    final all = _daresByLevel[_selectedLevel]!;
    final currentList = friend == null
        ? all.where((d) => !d.contains('{friend}')).toList()
        : all;
    if (currentList.isEmpty) {
      setState(() {
        _isGenerating = false;
        _currentDare = 'games.dare_need_squad'.tr();
      });
      return;
    }

    // Slot machine deceleration effect: 12 ticks
    const ticksCount = 12;
    for (int i = 0; i < ticksCount; i++) {
      await Future.delayed(Duration(milliseconds: 60 + i * 22));
      if (!mounted) return;

      final rawDare = currentList[random.nextInt(currentList.length)];

      setState(() {
        _currentDare = rawDare.replaceAll('{friend}', friend ?? '');
        _shakeX = (random.nextDouble() * 12) - 6;
        _shakeY = (random.nextDouble() * 12) - 6;
      });
      HapticFeedback.lightImpact();
    }

    setState(() {
      _isGenerating = false;
      _shakeX = 0.0;
      _shakeY = 0.0;
    });

    final tripId = ref.read(activeTripIdProvider);
    if (tripId != null) {
      unawaited(
        ref
            .read(gamesRepositoryProvider)
            .createSession(
              tripId,
              gameType: 'TRUTH_OR_DARE',
              state: {'dare': _currentDare, 'level': _selectedLevel},
            )
            .then((_) {
              ref.invalidate(squadXpProvider(tripId));
            })
            .catchError((_) {}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final Color inkColor = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final Color inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final Color surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final Color lineColor = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final Color fillColor = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final Color accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final Color onAccent =
        isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final Color accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;

    final Color semanticColor = _selectedLevel == 'chill'
        ? (isDark ? GenZTokens.successDark : GenZTokens.success)
        : _selectedLevel == 'chaos'
        ? (isDark ? GenZTokens.warningDark : GenZTokens.warning)
        : (isDark ? GenZTokens.dangerDark : GenZTokens.danger);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GenZTokens.space4,
            vertical: GenZTokens.space2,
          ),
          child: Column(
            children: [
              // Navigation bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(PhosphorIcons.arrowLeft(), color: inkColor),
                    style: IconButton.styleFrom(
                      backgroundColor: fillColor,
                      shape: const CircleBorder(),
                      side: BorderSide(
                        color: lineColor,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                  ),
                  Text(
                    'trip.mate',
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: accent,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: GenZTokens.space5),

              // Title block
              Text(
                'games.dare_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: inkColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: GenZTokens.space2),
              Text(
                'games.dare_sub'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13,
                  color: inkSoft,
                ),
              ),
              const SizedBox(height: GenZTokens.space5),

              // Difficulty/Vibe level selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _daresByLevel.keys.map((level) {
                  final isSelected = _selectedLevel == level;
                  final levelIcon = level == 'chill'
                      ? PhosphorIcons.smiley()
                      : level == 'chaos'
                      ? PhosphorIcons.lightning(PhosphorIconsStyle.fill)
                      : PhosphorIcons.skull(PhosphorIconsStyle.fill);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: _isGenerating
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedLevel = level;
                                _currentDare = 'games.dare_press'.tr();
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? accentSoft : fillColor,
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
                              levelIcon,
                              size: 16,
                              color: isSelected ? accent : inkSoft,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'games.dare_level_$level'.tr(),
                              style: AppFonts.heading(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected ? accent : inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: GenZTokens.space5),

              // Warning badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: semanticColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: semanticColor.withValues(alpha: 0.4),
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedLevel == 'chill'
                          ? PhosphorIcons.checkCircle()
                          : _selectedLevel == 'chaos'
                          ? PhosphorIcons.warning()
                          : PhosphorIcons.warningOctagon(),
                      color: semanticColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedLevel == 'chill'
                          ? 'games.mode_light'.tr()
                          : _selectedLevel == 'chaos'
                          ? 'games.mode_chaos'.tr()
                          : 'games.mode_extreme'.tr(),
                      style: AppFonts.heading(
                        color: semanticColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GenZTokens.space4),

              // Card
              Expanded(
                child: Transform.translate(
                  offset: Offset(_shakeX, _shakeY),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(GenZTokens.space5),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusCard,
                      ),
                      border: Border.all(
                        color: lineColor,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedLevel == 'chill'
                              ? PhosphorIcons.smiley()
                              : _selectedLevel == 'chaos'
                              ? PhosphorIcons.lightning(
                                  PhosphorIconsStyle.fill,
                                )
                              : PhosphorIcons.skull(PhosphorIconsStyle.fill),
                          color: semanticColor,
                          size: 56,
                        ),
                        const SizedBox(height: GenZTokens.space5),
                        AnimatedOpacity(
                          opacity: _isGenerating ? 0.4 : 1.0,
                          duration: const Duration(
                            milliseconds: GenZTokens.durationFast,
                          ),
                          child: Text(
                            _currentDare,
                            textAlign: TextAlign.center,
                            style: AppFonts.heading(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: inkColor,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GenZTokens.space5),

              // Draw Dare button
              GestureDetector(
                onTap: _generateDare,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGenerating)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(onAccent),
                          ),
                        )
                      else
                        Icon(
                          PhosphorIcons.diceFive(PhosphorIconsStyle.fill),
                          color: onAccent,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _isGenerating
                            ? 'games.dare_drawing'.tr()
                            : 'games.dare_draw_now'.tr(),
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
              const SizedBox(height: GenZTokens.space3),
            ],
          ),
        ),
      ),
    );
  }
}
