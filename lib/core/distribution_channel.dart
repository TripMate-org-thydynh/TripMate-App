import 'package:flutter/foundation.dart';

/// Kênh phân phối của bản app đang chạy.
///
/// Quyết định app được bày phương thức thanh toán nào:
///
/// - `play`   — tải từ CH Play. Chính sách Payments của Google bắt buộc mọi
///              hàng hoá số tiêu thụ trong app phải thanh toán qua Play Billing.
///              Chương trình "User Choice Billing" cho phép bày thêm cổng khác
///              nhưng **chưa mở cho Việt Nam**, nên bản này chỉ có Play Billing.
/// - `direct` — APK tải thẳng từ web TripMate. Không qua CH Play nên không bị
///              chính sách trên ràng buộc, và cũng không gọi được Play Billing.
/// - `web`    — chạy trên trình duyệt.
///
/// Server nhận giá trị này qua header `X-Client-Channel` và trả về danh sách
/// cổng tương ứng. Header chỉ quyết định **bày cái gì** — mọi cổng vẫn tự xác
/// thực lại lúc thanh toán, nên client khai sai không mở thêm được đường nào.
enum DistributionChannel {
  play,
  direct,
  web;

  String get wire => name;
}

/// Kênh của bản build hiện tại.
///
/// Trên Android, giá trị đến từ `--dart-define=DISTRIBUTION_CHANNEL=direct` khi
/// dựng bản APK phát hành ngoài cửa hàng. **Mặc định là `play`**: quên truyền cờ
/// thì app hiện Play Billing — thiếu một lựa chọn thanh toán thì khó chịu, còn
/// nhầm theo hướng ngược lại là bày VietQR trong bản CH Play và bị gỡ app.
final DistributionChannel kDistributionChannel = _detect();

DistributionChannel _detect() {
  if (kIsWeb) return DistributionChannel.web;

  const raw = String.fromEnvironment('DISTRIBUTION_CHANNEL');
  switch (raw.trim().toLowerCase()) {
    case 'direct':
      return DistributionChannel.direct;
    case 'web':
      return DistributionChannel.web;
    case 'play':
      return DistributionChannel.play;
  }

  // Play Billing chỉ tồn tại trên Android. iOS sẽ cần StoreKit và một nhánh
  // riêng; tới lúc đó thì thêm ở đây, còn bây giờ nói thật là không phải `play`.
  return defaultTargetPlatform == TargetPlatform.android
      ? DistributionChannel.play
      : DistributionChannel.direct;
}

/// Bản này có gọi được Google Play Billing không.
bool get kPlayBillingAvailable =>
    !kIsWeb &&
    kDistributionChannel == DistributionChannel.play &&
    defaultTargetPlatform == TargetPlatform.android;
