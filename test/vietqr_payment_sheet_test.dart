import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/premium/presentation/vietqr_payment_sheet.dart';

import 'helpers/localized.dart';

void main() {
  setUpAll(initLocalization);

  Widget wrap(Widget child) =>
      ProviderScope(child: localized(Scaffold(body: child)));

  testWidgets('VietQrPaymentSheet hiển thị đầy đủ thông tin ngân hàng và mã chuyển khoản',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        const VietQrPaymentSheet(
          orderCode: 'TM9X8A1Z',
          amount: 39000,
          qrUrl: 'https://vietqr.app/img?bank=MBBank&acc=0949064234&amount=39000&des=TM9X8A1Z',
          payUrl: 'https://qr.sepay.vn/gateway?acc=0949064234&bank=MBBank&amount=39000&des=TM9X8A1Z',
          bankInfo: {
            'bankCode': 'MBBank',
            'accountNumber': '0949064234',
            'accountName': 'CHAU THANH TRUNG',
            'amount': 39000,
            'transferContent': 'TM9X8A1Z',
          },
        ),
      ),
    );
    await tester.pump();

    // Tiêu đề
    expect(find.text('Quét mã VietQR để thanh toán'), findsOneWidget);

    // Thông tin tài khoản MBBank & CHAU THANH TRUNG
    expect(find.text('MBBank'), findsOneWidget);
    expect(find.text('0949064234'), findsOneWidget);
    expect(find.text('CHAU THANH TRUNG'), findsOneWidget);

    // Số tiền và cú pháp chuyển tiền
    expect(find.text('39.000 ₫'), findsOneWidget);
    expect(find.text('TM9X8A1Z'), findsWidgets);

    // Lắng nghe Webhook tự động
    expect(find.text('Đang chờ ngân hàng thông báo nhận tiền...'), findsOneWidget);
    expect(find.text('Tôi đã chuyển khoản xong'), findsNothing);
  });
}
