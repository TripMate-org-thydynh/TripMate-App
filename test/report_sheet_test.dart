import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tripmate/core/widgets/report_sheet.dart';

import 'helpers/localized.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });

  for (final dark in [false, true]) {
    testWidgets(
      'Sheet báo cáo: chưa chọn lý do thì không gửi được (dark=$dark)',
      (tester) async {
        tester.view.physicalSize = const Size(360 * 3, 640 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: dark ? ThemeData.dark() : ThemeData.light(),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => ReportSheet.show(
                      context,
                      target: ReportTarget.template,
                      targetId: 'x',
                    ),
                    child: const Text('mở'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('mở'));
        await tester.pumpAndSettle();

        expect(find.text('Báo cáo vi phạm'), findsOneWidget);
        final submit = find.widgetWithText(FilledButton, 'Gửi báo cáo');
        expect(tester.widget<FilledButton>(submit).onPressed, isNull);

        await tester.tap(find.text('Spam hoặc quảng cáo'));
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
