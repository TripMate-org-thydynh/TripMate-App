import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../data/xp_repository.dart';

/// Viên hiển thị số dư XP hiện tại.
///
/// Đặt ở AppBar của các màn cửa hàng để lúc nào cũng thấy còn bao nhiêu — trước
/// đây không màn nào cho biết số dư, vì chưa hề có số dư nào.
class XpBalanceChip extends ConsumerWidget {
  final bool isDark;

  const XpBalanceChip({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref
        .watch(xpWalletProvider)
        .maybeWhen(data: (w) => w.balance, orElse: () => null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GenZTokens.yellow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: GenZTokens.ink,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 15, color: GenZTokens.ink),
          const SizedBox(width: 3),
          Text(
            // Chưa tải xong thì hiện '—' thay vì 0, để không ai tưởng mình hết XP.
            balance == null ? '—' : '$balance',
            style: AppFonts.heading(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: GenZTokens.ink,
            ),
          ),
        ],
      ),
    );
  }
}
