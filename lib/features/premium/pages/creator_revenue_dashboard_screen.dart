import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/api_service.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';

/// Chợ nhà sáng tạo.
///
/// **Chợ này chưa tồn tại.** Không có luồng nộp tác phẩm, không có người sáng
/// tạo nào, và theme/sticker được mua bằng XP chứ không bằng tiền — danh mục
/// là một mảng do team soạn trong `store.catalog.ts`. Nên không có doanh thu
/// để chia và không có khoản chi trả nào đang chờ.
///
/// Bản trước dựng một bảng doanh thu đầy đủ: 1.450.000đ doanh thu, 70% chia
/// cho người sáng tạo, 450.000đ chờ chi trả, ba giao dịch kèm tên người mua cụ
/// thể — tất cả đều bịa và giống hệt nhau ở mọi tài khoản. Tệ nhất là nút "Rút
/// tiền": nó `Future.delayed(1500)` rồi báo "đã chi trả thành công" và đặt số
/// dư về 0. Không đồng nào đi đâu cả, nhưng người dùng vừa được thông báo là
/// đã nhận tiền.
///
/// Nay màn này nói thật: chợ chưa mở, kèm những con số đo được thật về cửa
/// hàng XP đang chạy.
class CreatorRevenueDashboardScreen extends StatefulWidget {
  const CreatorRevenueDashboardScreen({super.key});

  @override
  State<CreatorRevenueDashboardScreen> createState() =>
      _CreatorRevenueDashboardScreenState();
}

class _CreatorRevenueDashboardScreenState
    extends State<CreatorRevenueDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final res = await ApiService.get('/premium/creator-revenue');
    if (!mounted) return;
    setState(() {
      _data = res is Map ? res.cast<String, dynamic>() : null;
      _failed = _data == null;
      _loading = false;
    });
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
          'creator.title'.tr(),
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

    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final open = _data?['marketplaceOpen'] as bool? ?? false;

    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView(
        padding: const EdgeInsets.all(GenZTokens.space5),
        children: [
          if (!open)
            Container(
              padding: const EdgeInsets.all(GenZTokens.space5),
              decoration: BoxDecoration(
                color: GenZTokens.lilac,
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                border: Border.all(
                  color: GenZTokens.ink,
                  width: GenZTokens.borderWidth,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 28,
                    color: GenZTokens.ink,
                  ),
                  const SizedBox(height: GenZTokens.space3),
                  Text(
                    'creator.not_open_title'.tr(),
                    style: AppFonts.heading(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: GenZTokens.ink,
                    ),
                  ),
                  const SizedBox(height: GenZTokens.space2),
                  Text(
                    'creator.not_open_body'.tr(),
                    style: AppFonts.body(
                      fontSize: 13,
                      height: 1.45,
                      color: GenZTokens.ink,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: GenZTokens.space5),
          Text(
            'creator.my_store_title'.tr(),
            style: AppFonts.heading(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: GenZTokens.space2),
          Text(
            'creator.my_store_body'.tr(),
            style: AppFonts.body(fontSize: 12, color: inkSoft, height: 1.4),
          ),
          const SizedBox(height: GenZTokens.space4),

          Row(
            children: [
              Expanded(
                child: _stat(
                  isDark,
                  label: 'creator.stickers_owned'.tr(),
                  value: '${_data?['stickersOwned'] ?? 0}',
                ),
              ),
              const SizedBox(width: GenZTokens.space3),
              Expanded(
                child: _stat(
                  isDark,
                  label: 'creator.themes_owned'.tr(),
                  value: '${_data?['themesOwned'] ?? 0}',
                ),
              ),
            ],
          ),
          const SizedBox(height: GenZTokens.space3),
          _stat(
            isDark,
            label: 'creator.xp_spent'.tr(),
            // Đơn vị là XP, không phải đồng — cửa hàng này tiêu XP.
            value: '${_data?['xpSpent'] ?? 0} XP',
          ),
        ],
      ),
    );
  }

  Widget _stat(bool isDark, {required String label, required String value}) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppFonts.body(fontSize: 12, color: inkSoft)),
        ],
      ),
    );
  }
}
