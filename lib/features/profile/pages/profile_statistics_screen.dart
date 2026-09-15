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
/// "1,250 XP", "98% 🛡️" — không đọc dữ liệu nào (BUG-015). Đáng chú ý là chính
/// con số 4.200km ấy đã bị backend cố ý từ chối bịa (`users.service.ts` ghi rõ
/// *"thay vì số giả 4200km"*), nhưng nó vẫn sống ở tầng UI.
class ProfileStatisticsScreen extends ConsumerWidget {
  const ProfileStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final state = ref.watch(profileDataProvider);
    final stats = state.stats;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.stats_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ink,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              elevation: 0,
              color: surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: ink, width: 2.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: state.isLoading && stats == null
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: GenZTokens.orange,
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
                            inkSoft,
                          ),
                          Divider(
                            height: 24,
                            color: inkSoft.withValues(alpha: 0.2),
                          ),
                          _row(
                            'profile.stat_distance_done'.tr(),
                            '${_int(stats, 'totalDistanceKm')} km',
                            inkSoft,
                          ),
                          Divider(
                            height: 24,
                            color: inkSoft.withValues(alpha: 0.2),
                          ),
                          _row(
                            'profile.stat_places_done'.tr(),
                            'profile.place_count'.tr(
                              namedArgs: {'n': '${_int(stats, 'totalPlaces')}'},
                            ),
                            inkSoft,
                          ),
                          Divider(
                            height: 24,
                            color: inkSoft.withValues(alpha: 0.2),
                          ),
                          _row(
                            'profile.stat_xp'.tr(),
                            '${formatMoney(_int(stats, 'achievementPoints'), locale: context.locale.languageCode).replaceAll(RegExp(r'\s*[đ₫]$'), '')} XP',
                            inkSoft,
                          ),
                          Divider(
                            height: 24,
                            color: inkSoft.withValues(alpha: 0.2),
                          ),
                          _row(
                            'profile.stat_reputation'.tr(),
                            '${_int(stats, 'squadReputationScore')}%',
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

  Widget _row(String title, String val, Color inkSoft) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppFonts.body(color: inkSoft),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          val,
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            color: GenZTokens.purple,
          ),
        ),
      ],
    );
  }
}
