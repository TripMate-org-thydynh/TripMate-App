// Tiện ích cho widget test: nạp file dịch THẬT (`assets/translations/vi.json`)
// để `.tr()` trả về câu tiếng Việt người dùng đọc được.
//
// Trước đây các test bọc thẳng vào `MaterialApp`, nên mọi `.tr()` trả về đúng
// cái khoá (`polls.empty`). Lúc màn hình còn in cứng chuỗi thì test vẫn xanh;
// sau khi i18n hoá thì test tìm "Chưa có bình chọn nào" và không thấy gì.
//
// Nạp trực tiếp qua `Localization.load` thay vì bọc widget `EasyLocalization`:
// widget đó nạp bất đồng bộ nên test phải thêm pump, còn cách này xong ngay
// trong `setUpAll` và giữ nguyên nhịp pump sẵn có của test.
import 'dart:convert';

// `Localization` va `Translations` khong nam trong export cong khai cua
// easy_localization 3.0.8 nen phai import thang tu `src`.
// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gọi một lần trong `setUpAll` của mỗi file test có dùng `.tr()`.
Future<void> initLocalization() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final raw = await rootBundle.loadString('assets/translations/vi.json');
  final map = json.decode(raw) as Map<String, dynamic>;
  Localization.load(const Locale('vi'), translations: Translations(map));
}

/// Bọc [child] trong `MaterialApp` — bản dịch đã nạp sẵn ở [initLocalization].
Widget localized(Widget child) => MaterialApp(home: child);
