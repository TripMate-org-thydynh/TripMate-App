import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/api_service.dart';
import '../../../core/format/money.dart';
import '../../../core/theme/gen_z_tokens.dart';

class BillingHistoryScreen extends StatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  State<BillingHistoryScreen> createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends State<BillingHistoryScreen> {
  // Rỗng cho tới khi /premium/billing-history trả giao dịch thật (endpoint
  // nay đọc bảng payment_transactions). Trước đây 3 hoá đơn cứng
  // "Visa *4242 · 99.000đ · Thành công" hiện cho cả tài khoản chưa mua gì.
  List<Map<String, dynamic>> _invoices = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBillingHistory();
  }

  Future<void> _fetchBillingHistory() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.get('/premium/billing-history');
    if (response != null && response['history'] != null) {
      final List<dynamic> list = response['history'] as List<dynamic>;
      setState(() {
        _invoices = list
            .map(
              (item) => {
                'id': item['id'] ?? 'GD-${item.hashCode.abs()}',
                'date': item['date'] ?? 'premium.recent'.tr(),
                'title': item['description'] ?? 'premium.upgrade_tx'.tr(),
                'amount': formatMoney(
                  (item['amount'] as int?) ?? 0,
                  locale: context.locale.languageCode,
                ),
                'method': item['method'] ?? 'premium.saved_source'.tr(),
                'status': item['status'] ?? 'common.success_plain'.tr(),
              },
            )
            .toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final backgroundColor =
        isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surfaceColor =
        isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final accentColor = isDark ? GenZTokens.lilac : GenZTokens.purple;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(),
            color: ink,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'premium.billing_history'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIcons.arrowsClockwise(),
              color: ink,
            ),
            onPressed: _fetchBillingHistory,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor,
              ),
            )
          : _invoices.isEmpty
          // Chưa mua gì thì nói thẳng, thay vì hiện hoá đơn bịa như trước.
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.receipt(),
                      size: 40,
                      color: inkSoft,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'premium.no_invoices'.tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 14,
                        color: inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final inv = _invoices[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ink.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            inv['title'] as String,
                            style: AppFonts.heading(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          inv['amount'] as String,
                          style: AppFonts.heading(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'premium.tx_id_date'.tr(
                            namedArgs: {
                              'id': '${inv['id']}',
                              'date': '${inv['date']}',
                            },
                          ),
                          style: AppFonts.heading(
                            fontSize: 11.5,
                            color: inkSoft,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'premium.paid_with'.tr(
                            namedArgs: {'method': '${inv['method']}'},
                          ),
                          style: AppFonts.heading(
                            fontSize: 11.5,
                            color: inkSoft,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        PhosphorIcons.downloadSimple(),
                        color: accentColor,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'premium.downloading_invoice'.tr(
                                namedArgs: {'id': '${inv['id']}'},
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
