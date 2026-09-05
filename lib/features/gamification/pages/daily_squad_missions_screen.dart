import 'package:flutter/material.dart';

import '../data/games_repository.dart';
import '../widgets/challenge_list_view.dart';

/// Nhiệm vụ trong ngày của squad.
///
/// Trước đây màn này in cứng 4 nhiệm vụ với tiến độ bịa ("Upload 5 memories
/// 3/5", "Visit 3 cafes 1/3"), nên ai mở ra cũng thấy mình đang dở dang những
/// việc chưa từng làm. Nay tiến độ đếm thật từ hoạt động hôm nay.
class DailySquadMissionsScreen extends StatelessWidget {
  const DailySquadMissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChallengeListScreen(
      titleKey: 'games.daily_title',
      emptyIcon: Icons.today_outlined,
      provider: dailyMissionsProvider,
    );
  }
}
