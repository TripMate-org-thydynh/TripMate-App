import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/format/money.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/profile_provider.dart';

/// Thống kê hồ sơ — **số liệu thật** từ `GET /users/me/stats`.
///
/// Trước đây toàn bộ màn này là số bịa viết cứng: "12 chuyến đi", "4,200 km",
/// "1,250 XP", "98%" — không đọc dữ liệu nào (BUG-015). Đáng chú ý là chính
/// con số 4.200km ấy đã bị backend cố ý từ chối bịa (`users.service.ts` ghi rõ
/// *"thay vì số giả 4200km"*), nhưng nó vẫn sống ở tầng UI.
class ProfileStatisticsScreen extends ConsumerWidget {
  const ProfileStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final state = ref.watch(profileDataProvider);
    final stats = state.stats;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.stats_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(GenZTokens.space4),
        child: Column(
          children: [
            Card(
              elevation: 0,
              color: surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                side: BorderSide(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(GenZTokens.space4),
                child: state.isLoading && stats == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(GenZTokens.space4),
                          child: CircularProgressIndicator(
                            color: accent,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          _row(
                            'profile.stat_trips_done'.tr(),
                            'profile.trip_count'.tr(
                              namedArgs: {'n': '${_int(stats, 'totalTrips')}'},
                            ),
                            ink,
                            inkSoft,
                          ),
                          Divider(
                            height: GenZTokens.space5,
                            color: line,
                          ),
                          _row(
                            'profile.stat_distance_done'.tr(),
                            '${_int(stats, 'totalDistanceKm')} km',
                            ink,
                            inkSoft,
                          ),
                          Divider(
                            height: GenZTokens.space5,
                            color: line,
                          ),
                          _row(
                            'profile.stat_places_done'.tr(),
                            'profile.place_count'.tr(
                              namedArgs: {'n': '${_int(stats, 'totalPlaces')}'},
                            ),
                            ink,
                            inkSoft,
                          ),
                          Divider(
                            height: GenZTokens.space5,
                            color: line,
                          ),
                          _row(
                            'profile.stat_xp'.tr(),
                            '${formatMoney(_int(stats, 'achievementPoints'), locale: context.locale.languageCode).replaceAll(RegExp(r'\s*[đ₫]$'), '')} XP',
                            ink,
                            inkSoft,
                          ),
                          Divider(
                            height: GenZTokens.space5,
                            color: line,
                          ),
                          _row(
                            'profile.stat_reputation'.tr(),
                            '${_int(stats, 'squadReputationScore')}%',
                            ink,
                            inkSoft,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Thiếu trường thì hiện 0 — không suy đoán, không bịa.
  static int _int(Map<String, dynamic>? stats, String key) =>
      (stats?[key] as num?)?.toInt() ?? 0;

  Widget _row(String title, String val, Color ink, Color inkSoft) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppFonts.body(fontSize: 15, color: inkSoft),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          val,
          style: AppFonts.mono(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
      ],
    );
  }
}
