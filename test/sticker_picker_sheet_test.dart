import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tripmate/features/profile/data/xp_repository.dart';
import 'package:tripmate/features/social/data/custom_stickers_repository.dart';
import 'package:tripmate/features/social/presentation/widgets/sticker_picker_sheet.dart';

import 'helpers/localized.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });

  for (final dark in [false, true]) {
    testWidgets('Bảng sticker: có ô tạo sticker, chạm sticker emoji thì gửi '
        '(dark=$dark)', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      String? sent;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customStickersProvider.overrideWith((ref) async => const []),
            myStickersProvider.overrideWith(
              (ref) async => [
                StoreItem.fromJson(const {
                  'id': 'stk-laugh',
                  'emoji': '😂',
                  'labelKey': 'laugh',
                  'costXp': 100,
                }),
              ],
            ),
          ],
          child: MaterialApp(
            theme: dark ? ThemeData.dark() : ThemeData.light(),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => StickerPickerSheet.show(
                    context,
                    tripId: 't1',
                    onPick: (c) => sent = c,
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

      expect(find.text('Sticker của tôi'), findsOneWidget);
      expect(find.bySemanticsLabel('Tạo sticker từ ảnh'), findsOneWidget);

      await tester.tap(find.text('😂'));
      await tester.pumpAndSettle();
      expect(sent, 'stk-laugh');
      expect(tester.takeException(), isNull);
    });
  }
}
