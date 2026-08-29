import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// thiện 🚧". Nay bốc thử thách THẬT từ `/games/:tripId/dare/random` — BE điền
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
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final tripId = ref.watch(activeTripIdProvider);

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'games.chaos_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      floatingActionButton: tripId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _busy ? null : () => _draw(),
              backgroundColor: GenZTokens.purple,
              foregroundColor: Colors.white,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.casino_outlined),
              label: Text(
                'games.chaos_draw'.tr(),
                style: AppFonts.heading(fontWeight: FontWeight.w800),
              ),
            ),
      body: _body(isDark, tripId),
    );
  }

  Widget _body(bool isDark, String? tripId) {
    if (tripId == null) {
      return AppEmptyState(
        isDark: isDark,
        icon: Icons.local_fire_department_outlined,
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
              icon: Icons.local_fire_department_outlined,
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
    // Càng chaos càng nóng màu — đọc lướt là biết độ khó.
    final level = dare.chaosLevel;
    final color = level >= 4
        ? GenZTokens.red
        : level == 3
        ? GenZTokens.orange
        : level == 2
        ? GenZTokens.yellow
        : GenZTokens.green;

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space5),
      decoration: BoxDecoration(
        color: done ? color.withValues(alpha: 0.18) : surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dare.chaosLabel.isEmpty ? '🔥' * level : dare.chaosLabel,
                style: AppFonts.heading(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: GenZTokens.ink,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  '+${dare.xpReward} XP',
                  style: AppFonts.heading(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: GenZTokens.ink,
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
            child: ElevatedButton.icon(
              onPressed: done ? null : () => _complete(index),
              icon: Icon(done ? Icons.check_circle : Icons.bolt, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: done ? color : GenZTokens.yellow,
                foregroundColor: GenZTokens.ink,
                disabledBackgroundColor: color,
                disabledForegroundColor: GenZTokens.ink,
                elevation: 0,
                side: BorderSide(color: ink, width: GenZTokens.borderWidth),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              label: Text(
                done ? 'games.chaos_completed'.tr() : 'games.chaos_do'.tr(),
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: GenZTokens.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
