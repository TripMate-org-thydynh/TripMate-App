import 'dart:math';

/// Hệ thẻ hành động dùng chung cho các trò trên bàn cờ.
///
/// Thẻ chia hai loại: thẻ **luật** đổi trạng thái ván (thêm lượt, cướp điểm)
/// và thẻ **nhóm** chỉ là thử thách ngoài đời để cả nhóm cùng làm — đây là
/// phần biến một trò hai người thành trò cho cả chuyến đi.
enum ActionCardKind {
  /// Đi thêm một lượt ngay.
  extraTurn,

  /// Lấy [ActionCard.amount] điểm dân từ đối thủ (không âm).
  steal,

  /// Thử thách nhóm, không đổi điểm.
  squad,
}

class ActionCard {
  final String id;
  final ActionCardKind kind;

  /// Khoá dịch của tiêu đề và mô tả: `oaq.card_<id>_title` / `_body`.
  String get titleKey => 'oaq.card_${id}_title';
  String get bodyKey => 'oaq.card_${id}_body';
  final int amount;

  const ActionCard(this.id, this.kind, {this.amount = 0});
}

const List<ActionCard> kActionCards = [
  ActionCard('extra', ActionCardKind.extraTurn),
  ActionCard('extra2', ActionCardKind.extraTurn),
  ActionCard('steal3', ActionCardKind.steal, amount: 3),
  ActionCard('steal5', ActionCardKind.steal, amount: 5),
  ActionCard('local_food', ActionCardKind.squad),
  ActionCard('photo', ActionCardKind.squad),
  ActionCard('accent', ActionCardKind.squad),
  ActionCard('compliment', ActionCardKind.squad),
  ActionCard('memory', ActionCardKind.squad),
  ActionCard('dj', ActionCardKind.squad),
];

/// Bộ bài xáo một lần, rút hết thì xáo lại — tránh một thẻ ra liên tục như
/// khi rút ngẫu nhiên độc lập.
class ActionDeck {
  final Random _rng;
  final List<ActionCard> _pile = [];

  ActionDeck({Random? random}) : _rng = random ?? Random();

  ActionCard draw() {
    if (_pile.isEmpty) {
      _pile
        ..addAll(kActionCards)
        ..shuffle(_rng);
    }
    return _pile.removeLast();
  }

  /// Lượt này có được rút thẻ không: ăn được quan, hoặc ăn từ 5 điểm trở lên.
  static bool earns({required int gained, required int quanTaken}) =>
      quanTaken > 0 || gained >= 5;
}
