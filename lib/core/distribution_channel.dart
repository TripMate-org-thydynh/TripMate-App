import 'dart:io' show Platform;

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
/// - `appstore` — tải từ Apple App Store (iOS). App Store Review Guideline 3.1.1
///              bắt buộc mọi hàng hoá số tiêu thụ trong app phải thanh toán qua
///              Apple In-App Purchase (StoreKit), không được bày VietQR/SePay.
///
/// Server nhận giá trị này qua header `X-Client-Channel` và trả về danh sách
/// cổng tương ứng. Header chỉ quyết định **bày cái gì** — mọi cổng vẫn tự xác
/// thực lại lúc thanh toán, nên client khai sai không mở thêm được đường nào.
enum DistributionChannel {
  play,
  direct,
  web,
  appstore;

  String get wire => name;
}

/// Kênh của bản build hiện tại.
///
/// Trên Android, giá trị đến từ `--dart-define=DISTRIBUTION_CHANNEL=direct` khi
/// dựng bản APK phát hành ngoài cửa hàng. **Mặc định là `play`**: quên truyền cờ
/// thì app hiện Play Billing — thiếu một lựa chọn thanh toán thì khó chịu, còn
/// nhầm theo hướng ngược lại là bày VietQR trong bản CH Play và bị gỡ app.
///
/// Trên iOS, mặc định là `appstore` theo App Store Review Guideline 3.1.1:
/// hàng số phải qua Apple In-App Purchase, không được bày VietQR/SePay.
final DistributionChannel kDistributionChannel = _detect();

DistributionChannel _detect({
  TargetPlatform? platform,
  bool? isWeb,
  String? overrideEnv,
}) {
  if (isWeb ?? kIsWeb) return DistributionChannel.web;

  final raw =
      overrideEnv ?? const String.fromEnvironment('DISTRIBUTION_CHANNEL');
  switch (raw.trim().toLowerCase()) {
    case 'direct':
      return DistributionChannel.direct;
    case 'web':
      return DistributionChannel.web;
    case 'play':
      return DistributionChannel.play;
    case 'appstore':
    case 'ios':
    case 'apple':
      return DistributionChannel.appstore;
  }

  // Trên iOS (không phải web), bắt buộc rơi vào kênh appstore theo Apple Guideline 3.1.1.
  final target = platform ?? defaultTargetPlatform;
  if (target == TargetPlatform.iOS) {
    return DistributionChannel.appstore;
  }
  try {
    if (Platform.isIOS) {
      return DistributionChannel.appstore;
    }
  } catch (_) {}

  return target == TargetPlatform.android
      ? DistributionChannel.play
      : DistributionChannel.direct;
}

/// Expose hàm detect để unit test có thể kiểm thử các platform / env khác nhau.
@visibleForTesting
DistributionChannel detectDistributionChannel({
  TargetPlatform? platform,
  bool? isWeb,
  String? overrideEnv,
}) =>
    _detect(platform: platform, isWeb: isWeb, overrideEnv: overrideEnv);

/// Bản này có gọi được Store Billing (Google Play / Apple StoreKit) không.
bool get kStoreBillingAvailable =>
    kPlayBillingAvailable || kAppleBillingAvailable;

/// Bản này có gọi được Google Play Billing không.
bool get kPlayBillingAvailable =>
    !kIsWeb &&
    kDistributionChannel == DistributionChannel.play &&
    defaultTargetPlatform == TargetPlatform.android;

/// Bản này có gọi được Apple In-App Purchase (StoreKit) không.
bool get kAppleBillingAvailable =>
    !kIsWeb &&
    kDistributionChannel == DistributionChannel.appstore &&
    defaultTargetPlatform == TargetPlatform.iOS;


