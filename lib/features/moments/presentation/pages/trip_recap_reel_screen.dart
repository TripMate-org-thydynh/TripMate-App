import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../../core/widgets/state_views.dart';
import '../../data/trip_recap_repository.dart';

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
  State<_RecapReel> createState() => _RecapReelState();
}

class _RecapReelState extends State<_RecapReel> with TickerProviderStateMixin {
  static const Duration _slideDuration = Duration(milliseconds: 4700);

  late final AnimationController _progress;

  /// Tiến trình "vào slide" 0→1, chạy lại mỗi lần đổi slide.
  ///
  /// Trước đây mọi thứ trong recap hiện ra tĩnh cùng lúc; nay từng phần tử
  /// vào so le (mờ dần + trượt lên + phóng nhẹ) như Spotify Wrapped.
  late final AnimationController _enter;
  late final List<_RecapSlide> _slides = _buildSlides();
  int _index = 0;

  /// Người dùng đang giữ màn hình.
  ///
  /// Trước đây ấn giữ chỉ dừng thanh tiến trình, còn nội dung vẫn chạy tiếp —
  /// nên "giữ để xem kỹ" không có tác dụng thật. Cờ này đi xuống tận slide để
  /// cuộn phim đứng lại đúng khung đang chiếu.
  bool _paused = false;

  TripRecap get recap => widget.recap;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _slideDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      })
      ..forward();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..forward();
  }

  /// Chạy lại hoạt ảnh vào cho slide mới.
  void _replayEnter() {
    _enter
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    _enter.dispose();
    super.dispose();
  }

  List<_RecapSlide> _buildSlides() {
    return [
      _RecapSlide.hero(
        palette: _Palette.tangerine,
        kicker: 'recap.k_wrapped'.tr(),
        title: recap.tripName.isEmpty ? 'recap.your_trip'.tr() : recap.tripName,
        caption: recap.destination?.trim().isNotEmpty == true
            ? recap.destination!.trim()
            : 'recap.cap_hero'.tr(),
      ),
      // Cuộn phim ký ức: đặt ngay sau slide mở đầu, khi người xem còn chưa
      // biết sẽ thấy gì. Ảnh chạy vụt qua rồi chậm dần lại đúng một tấm — cảm
      // giác tua lại băng cũ, thay vì mở thẳng ra một lưới ảnh.
      if (recap.moments.length >= 3)
        _RecapSlide.reel(
          palette: _Palette.midnight,
          kicker: 'recap.k_reel'.tr(),
          title: 'recap.reel_title'.tr(),
          caption: 'recap.reel_caption'.tr(),
        ),
      if (recap.moments.isNotEmpty)
        _RecapSlide.gallery(
          palette: _Palette.ink,
          kicker: 'recap.k_wall'.tr(),
          title: '${recap.momentCount}',
          unit: 'recap.unit_moments'.tr(),
          caption: recap.moments.first.caption?.trim().isNotEmpty == true
              ? recap.moments.first.caption!.trim()
              : 'recap.cap_wall'.tr(),
        )
      else if (recap.momentCount > 0)
        _RecapSlide.stat(
          palette: _Palette.ink,
          icon: PhosphorIcons.camera(PhosphorIconsStyle.fill),
          kicker: 'MEMORY WALL',
          title: '${recap.momentCount}',
          unit: 'recap.unit_moments'.tr(),
          caption: 'recap.cap_moments'.tr(args: ['${recap.momentCount}']),
        ),
      if (recap.placeCount > 0)
        _RecapSlide.stat(
          palette: _Palette.lime,
          icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
          kicker: 'recap.k_route'.tr(),
          title: '${recap.placeCount}',
          unit: 'recap.unit_places'.tr(),
          caption: 'recap.cap_places'.tr(args: ['${recap.placeCount}']),
        ),
      if (recap.days > 0)
        _RecapSlide.stat(
          palette: _Palette.cobalt,
          icon: PhosphorIcons.path(PhosphorIconsStyle.fill),
          kicker: 'recap.k_streak'.tr(),
          title: '${recap.days}',
          unit: 'recap.unit_days'.tr(),
          caption: 'recap.cap_days'.tr(args: ['${recap.memberCount}']),
        ),
      if (recap.mvpName != null)
        _RecapSlide.mvp(
          palette: _Palette.rose,
          kicker: 'recap.k_mvp'.tr(),
          title: recap.mvpName!,
          caption: 'recap.mvp_caption'.tr(),
        ),
      if (recap.totalSpent > 0)
        _RecapSlide.money(
          palette: _Palette.green,
          kicker: 'recap.k_spend'.tr(),
          title: _money(recap.totalSpent, recap.currency),
          caption: 'recap.cap_money'.tr(args: ['${recap.expenseCount}']),
          unit: 'recap.per_head'.tr(
            args: [_money(recap.perHead, recap.currency)],
          ),
        ),
      _RecapSlide.outro(
        palette: _Palette.midnight,
        kicker: 'recap.k_outro'.tr(),
        title: 'recap.replay_tagline'.tr(),
        caption: 'recap.cap_outro'.tr(),
      ),
    ];
  }

  static String _money(double value, String currency) {
    final number = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) buffer.write('.');
      buffer.write(number[i]);
    }
    return currency == 'VND' ? '${buffer}d' : '$buffer $currency';
  }

  void _next() {
    if (_index < _slides.length - 1) {
      setState(() => _index++);
      _replayEnter();
      _restartProgress();
      HapticFeedback.selectionClick();
    } else {
      _progress.stop();
    }
  }

  void _prev() {
    if (_index > 0) {
      setState(() => _index--);
      _replayEnter();
      HapticFeedback.selectionClick();
    }
    _restartProgress();
  }

  void _restartProgress() {
    _progress
      ..reset()
      ..forward();
  }

  void _onTapDown(TapDownDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    details.globalPosition.dx < width * 0.35 ? _prev() : _next();
  }

  Future<void> _share() async {
    HapticFeedback.mediumImpact();
    await Share.share(
      'recap.share_text'.tr(
        args: [
          recap.tripName,
          '${recap.placeCount}',
          '${recap.momentCount}',
          '${recap.days}',
        ],
      ),
      subject: 'TripMate - ${recap.tripName} Wrapped',
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onLongPressStart: (_) {
          setState(() => _paused = true);
          _progress.stop();
          _enter.stop();
        },
        onLongPressEnd: (_) {
          setState(() => _paused = false);
          _progress.forward();
          _enter.forward();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Khong dung AnimatedSwitcher: no lam mo CHONG hai slide len nhau
            // (chu va anh cua slide cu con hien xuyen qua slide moi). Nen doi
            // ngay, con noi dung thi vao so le bang _enter.
            _EnterScope(
              animation: _enter,
              child: SizedBox.expand(
                key: ValueKey('slide-$_index'),
                child: _SlideStage(
                  slide: slide,
                  recap: recap,
                  share: _share,
                  paused: _paused,
                ),
              ),
            ),
            _TopChrome(
              index: _index,
              length: _slides.length,
              controller: _progress,
            ),
            // Chỉ báo dừng: không có nó thì người dùng giữ màn hình mà không
            // chắc app có nhận hay không.
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _paused ? 1 : 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 96),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pause_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'recap.paused'.tr(),
                            style: AppFonts.body(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mang tiến trình "vào slide" xuống cho mọi phần tử con.
class _EnterScope extends InheritedWidget {
  final Animation<double> animation;

  const _EnterScope({required this.animation, required super.child});

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EnterScope>()?.animation;

  @override
  bool updateShouldNotify(_EnterScope old) => old.animation != animation;
}

/// Một phần tử vào màn theo thứ tự [order]: mờ dần + trượt lên + phóng nhẹ.
///
/// [order] càng lớn thì vào càng trễ, tạo nhịp "rơi xuống lần lượt" quen thuộc
/// của Spotify/TikTok Wrapped.
class _Enter extends StatelessWidget {
  final int order;
  final double dy;
  final Widget child;

  const _Enter({required this.order, this.dy = 34, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = _EnterScope.maybeOf(context);
    if (t == null) return child;
    final start = (order * 0.085).clamp(0.0, 0.7);
    final curved = CurvedAnimation(
      parent: t,
      curve: Interval(
        start,
        (start + 0.42).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, c) {
        final v = curved.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * dy),
            child: Transform.scale(
              scale: 0.94 + 0.06 * v,
              alignment: Alignment.centerLeft,
              child: c,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _SlideStage extends StatelessWidget {
  final _RecapSlide slide;
  final TripRecap recap;
  final VoidCallback share;
  final bool paused;

  const _SlideStage({
    required this.slide,
    required this.recap,
    required this.share,
    required this.paused,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.palette.colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _BackgroundMedia(recap: recap, slide: slide),
          // Lớp phủ tối dần xuống đáy.
          //
          // Khi ảnh nền được cho hiện rõ, chữ trắng lập tức chìm vào những vùng
          // sáng của ảnh. Phủ một lớp tối theo chiều dọc giữ chữ luôn đọc được
          // mà không phải hạ ảnh xuống mờ tịt như trước.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x59000000), Color(0x14000000), Color(0xB3000000)],
                stops: [0.0, 0.38, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),
          _TextureOverlay(seed: slide.palette.seed),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 720;
                // Cuộn phim phải TRÀN KÍN màn.
                //
                // Mọi slide khác dùng chung một khung lề, nhưng ở đây lề biến
                // ảnh thành một tấm hình dán giữa nền — mất hẳn cảm giác đang
                // ngồi trước máy chiếu. Nó tự lo phần chữ bằng dải tối riêng.
                if (slide.type == _SlideType.reel) {
                  return _ReelSlide(
                    slide: slide,
                    recap: recap,
                    paused: paused,
                  );
                }
                return Padding(
                  padding: EdgeInsets.fromLTRB(22, compact ? 58 : 70, 22, 28),
                  child: switch (slide.type) {
                    _SlideType.hero => _HeroSlide(slide: slide, recap: recap),
                    _SlideType.reel => const SizedBox.shrink(),
                    _SlideType.gallery => _GallerySlide(
                      slide: slide,
                      recap: recap,
                    ),
                    _SlideType.stat => _StatSlide(slide: slide, recap: recap),
                    _SlideType.mvp => _MvpSlide(slide: slide, recap: recap),
                    _SlideType.money => _MoneySlide(slide: slide, recap: recap),
                    _SlideType.outro => _OutroSlide(
                      slide: slide,
                      recap: recap,
                      share: share,
                    ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final _RecapSlide slide;
  final TripRecap recap;

  const _HeroSlide({required this.slide, required this.recap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Enter(order: 0, child: _Kicker(text: slide.kicker)),
        const Spacer(),
        _Enter(
          order: 1,
          child: _AvatarRail(
            members: recap.members,
            mvpAvatarUrl: recap.mvpAvatarUrl,
          ),
        ),
        const SizedBox(height: 22),
        _Enter(order: 2, child: _DisplayTitle(slide.title, maxLines: 4)),
        const SizedBox(height: 14),
        _Enter(order: 3, child: _CaptionText(slide.caption)),
        const SizedBox(height: 28),
        _Enter(order: 4, child: _MiniStats(recap: recap)),
      ],
    );
  }
}

/// Cuộn phim ký ức: ảnh chạy vụt qua rồi **chậm dần** lại đúng một tấm.
///
/// Nhịp mượn từ chuyện tua lại một cuộn băng: lúc đầu ảnh lướt qua nhanh tới
/// mức chỉ kịp nhận ra màu, rồi thưa dần, rồi dừng hẳn. Điều khiến nó "có cảm
/// giác quá khứ" không phải tốc độ mà là **sự bất thường của khung hình** —
/// nhấp nháy độ sáng, ngả vàng, và một vệt sáng quét dọc như xước phim.
///
/// Toàn bộ chạy trên một `AnimationController`; chỉ số ảnh suy ra từ tiến trình
/// nên khi người dùng giữ màn hình để dừng, ảnh đứng lại đúng khung đang xem.
class _ReelSlide extends StatefulWidget {
  final _RecapSlide slide;
  final TripRecap recap;
  final bool paused;

  const _ReelSlide({
    required this.slide,
    required this.recap,
    required this.paused,
  });

  @override
  State<_ReelSlide> createState() => _ReelSlideState();
}

class _ReelSlideState extends State<_ReelSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reel = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..forward();

  @override
  void didUpdateWidget(covariant _ReelSlide old) {
    super.didUpdateWidget(old);
    // Giữ màn hình thì cuộn phim đứng lại ngay khung đang chiếu; thả ra thì
    // chạy tiếp từ đúng chỗ đó, không nhảy cóc.
    if (widget.paused != old.paused) {
      widget.paused ? _reel.stop() : _reel.forward();
    }
  }

  @override
  void dispose() {
    _reel.dispose();
    super.dispose();
  }

  /// Tổng số khung đã lướt qua tại thời điểm [t] (0→1).
  ///
  /// Dùng hàm mũ giảm dần: đạo hàm chính là tốc độ, nên tốc độ tự chậm lại mà
  /// không cần chia giai đoạn bằng tay. `1 - pow(1 - t, 3)` cho đúng cảm giác
  /// "vụt qua rồi thả trôi".
  static const _totalFrames = 34;

  int _frameAt(double t) {
    final eased = 1 - math.pow(1 - t, 3).toDouble();
    return (eased * _totalFrames).floor();
  }

  @override
  Widget build(BuildContext context) {
    final shots = widget.recap.moments;
    if (shots.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _reel,
      builder: (context, _) {
        final t = _reel.value;
        final frame = _frameAt(t);
        final shot = shots[frame % shots.length];
        // Nhấp nháy mạnh lúc chạy nhanh, tắt dần khi ảnh đã đứng lại — cuối
        // slide phải nhìn rõ được tấm ảnh, không thể cứ chớp mãi.
        final flickerAmount = (1 - t) * 0.6;

        return Stack(
          children: [
            Positioned.fill(
              child: _ReelFrame(
                key: ValueKey(shot.posterUrl),
                url: shot.posterUrl,
                flicker: flickerAmount,
                settle: t,
              ),
            ),
            Positioned.fill(child: _AgedFilm(progress: t, amount: flickerAmount)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 60, 22, 34),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xD9000000)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Kicker(text: widget.slide.kicker),
                    const SizedBox(height: 10),
                    Text(
                      widget.slide.title,
                      style: AppFonts.heading(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CaptionText(widget.slide.caption),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Một khung của cuộn phim.
///
/// Ảnh hơi phóng to lúc đầu rồi lùi về đúng cỡ khi dừng, cộng độ sáng dao
/// động — hai thứ đó gộp lại cho cảm giác máy chiếu đang bắt nét.
class _ReelFrame extends StatelessWidget {
  final String url;
  final double flicker;
  final double settle;

  const _ReelFrame({
    super.key,
    required this.url,
    required this.flicker,
    required this.settle,
  });

  @override
  Widget build(BuildContext context) {
    // Dao động theo khung, không theo thời gian thực: nhấp nháy phải trùng
    // nhịp đổi ảnh thì mới ra chất phim, lệch nhịp sẽ thành lỗi hiển thị.
    final jitter = flicker * 0.22 * (url.hashCode % 7 - 3) / 3;
    return Opacity(
      opacity: (1 - flicker * 0.18 + jitter).clamp(0.55, 1.0),
      child: Transform.scale(
        scale: 1.14 - 0.14 * settle,
        child: _NetworkOrAssetImage(url: url, fit: BoxFit.cover),
      ),
    );
  }
}

/// Lớp "phim cũ": ngả vàng, tối bốn góc, và một vệt xước quét dọc.
class _AgedFilm extends StatelessWidget {
  final double progress;
  final double amount;

  const _AgedFilm({required this.progress, required this.amount});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Ngả vàng — dấu hiệu quen thuộc nhất của ảnh cũ.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFD9A441).withValues(alpha: 0.20 * amount + 0.06),
              ),
            ),
          ),
          // Tối bốn góc, kéo mắt vào giữa khung.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.95,
                  colors: [Color(0x00000000), Color(0x8C000000)],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
          ),
          // Vệt xước quét dọc một lần, đúng lúc phim đang chạy nhanh nhất.
          if (amount > 0.08)
            Positioned(
              left: 0,
              right: 0,
              top: -120 + progress * 1400,
              height: 90,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.10 * amount),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GallerySlide extends StatelessWidget {
  final _RecapSlide slide;
  final TripRecap recap;

  const _GallerySlide({required this.slide, required this.recap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Enter(order: 0, child: _Kicker(text: slide.kicker)),
        Expanded(child: _MomentDeck(moments: recap.moments)),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: _Enter(
                order: 5,
                child: _BigNumber(value: slide.title, fontSize: 92),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _Enter(order: 6, child: _UnitText(slide.unit ?? '')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Enter(order: 7, child: _CaptionText(slide.caption)),
      ],
    );
  }
}

/// Slide số liệu — bố cục kiểu **áp phích**, không phải slide trình chiếu.
///
/// Bản trước có đủ dấu hiệu của một màn hình do máy sinh ra: gradient hai màu
/// bão hoà, mọi khối căn trái đều tăm tắp, chữ trắng an toàn, dải bốn ảnh bo
/// góc bằng nhau như danh sách thumbnail. Không khối nào tranh sự chú ý với
/// khối nào, nên chẳng có gì để nhìn.
///
/// Ba thay đổi tạo ra khác biệt:
///
/// 1. **Con số tràn khỏi mép trái.** Bị cắt mất một phần là điều khiến mắt đọc
///    nó như một mảng hình, không phải một dòng dữ liệu.
/// 2. **Nhãn đơn vị đè lên chân số.** Hai lớp chữ chồng nhau phá thế xếp hàng
///    dọc đều đặn — đó chính là thứ làm bố cục cũ trông vô hồn.
/// 3. **Ảnh nghiêng, chồng, lệch cỡ** thay cho hàng thumbnail đều nhau.
class _StatSlide extends StatelessWidget {
  final _RecapSlide slide;
  final TripRecap recap;

  const _StatSlide({required this.slide, required this.recap});

  @override
  Widget build(BuildContext context) {
    final shots = recap.moments.take(3).toList();
    return Stack(
      children: [
        // Ảnh nghiêng thả ở góc trên phải: phá thế cân đối, và cho người xem
        // một mảnh chuyến thật để nhận ra.
        if (shots.isNotEmpty)
          Positioned(
            top: 4,
            // Truoc de -18 nen tam ngoai cung bi cat mat o mep man.
            right: 0,
            child: _TiltedShots(shots: shots),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Kicker(text: slide.kicker)
                .animate()
                .fadeIn(duration: 420.ms)
                .slideX(begin: -0.12, curve: Curves.easeOutCubic),
            const Spacer(flex: 3),
            // Số + nhãn: nhãn đè lên chân số, cả cụm tràn trái.
            Transform.translate(
              offset: const Offset(-16, 0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _BigNumber(value: slide.title, fontSize: 148)
                      .animate()
                      .fadeIn(duration: 320.ms)
                      .slideX(
                        begin: -0.25,
                        duration: 640.ms,
                        curve: Curves.easeOutQuint,
                      ),
                  Positioned(
                    left: 26,
                    bottom: -6,
                    child:
                        _UnitText(slide.unit ?? '')
                            .animate(delay: 260.ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.6, curve: Curves.easeOutCubic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            _CaptionText(slide.caption)
                .animate(delay: 420.ms)
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.25, curve: Curves.easeOutCubic),
            const SizedBox(height: 18),
            _AvatarRail(members: recap.members, compact: true)
                .animate(delay: 540.ms)
                .fadeIn(duration: 380.ms)
                .slideX(begin: -0.1, curve: Curves.easeOutCubic),
            // Chi mot khoang tho nho truoc ribbon: de Spacer o day thi mang
            // trong giua avatar va ribbon rong bang ca mot phan tu man hinh.
            const SizedBox(height: 28),
            _MetricRibbon(recap: recap)
                .animate(delay: 660.ms)
                .fadeIn(duration: 420.ms)
                .slideY(begin: 0.4, curve: Curves.easeOutCubic),
          ],
        ),
      ],
    );
  }
}

/// Ba tấm ảnh nghiêng chồng nhau, lệch cỡ.
///
/// Cùng ngôn ngữ hình ảnh với widget màn hình chính, nên người dùng nhận ra
/// ngay đây là cùng một app — thay vì một màn hình lạ.
class _TiltedShots extends StatelessWidget {
  final List<TripRecapMoment> shots;

  const _TiltedShots({required this.shots});

  static const _tilts = [-11.0, 7.0, -3.0];
  static const _sizes = [96.0, 116.0, 84.0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = shots.length - 1; i >= 0; i--)
            Positioned(
              right: 12.0 + i * 46,
              top: 10.0 + i * 26,
              child:
                  Transform.rotate(
                        angle: _tilts[i % _tilts.length] * 3.1415926 / 180,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.28),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: _sizes[i % _sizes.length],
                              height: _sizes[i % _sizes.length],
                              child: _NetworkOrAssetImage(
                                url: shots[i].posterUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      )
                      // Bay từ ngoài mép phải vào, vừa xoay vừa thu về đúng
                      // góc nghiêng của mình. Chỉ phóng to rồi mờ dần như
                      // trước thì ảnh "hiện ra", còn thế này thì ảnh "được
                      // ném vào" — đó mới là thứ giữ mắt người xem.
                      .animate(delay: (140 * (shots.length - i)).ms)
                      .fadeIn(duration: 320.ms)
                      .slideX(
                        begin: 1.4,
                        duration: 620.ms,
                        curve: Curves.easeOutQuint,
                      )
                      .rotate(
                        begin: 0.06,
                        end: 0,
                        duration: 620.ms,
                        curve: Curves.easeOutBack,
                      )
                      .scale(
                        begin: const Offset(0.86, 0.86),
                        curve: Curves.easeOutBack,
                        duration: 560.ms,
                      ),
            ),
        ],
      ),
    );
  }
}

class _MvpSlide extends StatelessWidget {
  final _RecapSlide slide;
  final TripRecap recap;

  const _MvpSlide({required this.slide, required this.recap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Enter(order: 0, child: _Kicker(text: slide.kicker)),
        const Spacer(),
        Center(
          child: _Enter(
            order: 1,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _AvatarBubble(
                  url: recap.mvpAvatarUrl,
                  name: slide.title,
                  size: 138,
                  borderWidth: 4,
                ),
                Positioned(
                  right: -12,
                  top: -14,
                  child: _IconBadge(
                    icon: PhosphorIcons.crown(PhosphorIconsStyle.fill),
                    size: 58,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: _Enter(
            order: 2,
            child: _DisplayTitle(slide.title, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: _Enter(
            order: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: _CaptionText(slide.caption, textAlign: TextAlign.center),
            ),
          ),
        ),
        const Spacer(),
        _Enter(order: 4, child: _AvatarRail(members: recap.members)),
      ],
    );
  }
}

class _MoneySlide extends StatelessWidget {
  final _RecapSlide slide;
  final TripRecap recap;

  const _MoneySlide({required this.slide, required this.recap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Enter(order: 0, child: _Kicker(text: slide.kicker)),
        const Spacer(),
        _Enter(
          order: 1,
          child: _IconBadge(
            icon: PhosphorIcons.wallet(PhosphorIconsStyle.fill),
          ),
        ),
        const SizedBox(height: 18),
        _Enter(order: 2, child: _DisplayTitle(slide.title, maxLines: 2)),
        const SizedBox(height: 10),
        _Enter(order: 3, child: _Pill(label: slide.unit ?? '')),
        const SizedBox(height: 16),
        _Enter(order: 4, child: _CaptionText(slide.caption)),
        const Spacer(),
        _Enter(order: 5, child: _MetricRibbon(recap: recap)),
      ],
    );
  }
}

class _OutroSlide extends StatelessWidget {
  final _RecapSlide slide;
  final TripRecap recap;
  final VoidCallback share;

  const _OutroSlide({
    required this.slide,
    required this.recap,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Kicker(text: slide.kicker),
        const Spacer(),
        _MomentStrip(moments: recap.moments),
        const SizedBox(height: 28),
        _DisplayTitle(slide.title, maxLines: 3),
        const SizedBox(height: 14),
        _CaptionText(slide.caption),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: share,
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIcons.shareNetwork(PhosphorIconsStyle.fill),
                  color: slide.palette.colors.first,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Text(
                  'recap.share_cta'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: slide.palette.colors.first,
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

class _BackgroundMedia extends StatelessWidget {
  final TripRecap recap;
  final _RecapSlide slide;

  const _BackgroundMedia({required this.recap, required this.slide});

  @override
  Widget build(BuildContext context) {
    final url = recap.coverImage?.trim().isNotEmpty == true
        ? recap.coverImage!.trim()
        : recap.moments.isNotEmpty
        ? recap.moments.first.posterUrl
        : null;
    if (url == null) return const SizedBox.shrink();
    // Ken Burns: anh nen phong cham suot slide cho do tinh.
    final t = _EnterScope.maybeOf(context);
    final image = _NetworkOrAssetImage(url: url, fit: BoxFit.cover);
    return Opacity(
      // Ảnh nền để RÕ hẳn, không còn mờ tịt.
      //
      // Mức 0.13 cũ vừa không nhìn thấy gì vừa làm nền đục — tệ hơn cả không
      // có ảnh. Nay bảng màu đã tối xuyên suốt nên chữ trắng vẫn nổi, và người
      // xem thực sự thấy được chuyến của mình phía sau con số.
      opacity: switch (slide.type) {
        _SlideType.stat => 0.42,
        _SlideType.gallery => 0.30,
        _ => 0.46,
      },
      child: t == null
          ? image
          : AnimatedBuilder(
              animation: t,
              builder: (context, child) =>
                  Transform.scale(scale: 1.06 + 0.10 * t.value, child: child),
              child: image,
            ),
    );
  }
}

class _TextureOverlay extends StatelessWidget {
  final int seed;

  const _TextureOverlay({required this.seed});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _TexturePainter(seed: seed));
  }
}

class _TexturePainter extends CustomPainter {
  final int seed;

  _TexturePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.055);
    for (var i = 0; i < 22; i++) {
      final x = ((seed * 37 + i * 83) % 1000) / 1000 * size.width;
      final y = ((seed * 71 + i * 59) % 1000) / 1000 * size.height;
      final r = 2.0 + ((seed + i * 11) % 12);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    final line = Paint()
      ..color = Colors.black.withValues(alpha: 0.09)
      ..strokeWidth = 1.2;
    for (var i = 0; i < 9; i++) {
      final y = size.height * (0.14 + i * 0.095);
      canvas.drawLine(Offset(-40, y), Offset(size.width + 40, y + 26), line);
    }
  }

  @override
  bool shouldRepaint(covariant _TexturePainter oldDelegate) =>
      oldDelegate.seed != seed;
}

class _MomentDeck extends StatelessWidget {
  final List<TripRecapMoment> moments;

  const _MomentDeck({required this.moments});

  @override
  Widget build(BuildContext context) {
    final shown = moments.take(5).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final cardW = math.min(width * 0.58, 230.0);
        final cardH = math.min(height * 0.62, 310.0);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Xep nguoc de tam dau nam tren cung, va cho tung tam bay vao
            // so le tu duoi len — cam giac "rai bai" nhu Wrapped.
            for (var i = shown.length - 1; i >= 0; i--)
              _Enter(
                order: shown.length - i,
                dy: 60,
                child: Transform.translate(
                  offset: Offset((i - 2) * 34.0, (i.isEven ? 1 : -1) * 18.0),
                  child: Transform.rotate(
                    angle: (-8 + i * 4) * math.pi / 180,
                    child: _PhotoCard(
                      moment: shown[i],
                      width: cardW,
                      height: cardH,
                      emphasis: i == 0,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final TripRecapMoment moment;
  final double width;
  final double height;
  final bool emphasis;

  const _PhotoCard({
    required this.moment,
    required this.width,
    required this.height,
    required this.emphasis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.26),
            blurRadius: emphasis ? 34 : 18,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _NetworkOrAssetImage(url: moment.posterUrl, fit: BoxFit.cover),
            if (moment.type == 'VIDEO')
              Center(
                child: Icon(
                  PhosphorIcons.playCircle(PhosphorIconsStyle.fill),
                  color: Colors.white.withValues(alpha: 0.92),
                  size: 42,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MomentStrip extends StatelessWidget {
  final List<TripRecapMoment> moments;

  const _MomentStrip({required this.moments});

  @override
  Widget build(BuildContext context) {
    final shown = moments.take(4).toList();
    if (shown.isEmpty) {
      return SizedBox(
        height: 92,
        child: Row(
          children: const [
            Expanded(
              child: _AssetTile('assets/images/cover_theme_dalat_mist.webp'),
            ),
            SizedBox(width: 10),
            Expanded(child: _AssetTile('assets/images/cover_island_time.webp')),
            SizedBox(width: 10),
            Expanded(child: _AssetTile('assets/images/cover_tokyo_drift.webp')),
          ],
        ),
      );
    }
    return SizedBox(
      height: 98,
      child: Row(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _NetworkOrAssetImage(
                  url: shown[i].posterUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (i != shown.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final String asset;

  const _AssetTile(this.asset);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(asset, fit: BoxFit.cover),
    );
  }
}

class _AvatarRail extends StatelessWidget {
  final List<TripRecapMember> members;
  final String? mvpAvatarUrl;
  final bool compact;

  const _AvatarRail({
    required this.members,
    this.mvpAvatarUrl,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final shown = members.take(5).toList();
    final size = compact ? 38.0 : 48.0;
    if (shown.isEmpty && (mvpAvatarUrl == null || mvpAvatarUrl!.isEmpty)) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: size + 8,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * (size * 0.72),
              child: _AvatarBubble(
                url: shown[i].avatarUrl,
                name: shown[i].name,
                size: size,
                borderWidth: 2.5,
              ),
            ),
          if (shown.isEmpty)
            _AvatarBubble(
              url: mvpAvatarUrl,
              name: '',
              size: size,
              borderWidth: 2.5,
            ),
        ],
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  final double borderWidth;

  const _AvatarBubble({
    required this.url,
    required this.name,
    required this.size,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'T' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
        color: Colors.black.withValues(alpha: 0.18),
      ),
      child: ClipOval(
        child: url?.trim().isNotEmpty == true
            ? _NetworkOrAssetImage(url: url!.trim(), fit: BoxFit.cover)
            : Center(
                child: Text(
                  initial,
                  style: AppFonts.heading(
                    fontSize: size * 0.42,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
      ),
    );
  }
}

class _MiniStats extends StatelessWidget {
  final TripRecap recap;

  const _MiniStats({required this.recap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(value: '${recap.days}', label: 'recap.mini_days'.tr()),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(value: '${recap.placeCount}', label: 'recap.mini_stops'.tr()),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(value: '${recap.momentCount}', label: 'recap.mini_moments'.tr()),
        ),
      ],
    );
  }
}

class _MetricRibbon extends StatelessWidget {
  final TripRecap recap;

  const _MetricRibbon({required this.recap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(value: '${recap.memberCount}', label: 'recap.mini_crew'.tr()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(value: '${recap.placeCount}', label: 'recap.mini_stops'.tr()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(value: '${recap.expenseCount}', label: 'recap.mini_bills'.tr()),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: AppFonts.heading(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopChrome extends StatelessWidget {
  final int index;
  final int length;
  final AnimationController controller;

  const _TopChrome({
    required this.index,
    required this.length,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _SegmentBar(
                          fill: i < index
                              ? 1
                              : i == index
                              ? null
                              : 0,
                          controller: controller,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
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
            Container(color: Colors.white.withValues(alpha: 0.28)),
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
                widthFactor: fill!.clamp(0, 1),
                child: Container(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  final String text;

  const _Kicker({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.body(
        color: Colors.white.withValues(alpha: 0.82),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _DisplayTitle extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextAlign textAlign;

  const _DisplayTitle(
    this.text, {
    this.maxLines = 3,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: AppFonts.heading(
              color: Colors.white,
              fontSize: 46,
              height: 0.98,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      },
    );
  }
}

/// Con so lon cua slide — dem tu 0 len gia tri that khi vao slide.
///
/// Truoc day con so hien ngay lap tuc; dem len la mot trong nhung thu lam
/// Spotify Wrapped "da mat", va o day dem bang chinh so lieu that cua chuyen.
class _BigNumber extends StatelessWidget {
  final String value;
  final double fontSize;

  const _BigNumber({required this.value, required this.fontSize});

  /// Tach phan so de dem: "250.000d" -> (250000, "", "d").
  static (int, String, String)? _numeric(String raw) {
    final m = RegExp(r'^(\D*)([\d.,]+)(.*)$').firstMatch(raw);
    if (m == null) return null;
    final digits = m.group(2)!.replaceAll(RegExp(r'[.,]'), '');
    final n = int.tryParse(digits);
    if (n == null || n <= 0) return null;
    return (n, m.group(1)!, m.group(3)!);
  }

  /// 250000 -> "250.000" (giu dung kieu ngan cach cua ban goc).
  static String _group(int n, bool grouped) {
    final raw = n.toString();
    if (!grouped) return raw;
    final b = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) b.write('.');
      b.write(raw[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _numeric(value);
    final t = _EnterScope.maybeOf(context);

    Widget label(String text) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        style: AppFonts.heading(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 0.92,
          letterSpacing: -2,
        ),
      ),
    );

    if (parsed == null || t == null) return label(value);

    final (target, prefix, suffix) = parsed;
    final grouped = value.contains('.') || value.contains(',');
    final curve = CurvedAnimation(
      parent: t,
      curve: const Interval(0.15, 0.95, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, _) {
        final n = (target * curve.value).round();
        return label('$prefix${_group(n, grouped)}$suffix');
      },
    );
  }
}

class _UnitText extends StatelessWidget {
  final String text;

  const _UnitText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.heading(
        color: Colors.white,
        fontSize: 25,
        height: 1,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CaptionText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;

  const _CaptionText(this.text, {this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: AppFonts.body(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;

  const _IconBadge({required this.icon, this.size = 62});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.48),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.body(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NetworkOrAssetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const _NetworkOrAssetImage({required this.url, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: fit);
    }
    if (!url.startsWith('http')) {
      return Container(color: Colors.black.withValues(alpha: 0.14));
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, _) =>
          Container(color: Colors.black.withValues(alpha: 0.14)),
      errorWidget: (context, _, _) => Container(
        color: Colors.black.withValues(alpha: 0.18),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

enum _SlideType { hero, reel, gallery, stat, mvp, money, outro }

class _RecapSlide {
  final _SlideType type;
  final _Palette palette;
  final IconData? icon;
  final String kicker;
  final String title;
  final String caption;
  final String? unit;

  const _RecapSlide._({
    required this.type,
    required this.palette,
    required this.kicker,
    required this.title,
    required this.caption,
    this.icon,
    this.unit,
  });

  factory _RecapSlide.hero({
    required _Palette palette,
    required String kicker,
    required String title,
    required String caption,
  }) => _RecapSlide._(
    type: _SlideType.hero,
    palette: palette,
    kicker: kicker,
    title: title,
    caption: caption,
  );

  factory _RecapSlide.reel({
    required _Palette palette,
    required String kicker,
    required String title,
    required String caption,
  }) => _RecapSlide._(
    type: _SlideType.reel,
    palette: palette,
    kicker: kicker,
    title: title,
    caption: caption,
  );

  factory _RecapSlide.gallery({
    required _Palette palette,
    required String kicker,
    required String title,
    required String unit,
    required String caption,
  }) => _RecapSlide._(
    type: _SlideType.gallery,
    palette: palette,
    kicker: kicker,
    title: title,
    unit: unit,
    caption: caption,
  );

  factory _RecapSlide.stat({
    required _Palette palette,
    required IconData icon,
    required String kicker,
    required String title,
    required String unit,
    required String caption,
  }) => _RecapSlide._(
    type: _SlideType.stat,
    palette: palette,
    icon: icon,
    kicker: kicker,
    title: title,
    unit: unit,
    caption: caption,
  );

  factory _RecapSlide.mvp({
    required _Palette palette,
    required String kicker,
    required String title,
    required String caption,
  }) => _RecapSlide._(
    type: _SlideType.mvp,
    palette: palette,
    kicker: kicker,
    title: title,
    caption: caption,
  );

  factory _RecapSlide.money({
    required _Palette palette,
    required String kicker,
    required String title,
    required String unit,
    required String caption,
  }) => _RecapSlide._(
    type: _SlideType.money,
    palette: palette,
    kicker: kicker,
    title: title,
    unit: unit,
    caption: caption,
  );

  factory _RecapSlide.outro({
    required _Palette palette,
    required String kicker,
    required String title,
    required String caption,
  }) => _RecapSlide._(
    type: _SlideType.outro,
    palette: palette,
    kicker: kicker,
    title: title,
    caption: caption,
  );
}

class _Palette {
  final List<Color> colors;
  final int seed;

  const _Palette(this.colors, this.seed);

  // Bảng màu: **cùng họ, tối dần**, không nhảy sang vàng chói ở góc đối diện.
  //
  // Bản trước có bảy palette nhưng chung đúng một công thức — tối, rồi bão hoà,
  // rồi vàng/cam sáng. Nhìn slide nào cũng ra slide nào, và cặp "xanh lá sang
  // vàng" là thứ không ai chọn có chủ đích. Nay mỗi bảng đi trong một họ màu và
  // giữ nền tối xuyên suốt: chỗ sáng duy nhất trên màn là chữ và ảnh, nên mắt
  // biết phải nhìn đâu.
  static const tangerine = _Palette([
    Color(0xFF2B0F0A),
    Color(0xFF7A2A12),
    Color(0xFF3D1408),
  ], 3);
  static const ink = _Palette([
    Color(0xFF0B1020),
    Color(0xFF2A2069),
    Color(0xFF120E24),
  ], 7);
  static const lime = _Palette([
    Color(0xFF07231B),
    Color(0xFF11543D),
    Color(0xFF09261D),
  ], 13);
  static const cobalt = _Palette([
    Color(0xFF061428),
    Color(0xFF10396E),
    Color(0xFF07182E),
  ], 19);
  static const rose = _Palette([
    Color(0xFF2A0A22),
    Color(0xFF6E1F4A),
    Color(0xFF320C28),
  ], 23);
  static const green = _Palette([
    Color(0xFF04211F),
    Color(0xFF0B4F45),
    Color(0xFF062825),
  ], 29);
  static const midnight = _Palette([
    Color(0xFF07070A),
    Color(0xFF171A33),
    Color(0xFF0B0B12),
  ], 31);
}
