import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api_service.dart';
import '../../../core/format/money.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';

/// Màn mua gói.
///
/// Bản trước gọi thẳng Google Play Billing với product id `elite_squad_monthly`
/// — một sản phẩm chưa từng được tạo trên Play Console — rồi rơi vào nhánh
/// "chưa mở bán" ở mọi lần bấm. Nó cũng đọc `response['benefits']`, một trường
/// backend không hề trả về, nên danh sách quyền lợi luôn là bản cứng.
///
/// Nay đi qua ví Momo/ZaloPay, là đường duy nhất hiện có cổng thật:
/// `/premium/plans` cho bảng giá → `/premium/orders` tạo đơn → mở link ví →
/// hỏi lại `/premium/orders/:id` cho tới khi webhook về.
///
/// Giá và kỳ hạn **không** hardcode ở đây: chép số ra client là lúc nào đó UI
/// nói một giá còn server thu một giá khác.
class SubscriptionCheckoutScreen extends StatefulWidget {
  const SubscriptionCheckoutScreen({super.key});

  @override
  State<SubscriptionCheckoutScreen> createState() =>
      _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState
    extends State<SubscriptionCheckoutScreen> {
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
  }

  List<String> get _gateways =>
      (_catalog?['gateways'] as List?)?.whereType<String>().toList() ??
      const [];

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

    final res = await ApiService.post('/premium/orders', {
      'plan': _plan,
      'months': _months,
      'provider': _gateway,
      // Chỉ gửi MÃ, không gửi mức giảm: server tự tra và tự tính. Gửi số tiền
      // lên thì mua gói năm với giá 1.000đ.
      if (_promo != null) 'promoCode': _promo!['code'],
    });

    if (!mounted) return;
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
  /// Bỏ cuộc sau 2 phút thay vì quay vòng mãi; đơn treo sẽ tự hết hạn ở server.
  void _watchOrder(String orderId) {
    var elapsed = 0;
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 3), (t) async {
      elapsed += 3;
      final res = await ApiService.get('/premium/orders/$orderId');
      if (!mounted) {
        t.cancel();
        return;
      }
      final status = res is Map ? res['status'] as String? : null;

      if (status == 'SUCCESS') {
        t.cancel();
        setState(() => _processing = false);
        _showSuccess();
      } else if (status == 'FAILED' || status == 'CANCELLED') {
        t.cancel();
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('premium.payment_failed'.tr())),
        );
      } else if (elapsed >= 120) {
        t.cancel();
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('premium.payment_pending'.tr())),
        );
      }
    });
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'premium.joined_elite'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.heading(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: Text('common.got_it'.tr()),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        icon: Icons.storefront_outlined,
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
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
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
          gateway == 'MOMO' ? 'MoMo' : 'ZaloPay',
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
    final total = _payable;
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _processing ? null : _buy,
        style: ElevatedButton.styleFrom(
          backgroundColor: GenZTokens.ink,
          foregroundColor: GenZTokens.cream,
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
                  color: GenZTokens.cream,
                ),
              )
            : Text(
                'premium.pay_now'.tr(
                  namedArgs: {'amount': formatMoney(total, locale: locale)},
                ),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
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
            const Icon(Icons.local_offer, size: 18, color: GenZTokens.ink),
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
              icon: const Icon(Icons.close, size: 18, color: GenZTokens.ink),
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
