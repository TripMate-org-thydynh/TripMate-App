import 'dart:ui';

/// Ngôn ngữ khởi đầu theo cài đặt máy: tiếng Việt nếu bất kỳ ngôn ngữ ưu tiên
/// nào là `vi` hoặc vùng là `VN` (người Việt để máy tiếng Anh vẫn ra tiếng
/// Việt); ngược lại tiếng Anh.
Locale detectStartLocale(List<Locale> deviceLocales) {
  for (final l in deviceLocales) {
    if (l.languageCode == 'vi' || l.countryCode?.toUpperCase() == 'VN') {
      return const Locale('vi');
    }
  }
  return const Locale('en');
}
