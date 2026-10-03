import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/features/ai/widgets/matey_message_body.dart';

Widget _wrap(String text, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: SingleChildScrollView(
          child: MateyMessageBody(
            text: text,
            textColor: Colors.black,
            linkColor: Colors.blue,
          ),
        ),
      ),
    );

String _allText(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((r) => r.text.toPlainText())
    .join('\n');

void main() {
  testWidgets('ảnh markdown thành ảnh, alt thành chú thích', (tester) async {
    await tester.pumpWidget(
      _wrap(
        'Lịch trình nè:\n![Hồ Xuân Hương](https://example.com/a.webp)\nHết.',
      ),
    );
    final img = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(img.imageUrl, 'https://example.com/a.webp');
    expect(find.text('Hồ Xuân Hương'), findsOneWidget);
    // Cú pháp markdown không lọt ra thành chữ.
    expect(_allText(tester), isNot(contains('![')));
  });

  testWidgets('ảnh http (không mã hoá) bị bỏ qua, giữ nguyên chữ', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap('![x](http://example.com/a.jpg)'));
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('đậm, gạch đầu dòng, link rút gọn', (tester) async {
    await tester.pumpWidget(
      _wrap(
        '- **Ngày 1:** Suối Tía\n'
        'Nguồn: [tatinta.com](https://tatinta.com/blogs/x)\n'
        'https://www.vnguide.vn/entertainment/war-remnants-museum-311103',
      ),
    );
    final all = _allText(tester);
    expect(all, contains('•'));
    expect(all, contains('Ngày 1:'));
    expect(all, isNot(contains('**')));
    expect(all, contains('tatinta.com'));
    expect(all, isNot(contains('](')));
    // Link trần dài được rút gọn thay vì làm vỡ bong bóng.
    expect(all, contains('vnguide.vn/entertainment/war-remna…'));
  });

  testWidgets('cú pháp ảnh chưa chảy xong vẫn hiện như chữ', (tester) async {
    await tester.pumpWidget(_wrap('![Hồ Xu'));
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(_allText(tester), contains('![Hồ Xu'));
  });

  testWidgets('chế độ tối dựng được', (tester) async {
    await tester.pumpWidget(
      _wrap('![a](https://example.com/a.png)', brightness: Brightness.dark),
    );
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
}
