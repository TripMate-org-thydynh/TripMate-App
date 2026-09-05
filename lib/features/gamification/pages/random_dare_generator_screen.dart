import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../trips/application/trips_providers.dart';

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
    'Chill 🥤': [
      'dares.d1'.tr(),
      'dares.d2'.tr(),
      'dares.d3'.tr(),
      'dares.d4'.tr(),
      'dares.d5'.tr(),
    ],
    'Chaos ⚡': [
      'dares.d6'.tr(),
      'dares.d7'.tr(),
      'dares.d8'.tr(),
      'dares.d9'.tr(),
      'dares.d10'.tr(),
    ],
    'Extreme 💀': [
      'dares.d11'.tr(),
      'dares.d12'.tr(),
      'dares.d13'.tr(),
      'dares.d14'.tr(),
      'dares.d15'.tr(),
    ],
  };

  String _selectedLevel = 'Chill 🥤';
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark
        ? const Color(0xFF1A1712)
        : const Color(0xFFFDF6D3);
    final Color inkColor = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final Color surfaceColor = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final Color activeColor = _selectedLevel == 'Chill 🥤'
        ? GenZTokens.green
        : _selectedLevel == 'Chaos ⚡'
        ? GenZTokens.orange
        : GenZTokens.red;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // Navigation bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: inkColor),
                    style: IconButton.styleFrom(
                      backgroundColor: surfaceColor.withValues(
                        alpha: isDark ? 0.3 : 0.8,
                      ),
                      shape: const CircleBorder(),
                      side: BorderSide(color: inkColor, width: 1.5),
                    ),
                  ),
                  Text(
                    'trip.mate',
                    style: AppFonts.heading(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: activeColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              // Title block
              Text(
                'games.dare_title'.tr(),
                style: AppFonts.heading(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: inkColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'games.dare_sub'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  fontSize: 13,
                  color: isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft,
                ),
              ),
              const SizedBox(height: 32),

              // Difficulty/Vibe level selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _daresByLevel.keys.map((level) {
                  final isSelected = _selectedLevel == level;
                  Color levelColor = GenZTokens.green;
                  if (level == 'Chaos ⚡') levelColor = GenZTokens.orange;
                  if (level == 'Extreme 💀') levelColor = GenZTokens.red;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: GestureDetector(
                      onTap: _isGenerating
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                _selectedLevel = level;
                                _currentDare =
                                    'games.dare_press'.tr();
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? levelColor : surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: inkColor, width: 2),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: inkColor,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          level,
                          style: AppFonts.heading(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? GenZTokens.ink : inkColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Comical warning text
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: activeColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedLevel == 'Chill 🥤'
                          ? Icons.check_circle_outline
                          : _selectedLevel == 'Chaos ⚡'
                          ? Icons.warning_amber_rounded
                          : Icons.dangerous_outlined,
                      color: activeColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedLevel == 'Chill 🥤'
                          ? 'games.mode_light'.tr()
                          : _selectedLevel == 'Chaos ⚡'
                          ? 'games.mode_chaos'.tr()
                          : 'games.mode_extreme'.tr(),
                      style: AppFonts.heading(
                        color: activeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Glowing Neo-Brutalist card
              Expanded(
                child: Transform.translate(
                  offset: Offset(_shakeX, _shakeY),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: inkColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(color: inkColor, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedLevel == 'Chill 🥤'
                              ? Icons.emoji_emotions_outlined
                              : _selectedLevel == 'Chaos ⚡'
                              ? Icons.bolt
                              : Icons.dangerous_outlined,
                          color: activeColor,
                          size: 64,
                        ),
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          opacity: _isGenerating ? 0.4 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Text(
                            _currentDare,
                            textAlign: TextAlign.center,
                            style: AppFonts.heading(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: inkColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Draw Dare button
              GestureDetector(
                onTap: _generateDare,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: inkColor, width: 2.5),
                    boxShadow: [
                      BoxShadow(color: inkColor, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGenerating)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              GenZTokens.ink,
                            ),
                          ),
                        )
                      else
                        Icon(Icons.casino, color: GenZTokens.ink, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        _isGenerating ? 'games.dare_drawing'.tr() : 'games.dare_draw_now'.tr(),
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: GenZTokens.ink,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
