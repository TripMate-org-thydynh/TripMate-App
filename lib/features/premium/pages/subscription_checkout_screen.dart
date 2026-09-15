import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api_service.dart';
import '../../../core/format/money.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/play_billing_service.dart';
import '../presentation/vietqr_payment_sheet.dart';

/// Màn mua gói.
///
/// Bản trước gọi thẳng Google Play Billing với product id `elite_squad_monthly`
/// — một sản phẩm chưa từng được tạo trên Play Console — rồi rơi vào nhánh
/// "chưa mở bán" ở mọi lần bấm. Nó cũng đọc `response['benefits']`, một trường
/// backend không hề trả về, nên danh sách quyền lợi luôn là bản cứng.
///
/// Hai kiểu thanh toán, **không bao giờ hiện cùng lúc**:
///
/// - **Google Play Billing** ở bản tải từ CH Play. Google giữ tiền và giữ giá;
///   app chỉ mở hộp thoại của Google rồi đưa biên lai cho server xác thực.
/// - **VietQR qua SePay và ví Momo/ZaloPay** ở bản APK/web:
///   `/premium/plans` → `/premium/orders` tạo đơn → mở QR hoặc link ví → hỏi
///   lại `/premium/orders/:id` cho tới khi webhook về.
///
/// **Server quyết định bày cổng nào**, dựa trên header `X-Client-Channel`. Màn
/// này chỉ vẽ đúng những gì `/premium/plans` trả về. Lý do phải chặt như vậy:
/// chính sách Payments của Google cấm bày cổng thanh toán khác cạnh Play
/// Billing trong bản phát hành trên CH Play, và Việt Nam chưa nằm trong chương
/// trình "User Choice Billing" cho phép ngoại lệ đó.
///
/// Giá và kỳ hạn **không** hardcode ở đây: chép số ra client là lúc nào đó UI
/// nói một giá còn server thu một giá khác.
class SubscriptionCheckoutScreen extends ConsumerStatefulWidget {
  const SubscriptionCheckoutScreen({super.key});

  @override
  ConsumerState<SubscriptionCheckoutScreen> createState() =>
      _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState
    extends ConsumerState<SubscriptionCheckoutScreen> {
  Map<String, dynamic>? _catalog;
  bool _loading = true;
  bool _failed = false;

  String _plan = 'PLUS';
  int _months = 1;
  String? _gateway;

  /// Đang chờ ví trả lời. Khoá nút để không tạo hai đơn cho một lần mua.
  bool _processing = false;
  Timer? _poll;

  /// Mã giảm giá đã được server chấp nhận, kèm số tiền giảm THẬT.
  ///
  /// Giữ nguyên phản hồi của server thay vì tự nhân phần trăm ở client: hai
  /// bên tính khác nhau một đồng là người dùng thấy một giá rồi bị thu một giá
  /// khác.
  final _promoController = TextEditingController();
  Map<String, dynamic>? _promo;
  String? _promoError;
  bool _checkingPromo = false;

  /// Thông tin sản phẩm do Google trả về, khoá theo mã sản phẩm.
  ///
  /// Rỗng ở bản không phải CH Play, và cũng rỗng nếu Google chưa duyệt sản
  /// phẩm — cả hai trường hợp đều dẫn tới cùng một kết quả: không có nút Play
  /// Billing để bấm.
  Map<String, ProductDetails> _playProducts = const {};

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  /// Nạp giá từ Google và nhặt lại biên lai còn treo.
  ///
  /// Biên lai treo là trường hợp người dùng đã trả tiền nhưng app rớt mạng ngay
  /// lúc gọi server xác thực. Không có bước này thì tiền đã mất mà gói không
  /// bao giờ tới, và người dùng không có cách nào tự sửa.
  Future<void> _initPlayBilling() async {
    if (!_gateways.contains('GOOGLE_PLAY')) return;

    final ids = <String>{};
    for (final plan in _plans) {
      final terms = (plan['terms'] as List?)?.whereType<Map>().toList();
      for (final t in terms ?? const <Map>[]) {
        final id = t['playProductId'];
        if (id is String && id.isNotEmpty) ids.add(id);
      }
    }
    if (ids.isEmpty) return;

    final loaded = await PlayBillingService.instance.loadProducts(ids);
    if (!mounted) return;
    setState(() => _playProducts = loaded);

    await PlayBillingService.instance.restore();
  }

  /// Hỏi server xem mã có dùng được cho gói đang chọn không.
  ///
  /// Kiểm theo đúng gói và kỳ hạn hiện tại, vì có mã chỉ áp cho một gói — kiểm
  /// chung chung rồi báo hợp lệ, tới lúc tạo đơn mới hỏng là tệ hơn không kiểm.
  Future<void> _applyPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty || _checkingPromo) return;
    setState(() {
      _checkingPromo = true;
      _promoError = null;
    });

    final res = await ApiService.post('/premium/promo-codes/validate', {
      'code': code,
      'plan': _plan,
      'months': _months,
    });

    if (!mounted) return;
    setState(() {
      _checkingPromo = false;
      if (res is Map && res['discount'] != null) {
        _promo = res.cast<String, dynamic>();
      } else {
        _promo = null;
        _promoError = 'premium.promo_invalid'.tr();
      }
    });
  }

  void _clearPromo() {
    setState(() {
      _promo = null;
      _promoError = null;
      _promoController.clear();
    });
  }

  /// Số tiền cuối cùng phải trả — đã trừ giảm giá nếu có.
  int get _payable {
    final total = ((_selectedTerm?['total'] as num?) ?? 0).toInt();
    final discounted = (_promo?['total'] as num?)?.toInt();
    return discounted ?? total;
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final res = await ApiService.get('/premium/plans');
    if (!mounted) return;
    setState(() {
      _catalog = res is Map ? res.cast<String, dynamic>() : null;
      _failed = _catalog == null;
      _loading = false;
      final gws = _gateways;
      _gateway = gws.isEmpty ? null : gws.first;
    });
    // Sau khi biết server bày cổng nào mới hỏi Google — bản APK/web không có
    // Play Billing thì không việc gì phải gọi tới cửa hàng.
    unawaited(_initPlayBilling());
  }

  /// Cổng được bày, **đúng như server trả về**.
  ///
  /// Bản trước tự chèn `SEPAY` vào đầu danh sách khi server không trả về nó.
  /// Điều đó vô hiệu hoá toàn bộ việc lọc theo kênh phân phối: bản phát hành
  /// trên CH Play vẫn hiện nút VietQR, đúng thứ chính sách của Google cấm.
  /// Server thiếu cổng nào là có lý do của nó — chưa cấu hình tài khoản nhận
  /// tiền, hoặc kênh này không được phép — nên client không đoán thay.
  /// Mua qua Google Play Billing.
  ///
  /// Không tạo đơn ở server và không gửi số tiền đi đâu cả: Google giữ tiền,
  /// giữ giá, và trả về một biên lai. Server xác thực biên lai đó **trực tiếp
  /// với Google** rồi mới cấp gói — nên gói được cấp dựa trên thứ Google xác
  /// nhận đã bán, không dựa trên bất cứ điều gì màn hình này khai.
  ///
  /// Mã giảm giá của TripMate không áp được ở nhánh này. Khuyến mãi trên Play
  /// là mã do Google phát hành và người dùng nhập trong hộp thoại của Google,
  /// không phải ô nhập mã ở màn này.
  Future<void> _buyViaPlay() async {
    final productId = _playProductId;
    final userId = ref.read(authProvider).user?['id'] as String?;

    if (productId == null || userId == null) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('premium.play_product_missing'.tr())),
        );
      }
      return;
    }

    final result = await PlayBillingService.instance.buy(
      productId: productId,
      userId: userId,
    );
    if (!mounted) return;
    setState(() => _processing = false);

    switch (result.outcome) {
      case PlayPurchaseOutcome.granted:
        _handleSuccess();
        break;
      case PlayPurchaseOutcome.canceled:
        // Người dùng chủ động đóng hộp thoại. Không có gì hỏng, nên không báo lỗi.
        break;
      case PlayPurchaseOutcome.pendingVerification:
      case PlayPurchaseOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((result.message ?? 'premium.play_failed').tr()),
          ),
        );
        break;
    }
  }

  List<String> get _gateways =>
      (_catalog?['gateways'] as List?)?.whereType<String>().toList() ??
      const [];

  /// Mã sản phẩm Play của kỳ hạn đang chọn. `null` nếu kỳ hạn này không bán
  /// trên Play.
  String? get _playProductId => _selectedTerm?['playProductId'] as String?;

  /// Giá Google hiển thị cho kỳ hạn đang chọn.
  ///
  /// Play tự quy đổi tiền tệ và tự cộng thuế theo nước người mua, nên con số
  /// duy nhất đúng cho nhánh này là con số Google trả về — không phải giá VND
  /// trong bảng giá của mình.
  String? get _playPrice {
    final id = _playProductId;
    return id == null ? null : _playProducts[id]?.price;
  }

  List<Map<String, dynamic>> get _plans =>
      (_catalog?['plans'] as List?)
          ?.whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList() ??
      const [];

  Map<String, dynamic>? get _selectedPlan {
    for (final p in _plans) {
      if (p['plan'] == _plan) return p;
    }
    return _plans.isEmpty ? null : _plans.first;
  }

  List<Map<String, dynamic>> get _terms =>
      (_selectedPlan?['terms'] as List?)
          ?.whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList() ??
      const [];

  Map<String, dynamic>? get _selectedTerm {
    for (final t in _terms) {
      if (t['months'] == _months) return t;
    }
    return _terms.isEmpty ? null : _terms.first;
  }

  /// Tạo đơn rồi mở ví.
  ///
  /// Không gửi số tiền lên server — server tự tính theo bảng giá của nó. Gửi
  /// được thì mua gói năm với giá 1.000đ.
  Future<void> _buy() async {
    if (_gateway == null || _processing) return;
    setState(() => _processing = true);

    if (_gateway == 'GOOGLE_PLAY') {
      await _buyViaPlay();
      return;
    }

    if (_gateway == 'SEPAY') {
      try {
        final res = await ApiService.post('/premium/checkout', {
          'plan': _plan,
          'tier': _plan,
          'months': _months,
          'paymentMethod': 'SEPAY',
          if (_promo != null) 'promoCode': _promo!['code'],
        });
        if (!mounted) return;
        if (res is Map && res['payUrl'] != null) {
          final orderCode =
              res['orderCode'] as String? ?? res['orderId'] as String? ?? '';
          final qrUrl =
              res['vietqrUrl'] as String? ?? res['qrUrl'] as String? ?? '';
          final amount = (res['amount'] as num?)?.toInt() ?? 10000;
          final payUrl = res['payUrl'] as String?;
          final bankInfo = res['bankInfo'] as Map<String, dynamic>?;

          final success = await VietQrPaymentSheet.show(
            context,
            orderCode: orderCode,
            amount: amount,
            qrUrl: qrUrl,
            payUrl: payUrl,
            bankInfo: bankInfo,
          );
          if (success == true) {
            _handleSuccess();
          }
        }
      } catch (e) {
        debugPrint('VietQR checkout error: $e');
      } finally {
        if (mounted) setState(() => _processing = false);
      }
      return;
    }

    final res = await ApiService.post('/premium/orders', {
      'plan': _plan,
      'months': _months,
      'provider': _gateway,
      // Chỉ gửi MÃ, không gửi mức giảm: server tự tra và tự tính. Gửi số tiền
      // lên thì mua gói năm với giá 1.000đ.
      if (_promo != null) 'promoCode': _promo!['code'],
    });

    if (!mounted) return;

    // Đơn 0 đồng được server hoàn tất ngay nên không có payUrl, không phải lỗi.
    if (res is Map && res['paid'] == true) {
      _handleSuccess();
      return;
    }

    if (res is! Map || res['payUrl'] == null) {
      // ApiService đã hiện snackbar lỗi từ server.
      setState(() => _processing = false);
      return;
    }

    final orderId = res['orderId'] as String;
    final url = Uri.parse((res['deeplink'] ?? res['payUrl']) as String);
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('premium.cannot_open_wallet'.tr())),
      );
      return;
    }

    _watchOrder(orderId);
  }

  /// Hỏi lại trạng thái đơn cho tới khi webhook về.
  ///
  /// Người dùng gần như luôn quay lại app trước khi cổng kịp gọi webhook, nên
  /// không thể coi "vừa về từ ví" là "đã trả tiền" — chỉ server mới biết.
  /// Giãn dần polling (5 lần đầu cách 3s, sau đó 6s, rồi 10s) để tránh chạm trần
  /// 100 req/60s của backend; dừng sau khoảng 2 phút như cũ.
  void _watchOrder(String orderId) {
    var attempts = 0;
    var elapsed = 0;
    _poll?.cancel();

    void schedulePoll() {
      final int interval;
      if (attempts < 5) {
        interval = 3;
      } else if (attempts < 15) {
        interval = 6;
      } else {
        interval = 10;
      }

      _poll = Timer(Duration(seconds: interval), () async {
        attempts++;
        elapsed += interval;
        final res = await ApiService.get('/premium/orders/$orderId');
        if (!mounted) return;
        final status = res is Map ? res['status'] as String? : null;

        if (status == 'SUCCESS') {
          _handleSuccess();
        } else if (status == 'FAILED' || status == 'CANCELLED') {
          setState(() => _processing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('premium.payment_failed'.tr())),
          );
        } else if (elapsed >= 120) {
          setState(() => _processing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('premium.payment_pending'.tr())),
          );
        } else {
          schedulePoll();
        }
      });
    }

    schedulePoll();
  }

  void _handleSuccess() {
    if (!mounted) return;
    _poll?.cancel();
    setState(() => _processing = false);
    _showSuccess();
  }

  void _showSuccess() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final accent = isDark ? GenZTokens.lilac : GenZTokens.purple;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? GenZTokens.paperDark : GenZTokens.paper,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: GenZTokens.success,
              ),
              child: Icon(
                PhosphorIcons.check(PhosphorIconsStyle.bold),
                color: GenZTokens.ink,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'premium.joined_elite'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: Text(
              'common.got_it'.tr(),
              style: AppFonts.heading(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'premium.upgrade_elite'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: _body(isDark),
    );
  }

  Widget _body(bool isDark) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_failed) return AppErrorState(isDark: isDark, onRetry: _fetch);

    // Chưa cấu hình cổng nào ở server thì nói thẳng là chưa mở bán, thay vì vẽ
    // nút mua để người dùng bấm vào một lỗi.
    if (_gateways.isEmpty) {
      return AppEmptyState(
        isDark: isDark,
        icon: PhosphorIcons.storefront(),
        title: 'premium.not_on_sale'.tr(),
        body: 'premium.not_on_sale_2'.tr(),
      );
    }

    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'vi';
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return ListView(
      padding: const EdgeInsets.all(GenZTokens.space5),
      children: [
        _sectionLabel('premium.choose_plan'.tr(), ink),
        const SizedBox(height: GenZTokens.space3),
        ..._plans.map((p) => _planCard(p, isDark, locale)),

        const SizedBox(height: GenZTokens.space5),
        _sectionLabel('premium.choose_term'.tr(), ink),
        const SizedBox(height: GenZTokens.space3),
        ..._terms.map((t) => _termCard(t, isDark, locale)),

        const SizedBox(height: GenZTokens.space5),
        _sectionLabel('premium.choose_wallet'.tr(), ink),
        const SizedBox(height: GenZTokens.space3),
        Row(
          children: _gateways
              .map(
                (g) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: GenZTokens.space2),
                    child: _walletChip(g, isDark),
                  ),
                ),
              )
              .toList(),
        ),

        const SizedBox(height: GenZTokens.space5),
        _sectionLabel('premium.promo_label'.tr(), ink),
        const SizedBox(height: GenZTokens.space3),
        _promoField(isDark, locale),

        const SizedBox(height: GenZTokens.space6),
        _payButton(isDark, locale),
        const SizedBox(height: GenZTokens.space3),
        // Nói rõ sẽ thu bao nhiêu, cho kỳ nào, trước khi người dùng bấm.
        Text(
          'premium.charge_notice'.tr(
            namedArgs: {
              'amount': formatMoney(_payable, locale: locale),
              'months': '$_months',
            },
          ),
          textAlign: TextAlign.center,
          style: AppFonts.body(
            fontSize: 12,
            color: isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, Color ink) => Text(
    text,
    style: AppFonts.heading(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: ink,
    ),
  );

  Widget _planCard(Map<String, dynamic> p, bool isDark, String locale) {
    final plan = p['plan'] as String;
    final selected = plan == _plan;
    final seats = (p['seats'] as num?)?.toInt() ?? 1;
    return _optionCard(
      isDark: isDark,
      selected: selected,
      onTap: () {
        setState(() {
          _plan = plan;
          _months = 1;
        });
        // Đổi gói thì mã phải kiểm lại: có mã chỉ áp cho một gói, giữ nguyên
        // mức giảm cũ là hiện một giá mà server sẽ không chấp nhận.
        if (_promo != null) _applyPromo();
      },
      title: 'premium.plan_$plan'.tr(),
      subtitle: seats > 1
          ? 'premium.seats_included'.tr(namedArgs: {'n': '$seats'})
          : 'premium.seats_single'.tr(),
      trailing:
          '${formatMoney((p['monthlyPrice'] as num?) ?? 0, locale: locale)}'
          '/${'premium.per_month'.tr()}',
    );
  }

  Widget _termCard(Map<String, dynamic> t, bool isDark, String locale) {
    final months = (t['months'] as num).toInt();
    final discount = ((t['discount'] as num?) ?? 0) * 100;
    return _optionCard(
      isDark: isDark,
      selected: months == _months,
      onTap: () {
        setState(() => _months = months);
        if (_promo != null) _applyPromo();
      },
      title: 'premium.term_months'.tr(namedArgs: {'n': '$months'}),
      subtitle: discount > 0
          ? 'premium.term_save'.tr(
              namedArgs: {'p': discount.toStringAsFixed(0)},
            )
          : '${formatMoney((t['perMonth'] as num?) ?? 0, locale: locale)}'
                '/${'premium.per_month'.tr()}',
      trailing: formatMoney((t['total'] as num?) ?? 0, locale: locale),
    );
  }

  /// Ô chọn dùng chung cho gói và kỳ hạn.
  Widget _optionCard({
    required bool isDark,
    required bool selected,
    required VoidCallback onTap,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    return Padding(
      padding: const EdgeInsets.only(bottom: GenZTokens.space3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(GenZTokens.space4),
          decoration: BoxDecoration(
            color: selected ? GenZTokens.lilac : surface,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(
              color: ink,
              width: selected
                  ? GenZTokens.borderWidth
                  : GenZTokens.borderWidthThin,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? PhosphorIcons.radioButton(PhosphorIconsStyle.fill)
                    : PhosphorIcons.circle(),
                color: selected ? GenZTokens.ink : inkSoft,
                size: 20,
              ),
              const SizedBox(width: GenZTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.heading(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: selected ? GenZTokens.ink : ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppFonts.body(
                        fontSize: 12,
                        color: selected ? GenZTokens.ink : inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                trailing,
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: selected ? GenZTokens.ink : ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletChip(String gateway, bool isDark) {
    final selected = gateway == _gateway;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    return InkWell(
      onTap: () => setState(() => _gateway = gateway),
      borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: GenZTokens.space3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? GenZTokens.pink : surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
          border: Border.all(
            color: ink,
            width: selected
                ? GenZTokens.borderWidth
                : GenZTokens.borderWidthThin,
          ),
        ),
        child: Text(
          switch (gateway) {
            'SEPAY' => 'VietQR',
            'MOMO' => 'MoMo',
            'ZALOPAY' => 'ZaloPay',
            'GOOGLE_PLAY' => 'Google Play',
            _ => gateway,
          },
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: selected ? GenZTokens.ink : ink,
          ),
        ),
      ),
    );
  }

  Widget _payButton(bool isDark, String locale) {
    // Qua Play thì giá do Google định và đã gồm thuế của nước người mua, nên
    // hiển thị đúng chuỗi Google trả về. Vẽ giá VND của mình ở đây là hứa một
    // con số mà hộp thoại thanh toán ngay sau đó sẽ nói khác.
    if (_gateway == 'GOOGLE_PLAY') {
      final price = _playPrice;
      return SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _processing || price == null ? null : _buy,
          style: ElevatedButton.styleFrom(
            backgroundColor: GenZTokens.yellow,
            foregroundColor: GenZTokens.ink,
            elevation: 0,
            side: BorderSide(
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
              width: GenZTokens.borderWidth,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
            ),
          ),
          child: _processing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: GenZTokens.ink,
                  ),
                )
              : Text(
                  price == null
                      ? 'premium.play_product_missing'.tr()
                      : 'premium.pay_now'.tr(namedArgs: {'amount': price}),
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: GenZTokens.ink,
                  ),
                ),
        ),
      );
    }

    final total = _payable;
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _processing ? null : _buy,
        style: ElevatedButton.styleFrom(
          backgroundColor: GenZTokens.yellow,
          foregroundColor: GenZTokens.ink,
          elevation: 0,
          side: BorderSide(
            color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
            width: GenZTokens.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
          ),
        ),
        child: _processing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: GenZTokens.ink,
                ),
              )
            : Text(
                'premium.pay_now'.tr(
                  namedArgs: {'amount': formatMoney(total, locale: locale)},
                ),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: GenZTokens.ink,
                ),
              ),
      ),
    );
  }

  /// Ô nhập mã giảm giá.
  ///
  /// Khi mã được chấp nhận, hiện thẳng số tiền được giảm chứ không hiện "giảm
  /// 50%": người dùng cần biết mình trả bao nhiêu, không phải làm phép nhân.
  Widget _promoField(bool isDark, String locale) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final promo = _promo;

    if (promo != null) {
      return Container(
        padding: const EdgeInsets.all(GenZTokens.space4),
        decoration: BoxDecoration(
          color: GenZTokens.green,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: GenZTokens.ink,
            width: GenZTokens.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.tag(PhosphorIconsStyle.fill),
              size: 18,
              color: GenZTokens.ink,
            ),
            const SizedBox(width: GenZTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo['code'] as String? ?? '',
                    style: AppFonts.heading(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: GenZTokens.ink,
                    ),
                  ),
                  Text(
                    'premium.promo_saved'.tr(
                      namedArgs: {
                        'amount': formatMoney(
                          (promo['discount'] as num?) ?? 0,
                          locale: locale,
                        ),
                      },
                    ),
                    style: AppFonts.body(fontSize: 12, color: GenZTokens.ink),
                  ),
                ],
              ),
            ),
            // Gỡ mã phải dễ như áp mã.
            IconButton(
              onPressed: _clearPromo,
              icon: Icon(PhosphorIcons.x(), size: 18, color: GenZTokens.ink),
              tooltip: 'premium.promo_remove'.tr(),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: GenZTokens.space4),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
            border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'premium.promo_hint'.tr(),
                    hintStyle: AppFonts.body(fontSize: 13, color: inkSoft),
                  ),
                  onSubmitted: (_) => _applyPromo(),
                ),
              ),
              _checkingPromo
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: _applyPromo,
                      child: Text(
                        'premium.promo_apply'.tr(),
                        style: AppFonts.heading(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        if (_promoError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _promoError!,
              style: AppFonts.body(fontSize: 12, color: GenZTokens.danger),
            ),
          ),
      ],
    );
  }
}
