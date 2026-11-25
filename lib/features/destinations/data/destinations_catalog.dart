import 'package:easy_localization/easy_localization.dart';
import 'package:latlong2/latlong.dart';

/// Một điểm đến gợi ý trên trang chủ.
///
/// Danh sách cố định (không gọi API): tên, mô tả và mùa nên đi lấy qua i18n
/// `destinations.<id>.*`, toạ độ dùng để hỏi thời tiết Open-Meteo.
class Destination {
  const Destination({
    required this.id,
    required this.coords,
    required this.keywords,
    this.coverAsset,
  });

  final String id;
  final LatLng coords;

  /// Từ khoá không dấu để khớp khi gõ tìm (vd. "da lat", "dalat").
  final List<String> keywords;

  /// Ảnh bìa trong `assets/images/`; `null` thì dùng minh hoạ.
  final String? coverAsset;

  String get name => 'destinations.$id.name'.tr();
  String get blurb => 'destinations.$id.blurb'.tr();
  String get season => 'destinations.$id.season'.tr();

  /// 3 điểm nên ghé (gợi ý tĩnh khi kho mẫu chưa có lịch trình cho điểm này).
  List<String> get highlights =>
      [for (var i = 1; i <= 3; i++) 'destinations.$id.spot$i'.tr()];

  bool matches(String query) {
    final q = foldVietnamese(query).trim();
    if (q.isEmpty) return false;
    if (foldVietnamese(name).contains(q)) return true;
    return keywords.any((k) => k.contains(q) || q.contains(k));
  }
}

const destinationsCatalog = <Destination>[
  Destination(
    id: 'dalat',
    coords: LatLng(11.9406, 108.4452),
    keywords: ['da lat', 'dalat', 'lam dong'],
    coverAsset: 'assets/images/cover_dalat.webp',
  ),
  Destination(
    id: 'phuquoc',
    coords: LatLng(10.2899, 103.9840),
    keywords: ['phu quoc', 'phuquoc', 'kien giang'],
    coverAsset: 'assets/images/cover_phuquoc.webp',
  ),
  Destination(
    id: 'danang',
    coords: LatLng(16.0470, 108.2060),
    keywords: ['da nang', 'danang'],
    coverAsset: 'assets/images/cover_danang.webp',
  ),
  Destination(
    id: 'hoian',
    coords: LatLng(15.8801, 108.3380),
    keywords: ['hoi an', 'hoian', 'quang nam'],
  ),
  Destination(
    id: 'sapa',
    coords: LatLng(22.3364, 103.8438),
    keywords: ['sa pa', 'sapa', 'lao cai'],
    coverAsset: 'assets/images/cover_sapa.webp',
  ),
  Destination(
    id: 'nhatrang',
    coords: LatLng(12.2388, 109.1967),
    keywords: ['nha trang', 'nhatrang', 'khanh hoa'],
  ),
  Destination(
    id: 'hagiang',
    coords: LatLng(22.8233, 104.9836),
    keywords: ['ha giang', 'hagiang'],
  ),
  Destination(
    id: 'hue',
    coords: LatLng(16.4637, 107.5909),
    keywords: ['hue', 'thua thien'],
  ),
];

/// Bỏ dấu tiếng Việt + chữ thường, để "Đà Lạt" khớp "da lat".
String foldVietnamese(String input) {
  const from =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  const to =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  final lower = input.toLowerCase();
  final b = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}
