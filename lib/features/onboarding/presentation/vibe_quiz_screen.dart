import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/api_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/gen_z_widgets.dart';

/// Onboarding vibe quiz — 5 câu chọn nhanh để cá nhân hoá gu du lịch.
/// Đây là NƠI DUY NHẤT hỏi vibe (màn đăng nhập không còn băng chuyền vibe).
/// Thẻ trả lời cao vừa nội dung (trước đây mỗi thẻ chiếm nửa màn, chữ lọt thỏm
/// giữa khoảng trống), có trạng thái đã chọn 150ms trước khi sang câu mới, và
/// nút quay lại câu trước.
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
  int? _selected;

  List<_Question> get _questions => [
    _Question('onboarding.q_trip'.tr(), [
      _Choice(
        'onboarding.a_chill'.tr(),
        PhosphorIcons.leaf(PhosphorIconsStyle.fill),
      ),
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

  Future<void> _pick(int choice) async {
    if (_selected != null) return;
    HapticFeedback.selectionClick();
    _answers[_step] = choice;
    setState(() => _selected = choice);
    // Cho thấy lựa chọn đã ăn rồi mới sang câu mới.
    await Future<void>.delayed(
      const Duration(milliseconds: GenZTokens.durationFast + 30),
    );
    if (!mounted) return;
    if (_step < _questions.length - 1) {
      setState(() {
        _step++;
        _selected = null;
      });
    } else {
      await _finish();
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() {
      _step--;
      _selected = null;
    });
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
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final q = _questions[_step];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            GenZTokens.space5,
            GenZTokens.space4,
            GenZTokens.space5,
            GenZTokens.space6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: quay lại + progress segment rời + bỏ qua
              Row(
                children: [
                  if (_step > 0) ...[
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: _back,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
                    ),
                    const SizedBox(width: GenZTokens.space2),
                  ],
                  Expanded(
                    child: SegmentedProgress(
                      total: _questions.length,
                      completed: _step + 1,
                      fillColor: accent,
                    ),
                  ),
                  const SizedBox(width: GenZTokens.space4),
                  TextButton(
                    onPressed: _finish,
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
              const SizedBox(height: 36),

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
                duration: const Duration(milliseconds: GenZTokens.durationBase),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: Text(
                  q.text,
                  key: ValueKey(_step),
                  style: AppFonts.heading(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: ink,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              for (var i = 0; i < q.choices.length; i++) ...[
                if (i > 0) const SizedBox(height: GenZTokens.space3),
                _choiceCard(
                  choice: q.choices[i],
                  idx: i,
                  paper: paper,
                  line: line,
                  fill: fill,
                  ink: ink,
                  inkSoft: inkSoft,
                  accent: accent,
                  accentSoft: isDark
                      ? GenZTokens.accentSoftDark
                      : GenZTokens.accentSoft,
                ),
              ],
              const Spacer(),
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
    required Color accentSoft,
  }) {
    final selected =
        _selected == idx || (_selected == null && _answers[_step] == idx);
    final radius = BorderRadius.circular(GenZTokens.radiusCard);
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: GenZTokens.durationFast),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? accentSoft : paper,
          borderRadius: radius,
          border: Border.all(
            color: selected ? accent : line,
            width: selected ? 1.5 : GenZTokens.borderWidthThin,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: () => _pick(idx),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected ? paper : fill,
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusButton,
                      ),
                    ),
                    child: Icon(
                      choice.icon,
                      color: selected ? accent : ink,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      choice.label,
                      style: AppFonts.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                        : PhosphorIcons.caretRight(),
                    size: 20,
                    color: selected ? accent : inkSoft,
                  ),
                ],
              ),
            ),
          ),
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
