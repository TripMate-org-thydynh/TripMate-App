import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/core/locale_detect.dart';

void main() {
  test('máy tiếng Việt → vi', () {
    expect(detectStartLocale(const [Locale('vi', 'VN')]), const Locale('vi'));
  });
  test('máy tiếng Anh nhưng vùng Việt Nam → vi', () {
    expect(detectStartLocale(const [Locale('en', 'VN')]), const Locale('vi'));
  });
  test('máy tiếng Anh ở Mỹ → en', () {
    expect(detectStartLocale(const [Locale('en', 'US')]), const Locale('en'));
  });
  test('tiếng Việt là ngôn ngữ ưu tiên thứ hai → vi', () {
    expect(
      detectStartLocale(const [Locale('ja', 'JP'), Locale('vi')]),
      const Locale('vi'),
    );
  });
  test('không có thông tin → en', () {
    expect(detectStartLocale(const []), const Locale('en'));
  });
}
