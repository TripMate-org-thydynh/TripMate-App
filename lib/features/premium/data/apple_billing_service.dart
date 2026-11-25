import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/api_service.dart';
import '../../../core/distribution_channel.dart';

/// Kết quả một lần mua qua Apple App Store.
enum ApplePurchaseOutcome {
  /// Đã trả tiền và server đã cấp gói.
  granted,

  /// Người dùng đóng hộp thoại của Apple giữa chừng.
  canceled,

  /// Trả tiền xong nhưng chưa xác nhận được với server.
  ///
  /// Không phải mất tiền. Biên lai vẫn nằm trong tài khoản Apple của người
  /// dùng và `restorePurchases()` sẽ lấy lại được ở lần mở app sau.
  pendingVerification,

  /// Không mở được luồng mua, hoặc Apple từ chối.
  failed,
}

class ApplePurchaseResult {
  const ApplePurchaseResult(this.outcome, {this.message});
  final ApplePurchaseOutcome outcome;
  final String? message;
}

/// Mua gói qua Apple In-App Purchase (StoreKit).
///
/// Luồng hoạt động song song với Play Billing: Apple giữ tiền và giữ giá,
/// app nhận về biên lai (transactionId / receiptData) rồi đưa cho backend
/// xác thực tại `/premium/apple/verify`.
class AppleBillingService {
  AppleBillingService._([InAppPurchase? iap])
      : _iap = iap ?? InAppPurchase.instance;
  static AppleBillingService instance = AppleBillingService._();

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Chờ kết quả của lần mua đang mở. Chỉ có tối đa một lần mua tại một thời điểm.
  Completer<ApplePurchaseResult>? _pending;

  /// Mã sản phẩm của lần mua đang chờ, để đối chiếu biên lai trả về.
  String? _pendingProductId;

  bool _started = false;

  /// Giá hiển thị theo đúng định dạng vùng của Apple ID, khoá theo mã sản phẩm.
  final Map<String, ProductDetails> _products = {};

  /// Cửa hàng có sẵn sàng không. Trả `false` trên bản không phải App Store.
  Future<bool> isAvailable() async {
    if (!kAppleBillingAvailable) return false;
    try {
      return await _iap.isAvailable();
    } catch (e) {
      debugPrint('AppleBilling: khong kiem tra duoc cua hang: $e');
      return false;
    }
  }

  /// Nạp thông tin sản phẩm từ Apple StoreKit.
  Future<Map<String, ProductDetails>> loadProducts(Set<String> ids) async {
    if (ids.isEmpty || !await isAvailable()) return const {};
    try {
      final res = await _iap.queryProductDetails(ids);
      if (res.notFoundIDs.isNotEmpty) {
        debugPrint(
          'AppleBilling: StoreKit khong co san pham ${res.notFoundIDs}',
        );
      }
      for (final p in res.productDetails) {
        _products[p.id] = p;
      }
      return {for (final p in res.productDetails) p.id: p};
    } catch (e) {
      debugPrint('AppleBilling: loi nap san pham: $e');
      return const {};
    }
  }

  /// Bắt đầu lắng nghe luồng biên lai.
  void start() {
    if (_started || !kAppleBillingAvailable) return;
    _started = true;
    _sub = _iap.purchaseStream.listen(
      _onPurchases,
      onDone: () => _sub?.cancel(),
      onError: (Object e) => debugPrint('AppleBilling: loi luong bien lai: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _started = false;
  }

  /// Mở hộp thoại mua của Apple và chờ tới khi server cấp xong gói.
  Future<ApplePurchaseResult> buy({
    required String productId,
    required String userId,
  }) async {
    if (!await isAvailable()) {
      return const ApplePurchaseResult(
        ApplePurchaseOutcome.failed,
        message: 'premium.apple_unavailable',
      );
    }
    if (_pending != null) {
      return const ApplePurchaseResult(
        ApplePurchaseOutcome.failed,
        message: 'premium.apple_busy',
      );
    }

    start();

    final product =
        _products[productId] ?? (await loadProducts({productId}))[productId];
    if (product == null) {
      return const ApplePurchaseResult(
        ApplePurchaseOutcome.failed,
        message: 'premium.apple_product_missing',
      );
    }

    final completer = Completer<ApplePurchaseResult>();
    _pending = completer;
    _pendingProductId = productId;

    try {
      final ok = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: userId,
        ),
      );
      if (!ok) {
        _finish(
          const ApplePurchaseResult(
            ApplePurchaseOutcome.failed,
            message: 'premium.apple_launch_failed',
          ),
        );
      }
    } catch (e) {
      debugPrint('AppleBilling: khong mo duoc luong mua: $e');
      _finish(
        const ApplePurchaseResult(
          ApplePurchaseOutcome.failed,
          message: 'premium.apple_launch_failed',
        ),
      );
    }

    return completer.future;
  }

  /// Khôi phục các giao dịch đã mua trên tài khoản Apple ID.
  Future<void> restore() async {
    if (!await isAvailable()) return;
    start();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('AppleBilling: khong khoi phuc duoc bien lai: $e');
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          break;

        case PurchaseStatus.canceled:
          await _complete(p);
          _finish(const ApplePurchaseResult(ApplePurchaseOutcome.canceled));
          break;

        case PurchaseStatus.error:
          debugPrint('AppleBilling: StoreKit bao loi: ${p.error?.message}');
          await _complete(p);
          _finish(
            const ApplePurchaseResult(
              ApplePurchaseOutcome.failed,
              message: 'premium.apple_failed',
            ),
          );
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyThenComplete(p);
          break;
      }
    }
  }

  Future<void> _verifyThenComplete(PurchaseDetails p) async {
    final receiptData = p.verificationData.serverVerificationData;
    final transactionId = p.purchaseID;
    if (receiptData.isEmpty &&
        (transactionId == null || transactionId.isEmpty)) {
      _finish(
        const ApplePurchaseResult(
          ApplePurchaseOutcome.failed,
          message: 'premium.apple_failed',
        ),
      );
      return;
    }

    bool verified = false;
    try {
      final res = await ApiService.post('/premium/apple/verify', {
        if (transactionId != null && transactionId.isNotEmpty)
          'transactionId': transactionId,
        if (receiptData.isNotEmpty) 'receiptData': receiptData,
        'productId': p.productID,
      });
      verified = res is Map && res['success'] == true;
    } catch (e) {
      debugPrint('AppleBilling: server chua xac thuc duoc bien lai: $e');
    }

    if (verified) {
      // Chỉ complete khi server đã cấp gói thành công
      await _complete(p);
      if (_matchesPending(p)) {
        _finish(const ApplePurchaseResult(ApplePurchaseOutcome.granted));
      }
      return;
    }

    // Chưa xác thực được thì giữ nguyên biên lai để restore sau
    if (_matchesPending(p)) {
      _finish(
        const ApplePurchaseResult(
          ApplePurchaseOutcome.pendingVerification,
          message: 'premium.apple_pending_verification',
        ),
      );
    }
  }

  bool _matchesPending(PurchaseDetails p) =>
      _pendingProductId == null || p.productID == _pendingProductId;

  Future<void> _complete(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(p);
    } catch (e) {
      debugPrint('AppleBilling: khong dong duoc giao dich: $e');
    }
  }

  void _finish(ApplePurchaseResult result) {
    final c = _pending;
    _pending = null;
    _pendingProductId = null;
    if (c != null && !c.isCompleted) c.complete(result);
  }
}
