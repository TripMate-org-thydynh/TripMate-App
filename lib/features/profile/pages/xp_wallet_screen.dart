import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../data/xp_repository.dart';

/// Ví XP: số dư, cấp, và sổ cái từng lần cộng/trừ.
///
/// Sổ cái quan trọng vì XP nay là tiền tệ thật — người dùng phải tra được vì sao
/// số dư ra con số đó, thay vì thấy một con số không giải thích được.
class XpWalletScreen extends ConsumerWidget {
  final bool isDarkMode;

  const XpWalletScreen({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'xp.wallet'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ink),
            onPressed: () => ref.invalidate(xpWalletProvider),
          ),
        ],
      ),
      body: ref
          .watch(xpWalletProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(xpWalletProvider),
            ),
            data: (w) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(xpWalletProvider),
              child: ListView(
                padding: const EdgeInsets.all(GenZTokens.space5),
                children: [
                  _summary(isDark, w),
                  const SizedBox(height: GenZTokens.space5),
                  Text(
                    'xp.history'.tr(),
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: GenZTokens.space3),
                  if (w.history.isEmpty)
                    Text(
                      'xp.history_empty'.tr(),
                      style: AppFonts.body(
                        fontSize: 13,
                        color: isDark
                            ? GenZTokens.inkSoftDark
                            : GenZTokens.inkSoft,
                      ),
                    )
                  else
                    for (final e in w.history) _entry(isDark, e),
                ],
              ),
            ),
          ),
    );
  }

  Widget _summary(bool isDark, XpWallet w) {
    // Còn bao nhiêu XP nữa lên cấp — tính từ tổng đã kiếm, không phải số dư.
    final toNext = w.xpPerLevel - (w.earned % w.xpPerLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GenZTokens.space6),
      decoration: BoxDecoration(
        color: GenZTokens.yellow,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: GenZTokens.ink,
          width: GenZTokens.borderWidth,
        ),
      ),
      child: Column(
        children: [
          Text(
            '${w.balance}',
            style: AppFonts.heading(
              fontSize: 46,
              fontWeight: FontWeight.w900,
              color: GenZTokens.ink,
            ),
          ),
          Text(
            'xp.balance'.tr(),
            style: AppFonts.body(fontSize: 13, color: GenZTokens.ink),
          ),
          const SizedBox(height: GenZTokens.space5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'xp.level'.tr(args: ['${w.level}']),
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: GenZTokens.ink,
                ),
              ),
              Text(
                'xp.to_next'.tr(args: ['$toNext']),
                style: AppFonts.body(fontSize: 12.5, color: GenZTokens.ink),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: w.levelProgress / 100,
              minHeight: 10,
              backgroundColor: GenZTokens.ink.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(GenZTokens.ink),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${'xp.earned'.tr()}: ${w.earned}',
            style: AppFonts.body(fontSize: 12, color: GenZTokens.ink),
          ),
        ],
      ),
    );
  }

  Widget _entry(bool isDark, XpEntry e) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final at = e.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: GenZTokens.space2),
      padding: const EdgeInsets.symmetric(
        horizontal: GenZTokens.space4,
        vertical: GenZTokens.space3,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        children: [
          Icon(
            e.isEarn ? Icons.add_circle_outline : Icons.remove_circle_outline,
            size: 18,
            color: e.isEarn ? GenZTokens.success : GenZTokens.orange,
          ),
          const SizedBox(width: GenZTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                if (at != null)
                  Text(
                    DateFormat.yMMMd().add_Hm().format(at.toLocal()),
                    style: AppFonts.body(fontSize: 11.5, color: inkSoft),
                  ),
              ],
            ),
          ),
          Text(
            e.isEarn ? '+${e.delta}' : '${e.delta}',
            style: AppFonts.heading(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: e.isEarn ? GenZTokens.success : GenZTokens.orange,
            ),
          ),
        ],
      ),
    );
  }
}
