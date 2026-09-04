import 'package:flutter/material.dart';
import '../../../profile/data/bucket_list_repository.dart';
import '../../../trip_planner/application/wishlist_providers.dart';
import '../../../trips/application/trips_providers.dart';
import '../../../../core/network/api_exception.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
          backgroundColor: Colors.redAccent,
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
      if (mounted) setState(() { _loadError = e.message; _loading = false; });
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
      [Color(0xFF1FA85C), Color(0xFF0F766E)],
      [Color(0xFFF5822B), Color(0xFFB23A1E)],
      [Color(0xFF8B4DE8), Color(0xFFF5822B)],
      [Color(0xFFFFD84D), Color(0xFFEA580C)],
      [Color(0xFFD6248C), Color(0xFF8B4DE8)],
    ];
    return palettes[id.hashCode.abs() % palettes.length];
  }

  int _index = 0;
  Offset _drag = Offset.zero;
  final List<_Place> _liked = [];

  /// Accent lay tu theme dang chon.
  ///
  /// Truoc day la `widget.isDarkMode ? Color(0xFFF5822B) : Color(0xFFF5822B)` —
  /// hai nhanh y het nhau, va 0xFFF5822B chinh la accent cua preset *grape*.
  /// Day la State nen doc thang `context` duoc.
  Color get _primary => Theme.of(context).colorScheme.primary;
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _textPri =>
      widget.isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

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
        backgroundColor: _bgOf(context),
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
      backgroundColor: _bgOf(context),
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
            icon: Icon(Icons.arrow_back, color: _textPri),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'vibe_deck.title'.tr(),
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _textPri,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  // Deck rong thi khong the "Xong roi!" — truoc day header van
                  // bao xong trong khi than man dang noi la chua co gi de vuot.
                  _places.isEmpty
                      ? ''
                      : (_index < _places.length
                            ? '${_index + 1} / ${_places.length}'
                            : 'common.done_excl'.tr()),
                  style: AppFonts.body(fontSize: 12, color: _textSec),
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
            Transform.scale(
              scale: 0.94,
              child: _card(_places[_index + 1], behind: true),
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
                  child: _stamp('vibe_deck.like'.tr(), const Color(0xFF1FA85C), -0.3),
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
                    const Color(0xFFD8422B),
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
          border: Border.all(color: color, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: AppFonts.heading(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _card(_Place place, {bool behind = false}) {
    final ink = widget.isDarkMode
        ? const Color(0xFFFDF6D3)
        : const Color(0xFF141210);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ink, width: 2.5),
        boxShadow: behind
            ? null
            : [BoxShadow(color: ink, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
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
            Image.network(
              place.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
            // Scrim
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
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
                  color: const Color(0xFFFFD84D),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0xFF141210), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                      color: const Color(0xFF141210),
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${place.match}% SQUAD MATCH',
                      style: AppFonts.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF141210),
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
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.location,
                        style: AppFonts.body(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9B8FF),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: const Color(0xFF141210),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      place.tags.toUpperCase(),
                      style: AppFonts.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF141210),
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
            icon: Icons.close,
            color: const Color(0xFFD8422B),
            size: 64,
            onTap: () => _swipe(false),
          ),
          const SizedBox(width: 28),
          _circleBtn(
            icon: Icons.favorite,
            color: const Color(0xFF1FA85C),
            size: 72,
            onTap: () => _swipe(true),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: widget.isDarkMode
                ? const Color(0xFFFDF6D3)
                : const Color(0xFF141210),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isDarkMode
                  ? const Color(0xFFFDF6D3)
                  : const Color(0xFF141210),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.42),
      ),
    );
  }

  Widget _buildResult() {
    final top = (_liked.toList()..sort((a, b) => b.match.compareTo(a.match)));
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF141210), width: 2.5),
              boxShadow: const [
                BoxShadow(color: Color(0xFF141210), offset: Offset(0, 4)),
              ],
            ),
            child: Icon(
              PhosphorIcons.confetti(PhosphorIconsStyle.fill),
              color: const Color(0xFFFFFDF5),
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _liked.isEmpty ? 'vibe_deck.picky'.tr() : 'vibe_deck.squad_done'.tr(),
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _textPri,
              letterSpacing: -0.8,
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
          const SizedBox(height: 20),
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
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveLikedToBucket,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bookmark_add_outlined, size: 18),
                label: Text(
                  'vibe_deck.save_to_bucket'.tr(),
                  style: AppFonts.heading(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1FA85C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                backgroundColor: _primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'discovery.swipe_again'.tr(),
                style: AppFonts.heading(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
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
        color: widget.isDarkMode
            ? const Color(0xFF262019)
            : const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDarkMode
              ? const Color(0xFFFDF6D3)
              : const Color(0xFF141210),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDarkMode
                ? const Color(0xFFFDF6D3)
                : const Color(0xFF141210),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: place.gradient),
            ),
            child: Center(
              child: Text(
                '#${rank + 1}',
                style: AppFonts.heading(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 16,
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
                    fontWeight: FontWeight.w800,
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
              fontSize: 16,
              fontWeight: FontWeight.w900,
              // Accent chi hop lam nen; lam mau chu tren nen sang thi khong doc ra.
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
    if (_loading) return const CircularProgressIndicator();
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
