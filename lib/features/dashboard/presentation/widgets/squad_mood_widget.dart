import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/theme.dart';

class SquadMoodWidget extends StatefulWidget {
  const SquadMoodWidget({super.key});

  @override
  State<SquadMoodWidget> createState() => _SquadMoodWidgetState();
}

class _SquadMoodWidgetState extends State<SquadMoodWidget> {
  String _myActiveMood = "⚡";

  final List<Map<String, dynamic>> _moodOptions = const [
    {"emoji": "⚡", "label": "Chaotic"},
    {"emoji": "🥱", "label": "Sleepy"},
    {"emoji": "🍲", "label": "Hungry"},
    {"emoji": "🤑", "label": "Rich"},
    {"emoji": "🥳", "label": "Hyped"},
  ];

  // Group mood distribution mockup
  final Map<String, double> _groupMoods = const {
    "⚡": 0.45,
    "🥱": 0.20,
    "🍲": 0.15,
    "🤑": 0.10,
    "🥳": 0.10,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? TripMateTheme.darkSurface.withValues(alpha: 0.8) : TripMateTheme.lightSurface,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? TripMateTheme.darkSecondary.withValues(alpha: 0.15)
                      : TripMateTheme.lightSecondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "⚡ Chaotic Good (85%)",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Interactive mood selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moodOptions.map((opt) {
              final isSelected = _myActiveMood == opt["emoji"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _myActiveMood = opt["emoji"] as String;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Updated your vibe to ${opt['label']}!"),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    opt["emoji"] as String,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Horizontal stack bar showing group distribution
          Text(
            "Group Vibe Breakdown",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 16,
              child: Row(
                children: _groupMoods.entries.map((entry) {
                  final double widthFraction = entry.value;
                  final String emoji = entry.key;

                  // Sample palette for parts
                  Color barColor;
                  switch (emoji) {
                    case "⚡":
                      barColor = const Color(0xFF8B5CF6);
                      break;
                    case "🥱":
                      barColor = const Color(0xFFF59E0B);
                      break;
                    case "🍲":
                      barColor = const Color(0xFFEF4444);
                      break;
                    case "🤑":
                      barColor = const Color(0xFF10B981);
                      break;
                    default:
                      barColor = const Color(0xFF3B82F6);
                  }

                  return Expanded(
                    flex: (widthFraction * 100).toInt(),
                    child: Container(
                      color: barColor,
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 9, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
