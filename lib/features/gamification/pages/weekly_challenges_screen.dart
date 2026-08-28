import 'package:flutter/material.dart';

import '../data/games_repository.dart';
import '../widgets/challenge_list_view.dart';

/// Nhiệm vụ tuần — tiến độ tính từ hoạt động thật trong 7 ngày gần nhất.
class WeeklyChallengesScreen extends StatelessWidget {
  const WeeklyChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChallengeListScreen(
      titleKey: 'games.weekly_title',
      emptyIcon: Icons.bolt_outlined,
      provider: weeklyChallengesProvider,
    );
  }
}
