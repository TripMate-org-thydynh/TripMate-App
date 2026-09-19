import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../profile/data/xp_repository.dart';
import '../data/games_repository.dart';

/// Bảng thử thách chaos của squad.
///
/// Trước đây màn này liệt kê 4 thử thách in cứng ("Order mystery food — Voted
/// by Minh Nhật"...) và mọi nút Join đều chỉ hiện "Tính năng đang được hoàn
/// thiện". Nay bốc thử thách THẬT từ `/games/:tripId/dare/random` — BE điền
/// sẵn tên thành viên có thật trong chuyến — và bấm "Xong" sẽ ghi một ván chơi,
/// cộng XP vào bảng xếp hạng squad.
class ChaosChallengesScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const ChaosChallengesScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  ConsumerState<ChaosChallengesScreen> createState() =>
      _ChaosChallengesScreenState();
}

class _ChaosChallengesScreenState extends ConsumerState<ChaosChallengesScreen> {
  final List<SquadDare> _board = [];
  final Set<int> _done = {};
  bool _busy = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Mở màn là có sẵn vài thử thách để chơi ngay, không phải bấm mới có.
    WidgetsBinding.instance.addPostFrameCallback((_) => _draw(count: 3));
  }

  String? get _tripId => ref.read(activeTripIdProvider);

  Future<void> _draw({int count = 1}) async {
    final tripId = _tripId;
    if (tripId == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(gamesRepositoryProvider);
      final drawn = <SquadDare>[];
      for (var i = 0; i < count; i++) {
        final d = await repo.fetchDare(tripId);
        // Tránh bốc trùng ngay trong cùng một lượt.
        if (!drawn.any((x) => x.dareText == d.dareText) &&
            !_board.any((x) => x.dareText == d.dareText)) {
          drawn.add(d);
        }
      }
      if (!mounted) return;
      setState(() {
        _board.addAll(drawn);
        _busy = false;
      });
      HapticFeedback.selectionClick();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e;
      });
    }
  }

  /// Đánh dấu hoàn thành → ghi ván chơi để XP vào bảng xếp hạng.
  Future<void> _complete(int index) async {
    final tripId = _tripId;
    if (tripId == null || _done.contains(index)) return;
    final dare = _board[index];
    setState(() => _done.add(index));
    HapticFeedback.mediumImpact();
    try {
      await ref
          .read(gamesRepositoryProvider)
          .createSession(
            tripId,
            // GameType là enum của Prisma; 'CHAOS_CHALLENGE' không có trong
            // đó nên BE trả 400. Thử thách chính là truth-or-dare.
            gameType: 'TRUTH_OR_DARE',
            state: {
              'dare': dare.dareText,
              'xpReward': dare.xpReward,
              'chaos': dare.chaosLabel,
            },
          );
      if (!mounted) return;
      ref.invalidate(squadXpProvider(tripId));
      ref.invalidate(leaderboardProvider(tripId));
      // Ví XP cá nhân vừa tăng — làm mới để chip số dư không hiện số cũ.
      ref.invalidate(xpWalletProvider);
      showGlobalSnack('games.chaos_done'.tr(args: ['${dare.xpReward}']));
    } catch (e) {
      if (!mounted) return;
      // Ghi hỏng thì bỏ đánh dấu để người chơi thử lại, không im lặng nuốt.
      setState(() => _done.remove(index));
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark || widget.isDarkMode;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'games.chaos_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
      ),
      floatingActionButton: tripId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _busy ? null : () => _draw(),
              backgroundColor: accent,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
              icon: _busy
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: onAccent,
                      ),
                    )
                  : Icon(PhosphorIcons.diceFive(PhosphorIconsStyle.fill)),
              label: Text(
                'games.chaos_draw'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: onAccent,
                ),
              ),
            ),
      body: _body(isDark, tripId),
    );
  }

  Widget _body(bool isDark, String? tripId) {
    if (tripId == null) {
      return AppEmptyState(
        isDark: isDark,
        icon: PhosphorIcons.fire(PhosphorIconsStyle.fill),
        title: 'games.need_trip_title'.tr(),
        body: 'games.need_trip_body'.tr(),
      );
    }
    if (_error != null && _board.isEmpty) {
      return AppErrorState(
        isDark: isDark,
        error: _error,
        onRetry: () => _draw(count: 3),
      );
    }
    if (_board.isEmpty) {
      return _busy
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : AppEmptyState(
              isDark: isDark,
              icon: PhosphorIcons.fire(PhosphorIconsStyle.fill),
              title: 'games.chaos_title'.tr(),
              body: 'games.chaos_empty'.tr(),
            );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        GenZTokens.space5,
        GenZTokens.space5,
        GenZTokens.space5,
        96,
      ),
      itemCount: _board.length,
      separatorBuilder: (_, _) => const SizedBox(height: GenZTokens.space4),
      itemBuilder: (_, i) => _card(isDark, i),
    );
  }

  Widget _card(bool isDark, int index) {
    final dare = _board[index];
    final done = _done.contains(index);
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;
    final warning = isDark ? GenZTokens.warningDark : GenZTokens.warning;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;
    final info = isDark ? GenZTokens.infoDark : GenZTokens.info;

    // Càng chaos càng nóng màu — đọc lướt là biết độ khó.
    final level = dare.chaosLevel;
    final levelColor = level >= 4
        ? danger
        : level == 3
            ? danger
            : level == 2
                ? warning
                : info;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: done ? success : line,
          width: done ? GenZTokens.borderWidth : GenZTokens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (dare.chaosLabel.isNotEmpty) ...[
                Icon(
                  PhosphorIcons.fire(PhosphorIconsStyle.fill),
                  size: 16,
                  color: levelColor,
                ),
                const SizedBox(width: 4),
                Text(
                  dare.chaosLabel,
                  style: AppFonts.heading(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ] else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    level.clamp(1, 5),
                    (_) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        PhosphorIcons.fire(PhosphorIconsStyle.fill),
                        size: 16,
                        color: levelColor,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  '+${dare.xpReward} XP',
                  style: AppFonts.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GenZTokens.space3),
          Text(
            dare.dareText,
            style: AppFonts.body(fontSize: 15, color: ink, height: 1.4),
          ),
          const SizedBox(height: GenZTokens.space4),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: done ? null : () => _complete(index),
              icon: Icon(
                done
                    ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                    : PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                size: 18,
                color: done ? success : ink,
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: done ? fill : null,
                disabledBackgroundColor: fill,
                side: BorderSide(
                  color: done ? success : line,
                  width: GenZTokens.borderWidthThin,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              label: Text(
                done ? 'games.chaos_completed'.tr() : 'games.chaos_do'.tr(),
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: done ? success : ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
