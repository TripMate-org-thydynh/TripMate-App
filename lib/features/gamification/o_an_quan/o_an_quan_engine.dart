import 'dart:math';

/// Bộ luật Ô Ăn Quan — trò chơi dân gian Việt Nam (luật thuộc phạm vi công
/// cộng; không dùng hình ảnh hay tài sản của sản phẩm thương mại nào).
///
/// Bàn 12 ô xếp thành vòng, đi theo chiều kim đồng hồ khi `dir = +1`:
///
/// ```
///        11  10   9   8   7        ← hàng của người chơi 1
///   [0]                     [6]    ← hai ô quan
///         1   2   3   4   5        ← hàng của người chơi 0
/// ```
///
/// Luật dùng (biến thể phổ biến, không có "quan non"):
/// - Mỗi ô dân 5 viên, mỗi ô quan 1 viên quan (= 10 điểm).
/// - Bốc hết một ô dân của mình, rải mỗi ô một viên theo chiều đã chọn.
/// - Rải xong, nhìn ô kế tiếp: có dân (không phải ô quan) → bốc lên rải tiếp;
///   là ô quan còn quân → mất lượt; trống mà ô sau nữa có quân → ăn ô đó, rồi
///   lặp lại "trống – có quân" để ăn liên hoàn; hai ô trống liền → mất lượt.
/// - Đến lượt mà 5 ô của mình trống: lấy 5 dân đã ăn rải lại (thiếu thì rải
///   bằng số đang có; không còn gì là thua).
/// - Hết quan cả hai bên → mỗi người thu dân còn trên hàng mình, ván kết thúc.
class OAnQuanState {
  final List<int> dan;
  final List<bool> quan;
  final List<int> capturedDan;
  final List<int> capturedQuan;
  final int turn;
  final bool over;

  const OAnQuanState({
    required this.dan,
    required this.quan,
    required this.capturedDan,
    required this.capturedQuan,
    required this.turn,
    this.over = false,
  });

  factory OAnQuanState.initial() => OAnQuanState(
    dan: List.generate(12, (i) => isQuanCell(i) ? 0 : 5),
    quan: List.generate(12, isQuanCell),
    capturedDan: const [0, 0],
    capturedQuan: const [0, 0],
    turn: 0,
  );

  static bool isQuanCell(int i) => i == 0 || i == 6;

  /// Ô dân thuộc về người chơi nào (null với ô quan).
  static int? ownerOf(int i) {
    if (i >= 1 && i <= 5) return 0;
    if (i >= 7 && i <= 11) return 1;
    return null;
  }

  static List<int> rowOf(int player) =>
      player == 0 ? const [1, 2, 3, 4, 5] : const [7, 8, 9, 10, 11];

  int score(int player) => capturedDan[player] + capturedQuan[player] * 10;

  bool isEmpty(int i) => dan[i] == 0 && !quan[i];

  bool canPlay(int cell) => !over && ownerOf(cell) == turn && dan[cell] > 0;

  OAnQuanState copyWith({
    List<int>? dan,
    List<bool>? quan,
    List<int>? capturedDan,
    List<int>? capturedQuan,
    int? turn,
    bool? over,
  }) => OAnQuanState(
    dan: dan ?? List.of(this.dan),
    quan: quan ?? List.of(this.quan),
    capturedDan: capturedDan ?? List.of(this.capturedDan),
    capturedQuan: capturedQuan ?? List.of(this.capturedQuan),
    turn: turn ?? this.turn,
    over: over ?? this.over,
  );
}

enum StepKind { pickUp, sow, capture, refill, collect }

/// Một bước để màn chơi phát lại thành hoạt ảnh. [after] là trạng thái ngay
/// sau bước đó.
class OAnQuanStep {
  final StepKind kind;
  final int cell;
  final OAnQuanState after;
  const OAnQuanStep(this.kind, this.cell, this.after);
}

class MoveResult {
  final List<OAnQuanStep> steps;
  final OAnQuanState state;

  /// Điểm ăn được trong lượt này (dân + quan × 10) — dùng để rút thẻ.
  final int gained;
  final int quanTaken;
  const MoveResult(this.steps, this.state, this.gained, this.quanTaken);
}

class OAnQuanEngine {
  /// Chặn vòng lặp bất thường (về lý thuyết không xảy ra, nhưng một lượt
  /// treo máy thì tệ hơn nhiều so với một lượt bị cắt ngắn).
  static const _maxSteps = 600;

  static int next(int i, int dir) => (i + dir + 12) % 12;

  /// Chuẩn bị đầu lượt: rải lại 5 dân nếu hàng mình trống; kết thúc ván nếu
  /// hết quan hoặc người đến lượt không còn gì để đi.
  static MoveResult beginTurn(OAnQuanState s) {
    if (s.over) return MoveResult(const [], s, 0, 0);
    final steps = <OAnQuanStep>[];
    var st = s.copyWith();

    if (st.isEmpty(0) && st.isEmpty(6)) {
      return _finish(st, steps);
    }

    final row = OAnQuanState.rowOf(st.turn);
    if (row.every((c) => st.dan[c] == 0)) {
      final have = st.capturedDan[st.turn];
      if (have == 0) return _finish(st, steps);
      final put = min(5, have);
      for (var k = 0; k < put; k++) {
        st.dan[row[k]]++;
        st.capturedDan[st.turn]--;
        steps.add(OAnQuanStep(StepKind.refill, row[k], st.copyWith()));
      }
    }
    return MoveResult(steps, st, 0, 0);
  }

  static MoveResult _finish(OAnQuanState s, List<OAnQuanStep> steps) {
    final st = s.copyWith();
    for (final p in const [0, 1]) {
      for (final c in OAnQuanState.rowOf(p)) {
        if (st.dan[c] == 0) continue;
        st.capturedDan[p] += st.dan[c];
        st.dan[c] = 0;
        steps.add(OAnQuanStep(StepKind.collect, c, st.copyWith()));
      }
    }
    final done = st.copyWith(over: true);
    return MoveResult(steps, done, 0, 0);
  }

  /// Đi một nước. Ném [ArgumentError] nếu nước đi không hợp lệ.
  static MoveResult play(OAnQuanState s, int cell, int dir) {
    if (!s.canPlay(cell)) throw ArgumentError('Nước đi không hợp lệ: $cell');
    if (dir != 1 && dir != -1) throw ArgumentError('Chiều phải là 1 hoặc -1');

    final st = s.copyWith();
    final me = st.turn;
    final steps = <OAnQuanStep>[];
    var gained = 0;
    var quanTaken = 0;
    var guard = 0;

    var hand = st.dan[cell];
    st.dan[cell] = 0;
    steps.add(OAnQuanStep(StepKind.pickUp, cell, st.copyWith()));
    var pos = cell;

    while (guard++ < _maxSteps) {
      while (hand > 0) {
        pos = next(pos, dir);
        st.dan[pos]++;
        hand--;
        steps.add(OAnQuanStep(StepKind.sow, pos, st.copyWith()));
      }

      final n = next(pos, dir);
      if (!st.isEmpty(n)) {
        // Không được bốc ô quan để rải tiếp.
        if (OAnQuanState.isQuanCell(n)) break;
        hand = st.dan[n];
        st.dan[n] = 0;
        pos = n;
        steps.add(OAnQuanStep(StepKind.pickUp, n, st.copyWith()));
        continue;
      }

      // Ô kế trống: ăn liên hoàn "trống – có quân".
      var gap = n;
      while (guard++ < _maxSteps) {
        final target = next(gap, dir);
        if (st.isEmpty(target)) break;
        gained += st.dan[target];
        st.capturedDan[me] += st.dan[target];
        st.dan[target] = 0;
        if (st.quan[target]) {
          st.quan[target] = false;
          st.capturedQuan[me]++;
          gained += 10;
          quanTaken++;
        }
        steps.add(OAnQuanStep(StepKind.capture, target, st.copyWith()));
        gap = next(target, dir);
        if (!st.isEmpty(gap)) break;
      }
      break;
    }

    final after = st.copyWith(turn: 1 - me);
    return MoveResult(steps, after, gained, quanTaken);
  }
}
