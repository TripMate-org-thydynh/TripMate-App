import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/api_service.dart';
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

  List<_Question> get _questions => [
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
    final vibeTagMap = [
      ['chill', 'chaos'],
      ['cafe', 'nightlife'],
      ['street_food', 'fine_dining'],
      ['budget', 'luxury'],
      ['photography', 'mindful'],
    ];
    final tags = <String>[];
    _answers.forEach((qIdx, choiceIdx) {
      if (qIdx < vibeTagMap.length && choiceIdx < vibeTagMap[qIdx].length) {
        tags.add(vibeTagMap[qIdx][choiceIdx]);
      }
    });
    if (tags.isNotEmpty) {
      try {
        await ApiService.patch('/users/me', {'vibeTags': tags});
      } catch (_) {}
    }
    await ref.read(authProvider.notifier).completeOnboarding();
    // Router redirect tự đưa về /dashboard khi onboardingDone = true.
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final paper = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final accent = Theme.of(context).colorScheme.primary;
    final q = _questions[_step];

    return Scaffold(
      backgroundColor: bg,
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
                      fillColor: accent,
                    ),
                  ),
                  const SizedBox(width: GenZTokens.space4),
                  GestureDetector(
                    onTap: _finish,
                    child: Text(
                      'common.skip_caps'.tr(),
                      style: AppFonts.mono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: inkSoft,
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
                color: fill,
              ),
              const SizedBox(height: GenZTokens.space3),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  q.text,
                  key: ValueKey(_step),
                  style: AppFonts.heading(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: ink,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _choiceCard(
                        choice: q.choices[0],
                        idx: 0,
                        paper: paper,
                        line: line,
                        fill: fill,
                        ink: ink,
                        inkSoft: inkSoft,
                        accent: accent,
                      ),
                    ),
                    const SizedBox(height: GenZTokens.space4),
                    Expanded(
                      child: _choiceCard(
                        choice: q.choices[1],
                        idx: 1,
                        paper: paper,
                        line: line,
                        fill: fill,
                        ink: ink,
                        inkSoft: inkSoft,
                        accent: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceCard({
    required _Choice choice,
    required int idx,
    required Color paper,
    required Color line,
    required Color fill,
    required Color ink,
    required Color inkSoft,
    required Color accent,
  }) {
    return GestureDetector(
      onTap: () => _pick(idx),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(color: line, width: GenZTokens.borderWidthThin),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Icon(choice.icon, color: accent, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                choice.label,
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ink,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Icon(
              PhosphorIcons.arrowRight(),
              size: 20,
              color: inkSoft,
            ),
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
