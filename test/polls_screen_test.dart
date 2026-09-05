// Widget test cho TripPollsScreen — verify render poll + % vote.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/localized.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tripmate/features/social/data/polls_repository.dart';
import 'package:tripmate/features/social/domain/poll.dart';
import 'package:tripmate/features/social/presentation/pages/trip_polls_screen.dart';

class _FakePollsRepo implements PollsRepository {
  final List<Poll> polls;
  _FakePollsRepo(this.polls);

  @override
  Future<List<Poll>> fetch(String tripId) async => polls;

  @override
  Future<Poll> create(String tripId,
      {required String question,
      required List<Map<String, String?>> options,
      bool isMultiple = false}) async {
    return Poll(id: 'new', question: question, options: const []);
  }

  @override
  Future<void> vote(String tripId, String optionId) async {}
}

Widget _wrap(PollsRepository repo) {
  return ProviderScope(
    overrides: [pollsRepositoryProvider.overrideWithValue(repo)],
    child: localized(
      const TripPollsScreen(tripId: 't1', isDarkMode: true),
    ),
  );
}

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });

  testWidgets('empty state khi chưa có poll', (tester) async {
    await tester.pumpWidget(_wrap(_FakePollsRepo([])));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Chưa có bình chọn nào'), findsOneWidget);
  });

  testWidgets('render câu hỏi + lựa chọn + tổng vote', (tester) async {
    final repo = _FakePollsRepo([
      const Poll(
        id: 'p1',
        question: 'Ăn gì tối nay?',
        options: [
          PollOption(id: 'o1', text: 'Lẩu', voteCount: 3),
          PollOption(id: 'o2', text: 'Nướng', voteCount: 1),
        ],
      ),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600)); // chờ TweenAnimation

    expect(find.text('Ăn gì tối nay?'), findsOneWidget);
    expect(find.text('Lẩu'), findsOneWidget);
    expect(find.text('Nướng'), findsOneWidget);
    expect(find.text('4 lượt vote'), findsOneWidget);
  });
}
