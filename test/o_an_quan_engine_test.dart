import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/gamification/o_an_quan/action_cards.dart';
import 'package:tripmate/features/gamification/o_an_quan/o_an_quan_engine.dart';

/// Tổng số quân trên bàn + đã ăn (quan tính 1 viên) — phải luôn bảo toàn.
int _total(OAnQuanState s) =>
    s.dan.reduce((a, b) => a + b) + s.capturedDan[0] + s.capturedDan[1];

OAnQuanState _board(Map<int, int> dan, {List<int> quanAt = const [0, 6]}) =>
    OAnQuanState(
      dan: List.generate(12, (i) => dan[i] ?? 0),
      quan: List.generate(12, (i) => quanAt.contains(i)),
      capturedDan: const [0, 0],
      capturedQuan: const [0, 0],
      turn: 0,
    );

void main() {
  test('bàn khởi đầu: 50 dân, 2 quan, người 0 đi trước', () {
    final s = OAnQuanState.initial();
    expect(_total(s), 50);
    expect(s.quan[0] && s.quan[6], isTrue);
    expect(s.turn, 0);
  });

  test('không được đi ô của đối thủ, ô quan hay ô trống', () {
    final s = OAnQuanState.initial();
    expect(() => OAnQuanEngine.play(s, 7, 1), throwsArgumentError);
    expect(() => OAnQuanEngine.play(s, 0, 1), throwsArgumentError);
    expect(
      () => OAnQuanEngine.play(_board({1: 0, 2: 3}), 1, 1),
      throwsArgumentError,
    );
  });

  test('rải xong gặp ô quan còn quân thì mất lượt, không ăn', () {
    // Ô 4 có 1 viên → rải vào 5; ô kế (6) là quan → dừng.
    final r = OAnQuanEngine.play(_board({4: 1, 9: 2}), 4, 1);
    expect(r.state.dan[5], 1);
    expect(r.gained, 0);
    expect(r.state.turn, 1);
  });

  test('trống rồi có quân → ăn, rồi ăn liên hoàn', () {
    // Ô 1 có 1 viên, rải vào 2. Ô 3 trống, ô 4 có 4 → ăn 4.
    // Ô 5 trống, ô 6 là quan (còn quân + 2 dân) → ăn tiếp được 2 + 10.
    final r = OAnQuanEngine.play(_board({1: 1, 4: 4, 6: 2, 9: 1}), 1, 1);
    expect(r.state.capturedDan[0], 6);
    expect(r.state.capturedQuan[0], 1);
    expect(r.state.quan[6], isFalse);
    expect(r.gained, 16);
    expect(r.quanTaken, 1);
  });

  test('rải xong gặp ô dân có quân thì bốc lên rải tiếp', () {
    // Ô 2 có 1 viên → rải vào 3; ô 4 có 1 → bốc rải vào 5; ô 6 quan → dừng.
    final r = OAnQuanEngine.play(_board({2: 1, 4: 1, 9: 1}), 2, 1);
    expect(r.state.dan[3], 1);
    expect(r.state.dan[4], 0);
    expect(r.state.dan[5], 1);
    expect(r.steps.where((s) => s.kind == StepKind.pickUp).length, 2);
  });

  test('hàng trống đầu lượt: rải lại 5 dân đã ăn', () {
    final s = _board({8: 3}).copyWith(capturedDan: [7, 0]);
    final r = OAnQuanEngine.beginTurn(s);
    expect(OAnQuanState.rowOf(0).every((c) => r.state.dan[c] == 1), isTrue);
    expect(r.state.capturedDan[0], 2);
  });

  test('hết quan hai bên → thu dân về và kết thúc', () {
    final s = _board({2: 3, 9: 4}, quanAt: const []);
    final r = OAnQuanEngine.beginTurn(s);
    expect(r.state.over, isTrue);
    expect(r.state.capturedDan, [3, 4]);
  });

  test('chơi ngẫu nhiên 200 ván: luôn kết thúc và bảo toàn số quân', () {
    final rng = Random(42);
    for (var game = 0; game < 200; game++) {
      var s = OAnQuanState.initial();
      var moves = 0;
      while (!s.over && moves < 400) {
        s = OAnQuanEngine.beginTurn(s).state;
        if (s.over) break;
        final legal = OAnQuanState.rowOf(s.turn).where(s.canPlay).toList();
        if (legal.isEmpty) break;
        final cell = legal[rng.nextInt(legal.length)];
        s = OAnQuanEngine.play(s, cell, rng.nextBool() ? 1 : -1).state;
        moves++;
        expect(_total(s), 50, reason: 'ván $game nước $moves');
      }
      expect(moves, lessThan(400), reason: 'ván $game không kết thúc');
      expect(
        s.capturedQuan[0] +
            s.capturedQuan[1] +
            (s.quan[0] ? 1 : 0) +
            (s.quan[6] ? 1 : 0),
        2,
      );
    }
  });

  test('bộ thẻ: rút hết 10 thẻ không trùng rồi mới xáo lại', () {
    final deck = ActionDeck(random: Random(1));
    final ids = List.generate(kActionCards.length, (_) => deck.draw().id);
    expect(ids.toSet().length, kActionCards.length);
    expect(ActionDeck.earns(gained: 4, quanTaken: 0), isFalse);
    expect(ActionDeck.earns(gained: 5, quanTaken: 0), isTrue);
    expect(ActionDeck.earns(gained: 0, quanTaken: 1), isTrue);
  });
}
