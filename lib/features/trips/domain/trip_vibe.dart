import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Metadata hiển thị cho vibe chuyến đi (code lưu ở BE: CHILL, PARTY...).
class TripVibe {
  final String code;

  /// KEY i18n, không phải nhãn — `_all` là const map nên không gọi được `.tr()`
  /// lúc khai báo. Dùng [label] để lấy nhãn theo ngôn ngữ hiện tại.
  final String labelKey;
  final IconData icon;
  final Color color;

  const TripVibe(this.code, this.labelKey, this.icon, this.color);

  /// Nhãn đã dịch — đọc lại mỗi lần gọi nên đổi ngôn ngữ là cập nhật ngay.
  String get label => labelKey.tr();

  static const _all = <String, TripVibe>{
    'CHILL': TripVibe(
      'CHILL',
      'trips.vibe_chill',
      Icons.cloud_outlined,
      Color(0xFF06B6D4),
    ),
    'PARTY': TripVibe(
      'PARTY',
      'trips.vibe_party',
      Icons.celebration_outlined,
      Color(0xFFD6248C),
    ),
    'ADVENTURE': TripVibe(
      'ADVENTURE',
      'trips.vibe_adventure',
      Icons.terrain_outlined,
      Color(0xFF1FA85C),
    ),
    'FOODIE': TripVibe(
      'FOODIE',
      'trips.vibe_foodie',
      Icons.restaurant_outlined,
      Color(0xFFF5822B),
    ),
    'CULTURE': TripVibe(
      'CULTURE',
      'trips.vibe_culture',
      Icons.account_balance_outlined,
      Color(0xFF8B4DE8),
    ),
    'AESTHETIC': TripVibe(
      'AESTHETIC',
      'trips.vibe_aesthetic',
      Icons.camera_alt_outlined,
      Color(0xFFFFB020),
    ),
  };

  /// Trả metadata cho code, hoặc null nếu không nhận diện được.
  static TripVibe? of(String? code) =>
      code == null ? null : _all[code.toUpperCase()];
}
