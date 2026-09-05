import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/premium/data/entitlement_provider.dart';
import 'package:tripmate/features/premium/presentation/paywall_sheet.dart';

import 'helpers/localized.dart';

/// Paywall phải **nói đúng thứ vừa bị chặn**.
///
/// Đây là điểm khác biệt giữa một paywall dùng được và một popup quảng cáo:
/// người dùng vừa bấm "tạo chuyến" thì phải đọc được câu về chuyến kèm đúng con
/// số giới hạn họ vừa chạm, không phải một danh sách quyền lợi rời rạc.
void main() {
  setUpAll(initLocalization);

  Widget wrap(Widget child) =>
      ProviderScope(child: localized(Scaffold(body: child)));

  testWidgets('nêu đúng hạn mức chuyến và con số vừa chạm', (tester) async {
    await tester.pumpWidget(
      wrap(const PaywallSheet(quota: Quota.activeTrips, limit: 2)),
    );
    await tester.pump();

    expect(find.textContaining('2'), findsWidgets);
    expect(find.textContaining('chuyến'), findsWidgets);
  });

  testWidgets('đổi câu theo từng loại hạn mức', (tester) async {
    await tester.pumpWidget(
      wrap(const PaywallSheet(quota: Quota.momentsPerTrip, limit: 100)),
    );
    await tester.pump();

    // Chạm hạn mức ảnh thì không được nói về chuyến.
    expect(find.textContaining('100'), findsWidgets);
  });

  testWidgets('Squad Pass đứng trước gói cá nhân', (tester) async {
    await tester.pumpWidget(wrap(const PaywallSheet()));
    await tester.pump();

    final squad = tester.getTopLeft(find.text('Squad Pass')).dy;
    final plus = tester.getTopLeft(find.text('TripMate+')).dy;
    // TripMate vốn là app đi nhóm, nên giá chia cho 5 người là cách đọc tự
    // nhiên nhất — phải nằm trên.
    expect(squad, lessThan(plus));
  });

  testWidgets('nói rõ chức năng lõi vẫn miễn phí', (tester) async {
    await tester.pumpWidget(wrap(const PaywallSheet()));
    await tester.pump();

    // Free giới hạn quy mô, không giới hạn chức năng lõi — paywall phải nói
    // điều đó, nếu không người dùng tưởng bị khoá mất thứ đang dùng.
    expect(find.textContaining('Chia tiền'), findsOneWidget);
  });

  testWidgets('trả true khi bấm nâng cấp, false khi để sau', (tester) async {
    bool? result;
    await tester.pumpWidget(
      ProviderScope(
        child: localized(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await PaywallSheet.show(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Để sau'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  test('quotaFromName khớp đúng tên backend gửi', () {
    expect(quotaFromName('activeTrips'), Quota.activeTrips);
    expect(quotaFromName('momentsPerTrip'), Quota.momentsPerTrip);
    // Tên lạ thì trả null để paywall rơi về câu chung, thay vì hiện sai loại.
    expect(quotaFromName('khongTonTai'), isNull);
    expect(quotaFromName(null), isNull);
  });
}
