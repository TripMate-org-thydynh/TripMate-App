import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/widgets/gen_z_widgets.dart';

class SquadMoodWidget extends StatefulWidget {
  const SquadMoodWidget({super.key});

  @override
  State<SquadMoodWidget> createState() => _SquadMoodWidgetState();
}

class _SquadMoodWidgetState extends State<SquadMoodWidget> {
  String _myActiveMood = "chaotic";

  final List<Map<String, dynamic>> _moodOptions = const [
    {
      "id": "chaotic",
      "label": "Chaotic",
      "icon": PhosphorIconsRegular.lightning,
    },
    {"id": "sleepy", "label": "Sleepy", "icon": PhosphorIconsRegular.moon},
    {
      "id": "hungry",
      "label": "Hungry",
      "icon": PhosphorIconsRegular.cookingPot,
    },
    {
      "id": "rich",
      "label": "Rich",
      "icon": PhosphorIconsRegular.currencyDollar,
    },
    {"id": "hyped", "label": "Hyped", "icon": PhosphorIconsRegular.confetti},
  ];

  final Map<String, double> _groupMoods = const {
    "chaotic": 0.45,
    "sleepy": 0.20,
    "hungry": 0.15,
    "rich": 0.10,
    "hyped": 0.10,
  };

  Color _barColor(String id) {
    switch (id) {
      case "chaotic":
        return GenZTokens.orange;
      case "sleepy":
        return GenZTokens.lilac;
      case "hungry":
        return GenZTokens.red;
      case "rich":
        return GenZTokens.green;
      default:
        return GenZTokens.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final activeMood = _moodOptions.firstWhere((o) => o["id"] == _myActiveMood);

    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    return HardShadowBox(
      color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "dashboard.squad_mood".tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              PillTag(
                text: 'dashboard.mood_active'.tr(
                  namedArgs: {'mood': activeMood['label'] as String},
                ),
                icon: activeMood["icon"] as IconData,
                color: GenZTokens.yellow,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moodOptions.map((opt) {
              final isSelected = _myActiveMood == opt["id"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _myActiveMood = opt["id"] as String;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'dashboard.vibe_updated'.tr(
                          namedArgs: {'mood': opt['label'] as String},
                        ),
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? ink : Colors.transparent,
                      width: GenZTokens.borderWidthThin,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: ink, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: Icon(
                    opt["icon"] as IconData,
                    size: 22,
                    color: isSelected
                        ? GenZTokens.ink
                        : ink.withValues(alpha: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'dashboard.group_vibe'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: _groupMoods.entries.map((entry) {
                    return Expanded(
                      flex: (entry.value * 100).toInt(),
                      child: Container(color: _barColor(entry.key)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
