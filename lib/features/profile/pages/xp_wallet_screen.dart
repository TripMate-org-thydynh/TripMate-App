import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
    final isDark = isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'xp.wallet'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise(), color: ink),
            onPressed: () => ref.invalidate(xpWalletProvider),
          ),
        ],
      ),
      body: ref
          .watch(xpWalletProvider)
          .when(
            loading: () => Center(
              child: CircularProgressIndicator(
                color: accent,
                strokeWidth: 2,
              ),
            ),
            error: (e, _) => AppErrorState(
              isDark: isDark,
              error: e,
              onRetry: () => ref.invalidate(xpWalletProvider),
            ),
            data: (w) => RefreshIndicator(
              color: accent,
              onRefresh: () async => ref.invalidate(xpWalletProvider),
              child: ListView(
                padding: const EdgeInsets.all(GenZTokens.space4),
                children: [
                  _summary(isDark, w),
                  const SizedBox(height: GenZTokens.space5),
                  Text(
                    'xp.history'.tr(),
                    style: AppFonts.heading(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: GenZTokens.space3),
                  if (w.history.isEmpty)
                    Text(
                      'xp.history_empty'.tr(),
                      style: AppFonts.body(
                        fontSize: 13,
                        color: inkSoft,
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
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    // Còn bao nhiêu XP nữa lên cấp — tính từ tổng đã kiếm, không phải số dư.
    final toNext = w.xpPerLevel - (w.earned % w.xpPerLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GenZTokens.space5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        children: [
          Text(
            '${w.balance}',
            style: AppFonts.mono(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'xp.balance'.tr(),
            style: AppFonts.body(fontSize: 13, color: inkSoft),
          ),
          const SizedBox(height: GenZTokens.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'xp.level'.tr(args: ['${w.level}']),
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              Text(
                'xp.to_next'.tr(args: ['$toNext']),
                style: AppFonts.body(fontSize: 12, color: inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
            child: LinearProgressIndicator(
              value: w.levelProgress / 100,
              minHeight: 8,
              backgroundColor: fill,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${'xp.earned'.tr()}: ${w.earned}',
            style: AppFonts.body(fontSize: 12, color: inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _entry(bool isDark, XpEntry e) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;
    final at = e.createdAt;
    final deltaColor = e.isEarn ? success : danger;

    return Container(
      margin: const EdgeInsets.only(bottom: GenZTokens.space2),
      padding: const EdgeInsets.symmetric(
        horizontal: GenZTokens.space4,
        vertical: GenZTokens.space3,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        children: [
          Icon(
            e.isEarn ? PhosphorIcons.plusCircle() : PhosphorIcons.minusCircle(),
            size: 20,
            color: deltaColor,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ink,
                  ),
                ),
                if (at != null)
                  Text(
                    DateFormat.yMMMd().add_Hm().format(at.toLocal()),
                    style: AppFonts.body(fontSize: 12, color: inkSoft),
                  ),
              ],
            ),
          ),
          Text(
            e.isEarn ? '+${e.delta}' : '${e.delta}',
            style: AppFonts.mono(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: deltaColor,
            ),
          ),
        ],
      ),
    );
  }
}
