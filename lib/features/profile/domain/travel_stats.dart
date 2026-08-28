// Model dùng chung cho Travel Atlas.
//
// Trước đây file này còn một class `TravelStats` với factory `.mock()` chứa
// số liệu và huy hiệu bịa. Nó chỉ còn được dùng làm fallback khi API chưa trả
// dữ liệu — khiến tài khoản mới thấy mình đã đi 12 chuyến và mở khoá huy hiệu.
// Đã gỡ; số liệu và huy hiệu nay đến hoàn toàn từ `TravelAtlasRepository`.

class BucketItem {
  final String id;
  final String title;
  final bool isCompleted;

  BucketItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });
}

class TravelBadge {
  final String title;
  final String description;
  final bool isUnlocked;

  TravelBadge({
    required this.title,
    required this.description,
    required this.isUnlocked,
  });
}
