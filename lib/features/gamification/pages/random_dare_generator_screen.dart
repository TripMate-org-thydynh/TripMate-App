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
  static const Map<String, List<String>> _daresByLevel = {
    'Chill 🥤': [
      'Uống hết ly nước này trong 5 giây! 🍺',
      'Hát một bài hát thiếu nhi bằng giọng em bé! 🎤',
      'Kể một trò đùa dở nhất mà bạn biết! 🤡',
      'Bắt chước âm thanh của 3 con vật khác nhau! 🐶🐱🐔',
      'Kể một sự thật đáng xấu hổ về bản thân! 🙈',
    ],
    'Chaos ⚡': [
      'Chụp ảnh dìm hàng {friend} và đăng lên Realtime Feed! 📸',
      'Nắm tay {friend} trong vòng 1 phút! 🤝',
      'Để cả nhóm vẽ bậy lên mặt bằng son! 💄',
      'Nói "Anh yêu em" hoặc "Em yêu anh" với {friend} cực sến súa! 💖',
      'Cho {friend} mượn điện thoại lướt lịch sử tìm kiếm 2 phút! 📱🔍',
    ],
    'Extreme 💀': [
      'Gọi điện cho crush (hoặc người yêu cũ) hát bài "Happy Birthday"! 📞🎂',
      'Để {friend} đăng status hài hước lên Facebook của bạn! 📝💬',
      'Đồng ý làm mọi yêu cầu của {friend} trong 5 phút! 🫡',
      'Uống cốc nước trộn 3 loại gia vị do nhóm tự chọn! 🤢',
      'Mặc ngược áo hoặc đội mũ bảo hiểm ngược đi quanh phòng 1 vòng! 👕🪖',
    ],
  };

  String _selectedLevel = 'Chill 🥤';
  String _currentDare = 'Nhấn nút đỏ bên dưới để bốc thử thách!';
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
                'Squad Dare 🎲',
                style: AppFonts.heading(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: inkColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bốc thử thách ngẫu nhiên dành cho bạn hoặc đồng đội',
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
                                    'Nhấn nút bên dưới để bốc thử thách!';
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
                          ? 'Chế độ nhẹ nhàng vui vẻ'
                          : _selectedLevel == 'Chaos ⚡'
                          ? 'Chế độ bắt đầu hỗn loạn'
                          : 'Chế độ cực kỳ nguy hiểm!',
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
                        _isGenerating ? 'ĐANG BỐC...' : 'BỐC DARE NGAY!',
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
