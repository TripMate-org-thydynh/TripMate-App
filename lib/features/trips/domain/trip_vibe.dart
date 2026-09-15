import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/gen_z_tokens.dart';

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
      PhosphorIconsFill.cloud,
      GenZTokens.blue,
    ),
    'PARTY': TripVibe(
      'PARTY',
      'trips.vibe_party',
      PhosphorIconsFill.confetti,
      GenZTokens.magenta,
    ),
    'ADVENTURE': TripVibe(
      'ADVENTURE',
      'trips.vibe_adventure',
      PhosphorIconsFill.mountains,
      GenZTokens.green,
    ),
    'FOODIE': TripVibe(
      'FOODIE',
      'trips.vibe_foodie',
      PhosphorIconsFill.forkKnife,
      GenZTokens.orange,
    ),
    'CULTURE': TripVibe(
      'CULTURE',
      'trips.vibe_culture',
      PhosphorIconsFill.bank,
      GenZTokens.purple,
    ),
    'AESTHETIC': TripVibe(
      'AESTHETIC',
      'trips.vibe_aesthetic',
      PhosphorIconsFill.cameraPlus,
      GenZTokens.yellow,
    ),
  };

  /// Trả metadata cho code, hoặc null nếu không nhận diện được.
  static TripVibe? of(String? code) =>
      code == null ? null : _all[code.toUpperCase()];
}
