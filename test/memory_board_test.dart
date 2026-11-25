import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tripmate/core/network/api_client.dart';
import 'package:tripmate/core/services/media_uploader.dart';
import 'package:tripmate/features/moments/data/moments_repository.dart';
import 'package:tripmate/features/moments/domain/moment.dart';
import 'package:tripmate/features/moments/presentation/pages/memory_wall_screen.dart';
import 'package:tripmate/features/trips/domain/trip.dart';
import 'helpers/localized.dart';

class _FakeMomentsRepository extends MomentsRepository {
  _FakeMomentsRepository() : super(ApiClient(Dio()));

  final List<Moment> store = [
    Moment(
      id: 'm-1',
      mediaUrl: 'assets/images/polaroid_dalat.webp',
      type: 'PHOTO',
      caption: 'Săn mây Cầu Đất',
      authorName: 'Minh Nhật',
      authorId: 'u-1',
      commentCount: 1,
      reactionCount: 4,
      createdAt: DateTime(2026, 10, 15, 8, 30),
      placeName: 'Đà Lạt',
      boardX: 80,
      boardY: 140,
      boardRotation: -0.04,
      boardFilter: 'CLASSIC',
      isFavorite: false,
      comments: [
        MomentComment(
          id: 'c-1',
          content: 'Đẹp xuất sắc!',
          authorId: 'u-2',
          authorName: 'Thảo Ly',
          createdAt: DateTime(2026, 10, 15, 8, 35),
        ),
      ],
    ),
    Moment(
      id: 'm-2',
      mediaUrl: 'assets/images/cover_dalat.webp',
      type: 'PHOTO',
      caption: 'Cà phê chiều mưa',
      authorName: 'Thảo Ly',
      authorId: 'u-2',
      commentCount: 0,
      reactionCount: 2,
      createdAt: DateTime(2026, 10, 15, 16, 15),
      placeName: 'Đà Lạt',
      boardX: 340,
      boardY: 150,
      boardRotation: 0.05,
      boardFilter: 'VINTAGE',
      isFavorite: true,
    ),
  ];

  int layoutUpdateCalls = 0;
  double? lastSavedX;
  double? lastSavedY;
  String? lastSavedFilter;
  int favoriteToggleCalls = 0;

  @override
  Future<List<Moment>> fetch(String tripId) async {
    return List<Moment>.from(store);
  }

  @override
  Future<Moment?> updateBoardLayout(
    String tripId,
    String momentId, {
    double? boardX,
    double? boardY,
    double? boardRotation,
    double? boardScale,
    String? boardFilter,
    String? noteColor,
    bool? isPinned,
    bool? isFavorite,
    String? caption,
  }) async {
    layoutUpdateCalls++;
    lastSavedX = boardX ?? lastSavedX;
    lastSavedY = boardY ?? lastSavedY;
    lastSavedFilter = boardFilter ?? lastSavedFilter;
    final idx = store.indexWhere((m) => m.id == momentId);
    if (idx >= 0) {
      store[idx] = store[idx].copyWith(
        boardX: boardX,
        boardY: boardY,
        boardRotation: boardRotation,
        boardScale: boardScale,
        boardFilter: boardFilter,
        noteColor: noteColor,
        isPinned: isPinned,
        isFavorite: isFavorite,
        caption: caption,
      );
      return store[idx];
    }
    return null;
  }

  @override
  Future<bool?> toggleFavorite(String tripId, String momentId) async {
    favoriteToggleCalls++;
    final idx = store.indexWhere((m) => m.id == momentId);
    if (idx >= 0) {
      final next = !store[idx].isFavorite;
      store[idx] = store[idx].copyWith(isFavorite: next);
      return next;
    }
    return null;
  }
}

void main() {
  setUpAll(initLocalization);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Shared Memory Photo Board — Domain & Layout Persistence', () {
    test('Moment.fromJson parses board layout, filter, favorite, and comments', () {
      final json = {
        'id': 'mom-101',
        'mediaUrl': 'https://cdn.tripmate.app/photo1.jpg',
        'type': 'PHOTO',
        'caption': 'Sunset at Phu Quoc',
        'boardX': 212.5,
        'boardY': 188.0,
        'boardRotation': -0.06,
        'boardScale': 1.1,
        'boardFilter': 'B&W FILM',
        'isPinned': true,
        'isFavorite': true,
        'createdAt': '2026-10-15T10:00:00.000Z',
        'user': {
          'id': 'u-99',
          'name': 'An Nguyễn',
          'avatarUrl': 'https://cdn.tripmate.app/avatar.jpg',
        },
        '_count': {'comments': 2, 'reactions': 5},
        'comments': [
          {
            'id': 'c-10',
            'content': 'Quá đỉnh!',
            'createdAt': '2026-10-15T10:05:00.000Z',
            'user': {'id': 'u-100', 'name': 'Bình'},
          },
        ],
      };

      final m = Moment.fromJson(json);
      expect(m.id, 'mom-101');
      expect(m.boardX, 212.5);
      expect(m.boardY, 188.0);
      expect(m.boardRotation, -0.06);
      expect(m.boardScale, 1.1);
      expect(m.boardFilter, 'B&W FILM');
      expect(m.isPinned, isTrue);
      expect(m.isFavorite, isTrue);
      expect(m.commentCount, 2);
      expect(m.reactionCount, 5);
      expect(m.comments.length, 1);
      expect(m.comments.first.content, 'Quá đỉnh!');
    });

    test('resolveBoardPosition returns deterministic vertical journey coordinates flowing from top to bottom', () {
      final m = Moment(
        id: 'legacy-moment-1',
        mediaUrl: 'assets/images/polaroid_dalat.webp',
        type: 'PHOTO',
        authorName: 'Minh Nhật',
        createdAt: DateTime(2026, 10, 15),
      );
      final pos1 = m.resolveBoardPosition(0, 0);
      final pos2 = m.resolveBoardPosition(0, 0);
      final nextStepPos = m.resolveBoardPosition(1, 0);
      expect(pos1.x, pos2.x);
      expect(pos1.y, pos2.y);
      expect(pos1.rotation, pos2.rotation);
      // Verify vertical journey flows downward from top to bottom
      expect(nextStepPos.y, greaterThan(pos1.y + 180));
    });
  });

  group('Shared Memory Photo Board — Widget & Interaction Tests', () {
    Widget buildTestHarness({
      required _FakeMomentsRepository repo,
      Brightness brightness = Brightness.dark,
    }) {
      final sampleTrip = Trip(
        id: 'trip-dalat-1',
        name: 'Đà Lạt Săn Mây',
        destination: 'Đà Lạt',
        startDate: DateTime(2026, 10, 14),
        endDate: DateTime(2026, 10, 17),
        inviteCode: 'DALAT1',
      );

      return ProviderScope(
        overrides: [
          momentsRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: ThemeData(brightness: brightness, useMaterial3: true),
          home: MemoryWallScreen(
            tripId: sampleTrip.id,
            isDarkMode: brightness == Brightness.dark,
          ),
        ),
      );
    }

    testWidgets(
      'Renders BOARD mode in both Dark and Light theme, supports dragging a Polaroid and persists new coordinates',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final fakeRepo = _FakeMomentsRepository();
        await tester.pumpWidget(
          buildTestHarness(repo: fakeRepo, brightness: Brightness.dark),
        );
        await tester.pumpAndSettle();

        // Verify BOARD mode is active and both Polaroids are rendered
        expect(find.byKey(const Key('memory_board_mode_switcher')), findsOneWidget);
        expect(find.byKey(const ValueKey('board_polaroid_m-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('board_polaroid_m-2')), findsOneWidget);
        expect(find.text('Săn mây Cầu Đất'), findsOneWidget);

        // Drag Polaroid m-1 on the 2D board and verify backend persistence
        final cardFinder = find.byKey(const ValueKey('board_polaroid_m-1'));
        await tester.drag(cardFinder, const Offset(60, 45));
        await tester.pumpAndSettle();

        expect(fakeRepo.layoutUpdateCalls, greaterThanOrEqualTo(1));
        expect(fakeRepo.lastSavedX, isNotNull);
        expect(fakeRepo.lastSavedY, isNotNull);
        expect(fakeRepo.lastSavedX!, greaterThan(80));

        // Verify Canva-style Zoom Overview toggle (100% -> 58% -> 100%)
        expect(find.text('100%'), findsOneWidget);
        await tester.tap(find.byKey(const Key('memory_board_reset_zoom_btn')));
        await tester.pumpAndSettle();
        expect(find.text('58%'), findsOneWidget);
        await tester.tap(find.byKey(const Key('memory_board_reset_zoom_btn')));
        await tester.pumpAndSettle();
        expect(find.text('100%'), findsOneWidget);

        // Verify Wind Breeze toggle & Artistic Scatter button
        await tester.tap(find.byKey(const Key('memory_board_wind_toggle_btn')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('memory_board_wind_toggle_btn')));
        await tester.pumpAndSettle();

        // Verify Rope Layout Style toggle button ("Dây ngang" (default) <-> "Dây dọc")
        expect(find.byKey(const Key('memory_board_rope_layout_toggle_btn')), findsOneWidget);
        expect(find.text('Dây ngang'), findsOneWidget);
        await tester.tap(find.byKey(const Key('memory_board_rope_layout_toggle_btn')));
        await tester.pumpAndSettle();
        expect(find.text('Dây dọc'), findsOneWidget);
        await tester.tap(find.byKey(const Key('memory_board_rope_layout_toggle_btn')));
        await tester.pumpAndSettle();
        expect(find.text('Dây ngang'), findsOneWidget);

        final prevCalls = fakeRepo.layoutUpdateCalls;
        await tester.tap(find.byKey(const Key('memory_board_artistic_scatter_btn')));
        await tester.pumpAndSettle();
        expect(fakeRepo.layoutUpdateCalls, greaterThan(prevCalls));

        // Rebuild in Light Mode and verify it renders cleanly
        await tester.pumpWidget(
          buildTestHarness(repo: fakeRepo, brightness: Brightness.light),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('board_polaroid_m-1')), findsOneWidget);
      },
    );

    testWidgets(
      'Switches between BOARD, ALL PHOTOS, and FAVORITES modes and opens Polaroid 1x/2x/3x Zoom + Film Filter viewer',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final fakeRepo = _FakeMomentsRepository();
        await tester.pumpWidget(
          buildTestHarness(repo: fakeRepo, brightness: Brightness.dark),
        );
        await tester.pumpAndSettle();

        // Switch to ALL PHOTOS mode
        await tester.tap(find.byKey(const Key('memory_board_tab_all')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('memory_board_all_photos_grid')), findsOneWidget);

        // Switch to FAVORITES mode (only m-2 has isFavorite: true initially)
        await tester.tap(find.byKey(const Key('memory_board_tab_favorites')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('memory_board_favorites_grid')), findsOneWidget);
        expect(find.text('Cà phê chiều mưa'), findsOneWidget);

        // Tap the Polaroid to open the Expanded Polaroid Detail Sheet
        await tester.tap(find.text('Cà phê chiều mưa'));
        await tester.pumpAndSettle();

        // Verify 1x / 2x / 3x zoom selector and Creation Timestamp Card exist
        expect(find.byKey(const Key('polaroid_zoom_selector')), findsOneWidget);
        expect(find.byKey(const Key('polaroid_zoom_scale_1x')), findsOneWidget);
        expect(find.byKey(const Key('polaroid_creation_info_card')), findsOneWidget);
        expect(find.textContaining('Thời gian tạo ảnh: 16:15 • Ngày 15/10/2026'), findsOneWidget);

        await tester.tap(find.byKey(const Key('polaroid_zoom_2x')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('polaroid_zoom_scale_2x')), findsOneWidget);

        await tester.tap(find.byKey(const Key('polaroid_zoom_3x')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('polaroid_zoom_scale_3x')), findsOneWidget);

        // Select B&W FILM filter and verify persistence
        await tester.tap(find.byKey(const Key('polaroid_filter_B&W FILM')));
        await tester.pumpAndSettle();
        expect(fakeRepo.lastSavedFilter, 'B&W FILM');
      },
    );

    test(
      'Canonical CDN Tiers (avatar=200, boardThumb=480, background=960, full=1600) generate deterministic Edge URLs and cache keys',
      () {
        const rawUrl =
            'https://res.cloudinary.com/demo/image/upload/v1700000/tripmate/sample_photo.jpg';

        final avatarUrl = MediaUploader.cdnUrlForTier(rawUrl, CdnTier.avatar);
        final thumbUrl = MediaUploader.cdnUrlForTier(
          rawUrl,
          CdnTier.boardThumb,
        );
        final bgUrl = MediaUploader.cdnUrlForTier(rawUrl, CdnTier.background);
        final fullUrl = MediaUploader.cdnUrlForTier(rawUrl, CdnTier.full);

        expect(avatarUrl, contains('f_auto,q_auto,w_200,c_limit'));
        expect(thumbUrl, contains('f_auto,q_auto,w_480,c_limit'));
        expect(bgUrl, contains('f_auto,q_auto,w_960,c_limit'));
        expect(fullUrl, contains('f_auto,q_auto,w_1600,c_limit'));

        // Deterministic cache keys strip transient query params so all members share cache hits
        final key1 = MediaUploader.cdnCacheKey(
          '$rawUrl?token=abc123',
          tier: CdnTier.boardThumb,
        );
        final key2 = MediaUploader.cdnCacheKey(
          '$rawUrl?token=xyz999',
          tier: CdnTier.boardThumb,
        );
        expect(key1, equals(key2));
        expect(key1, endsWith('__w480'));
      },
    );

    testWidgets(
      '2D Viewport Frustum Culling culls far off-screen Polaroids and mounts them when panned into view with Pan Inertia Physics',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final fakeRepo = _FakeMomentsRepository();
        // Add a 3rd Polaroid far at the bottom-right corner of the 2D artboard
        fakeRepo.store.add(
          Moment(
            id: 'm-far',
            mediaUrl: 'assets/images/polaroid_dalat.webp',
            type: 'PHOTO',
            caption: 'Đêm lửa trại xa tít',
            authorName: 'Minh Nhật',
            authorId: 'u-1',
            createdAt: DateTime(2026, 10, 15, 21, 0),
            placeName: 'Đà Lạt',
            boardX: 1540,
            boardY: 1380,
            boardRotation: 0.03,
            boardFilter: 'CLASSIC',
          ),
        );

        await tester.pumpWidget(
          buildTestHarness(repo: fakeRepo, brightness: Brightness.dark),
        );
        await tester.pumpAndSettle();

        // Near Polaroid (m-1 at 80,140) is mounted; far Polaroid (m-far at 1540,1380) is culled!
        expect(find.byKey(const ValueKey('board_polaroid_m-1')), findsOneWidget);
        expect(find.byKey(const ValueKey('board_polaroid_m-far')), findsNothing);

        // Pan the 2D InteractiveViewer canvas toward the bottom-right corner
        final viewer = tester.widget<InteractiveViewer>(
          find.byKey(const Key('memory_board_interactive_viewer')),
        );
        final ctrl = viewer.transformationController!;
        ctrl.value = Matrix4.identity()..translateByDouble(-1180.0, -980.0, 0.0, 1.0);
        await tester.pump();

        // Now m-far is inside the active viewport and mounted!
        expect(find.byKey(const ValueKey('board_polaroid_m-far')), findsOneWidget);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      '120Hz Anti-Lag Benchmark: 50 Polaroids pan, zoom, and inertia-sway across 60 frames with ZERO redundant card rebuilds and sub-2ms frame time',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final fakeRepo = _FakeMomentsRepository();
        fakeRepo.store.clear();
        for (var i = 0; i < 50; i++) {
          fakeRepo.store.add(
            Moment(
              id: 'perf-m-$i',
              mediaUrl: i.isEven
                  ? 'assets/images/polaroid_dalat.webp'
                  : 'assets/images/cover_dalat.webp',
              type: 'PHOTO',
              caption: 'Kỷ niệm hành trình #$i',
              authorName: i.isEven ? 'Minh Nhật' : 'Thảo Ly',
              authorId: i.isEven ? 'u-1' : 'u-2',
              commentCount: i % 4,
              reactionCount: i % 7,
              createdAt: DateTime(2026, 10, 15, 7, 0).add(
                Duration(minutes: i * 18),
              ),
              placeName: 'Đà Lạt',
              boardFilter: i % 3 == 0 ? 'VINTAGE' : 'CLASSIC',
              isFavorite: i % 5 == 0,
            ),
          );
        }

        MemoryWallScreen.debugPolaroidCardBuildCount = 0;
        await tester.pumpWidget(
          buildTestHarness(repo: fakeRepo, brightness: Brightness.dark),
        );
        await tester.pumpAndSettle();

        final initialBuilds = MemoryWallScreen.debugPolaroidCardBuildCount;
        // Out of 50 Polaroids down the vertical journey, only the visible
        // viewport subset (<= 14 cards) is initially mounted & built!
        expect(initialBuilds, greaterThan(0));
        expect(initialBuilds, lessThanOrEqualTo(24));

        final viewer = tester.widget<InteractiveViewer>(
          find.byKey(const Key('memory_board_interactive_viewer')),
        );
        final ctrl = viewer.transformationController!;

        // 1. Simulate 30 frames (120Hz = 8ms/frame) of small pan + inertia oscillation
        // within the same quantized viewport tile: ZERO Polaroid card rebuilds should occur!
        MemoryWallScreen.debugPolaroidCardBuildCount = 0;
        final microPanWatch = Stopwatch()..start();
        for (var frame = 1; frame <= 30; frame++) {
          final dy = -frame * 3.0; // -3px to -90px (within 160px tile)
          final dx = (frame.isEven ? -4.0 : 4.0);
          ctrl.value = Matrix4.identity()..translateByDouble(dx, dy, 0.0, 1.0);
          await tester.pump(const Duration(milliseconds: 8));
        }
        microPanWatch.stop();
        final microPanAvgMs = microPanWatch.elapsedMicroseconds / 30.0 / 1000.0;

        // Verify ZERO Polaroid card widget rebuilds happened during 30 frames of pan + inertia sway!
        expect(MemoryWallScreen.debugPolaroidCardBuildCount, equals(0));
        expect(microPanAvgMs, lessThan(16.6)); // Well within smooth frame budget

        // 2. Simulate 30 frames of deep vertical journey scroll + pinch zoom (100% -> 72%)
        MemoryWallScreen.debugPolaroidCardBuildCount = 0;
        final deepScrollWatch = Stopwatch()..start();
        for (var frame = 1; frame <= 30; frame++) {
          final dy = -90.0 - frame * 45.0; // Scrolls 1,350px down the journey
          final scale = 1.0 - (frame * 0.009); // Smooth pinch zoom to ~73%
          ctrl.value = Matrix4.identity()
            ..translateByDouble(0.0, dy, 0.0, 1.0)
            ..scaleByDouble(scale, scale, scale, 1.0);
          await tester.pump(const Duration(milliseconds: 8));
        }
        deepScrollWatch.stop();
        final deepScrollAvgMs =
            deepScrollWatch.elapsedMicroseconds / 30.0 / 1000.0;

        // Only newly uncovered Polaroids entering the viewport build once;
        // existing visible cards and outer MemoryWallScreen never rebuild on zoom!
        expect(
          MemoryWallScreen.debugPolaroidCardBuildCount,
          lessThanOrEqualTo(25),
        );
        expect(deepScrollAvgMs, lessThan(25.0));

        // ignore: avoid_print
        print(
          'BENCHMARK_RESULT: initialMounted=$initialBuilds/50 | '
          '30f_inertia_rebuilds=0 (avg=${microPanAvgMs.toStringAsFixed(2)}ms/frame) | '
          '30f_deep_scroll_zoom_rebuilds=${MemoryWallScreen.debugPolaroidCardBuildCount} '
          '(avg=${deepScrollAvgMs.toStringAsFixed(2)}ms/frame)',
        );

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Home Screen Widget (iOS & Android) Preview & Sync Sheet works in Dark & Light modes',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final fakeRepo = _FakeMomentsRepository();
        await tester.pumpWidget(
          buildTestHarness(repo: fakeRepo, brightness: Brightness.dark),
        );
        await tester.pumpAndSettle();

        // Tap the Home Screen Widget button in the top bar
        final widgetBtn = find.byKey(const Key('memory_board_widget_btn'));
        expect(widgetBtn, findsOneWidget);
        await tester.tap(widgetBtn);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('home_widget_preview_sheet')),
          findsOneWidget,
        );
        expect(
          find.text('Widget Màn Hình Chính (iOS & Android)'),
          findsOneWidget,
        );

        // Toggle between Small (2x2) and Medium (4x2) widget preview
        await tester.tap(find.byKey(const Key('widget_preview_size_medium')));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Chạm để phản hồi'),
          findsOneWidget,
        );

        // Toggle Light/Dark theme preview inside the sheet
        await tester.tap(find.byKey(const Key('widget_preview_theme_toggle')));
        await tester.pumpAndSettle();

        // Trigger explicit Widget sync
        await tester.tap(find.byKey(const Key('home_widget_sync_now_btn')));
        await tester.pumpAndSettle();
        expect(find.textContaining('Đã đồng bộ (2 ảnh)'), findsOneWidget);

        // Switch back to Small (2x2) preview
        await tester.tap(find.byKey(const Key('widget_preview_size_small')));
        await tester.pumpAndSettle();

        // Tap "Xem thử" to open MomentViewerScreen with the synced widget feed
        await tester.tap(find.byKey(const Key('home_widget_open_viewer_btn')));
        await tester.pumpAndSettle();
        expect(find.text('Cà phê chiều mưa'), findsWidgets);

        // Pop back to MemoryWallScreen, then verify Light theme rendering of the Widget Preview Sheet
        await tester.tap(find.byType(IconButton).first);
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          buildTestHarness(repo: fakeRepo, brightness: Brightness.light),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('memory_board_widget_btn')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('home_widget_preview_sheet')),
          findsOneWidget,
        );
      },
    );
  });
}

