import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../../core/api_service.dart';
import '../../../core/distribution_channel.dart';

/// Kết quả một lần mua qua Google Play.
enum PlayPurchaseOutcome {
  /// Đã trả tiền và server đã cấp gói.
  granted,

  /// Người dùng đóng hộp thoại của Google giữa chừng.
  canceled,

  /// Trả tiền xong nhưng chưa xác nhận được với server.
  ///
  /// **Không phải mất tiền.** Biên lai vẫn nằm trong tài khoản Google của người
  /// dùng và `restorePurchases()` sẽ lấy lại được ở lần mở app sau. Tách riêng
  /// khỏi `failed` vì lời nhắn cho người dùng phải khác hẳn nhau.
  pendingVerification,

  /// Không mở được luồng mua, hoặc Google từ chối.
  failed,
}

class PlayPurchaseResult {
  const PlayPurchaseResult(this.outcome, {this.message});
  final PlayPurchaseOutcome outcome;
  final String? message;
}

/// Mua gói qua Google Play Billing.
///
/// Luồng khác hẳn VietQR: ở đây **Google giữ tiền và giữ giá**. App không tạo
/// đơn ở server, không biết số tiền, không dựng mã QR. Nó chỉ mở hộp thoại của
/// Google, nhận về một biên lai, rồi đưa biên lai đó cho server xác thực với
/// Google. Gói được cấp dựa trên thứ Google xác nhận đã bán — không dựa trên
/// bất cứ điều gì app khai.
///
/// Vì thế màn hình thanh toán **không hiển thị giá của mình** cho nhánh này:
/// Play tự quy đổi tiền tệ và tự cộng thuế theo nước của người mua, nên con số
/// duy nhất đúng là con số Google trả về trong `ProductDetails.price`.
class PlayBillingService {
  PlayBillingService._();
  static final PlayBillingService instance = PlayBillingService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Chờ kết quả của lần mua đang mở. Chỉ có tối đa một lần mua tại một thời điểm.
  Completer<PlayPurchaseResult>? _pending;

  /// Mã sản phẩm của lần mua đang chờ, để đối chiếu biên lai trả về.
  String? _pendingProductId;

  bool _started = false;

  /// Giá hiển thị theo đúng định dạng nước người dùng, khoá theo mã sản phẩm.
  final Map<String, ProductDetails> _products = {};

  /// Cửa hàng có sẵn sàng không. Trả `false` trên bản không phải CH Play.
  Future<bool> isAvailable() async {
    if (!kPlayBillingAvailable) return false;
    try {
      return await _iap.isAvailable();
    } catch (e) {
      debugPrint('PlayBilling: khong kiem tra duoc cua hang: $e');
      return false;
    }
  }

  /// Nạp thông tin sản phẩm từ Google (tên, giá đã quy đổi tiền tệ).
  ///
  /// Mã nào Google không nhận (`notFoundIDs`) thì đơn giản là không mua được —
  /// thường do chưa khai trong Play Console hoặc bản build chưa lên track nào.
  /// Trả về đúng những sản phẩm Google xác nhận có thật.
  Future<Map<String, ProductDetails>> loadProducts(Set<String> ids) async {
    if (ids.isEmpty || !await isAvailable()) return const {};
    try {
      final res = await _iap.queryProductDetails(ids);
      if (res.notFoundIDs.isNotEmpty) {
        debugPrint('PlayBilling: Google khong co san pham ${res.notFoundIDs}');
      }
      for (final p in res.productDetails) {
        _products[p.id] = p;
      }
      return {for (final p in res.productDetails) p.id: p};
    } catch (e) {
      debugPrint('PlayBilling: loi nap san pham: $e');
      return const {};
    }
  }

  /// Bắt đầu lắng nghe luồng biên lai.
  ///
  /// Phải gọi **trước** khi mua lần đầu. Google phát lại luồng này mỗi lần app
  /// khởi động với những giao dịch chưa hoàn tất — nên đây cũng là chỗ nhặt lại
  /// biên lai của lần mua bị đứt giữa chừng (rớt mạng, tắt app, đổi máy).
  void start() {
    if (_started || !kPlayBillingAvailable) return;
    _started = true;
    _sub = _iap.purchaseStream.listen(
      _onPurchases,
      onDone: () => _sub?.cancel(),
      onError: (Object e) => debugPrint('PlayBilling: loi luong bien lai: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _started = false;
  }

  /// Mở hộp thoại mua của Google và chờ tới khi server cấp xong gói.
  ///
  /// `userId` được gắn vào biên lai (`applicationUserName`) và Google lưu lại
  /// thành `obfuscatedExternalAccountId`. Server đối chiếu trường đó với người
  /// đang đăng nhập — thiếu nó thì một biên lai mua bằng tài khoản Google bất kỳ
  /// đều đổi được thành Premium cho bất kỳ tài khoản TripMate nào.
  Future<PlayPurchaseResult> buy({
    required String productId,
    required String userId,
  }) async {
    if (!await isAvailable()) {
      return const PlayPurchaseResult(
        PlayPurchaseOutcome.failed,
        message: 'premium.play_unavailable',
      );
    }
    if (_pending != null) {
      // Hai lần mua chồng nhau thì không phân biệt được biên lai nào của lần
      // nào. Chặn ở đây thay vì để hai completer tranh nhau.
      return const PlayPurchaseResult(
        PlayPurchaseOutcome.failed,
        message: 'premium.play_busy',
      );
    }

    start();

    final product = _products[productId] ??
        (await loadProducts({productId}))[productId];
    if (product == null) {
      return const PlayPurchaseResult(
        PlayPurchaseOutcome.failed,
        message: 'premium.play_product_missing',
      );
    }

    final completer = Completer<PlayPurchaseResult>();
    _pending = completer;
    _pendingProductId = productId;

    try {
      final ok = await _iap.buyNonConsumable(
        purchaseParam: GooglePlayPurchaseParam(
          productDetails: product,
          applicationUserName: userId,
        ),
      );
      if (!ok) {
        // `false` nghĩa là không mở được luồng mua — chưa có biên lai nào sinh
        // ra, nên phải tự đóng completer, không thì màn hình quay mãi.
        _finish(const PlayPurchaseResult(
          PlayPurchaseOutcome.failed,
          message: 'premium.play_launch_failed',
        ));
      }
    } catch (e) {
      debugPrint('PlayBilling: khong mo duoc luong mua: $e');
      _finish(const PlayPurchaseResult(
        PlayPurchaseOutcome.failed,
        message: 'premium.play_launch_failed',
      ));
    }

    return completer.future;
  }

  /// Nhặt lại các biên lai đã trả tiền nhưng chưa xác thực xong với server.
  ///
  /// Gọi lúc mở màn hình gói. Trường hợp cần nó: người dùng trả tiền, app rớt
  /// mạng ngay lúc gọi server, biên lai nằm lại trong tài khoản Google. Không có
  /// bước này thì tiền đã mất mà gói không bao giờ tới.
  Future<void> restore() async {
    if (!await isAvailable()) return;
    start();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('PlayBilling: khong khoi phuc duoc bien lai: $e');
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          // Google đang chờ người dùng trả tiền (thẻ cần xác thực, hoặc thanh
          // toán chậm kiểu chuyển khoản). Chưa có gì để làm.
          break;

        case PurchaseStatus.canceled:
          await _complete(p);
          _finish(const PlayPurchaseResult(PlayPurchaseOutcome.canceled));
          break;

        case PurchaseStatus.error:
          debugPrint('PlayBilling: Google bao loi: ${p.error?.message}');
          await _complete(p);
          _finish(const PlayPurchaseResult(
            PlayPurchaseOutcome.failed,
            message: 'premium.play_failed',
          ));
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyThenComplete(p);
          break;
      }
    }
  }

  Future<void> _verifyThenComplete(PurchaseDetails p) async {
    final token = p.verificationData.serverVerificationData;
    if (token.isEmpty) {
      _finish(const PlayPurchaseResult(
        PlayPurchaseOutcome.failed,
        message: 'premium.play_failed',
      ));
      return;
    }

    bool verified = false;
    try {
      final res = await ApiService.post('/premium/verify-google-play', {
        'token': token,
        'productId': p.productID,
      });
      verified = res is Map && res['success'] == true;
    } catch (e) {
      debugPrint('PlayBilling: server chua xac thuc duoc bien lai: $e');
    }

    if (verified) {
      // Chỉ `completePurchase` khi server đã cấp gói.
      //
      // Gọi sớm hơn là nói với Google "đã giao hàng" trong khi phía mình chưa
      // cấp gì. Google sẽ thôi phát lại biên lai đó, và người dùng mất tiền mà
      // không còn đường nào lấy lại gói — kể cả `restorePurchases()`.
      await _complete(p);
      if (_matchesPending(p)) {
        _finish(const PlayPurchaseResult(PlayPurchaseOutcome.granted));
      }
      return;
    }

    // Chưa xác thực được thì **giữ nguyên biên lai**: Google sẽ phát lại ở lần
    // mở app sau và `restore()` nhặt được.
    if (_matchesPending(p)) {
      _finish(const PlayPurchaseResult(
        PlayPurchaseOutcome.pendingVerification,
        message: 'premium.play_pending_verification',
      ));
    }
  }

  /// Biên lai này có phải của lần mua đang chờ không.
  ///
  /// Luồng biên lai phát cả những giao dịch cũ được khôi phục, không chỉ lần mua
  /// vừa bấm. Không lọc thì một biên lai cũ sẽ đóng nhầm completer và màn hình
  /// báo mua thành công cho một lần mua chưa xong.
  bool _matchesPending(PurchaseDetails p) =>
      _pendingProductId == null || p.productID == _pendingProductId;

  Future<void> _complete(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(p);
    } catch (e) {
      debugPrint('PlayBilling: khong dong duoc giao dich: $e');
    }
  }

  void _finish(PlayPurchaseResult result) {
    final c = _pending;
    _pending = null;
    _pendingProductId = null;
    if (c != null && !c.isCompleted) c.complete(result);
  }
}
