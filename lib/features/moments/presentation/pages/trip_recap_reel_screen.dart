import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/state_views.dart';
import '../../data/trip_recap_repository.dart';

/// Trip Wrapped — chuỗi story-card tự chạy tổng kết cả chuyến (kiểu Spotify
/// Wrapped). Tap phải/trái để chuyển, giữ để tạm dừng, card cuối có nút Share.
///
/// Số liệu lấy từ `/trips/:id/recap`. Trước đây mọi con số đều in cứng — "7 địa
/// điểm", "142 khoảnh khắc", "186 km", MVP "Thảo Ly", tổng chi 6.020.000đ —
/// nên chuyến nào mở ra cũng ra một bản Wrapped y hệt.
class TripRecapReelScreen extends ConsumerWidget {
  final bool isDarkMode;
  final String tripId;

  const TripRecapReelScreen({
    super.key,
    required this.isDarkMode,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(tripRecapProvider(tripId))
        .when(
          loading: () => const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Scaffold(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: AppErrorState(
              isDark: isDarkMode,
              error: e,
              onRetry: () => ref.invalidate(tripRecapProvider(tripId)),
            ),
          ),
          data: (recap) {
            if (!recap.hasData) {
              return Scaffold(
                backgroundColor: isDarkMode ? Colors.black : Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                body: AppEmptyState(
                  isDark: isDarkMode,
                  icon: Icons.auto_awesome,
                  title: 'recap.empty_title'.tr(),
                  body: 'recap.empty_body'.tr(),
                ),
              );
            }
            return _RecapReel(recap: recap);
          },
        );
  }
}

class _RecapReel extends StatefulWidget {
  final TripRecap recap;
  const _RecapReel({required this.recap});

  @override
  State<_RecapReel> createState() => _TripRecapReelScreenState();
}

class _TripRecapReelScreenState extends State<_RecapReel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  int _index = 0;

  static const Duration _cardDuration = Duration(milliseconds: 4200);

  /// Chỉ dựng card cho hạng mục THỰC SỰ có dữ liệu — chuyến chưa có khoản chi
  /// thì không hiện thẻ tiền rỗng.
  late final List<_RecapCard> _cards = _buildCards();

  List<_RecapCard> _buildCards() {
    final r = widget.recap;
    return [
      _RecapCard.intro(),
      if (r.placeCount > 0)
        _RecapCard.stat(
          icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
          bigValue: '${r.placeCount}',
          unit: 'recap.unit_places'.tr(),
          caption: 'recap.cap_places'.tr(args: ['${r.placeCount}']),
          a: const Color(0xFFF5822B),
          b: const Color(0xFFFFD84D),
        ),
      if (r.momentCount > 0)
        _RecapCard.stat(
          icon: PhosphorIcons.camera(PhosphorIconsStyle.fill),
          bigValue: '${r.momentCount}',
          unit: 'recap.unit_moments'.tr(),
          caption: 'recap.cap_moments'.tr(args: ['${r.momentCount}']),
          a: const Color(0xFF8B4DE8),
          b: const Color(0xFFF5822B),
        ),
      if (r.days > 0)
        _RecapCard.stat(
          icon: PhosphorIcons.path(PhosphorIconsStyle.fill),
          bigValue: '${r.days}',
          unit: 'recap.unit_days'.tr(),
          caption: 'recap.cap_days'.tr(args: ['${r.memberCount}']),
          a: const Color(0xFF1FA85C),
          b: const Color(0xFFFFD84D),
        ),
      if (r.mvpName != null)
        _RecapCard.mvp(
          name: r.mvpName!,
          title: 'recap.mvp_title'.tr(),
          caption: 'recap.mvp_caption'.tr(),
        ),
      if (r.totalSpent > 0)
        _RecapCard.money(
          total: _money(r.totalSpent, r.currency),
          perHead: 'recap.per_head'.tr(args: [_money(r.perHead, r.currency)]),
          caption: 'recap.cap_money'.tr(args: ['${r.expenseCount}']),
        ),
      _RecapCard.outro(),
    ];
  }

  /// 6020000 -> "6.020.000đ" (VND) hoặc "6020000 USD".
  static String _money(double v, String currency) {
    final n = v.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < n.length; i++) {
      if (i > 0 && (n.length - i) % 3 == 0) b.write('.');
      b.write(n[i]);
    }
    return currency == 'VND' ? '${b.toString()}đ' : '$b $currency';
  }

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _cardDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });
    _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _cards.length - 1) {
      setState(() => _index++);
      _progress
        ..reset()
        ..forward();
      HapticFeedback.selectionClick();
    } else {
      _progress.stop();
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() => _index--);
      _progress
        ..reset()
        ..forward();
      HapticFeedback.selectionClick();
    } else {
      _progress
        ..reset()
        ..forward();
    }
  }

  void _onTapDown(TapDownDetails d) {
    final w = MediaQuery.of(context).size.width;
    if (d.globalPosition.dx < w * 0.3) {
      _prev();
    } else {
      _next();
    }
  }

  Future<void> _share() async {
    HapticFeedback.mediumImpact();
    final r = widget.recap;
    await Share.share(
      'recap.share_text'.tr(
        args: [r.tripName, '${r.placeCount}', '${r.momentCount}', '${r.days}'],
      ),
      subject: 'TripMate — ${r.tripName} Wrapped',
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _cards[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onLongPressStart: (_) => _progress.stop(),
        onLongPressEnd: (_) => _progress.forward(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Card content with crossfade
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Container(
                key: ValueKey(_index),
                decoration: BoxDecoration(color: card.bgA),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 72, 28, 48),
                    child: _buildCardBody(card),
                  ),
                ),
              ),
            ),

            // Segment progress bars
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: List.generate(_cards.length, (i) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _SegmentBar(
                            fill: i < _index
                                ? 1.0
                                : i == _index
                                ? null
                                : 0.0,
                            controller: _progress,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 0,
              right: 8,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBody(_RecapCard card) {
    switch (card.type) {
      case _RecapType.intro:
        return _introBody();
      case _RecapType.stat:
        return _statBody(card);
      case _RecapType.mvp:
        return _mvpBody(card);
      case _RecapType.money:
        return _moneyBody(card);
      case _RecapType.outro:
        return _outroBody();
    }
  }

  Widget _introBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'trip.mate',
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'recap.intro'.tr(args: [widget.recap.tripName]),
          style: AppFonts.heading(
            fontSize: 40,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cùng xem lại một chuyến đi đáng nhớ →',
          style: AppFonts.body(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _statBody(_RecapCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(card.icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 28),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, v, child) => Transform.scale(
            scale: 0.6 + 0.4 * v,
            alignment: Alignment.centerLeft,
            child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
          ),
          child: Text(
            card.bigValue!,
            style: AppFonts.heading(
              fontSize: 96,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -4,
              height: 1,
            ),
          ),
        ),
        Text(
          card.unit!,
          style: AppFonts.heading(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          card.caption!,
          style: AppFonts.body(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _mvpBody(_RecapCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card.title!.toUpperCase(),
          style: AppFonts.body(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: Center(
            child: Icon(
              PhosphorIcons.crown(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          card.name!,
          style: AppFonts.heading(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          card.caption!,
          style: AppFonts.body(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _moneyBody(_RecapCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          PhosphorIcons.wallet(PhosphorIconsStyle.fill),
          color: Colors.white,
          size: 36,
        ),
        const SizedBox(height: 24),
        Text(
          'Tổng chi cả nhóm',
          style: AppFonts.body(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card.total!,
          style: AppFonts.heading(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            card.perHead!,
            style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          card.caption!,
          style: AppFonts.body(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _outroBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đó là một chuyến đi\nkhông thể quên 🤍',
          style: AppFonts.heading(
            fontSize: 32,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _share,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.shareNetwork(PhosphorIconsStyle.fill),
                  color: const Color(0xFFF5822B),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Chia sẻ Trip Wrapped',
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF5822B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Segment progress bar ─────────────────────────────────────────────────────
class _SegmentBar extends StatelessWidget {
  /// null = đang chạy (theo controller); 0/1 = trống/đầy.
  final double? fill;
  final AnimationController controller;

  const _SegmentBar({required this.fill, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 3,
        child: Stack(
          children: [
            Container(color: Colors.white.withValues(alpha: 0.3)),
            if (fill == null)
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: controller.value,
                  child: Container(color: Colors.white),
                ),
              )
            else
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fill,
                child: Container(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Card model ───────────────────────────────────────────────────────────────
enum _RecapType { intro, stat, mvp, money, outro }

class _RecapCard {
  final _RecapType type;
  final Color bgA;
  final Color bgB;
  final IconData? icon;
  final String? bigValue;
  final String? unit;
  final String? caption;
  final String? name;
  final String? title;
  final String? total;
  final String? perHead;

  _RecapCard._({
    required this.type,
    required this.bgA,
    required this.bgB,
    this.icon,
    this.bigValue,
    this.unit,
    this.caption,
    this.name,
    this.title,
    this.total,
    this.perHead,
  });

  factory _RecapCard.intro() => _RecapCard._(
    type: _RecapType.intro,
    bgA: const Color(0xFFF5822B),
    bgB: const Color(0xFFB23A1E),
  );

  factory _RecapCard.stat({
    required IconData icon,
    required String bigValue,
    required String unit,
    required String caption,
    required Color a,
    required Color b,
  }) => _RecapCard._(
    type: _RecapType.stat,
    bgA: a,
    bgB: b,
    icon: icon,
    bigValue: bigValue,
    unit: unit,
    caption: caption,
  );

  factory _RecapCard.mvp({
    required String name,
    required String title,
    required String caption,
  }) => _RecapCard._(
    type: _RecapType.mvp,
    bgA: const Color(0xFFF5822B),
    bgB: const Color(0xFFB45309),
    name: name,
    title: title,
    caption: caption,
  );

  factory _RecapCard.money({
    required String total,
    required String perHead,
    required String caption,
  }) => _RecapCard._(
    type: _RecapType.money,
    bgA: const Color(0xFF1FA85C),
    bgB: const Color(0xFF0F766E),
    total: total,
    perHead: perHead,
    caption: caption,
  );

  factory _RecapCard.outro() => _RecapCard._(
    type: _RecapType.outro,
    bgA: const Color(0xFF8B4DE8),
    bgB: const Color(0xFFF5822B),
  );
}
