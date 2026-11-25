import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tripmate/features/gamification/o_an_quan/o_an_quan_screen.dart';

import 'helpers/localized.dart';

Widget _wrap({required bool dark}) => MaterialApp(
  theme: dark ? ThemeData.dark() : ThemeData.light(),
  // Tắt hoạt ảnh để nước đi áp dụng ngay, test không phải chờ từng bước.
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: const OAnQuanScreen(),
);

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });

  for (final dark in [false, true]) {
    testWidgets('Ô Ăn Quan dựng được và đi được một nước (dark=$dark)', (
      tester,
    ) async {
      // Màn hẹp cỡ điện thoại nhỏ — bắt lỗi tràn layout.
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrap(dark: dark));
      await tester.pumpAndSettle();

      expect(find.text('Ô Ăn Quan'), findsOneWidget);
      expect(find.text('Rải phải'), findsNothing);

      // Chạm ô đầu tiên của người 1 (hàng dưới) → hiện hai nút chọn chiều.
      await tester.tap(find.byKey(const ValueKey('oaq-cell-1')));
      await tester.pumpAndSettle();
      expect(find.text('Rải phải'), findsOneWidget);

      await tester.tap(find.text('Rải phải'));
      await tester.pumpAndSettle();

      // Lượt chuyển sang người 2 (hoặc người 1 nếu rút được thẻ thêm lượt).
      final dialog = find.byType(AlertDialog);
      if (dialog.evaluate().isNotEmpty) {
        await tester.tap(find.text('Xong'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Rải phải'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
