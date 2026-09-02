import 'package:flutter/material.dart';
import '../../../profile/data/bucket_list_repository.dart';
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
  final List<_Place> _places = [
    _Place(
      'Hidden Terraces',
      'Pù Luông',
      'Trekking · Nature',
      98,
      const [Color(0xFF1FA85C), Color(0xFF0F766E)],
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    ),
    _Place(
      'Night Market Chaos',
      'Shilin, Taipei',
      'Foodie · Nightlife',
      92,
      const [Color(0xFFF5822B), Color(0xFFB23A1E)],
      'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?w=800',
    ),
    _Place(
      'Misty Pine Forest',
      'Măng Đen',
      'Chill · Aesthetic',
      89,
      const [Color(0xFF8B4DE8), Color(0xFFF5822B)],
      'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800',
    ),
    _Place(
      'Secret Beach',
      'Phú Quốc',
      'Beach · Sunset',
      85,
      const [Color(0xFFFFD84D), Color(0xFFEA580C)],
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    ),
    _Place(
      'Rooftop Bar',
      'Sài Gòn',
      'Party · City View',
      81,
      const [Color(0xFFD6248C), Color(0xFF8B4DE8)],
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
    ),
  ];

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

  int _index = 0;
  Offset _drag = Offset.zero;
  final List<_Place> _liked = [];

  Color get _primary =>
      widget.isDarkMode ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
  Color _bgOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get _textPri =>
      widget.isDarkMode ? Colors.white : const Color(0xFF141210);
  Color get _textSec =>
      widget.isDarkMode ? const Color(0xFFB8AE9C) : const Color(0xFF4A453E);

  void _swipe(bool liked) {
    HapticFeedback.mediumImpact();
    if (liked) _liked.add(_places[_index]);
    setState(() {
      _index++;
      _drag = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  'Vibe Match',
                  style: AppFonts.heading(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _textPri,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  _index < _places.length
                      ? '${_index + 1} / ${_places.length}'
                      : 'Xong rồi!',
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
                  child: _stamp('THÍCH', const Color(0xFF1FA85C), -0.3),
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
            _liked.isEmpty ? 'Khó tính ghê!' : 'Squad đã chọn xong!',
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
                ? 'Bạn chưa thích chỗ nào. Thử lại với gu khác nha.'
                : 'Đây là ${_liked.length} nơi bạn muốn đi — thêm vào lịch trình thôi!',
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
                foregroundColor: Colors.white,
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
              color: _primary,
            ),
          ),
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

  const _Place(
    this.name,
    this.location,
    this.tags,
    this.match,
    this.gradient,
    this.image,
  );
}
