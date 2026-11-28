import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/media_uploader.dart';
import '../../data/moments_repository.dart';
import '../../domain/moment.dart';
import 'memory_wall_screen.dart';
import 'post_moment_screen.dart';

class TripPictureboardScreen extends ConsumerStatefulWidget {
  const TripPictureboardScreen({
    super.key,
    required this.tripId,
    required this.isDarkMode,
  });

  final String tripId;
  final bool isDarkMode;

  @override
  ConsumerState<TripPictureboardScreen> createState() =>
      _TripPictureboardScreenState();
}

class _TripPictureboardScreenState
    extends ConsumerState<TripPictureboardScreen> {
  late Future<({List<Moment> items, String? nextCursor})> _gallery;
  final _extra = <Moment>[];
  String? _nextCursor;
  bool _hasMorePage = false;
  bool _loadingMore = false;
  bool _pageFailed = false;
  bool _grid = false;

  @override
  void initState() {
    super.initState();
    _gallery = _fetch();
  }

  Future<({List<Moment> items, String? nextCursor})> _fetch({String? cursor}) =>
      ref
          .read(momentsRepositoryProvider)
          .gallery(widget.tripId, cursor: cursor);

  void _reload() {
    setState(() {
      _gallery = _fetch();
      _extra.clear();
      _nextCursor = null;
      _hasMorePage = false;
      _loadingMore = false;
      _pageFailed = false;
    });
  }

  Future<void> _loadMore(String cursor) async {
    final firstPage = _gallery;
    setState(() {
      _loadingMore = true;
      _pageFailed = false;
    });
    try {
      final page = await _fetch(cursor: cursor);
      if (!mounted || !identical(firstPage, _gallery)) return;
      setState(() {
        _extra.addAll(page.items);
        _nextCursor = page.nextCursor;
        _hasMorePage = true;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || !identical(firstPage, _gallery)) return;
      setState(() {
        _loadingMore = false;
        _pageFailed = true;
      });
    }
  }

  String _copy(String vi, String en) =>
      context.locale.languageCode == 'vi' ? vi : en;

  Future<void> _open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  Future<void> _openEditor(Widget page) async {
    await _open(page);
    if (mounted) _reload();
  }

  Widget _image(Moment photo, CdnTier tier, BoxFit fit) => CachedNetworkImage(
    imageUrl: cdnUrlForTier(photo.mediaUrl, tier),
    cacheKey: cdnCacheKey(photo.mediaUrl, tier: tier),
    memCacheWidth: tier.width,
    fit: fit,
    fadeInDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 160),
    errorWidget: (_, _, _) =>
        const Center(child: Icon(Icons.broken_image_outlined)),
  );

  void _showPhoto(Moment photo) {
    final timestamp = photo.takenAt ?? photo.createdAt;
    _open(
      Scaffold(
        appBar: AppBar(title: Text(photo.authorName)),
        body: ListView(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: InteractiveViewer(
                child: _image(photo, CdnTier.full, BoxFit.contain),
              ),
            ),
            ListTile(
              title: Text(photo.caption ?? photo.authorName),
              subtitle: Text(
                DateFormat.yMMMd(
                  context.locale.languageCode,
                ).add_jm().format(timestamp.toLocal()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _print(Moment photo, {bool featured = false}) {
    final label = photo.caption ?? photo.authorName;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: InkWell(
        onTap: () => _showPhoto(photo),
        child: Padding(
          padding: EdgeInsets.all(featured ? 8 : 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: featured ? 1.6 : 1,
                child: Semantics(
                  image: true,
                  label: label,
                  child: _image(
                    photo,
                    featured ? CdnTier.background : CdnTier.boardThumb,
                    BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 5, 2, 2),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('beta.pictureboard'.tr()),
        actions: [
          IconButton(
            onPressed: () => setState(() => _grid = !_grid),
            tooltip: _grid
                ? _copy('Xem dây ảnh', 'Show hanging prints')
                : _copy('Xem lưới ảnh', 'Show photo grid'),
            icon: Icon(_grid ? Icons.view_agenda_outlined : Icons.grid_view),
          ),
          IconButton(
            onPressed: () => _openEditor(
              MemoryWallScreen(
                tripId: widget.tripId,
                isDarkMode: widget.isDarkMode,
              ),
            ),
            tooltip: _copy('Chỉnh bố cục ảnh', 'Edit photo layout'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(
          PostMomentScreen(
            tripId: widget.tripId,
            isDarkMode: widget.isDarkMode,
          ),
        ),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(_copy('Thêm ảnh', 'Add photo')),
      ),
      body: FutureBuilder(
        future: _gallery,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final page = snapshot.data;
          if (page == null) {
            return Center(
              child: TextButton(
                onPressed: _reload,
                child: Text(_copy('Tải lại ảnh', 'Reload photos')),
              ),
            );
          }
          final cursor = _hasMorePage ? _nextCursor : page.nextCursor;
          final days = <DateTime, List<Moment>>{};
          final seen = <String>{};
          for (final photo in [...page.items, ..._extra]) {
            if (photo.type != 'PHOTO' || photo.isNoteOnly || photo.developing) {
              continue;
            }
            if (!seen.add(photo.id)) continue;
            final day = DateUtils.dateOnly(
              (photo.takenAt ?? photo.createdAt).toLocal(),
            );
            days.putIfAbsent(day, () => []).add(photo);
          }
          final sorted = days.keys.toList()..sort((a, b) => b.compareTo(a));
          if (sorted.isEmpty && cursor == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  _copy(
                    'Thêm bức ảnh đầu tiên của chuyến đi.',
                    'Add the first photo from this trip.',
                  ),
                ),
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              for (final day in sorted) ..._day(day, days[day]!),
              if (cursor != null)
                SliverToBoxAdapter(
                  child: Center(
                    child: TextButton(
                      onPressed: _loadingMore ? null : () => _loadMore(cursor),
                      child: Text(
                        _loadingMore
                            ? _copy('Đang tải ảnh…', 'Loading photos…')
                            : _pageFailed
                            ? _copy('Thử tải lại', 'Retry loading')
                            : _copy('Xem thêm ảnh', 'Show more photos'),
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _day(DateTime day, List<Moment> photos) {
    final featured = photos.firstWhere(
      (photo) => photo.isPinned,
      orElse: () => photos.first,
    );
    final rest = photos.where((photo) => photo.id != featured.id).toList();
    final scale = MediaQuery.textScalerOf(context).scale(14);
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 23, 22, 13),
          child: Semantics(
            header: true,
            child: Text(
              DateFormat.yMMMMd(context.locale.languageCode).format(day),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),
      if (_grid)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          sliver: SliverGrid.builder(
            itemCount: photos.length,
            itemBuilder: (_, index) => _print(photos[index]),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 178 + scale,
            ),
          ),
        )
      else
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
            child: Column(
              children: [
                const Divider(thickness: 2, height: 10),
                const Icon(Icons.push_pin, size: 18),
                _print(featured, featured: true),
                if (rest.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  const Divider(thickness: 2, height: 14),
                  SizedBox(
                    height: 136 + scale,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: rest.length,
                      padding: const EdgeInsets.all(5),
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, index) =>
                          SizedBox(width: 115, child: _print(rest[index])),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
    ];
  }
}
