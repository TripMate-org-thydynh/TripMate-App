import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/gen_z_widgets.dart';

/// Onboarding vibe quiz — 5 câu swipe nhanh để cá nhân hoá gu du lịch.
/// Phong cách Gen Z Neo-Brutalist: mỗi bước 1 khối màu accent full-bleed,
/// progress segment rời, heading khổng lồ, card viền ink + hard shadow.
/// Khi xong gọi authProvider.completeOnboarding() để router chuyển sang dashboard.
class VibeQuizScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const VibeQuizScreen({super.key, required this.isDarkMode});

  @override
  ConsumerState<VibeQuizScreen> createState() => _VibeQuizScreenState();
}

class _VibeQuizScreenState extends ConsumerState<VibeQuizScreen> {
  int _step = 0;
  final Map<int, int> _answers = {};

  // Mỗi bước một khối màu accent khác nhau (Design DNA: solid color blocks).
  static const List<Color> _stepColors = [
    GenZTokens.yellow,
    GenZTokens.green,
    GenZTokens.lilac,
    GenZTokens.orange,
    GenZTokens.pink,
  ];

  final List<_Question> _questions = [
    _Question('onboarding.q_trip'.tr(), [
      _Choice('onboarding.a_chill'.tr(), PhosphorIcons.leaf(PhosphorIconsStyle.fill)),
      _Choice(
        'onboarding.a_chaos'.tr(),
        PhosphorIcons.flame(PhosphorIconsStyle.fill),
      ),
    ]),
    _Question('onboarding.q_night'.tr(), [
      _Choice(
        'onboarding.a_cafe'.tr(),
        PhosphorIcons.coffee(PhosphorIconsStyle.fill),
      ),
      _Choice(
        'onboarding.a_bar'.tr(),
        PhosphorIcons.martini(PhosphorIconsStyle.fill),
      ),
    ]),
    _Question('onboarding.q_food'.tr(), [
      _Choice(
        'onboarding.a_street'.tr(),
        PhosphorIcons.forkKnife(PhosphorIconsStyle.fill),
      ),
      _Choice(
        'onboarding.a_restaurant'.tr(),
        PhosphorIcons.cookingPot(PhosphorIconsStyle.fill),
      ),
    ]),
    _Question('onboarding.q_budget'.tr(), [
      _Choice(
        'onboarding.vibe_budget_max'.tr(),
        PhosphorIcons.piggyBank(PhosphorIconsStyle.fill),
      ),
      _Choice(
        'onboarding.a_splurge'.tr(),
        PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
      ),
    ]),
    _Question('onboarding.q_memories'.tr(), [
      _Choice(
        'onboarding.a_photos'.tr(),
        PhosphorIcons.camera(PhosphorIconsStyle.fill),
      ),
      _Choice(
        'onboarding.a_present'.tr(),
        PhosphorIcons.heart(PhosphorIconsStyle.fill),
      ),
    ]),
  ];

  void _pick(int choice) {
    HapticFeedback.mediumImpact();
    _answers[_step] = choice;
    if (_step < _questions.length - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    HapticFeedback.heavyImpact();
    await ref.read(authProvider.notifier).completeOnboarding();
    // Router redirect tự đưa về /dashboard khi onboardingDone = true.
  }

  @override
  Widget build(BuildContext context) {
    // Khối màu full-bleed đổi theo bước; chữ và viền LUÔN là ink tối
    // để giữ tương phản AA trên mọi accent sáng (kể cả dark mode).
    final blockColor = _stepColors[_step % _stepColors.length];
    final q = _questions[_step];

    return Scaffold(
      backgroundColor: blockColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: progress segment rời + skip
              Row(
                children: [
                  Expanded(
                    child: SegmentedProgress(
                      total: _questions.length,
                      completed: _step + 1,
                      fillColor: GenZTokens.ink,
                    ),
                  ),
                  const SizedBox(width: GenZTokens.space4),
                  GestureDetector(
                    onTap: _finish,
                    child: Text(
                      'common.skip_caps'.tr(),
                      style: AppFonts.mono(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GenZTokens.ink,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              PillTag(
                text: 'onboarding.question_n'.tr(
                  namedArgs: {
                    'i': '${_step + 1}',
                    'total': '${_questions.length}',
                  },
                ),
                color: GenZTokens.paper,
              ),
              const SizedBox(height: GenZTokens.space3),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  q.text,
                  key: ValueKey(_step),
                  style: AppFonts.heading(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: GenZTokens.ink,
                    letterSpacing: -0.5,
                    height: 1.05,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _choiceCard(q.choices[0], 0)),
                    const SizedBox(height: GenZTokens.space4),
                    Expanded(child: _choiceCard(q.choices[1], 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceCard(_Choice choice, int idx) {
    return GestureDetector(
      onTap: () => _pick(idx),
      child: HardShadowBox(
        color: GenZTokens.paper,
        radius: GenZTokens.radiusCard,
        borderColor: GenZTokens.ink,
        shadowColor: GenZTokens.ink,
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _stepColors[(_step + idx + 1) % _stepColors.length],
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                border: Border.all(
                  color: GenZTokens.ink,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Icon(choice.icon, color: GenZTokens.ink, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                choice.label,
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: GenZTokens.ink,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 20, color: GenZTokens.ink),
          ],
        ),
      ),
    );
  }
}

class _Question {
  final String text;
  final List<_Choice> choices;
  const _Question(this.text, this.choices);
}

class _Choice {
  final String label;
  final IconData icon;
  const _Choice(this.label, this.icon);
}
