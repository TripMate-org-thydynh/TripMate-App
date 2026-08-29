import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Một dòng trong sổ cái XP.
class XpEntry {
  final String id;

  /// Dương = kiếm được, âm = đã tiêu.
  final int delta;
  final String reason;
  final int balanceAfter;
  final DateTime? createdAt;

  const XpEntry({
    required this.id,
    required this.delta,
    required this.reason,
    required this.balanceAfter,
    this.createdAt,
  });

  bool get isEarn => delta > 0;

  /// Nhãn tiếng người. BE chỉ trả mã lý do nên client dịch theo ngôn ngữ đang
  /// chọn; mã lạ (BE thêm lý do mới) rơi về nhãn chung thay vì hiện mã thô.
  String get label {
    const known = {
      'MOMENT_SHARED',
      'EXPENSE_ADDED',
      'ITINERARY_ADDED',
      'NOTE_ADDED',
      'JOURNAL_WRITTEN',
      'POLL_CREATED',
      'DOCUMENT_UPLOADED',
      'GAME_PLAYED',
      'STICKER_PURCHASE',
      'THEME_PURCHASE',
      'ADMIN_ADJUST',
    };
    final key = known.contains(reason) ? reason.toLowerCase() : 'unknown';
    return 'xp.reason_$key'.tr();
  }

  factory XpEntry.fromJson(Map<String, dynamic> j) => XpEntry(
    id: j['id'] as String? ?? '',
    delta: (j['delta'] as num?)?.toInt() ?? 0,
    reason: j['reason'] as String? ?? '',
    balanceAfter: (j['balanceAfter'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''),
  );
}

/// Ví XP cá nhân — số dư tiêu được, tổng đã kiếm, cấp.
class XpWallet {
  final int balance;
  final int earned;
  final int level;

  /// 0..100 tới cấp kế tiếp.
  final int levelProgress;
  final int xpPerLevel;
  final List<XpEntry> history;

  const XpWallet({
    required this.balance,
    required this.earned,
    required this.level,
    required this.levelProgress,
    required this.xpPerLevel,
    this.history = const [],
  });

  factory XpWallet.fromJson(Map<String, dynamic> j) => XpWallet(
    balance: (j['balance'] as num?)?.toInt() ?? 0,
    earned: (j['earned'] as num?)?.toInt() ?? 0,
    level: (j['level'] as num?)?.toInt() ?? 1,
    levelProgress: (j['levelProgress'] as num?)?.toInt() ?? 0,
    xpPerLevel: (j['xpPerLevel'] as num?)?.toInt() ?? 500,
    history:
        (j['history'] as List?)
            ?.whereType<Map>()
            .map((e) => XpEntry.fromJson(e.cast<String, dynamic>()))
            .toList() ??
        const [],
  );
}

/// Một món trong cửa hàng (sticker hoặc theme).
class StoreItem {
  final String id;

  /// Emoji với sticker, `null` với theme.
  final String? emoji;

  /// Mã màu với theme, `null` với sticker.
  final String? colorHex;

  /// Khoá accent trong app — chỉ theme mới có.
  final String? accentKey;
  final String labelKey;
  final int costXp;
  final String rarity;
  final bool owned;
  final bool affordable;

  const StoreItem({
    required this.id,
    required this.labelKey,
    required this.costXp,
    this.emoji,
    this.colorHex,
    this.accentKey,
    this.rarity = 'COMMON',
    this.owned = false,
    this.affordable = false,
  });

  String get label => 'xp.item_$labelKey'.tr();

  factory StoreItem.fromJson(Map<String, dynamic> j) => StoreItem(
    id: j['id'] as String? ?? '',
    emoji: j['emoji'] as String?,
    colorHex: j['colorHex'] as String?,
    accentKey: j['accentKey'] as String?,
    labelKey: j['labelKey'] as String? ?? '',
    // Sticker dùng `costXp`, theme dùng `priceXp`.
    costXp:
        (j['costXp'] as num?)?.toInt() ?? (j['priceXp'] as num?)?.toInt() ?? 0,
    rarity: j['rarity'] as String? ?? 'COMMON',
    owned: j['owned'] as bool? ?? false,
    affordable: j['affordable'] as bool? ?? false,
  );
}

class XpRepository {
  final ApiClient _client;
  XpRepository(this._client);

  Future<XpWallet> fetchWallet() async {
    final data = await _client.getData('/xp/wallet');
    return XpWallet.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<List<StoreItem>> _list(String path) async {
    final data = await _client.getData(path);
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => StoreItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<List<StoreItem>> fetchStickerStore() => _list('/xp/stickers/store');
  Future<List<StoreItem>> fetchMyStickers() => _list('/xp/stickers/mine');
  Future<List<StoreItem>> fetchThemeStore() => _list('/xp/themes/store');
  Future<List<StoreItem>> fetchMyThemes() => _list('/xp/themes/mine');

  Future<void> buySticker(String stickerId) =>
      _client.postData('/xp/stickers/purchase', {'stickerId': stickerId});

  Future<void> buyTheme(String themeId) =>
      _client.postData('/xp/themes/purchase', {'themeId': themeId});
}

final xpRepositoryProvider = Provider<XpRepository>(
  (ref) => XpRepository(ref.watch(apiClientProvider)),
);

/// `autoDispose` có chủ đích: XP tăng ở khắp nơi (chơi game, đăng ảnh, ghi chi
/// tiêu), nên số dư phải đọc lại mỗi lần mở màn thay vì dùng bản cache cũ.
final xpWalletProvider = FutureProvider.autoDispose<XpWallet>(
  (ref) => ref.watch(xpRepositoryProvider).fetchWallet(),
);

final stickerStoreProvider = FutureProvider.autoDispose<List<StoreItem>>(
  (ref) => ref.watch(xpRepositoryProvider).fetchStickerStore(),
);

final myStickersProvider = FutureProvider.autoDispose<List<StoreItem>>(
  (ref) => ref.watch(xpRepositoryProvider).fetchMyStickers(),
);

final themeStoreProvider = FutureProvider.autoDispose<List<StoreItem>>(
  (ref) => ref.watch(xpRepositoryProvider).fetchThemeStore(),
);

/// Làm mới mọi thứ liên quan tới XP sau khi mua.
void invalidateXp(WidgetRef ref) {
  ref.invalidate(xpWalletProvider);
  ref.invalidate(stickerStoreProvider);
  ref.invalidate(myStickersProvider);
  ref.invalidate(themeStoreProvider);
}
