import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../profile/data/bucket_list_repository.dart';
import '../../../trip_planner/application/wishlist_providers.dart';
import '../../../trips/application/trips_providers.dart';

/// Vibe Match dạng swipe deck (kiểu Tinder cho địa điểm).
/// Vuốt phải = thích, vuốt trái = bỏ qua. Cuối deck hiện kết quả nhóm.
class VibeSwipeDeckScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const VibeSwipeDeckScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  ConsumerState<VibeSwipeDeckScreen> createState() =>
      _VibeSwipeDeckScreenState();
}

class _VibeSwipeDeckScreenState extends ConsumerState<VibeSwipeDeckScreen> {
  // Deck dựng từ **wishlist thật** của chuyến gần nhất.
  //
  // Trước đây đây là 5 thẻ hardcode ngay trong widget (Hidden Terraces, Night
  // Market Chaos, ...) kèm % khớp bịa sẵn 98/92/89/85/81 — màn hình trông như
  // đã chạy nhưng không đọc dữ liệu nào (BUG-011). Thậm chí thẻ "Pù Luông ·
  // Trekking" lại dùng đúng ảnh bãi biển của thẻ "Phú Quốc".
  List<_Place> _places = [];
  bool _loading = true;
  String? _loadError;
  String? _tripId;

  bool _saving = false;
  bool _saved = false;

  /// Lưu các nơi đã thích vào bucket list thật.
  ///
  /// Trước đây danh sách `_liked` chỉ nằm trong bộ nhớ rồi biến mất khi thoát
  /// màn, dù CTA hứa "thêm vào lịch trình".
  Future<void> _saveLikedToBucket() async {
    if (_liked.isEmpty || _saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(bucketListRepositoryProvider);
      for (final p in _liked) {
        await repo.add('${p.name} · ${p.location}');
      }
      ref.invalidate(bucketListProvider);
      if (!mounted) return;
      setState(() => _saved = true);
      HapticFeedback.mediumImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'vibe_deck.saved'.tr(namedArgs: {'count': '${_liked.length}'}),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: GenZTokens.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDeck());
  }

  /// Nạp wishlist của chuyến gần nhất và đổi thành các thẻ vuốt.
  ///
  /// `% khớp` là tỉ lệ thành viên đã vote cho địa điểm đó — số thật, tính từ
  /// `voteCount / memberCount`, chứ không phải hằng số viết sẵn.
  Future<void> _loadDeck() async {
    try {
      final trips = await ref.read(tripsProvider.future);
      if (trips.isEmpty) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final trip = trips.first;
      final items = await ref.read(wishlistProvider(trip.id).future);
      final memberCount = trip.memberCount <= 0 ? 1 : trip.memberCount;
      if (!mounted) return;
      setState(() {
        _tripId = trip.id;
        _places = items
            .map(
              (i) => _Place(
                i.name,
                i.address ?? trip.destination ?? trip.name,
                i.type == 'FOOD'
                    ? 'vibe_deck.type_food'.tr()
                    : 'vibe_deck.type_place'.tr(),
                ((i.voteCount / memberCount) * 100).clamp(0, 100).round(),
                _gradientFor(i.id),
                '',
                id: i.id,
              ),
            )
            .toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = 'vibe_deck.load_failed'.tr();
          _loading = false;
        });
      }
    }
  }

  /// Màu thẻ suy từ id để mỗi địa điểm có một màu ổn định giữa các lần mở.
  static List<Color> _gradientFor(String id) {
    const palettes = [
      [GenZTokens.chart1, GenZTokens.chart5],
      [GenZTokens.chart2, GenZTokens.chart4],
      [GenZTokens.chart3, GenZTokens.chart1],
      [GenZTokens.chart4, GenZTokens.chart5],
      [GenZTokens.chart5, GenZTokens.chart6],
      [GenZTokens.chart6, GenZTokens.chart3],
    ];
    return palettes[id.hashCode.abs() % palettes.length];
  }

  int _index = 0;
  Offset _drag = Offset.zero;
  final List<_Place> _liked = [];

  Color get _bg => widget.isDarkMode ? GenZTokens.creamDark : GenZTokens.cream;
  Color get _surface =>
      widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  Color get _line => widget.isDarkMode ? GenZTokens.lineDark : GenZTokens.line;
  Color get _fill => widget.isDarkMode ? GenZTokens.fillDark : GenZTokens.fill;
  Color get _accent =>
      widget.isDarkMode ? GenZTokens.accentDark : GenZTokens.accent;
  Color get _onAccent =>
      widget.isDarkMode ? GenZTokens.onAccentDark : GenZTokens.onAccent;
  Color get _textPri => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _textSec =>
      widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;

  void _swipe(bool liked) {
    HapticFeedback.mediumImpact();
    final place = _places[_index];
    if (liked) {
      _liked.add(place);
      // Vuốt phải là một lá phiếu thật cho wishlist của chuyến, không chỉ là
      // hiệu ứng trên máy.
      final tripId = _tripId;
      final itemId = place.id;
      if (tripId != null && itemId != null) {
        ref.read(wishlistProvider(tripId).notifier).toggleVote(itemId);
      }
    }
    setState(() {
      _index++;
      _drag = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _loadError != null || _places.isEmpty) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: Center(child: _buildDeckPlaceholder())),
            ],
          ),
        ),
      );
    }
    final done = _index >= _places.length;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: done ? _buildResult() : _buildDeck()),
            if (!done) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'common.back'.tr(),
            icon: Icon(PhosphorIcons.arrowLeft(), color: _textPri),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'vibe_deck.title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _textPri,
                  ),
                ),
                Text(
                  _places.isEmpty
                      ? ''
                      : (_index < _places.length
                            ? '${_index + 1} / ${_places.length}'
                            : 'common.done_excl'.tr()),
                  style: AppFonts.body(fontSize: 13, color: _textSec),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDeck() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Next card peeking behind
          if (_index + 1 < _places.length)
            ExcludeSemantics(
              child: Transform.scale(
                scale: 0.94,
                child: _card(_places[_index + 1], behind: true),
              ),
            ),
          // Active card
          _buildDraggableCard(_places[_index]),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(_Place place) {
    final rotation = _drag.dx / 360;
    final likeOpacity = (_drag.dx / 120).clamp(0.0, 1.0);
    final nopeOpacity = (-_drag.dx / 120).clamp(0.0, 1.0);

    return GestureDetector(
      onPanUpdate: (d) => setState(() => _drag += d.delta),
      onPanEnd: (_) {
        if (_drag.dx > 110) {
          _swipe(true);
        } else if (_drag.dx < -110) {
          _swipe(false);
        } else {
          setState(() => _drag = Offset.zero);
        }
      },
      child: Transform.translate(
        offset: _drag,
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            children: [
              _card(place),
              // LIKE stamp
              Positioned(
                top: 32,
                left: 28,
                child: Opacity(
                  opacity: likeOpacity,
                  child: _stamp(
                    'vibe_deck.like'.tr(),
                    widget.isDarkMode
                        ? GenZTokens.successDark
                        : GenZTokens.success,
                    -0.3,
                  ),
                ),
              ),
              // NOPE stamp
              Positioned(
                top: 32,
                right: 28,
                child: Opacity(
                  opacity: nopeOpacity,
                  child: _stamp(
                    'common.skip_caps'.tr(),
                    widget.isDarkMode
                        ? GenZTokens.dangerDark
                        : GenZTokens.danger,
                    0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stamp(String text, Color color, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2.5),
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
        ),
        child: Text(
          text,
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _card(_Place place, {bool behind = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
        boxShadow: behind
            ? null
            : GenZTokens.hardShadow(_textPri, widget.isDarkMode),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fallback gradient + image
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: place.gradient,
                ),
              ),
            ),
            ExcludeSemantics(
              child: Image.network(
                place.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const SizedBox.shrink(),
              ),
            ),
            // Scrim
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.6, 1.0],
                  colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.55)],
                ),
              ),
            ),
            // Match badge
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: _line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                      color: _accent,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'vibe_deck.squad_match'.tr(
                        namedArgs: {'pct': '${place.match}'},
                      ),
                      style: AppFonts.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPri,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppFonts.heading(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                        color: Colors.white70,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.location,
                        style: AppFonts.body(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusPill,
                      ),
                      border: Border.all(
                        color: _line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Text(
                      place.tags,
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textPri,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _circleBtn(
            icon: PhosphorIcons.x(),
            color: _surface,
            iconColor: widget.isDarkMode
                ? GenZTokens.dangerDark
                : GenZTokens.danger,
            borderColor: _line,
            size: 56,
            label: 'common.skip_caps'.tr(),
            onTap: () => _swipe(false),
          ),
          const SizedBox(width: 24),
          _circleBtn(
            icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
            color: _accent,
            iconColor: _onAccent,
            borderColor: _accent,
            size: 64,
            label: 'vibe_deck.like'.tr(),
            onTap: () => _swipe(true),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required Color borderColor,
    required double size,
    required VoidCallback onTap,
    required String label,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: borderColor,
              width: GenZTokens.borderWidthThin,
            ),
            boxShadow: GenZTokens.hardShadow(_textPri, widget.isDarkMode),
          ),
          child: Icon(icon, color: iconColor, size: size * 0.44),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final top = (_liked.toList()..sort((a, b) => b.match.compareTo(a.match)));
    return Padding(
      padding: const EdgeInsets.all(GenZTokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? GenZTokens.accentSoftDark
                  : GenZTokens.accentSoft,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(
                color: _line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Icon(
              PhosphorIcons.confetti(PhosphorIconsStyle.fill),
              color: _accent,
              size: 28,
            ),
          ),
          const SizedBox(height: GenZTokens.space4),
          Text(
            _liked.isEmpty
                ? 'vibe_deck.picky'.tr()
                : 'vibe_deck.squad_done'.tr(),
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPri,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _liked.isEmpty
                ? 'vibe_deck.none_liked'.tr()
                : 'vibe_deck.liked_summary'.tr(
                    namedArgs: {'n': '${_liked.length}'},
                  ),
            style: AppFonts.body(fontSize: 14, color: _textSec, height: 1.4),
          ),
          const SizedBox(height: GenZTokens.space4),
          Expanded(
            child: ListView.separated(
              itemCount: top.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _resultTile(top[i], i),
            ),
          ),
          if (_liked.isNotEmpty && !_saved) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveLikedToBucket,
                icon: _saving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_onAccent),
                        ),
                      )
                    : Icon(
                        PhosphorIcons.bookmarkSimple(),
                        size: 18,
                        color: _onAccent,
                      ),
                label: Text(
                  'vibe_deck.save_to_bucket'.tr(),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: _onAccent,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _onAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: (_liked.isNotEmpty && !_saved)
                ? OutlinedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _index = 0;
                        _liked.clear();
                        _saved = false;
                        _drag = Offset.zero;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _fill,
                      foregroundColor: _textPri,
                      side: BorderSide(
                        color: _line,
                        width: GenZTokens.borderWidthThin,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusButton,
                        ),
                      ),
                    ),
                    child: Text(
                      'discovery.swipe_again'.tr(),
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: _textPri,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _index = 0;
                        _liked.clear();
                        _saved = false;
                        _drag = Offset.zero;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _onAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusButton,
                        ),
                      ),
                    ),
                    child: Text(
                      'discovery.swipe_again'.tr(),
                      style: AppFonts.heading(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: _onAccent,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _resultTile(_Place place, int rank) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: _line, width: GenZTokens.borderWidthThin),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              color: _fill,
              border: Border.all(
                color: _line,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: Center(
              child: Text(
                '#${rank + 1}',
                style: AppFonts.heading(
                  fontWeight: FontWeight.w700,
                  color: _textPri,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPri,
                  ),
                ),
                Text(
                  place.location,
                  style: AppFonts.body(fontSize: 12, color: _textSec),
                ),
              ],
            ),
          ),
          Text(
            '${place.match}%',
            style: AppFonts.heading(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textPri,
            ),
          ),
        ],
      ),
    );
  }

  /// Trạng thái nạp / lỗi / chưa có dữ liệu — thay cho việc luôn có sẵn 5 thẻ
  /// giả để màn hình "trông như đang chạy".
  Widget _buildDeckPlaceholder() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_accent),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _loadError != null
                ? PhosphorIcons.cloudSlash()
                : PhosphorIcons.heartBreak(),
            size: 40,
            color: _textSec,
          ),
          const SizedBox(height: 12),
          Text(
            _loadError ?? 'vibe_deck.empty'.tr(),
            textAlign: TextAlign.center,
            style: AppFonts.body(fontSize: 14, color: _textSec),
          ),
          if (_loadError != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _loadError = null;
                });
                _loadDeck();
              },
              style: TextButton.styleFrom(foregroundColor: _accent),
              child: Text('common.tap_to_retry'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}

class _Place {
  final String name;
  final String location;
  final String tags;
  final int match;
  final List<Color> gradient;
  final String image;

  /// Id của wishlist item — dùng để gửi vote thật khi vuốt phải.
  final String? id;

  const _Place(
    this.name,
    this.location,
    this.tags,
    this.match,
    this.gradient,
    this.image, {
    this.id,
  });
}
