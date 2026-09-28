import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/core/theme/gen_z_tokens.dart';
import 'package:tripmate/core/widgets/pill_tag.dart';

/// Chip truyen `color` lam nen thi chu phai doi theo nen.
///
/// Loi that tren may: chip "Chi Phi Moi" ra chu hong nhat tren nen xanh bac
/// ha, gan nhu khong doc duoc — vi nen doi theo `color` con chu van giu
/// `inkSoft` vuot cho nen mo mac dinh.
void main() {
  Future<Color> textColorOf(WidgetTester tester, Widget pill) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(body: Center(child: pill)),
      ),
    );
    return tester.widget<Text>(find.text('Chi Phi Moi')).style!.color!;
  }

  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  testWidgets('nen sang thi chu phai tham, du tuong phan de doc', (
    tester,
  ) async {
    const bg = GenZTokens.successDark; // xanh bac ha sang
    final fg = await textColorOf(
      tester,
      const PillTag(text: 'Chi Phi Moi', color: bg),
    );
    expect(
      contrast(fg, bg),
      greaterThan(4.5),
      reason: 'chu tren nen mau phai dat nguong doc duoc 4.5:1',
    );
  });

  testWidgets('nen toi thi chu phai sang', (tester) async {
    const bg = Color(0xFF1A3A2E);
    final fg = await textColorOf(
      tester,
      const PillTag(text: 'Chi Phi Moi', color: bg),
    );
    expect(contrast(fg, bg), greaterThan(4.5));
  });
}
