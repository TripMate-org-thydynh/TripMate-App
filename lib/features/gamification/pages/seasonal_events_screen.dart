import 'package:flutter/material.dart';

import '../data/games_repository.dart';
import '../widgets/challenge_list_view.dart';

/// Sự kiện theo mùa — mùa hiện tại suy ra từ tháng, tiến độ từ dữ liệu thật.
class SeasonalEventsScreen extends StatelessWidget {
  const SeasonalEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChallengeListScreen(
      titleKey: 'games.seasonal_title',
      emptyIcon: Icons.local_florist_outlined,
      provider: seasonalEventsProvider,
    );
  }
}
