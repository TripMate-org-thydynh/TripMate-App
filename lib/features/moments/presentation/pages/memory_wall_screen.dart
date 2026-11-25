import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/media_uploader.dart';
import '../../../../core/services/widget_pin.dart';
import '../../../../core/services/widget_sync.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/widgets/report_sheet.dart';
import '../../../premium/presentation/paywall_sheet.dart';
import '../../../profile/data/profile_provider.dart';
import '../../../profile/data/xp_repository.dart';
import '../../../trips/application/trips_providers.dart';
import '../../../trips/domain/trip.dart';
import '../../application/memory_board_audio_controller.dart';
import '../../application/moments_providers.dart';
import '../../data/moments_repository.dart';
import '../../domain/moment.dart';
import 'moment_viewer_screen.dart';
import 'squad_cam_screen.dart';
import 'trip_recap_reel_screen.dart';

enum MemoryBoardViewMode { board, allPhotos, favorites }

/// Two switchable rope layout styles inside the 2D BOARD view:
/// - [verticalJourney]: Vertical winding journey trail from top to bottom ("Dây dọc").
/// - [horizontalStages]: Classic horizontal ropes per stage/day row ("Dây ngang").
enum MemoryBoardRopeLayout { verticalJourney, horizontalStages }


/// Film filters available on the Shared Memory Photo Board.
class MemoryBoardFilters {
  static const String classic = 'CLASSIC';
  static const String bwFilm = 'B&W FILM';
  static const String vintage = 'VINTAGE';
  static const String warmGold = 'WARM GOLD';

  static const List<String> all = [classic, bwFilm, vintage, warmGold];

  static String labelOf(String code) {
    switch (code.toUpperCase()) {
      case bwFilm:
        return 'B&W FILM';
      case vintage:
        return 'VINTAGE';
      case warmGold:
        return 'WARM GOLD';
      default:
        return 'CLASSIC';
    }
  }

  static ColorFilter? colorFilterOf(String code) {
    switch (code.toUpperCase()) {
      case bwFilm:
        return const ColorFilter.matrix(<double>[
          0.33, 0.59, 0.08, 0, 10, //
          0.33, 0.59, 0.08, 0, 10, //
          0.33, 0.59, 0.08, 0, 8, //
          0, 0, 0, 1, 0,
        ]);
      case vintage:
        return const ColorFilter.matrix(<double>[
          0.92, 0.18, 0.05, 0, 14, //
          0.08, 0.86, 0.08, 0, 8, //
          0.04, 0.12, 0.72, 0, -6, //
          0, 0, 0, 1, 0,
        ]);
      case warmGold:
        return const ColorFilter.matrix(<double>[
          1.06, 0.06, 0.0, 0, 12, //
          0.02, 0.98, 0.0, 0, 6, //
          0.0, 0.04, 0.84, 0, -10, //
          0, 0, 0, 1, 0,
        ]);
      default:
        return null;
    }
  }
}

/// Adaptive theme tokens for the Shared Memory Photo Board (Dark & Light).
class _BoardPalette {
  final bool isDark;
  final Color canvasBgTop;
  final Color canvasBgBottom;
  final Color corkDot;
  final Color chromeSurface;
  final Color chromeBorder;
  final Color pillBg;
  final Color pillActive;
  final Color pillActiveText;
  final Color ropeColor;
  final Color ropeShadow;
  final Color pinGold;
  final Color polaroidFrame;
  final Color polaroidInk;
  final Color polaroidSubInk;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  const _BoardPalette({
    required this.isDark,
    required this.canvasBgTop,
    required this.canvasBgBottom,
    required this.corkDot,
    required this.chromeSurface,
    required this.chromeBorder,
    required this.pillBg,
    required this.pillActive,
    required this.pillActiveText,
    required this.ropeColor,
    required this.ropeShadow,
    required this.pinGold,
    required this.polaroidFrame,
    required this.polaroidInk,
    required this.polaroidSubInk,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  factory _BoardPalette.of(BuildContext context, {bool forceDark = false}) {
    final isDark =
        forceDark || Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _BoardPalette(
        isDark: true,
        canvasBgTop: Color(0xFF21110E),
        canvasBgBottom: Color(0xFF140A08),
        corkDot: Color(0x18E8A856),
        chromeSurface: Color(0xE6291511),
        chromeBorder: Color(0x33E8A856),
        pillBg: Color(0xFF2B1612),
        pillActive: Color(0xFFE5A253),
        pillActiveText: Color(0xFF1B0D0A),
        ropeColor: Color(0xFFC88B4B),
        ropeShadow: Color(0x88000000),
        pinGold: Color(0xFFE5A253),
        polaroidFrame: Color(0xFFFBF6EE),
        polaroidInk: Color(0xFF1E1714),
        polaroidSubInk: Color(0xFF6E5D53),
        textPrimary: Color(0xFFF9F1E6),
        textSecondary: Color(0xFFC2A999),
        accent: Color(0xFFE5A253),
      );
    }
    return const _BoardPalette(
      isDark: false,
      canvasBgTop: Color(0xFFF6EFE4),
      canvasBgBottom: Color(0xFFEAE0D0),
      corkDot: Color(0x188C5E3C),
      chromeSurface: Color(0xF2FAF5EC),
      chromeBorder: Color(0x268C5E3C),
      pillBg: Color(0xFFEBE1D1),
      pillActive: Color(0xFFC86D3B),
      pillActiveText: Color(0xFFFFFFFF),
      ropeColor: Color(0xFF9E6B3B),
      ropeShadow: Color(0x293E2512),
      pinGold: Color(0xFFD4883A),
      polaroidFrame: Color(0xFFFFFFFF),
      polaroidInk: Color(0xFF1E1714),
      polaroidSubInk: Color(0xFF6E5D53),
      textPrimary: Color(0xFF221813),
      textSecondary: Color(0xFF725F52),
      accent: Color(0xFFC86D3B),
    );
  }
}

/// Shared Memory Photo Board (`MemoryWallScreen`) — Phase 4 implementation.
///
/// Features:
/// - Switchable `BOARD` (2D interactive hanging Polaroid wall), `ALL PHOTOS`
///   (postage-stamp & Polaroid grid), and `FAVORITES` views.
/// - Two switchable rope layout styles inside `BOARD`:
///   1. `Dây dọc` ([MemoryBoardRopeLayout.verticalJourney]) — Vertical winding
///      journey trail from top to bottom.
///   2. `Dây ngang` ([MemoryBoardRopeLayout.horizontalStages]) — Classic
///      horizontal catenary ropes per stage/day row.
/// - Real drag-and-drop Polaroid repositioning on the 2D board with dynamic
///   catenary hanging ropes, velocity tilt, damped pendulum spring physics, and
///   backend persistence (`PATCH /trips/:tripId/moments/:id/layout`).
/// - Tap-to-open Expanded Polaroid Viewer with `1x / 2x / 3x` zoom selector,
///   film filters (`CLASSIC`, `B&W FILM`, `VINTAGE`, `WARM GOLD`), pin/favorite
///   toggles, reactions, comments, share, and report/delete actions.
/// - Tactile paper/clip pop SFX + user-controlled ambient music pill.
class MemoryWallScreen extends ConsumerStatefulWidget {
  final String? tripId;
  final bool isDarkMode;

  @visibleForTesting
  static int get debugPolaroidCardBuildCount =>
      _StaticPolaroidCardContent.debugBuildCount;

  @visibleForTesting
  static set debugPolaroidCardBuildCount(int value) =>
      _StaticPolaroidCardContent.debugBuildCount = value;

  const MemoryWallScreen({super.key, this.tripId, this.isDarkMode = false});

  @override
  ConsumerState<MemoryWallScreen> createState() => _MemoryWallScreenState();
}

class _MemoryWallScreenState extends ConsumerState<MemoryWallScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  MemoryBoardViewMode _viewMode = MemoryBoardViewMode.board;
  MemoryBoardRopeLayout _ropeLayout = MemoryBoardRopeLayout.horizontalStages;
  bool _forceRopeLayoutPositions = false;
  String? _selectedTripId;
  String? _selectedAuthorFilter;

  /// Local transient drag offsets while a user is actively dragging a card,
  /// keyed by moment ID.
  final Map<String, Offset> _livePositions = {};

  /// Local transient rotation angle (in radians) from drag velocity / pendulum
  /// spring simulation, keyed by moment ID.
  final Map<String, double> _liveSwayAngles = {};
  final Map<String, AnimationController> _swayControllers = {};

  String? _draggingMomentId;
  bool _uploading = false;
  double _uploadProgress = 0;
  bool _breezeEnabled = false;
  final bool _fairyLightsEnabled = true;
  double _boardZoomScale = 1.0;
  final ValueNotifier<int> _boardZoomPct = ValueNotifier<int>(100);

  /// Lightweight notifier that invalidates ONLY the board canvas inside
  /// [InteractiveViewer] during pan, inertia, or pendulum sway ticks without
  /// rebuilding the outer Scaffold, header, or floating dock.
  final ValueNotifier<int> _boardViewportTick = ValueNotifier<int>(0);

  /// Pan Inertia Physics: when the user drags/pans the 2D board canvas,
  /// both the hemp ropes and hanging Polaroids swing in the opposite direction
  /// of the canvas acceleration/velocity, then spring-oscillate back to rest.
  Offset? _lastMatrixTranslation;
  double _panInertiaAngle = 0.0;
  double _panInertiaLateralShift = 0.0;
  double _panInertiaSag = 0.0;
  double _panReleaseAngle = 0.0;
  double _panReleaseLateral = 0.0;
  double _panReleaseSag = 0.0;
  Timer? _panSettleDebounce;

  /// Tracks which moment IDs have already been prefetched into L1/L2 cache
  /// when entering the outer prefetch ring around the visible viewport.
  final Set<String> _prefetchedThumbIds = <String>{};

  late final TransformationController _boardTransform =
      TransformationController();
  late final AnimationController _windController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9600),
  );
  late final AnimationController _panInertiaController =
      AnimationController.unbounded(vsync: this);
  late final MemoryBoardAudioController _audio = MemoryBoardAudioController();
  final ImagePicker _picker = ImagePicker();

  bool get _isFlutterTest => Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedTripId = widget.tripId;
    _boardTransform.addListener(_onBoardTransformChanged);
    _panInertiaController.addListener(_onPanInertiaSpringTick);
    _audio.init();
    if (_isFlutterTest) {
      // Deterministic wind phase in widget tests so tester.pumpAndSettle() never hangs.
      _windController.value = 0.28;
    } else if (_breezeEnabled) {
      _windController.repeat();
    }
  }

  void _onPanInertiaSpringTick() {
    if (!mounted) return;
    final factor = _panInertiaController.value.clamp(-1.2, 1.2);
    _panInertiaAngle = _panReleaseAngle * factor;
    _panInertiaLateralShift = _panReleaseLateral * factor;
    _panInertiaSag = _panReleaseSag * factor;
    _boardViewportTick.value++;
  }

  void _startPanInertiaSpringBack() {
    if (!mounted) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _panInertiaAngle = 0.0;
      _panInertiaLateralShift = 0.0;
      _panInertiaSag = 0.0;
      _boardViewportTick.value++;
      return;
    }
    _panReleaseAngle = _panInertiaAngle;
    _panReleaseLateral = _panInertiaLateralShift;
    _panReleaseSag = _panInertiaSag;
    if (_panReleaseAngle.abs() < 0.003 &&
        _panReleaseLateral.abs() < 0.2 &&
        _panReleaseSag.abs() < 0.2) {
      return;
    }
    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 155.0,
      damping: 9.4,
    );
    final sim = SpringSimulation(spring, 1.0, 0.0, -2.4);
    _panInertiaController.animateWith(sim).whenCompleteOrCancel(() {
      if (!mounted) return;
      _panInertiaAngle = 0.0;
      _panInertiaLateralShift = 0.0;
      _panInertiaSag = 0.0;
      _boardViewportTick.value++;
    });
  }

  void _onBoardTransformChanged() {
    final storage = _boardTransform.value.storage;
    final scale = storage[0].clamp(0.35, 2.8);
    final currentTrans = Offset(storage[12], storage[13]);

    if (_lastMatrixTranslation != null && _draggingMomentId == null) {
      final dx = currentTrans.dx - _lastMatrixTranslation!.dx;
      final dy = currentTrans.dy - _lastMatrixTranslation!.dy;
      if (dx.abs() > 0.6 || dy.abs() > 0.6) {
        _panInertiaController.stop();
        // Opposing inertia: when the board is dragged right/down,
        // hanging Polaroids & ropes lag behind in the opposite direction.
        final targetAngle = ((-dx * 0.013) + (dy * 0.004)).clamp(-0.24, 0.24);
        final targetLateral = (-dx * 0.58).clamp(-20.0, 20.0);
        final targetSag = (-dy * 0.52).clamp(-16.0, 22.0);

        _panInertiaAngle = (_panInertiaAngle * 0.5 + targetAngle * 0.5).clamp(
          -0.24,
          0.24,
        );
        _panInertiaLateralShift =
            (_panInertiaLateralShift * 0.5 + targetLateral * 0.5).clamp(
              -20.0,
              20.0,
            );
        _panInertiaSag = (_panInertiaSag * 0.5 + targetSag * 0.5).clamp(
          -16.0,
          22.0,
        );

        _panSettleDebounce?.cancel();
        _panSettleDebounce = Timer(
          const Duration(milliseconds: 85),
          _startPanInertiaSpringBack,
        );
      }
    }
    _lastMatrixTranslation = currentTrans;

    final nextPct = (scale * 100).round();
    _boardZoomScale = scale;
    if (_boardZoomPct.value != nextPct) {
      _boardZoomPct.value = nextPct;
    }
    _boardViewportTick.value++;
  }

  /// Computes the currently visible 2D canvas rectangle in board coordinates
  /// from [_boardTransform] and the screen [viewportSize].
  Rect _computeVisibleCanvasRect(Size viewportSize) {
    final storage = _boardTransform.value.storage;
    final scale = storage[0].clamp(0.35, 2.8);
    final tx = storage[12];
    final ty = storage[13];
    final left = (-tx) / scale;
    final top = (-ty) / scale;
    final width = viewportSize.width / scale;
    final height = viewportSize.height / scale;
    return Rect.fromLTWH(left, top, width, height);
  }

  /// Snaps a viewport rectangle outward to [gridStep] boundaries so sub-pixel
  /// pan frames do not trigger unnecessary cull-rect state transitions.
  Rect _quantizeRect(Rect r, double gridStep) {
    final l = (r.left / gridStep).floorToDouble() * gridStep;
    final t = (r.top / gridStep).floorToDouble() * gridStep;
    final right = (r.right / gridStep).ceilToDouble() * gridStep;
    final bottom = (r.bottom / gridStep).ceilToDouble() * gridStep;
    return Rect.fromLTRB(l, t, right, bottom);
  }

  /// Prefetches a Polaroid's canonical `CdnTier.boardThumb` into the shared
  /// disk/memory cache when it enters the outer prefetch ring around the viewport.
  void _prefetchMomentThumbIfNeeded(BuildContext context, Moment moment) {
    if (_isFlutterTest) return;
    if (!moment.mediaUrl.startsWith('http')) return;
    if (!_prefetchedThumbIds.add(moment.id)) return;
    final thumbUrl = MediaUploader.cdnUrlForTier(
      moment.mediaUrl,
      CdnTier.boardThumb,
    );
    final cacheKey = MediaUploader.cdnCacheKey(
      moment.mediaUrl,
      tier: CdnTier.boardThumb,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
        CachedNetworkImageProvider(
          thumbUrl,
          cacheKey: cacheKey,
          maxWidth: CdnTier.boardThumb.width,
        ),
        context,
        onError: (_, _) {},
      );
    });
  }

  @override
  void didUpdateWidget(covariant MemoryWallScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tripId != oldWidget.tripId && widget.tripId != null) {
      _selectedTripId = widget.tripId;
      _prefetchedThumbIds.clear();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _audio.handleLifecycle(true);
      _windController.stop();
      _panInertiaController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _audio.handleLifecycle(false);
      if (_breezeEnabled && !_isFlutterTest) {
        _windController.repeat();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _panSettleDebounce?.cancel();
    for (final c in _swayControllers.values) {
      c.dispose();
    }
    _swayControllers.clear();
    _panInertiaController.removeListener(_onPanInertiaSpringTick);
    _panInertiaController.dispose();
    _windController.dispose();
    _boardTransform.removeListener(_onBoardTransformChanged);
    _boardTransform.dispose();
    _boardViewportTick.dispose();
    _boardZoomPct.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _toggleWindBreeze() {
    HapticFeedback.selectionClick();
    setState(() {
      _breezeEnabled = !_breezeEnabled;
      if (_breezeEnabled) {
        if (_isFlutterTest) {
          _windController.value = (_windController.value + 0.35) % 1.0;
        } else {
          _windController.repeat();
        }
      } else {
        _windController.stop();
      }
    });
    _boardViewportTick.value++;
  }

  /// Resolves the active trip ID from either `widget.tripId`, `_selectedTripId`,
  /// or the user's trips list.
  String? _resolveTripId(List<Trip> trips) {
    if (widget.tripId != null && widget.tripId!.isNotEmpty) {
      return widget.tripId;
    }
    if (_selectedTripId != null &&
        trips.any((t) => t.id == _selectedTripId)) {
      return _selectedTripId;
    }
    final active = trips.firstOrNull;
    return active?.id;
  }

  Trip? _resolveTrip(List<Trip> trips, String? tripId) {
    if (tripId == null) return trips.firstOrNull;
    return trips.where((t) => t.id == tripId).firstOrNull ?? trips.firstOrNull;
  }

  /// Triggers a damped pendulum oscillation when a Polaroid is dropped on the board.
  void _triggerPendulumSettle(String momentId, double initialAngleRad) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _liveSwayAngles.remove(momentId);
      _boardViewportTick.value++;
      return;
    }
    _swayControllers[momentId]?.dispose();
    final ctrl = AnimationController.unbounded(vsync: this);
    _swayControllers[momentId] = ctrl;

    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 142.0,
      damping: 10.2,
    );
    final sim = SpringSimulation(
      spring,
      initialAngleRad.clamp(-0.28, 0.28),
      0.0,
      0.0,
    );

    ctrl.addListener(() {
      if (!mounted) return;
      _liveSwayAngles[momentId] = ctrl.value;
      _boardViewportTick.value++;
    });
    ctrl.animateWith(sim).whenCompleteOrCancel(() {
      if (!mounted) return;
      _liveSwayAngles.remove(momentId);
      _boardViewportTick.value++;
    });
  }

  /// Propagates a sympathetic ripple wave along the rope to neighboring Polaroids
  /// when a card is dropped or when an artistic scatter gust is triggered.
  void _triggerCoupledRopeWave(
    List<Moment> moments,
    String sourceMomentId,
    double baseImpulseRad,
  ) {
    for (var i = 0; i < moments.length; i++) {
      final m = moments[i];
      if (m.id == sourceMomentId) continue;
      final sign = i.isEven ? 1.0 : -1.0;
      final coupledAngle = (baseImpulseRad * 0.48 * sign).clamp(-0.15, 0.15);
      _triggerPendulumSettle(m.id, coupledAngle);
    }
  }

  /// Switches between the Vertical Winding Journey Rope ("Dây dọc") and
  /// Horizontal Stage Rope Rows ("Dây ngang"), resetting card positions to the
  /// selected rope geometry and triggering a gentle pendulum settle.
  void _toggleRopeLayoutStyle(List<Moment> moments) {
    HapticFeedback.selectionClick();
    _audio.playPop();
    setState(() {
      _ropeLayout = _ropeLayout == MemoryBoardRopeLayout.verticalJourney
          ? MemoryBoardRopeLayout.horizontalStages
          : MemoryBoardRopeLayout.verticalJourney;
      _forceRopeLayoutPositions = true;
      _livePositions.clear();
      _boardTransform.value = Matrix4.identity();
    });
    _boardViewportTick.value++;
    for (var i = 0; i < moments.length; i++) {
      final impulse = (i.isEven ? 0.12 : -0.12);
      _triggerPendulumSettle(moments[i].id, impulse);
    }
  }

  /// Arranges all Polaroids sequentially along the active rope layout
  /// ([MemoryBoardRopeLayout.verticalJourney] or [MemoryBoardRopeLayout.horizontalStages]),
  /// evenly distributes cards so no row is crowded or left empty,
  /// triggers a gentle rope wave, and persists the coordinates to the backend.
  Future<void> _artisticScatterBoard(
    String tripId,
    List<Moment> moments,
  ) async {
    if (moments.isEmpty) return;
    HapticFeedback.mediumImpact();
    _audio.playPop();

    // Sort moments chronologically so the journey follows time order
    final sorted = [...moments]
      ..sort(
        (a, b) => (a.takenAt ?? a.createdAt).compareTo(b.takenAt ?? b.createdAt),
      );
    final n = sorted.length;
    const waypointsX = <double>[76.0, 332.0, 118.0, 308.0];
    final scatterSeed = DateTime.now().millisecondsSinceEpoch & 0x7ff;
    final isHorizontal =
        _ropeLayout == MemoryBoardRopeLayout.horizontalStages;

    setState(() {
      if (isHorizontal) {
        // Optimal row count to balance photos without leaving empty gaps or clustering:
        // 1-4 photos: 1 row
        // 5-8 photos: 2 rows (e.g. 3 & 2, 3 & 3, 4 & 3, 4 & 4)
        // 9-12 photos: 3 rows (e.g. 3 & 3 & 3, 4 & 3 & 3)
        // 13+ photos: ceil(n / 4) rows
        final rowCount = (n <= 4)
            ? 1
            : (n <= 8 ? 2 : (n <= 12 ? 3 : (n / 4.0).ceil()));
        const boardWidth = 1680.0;
        final boardHeight = math.max(1280.0, 160.0 + rowCount * 408.0);
        final strands = _ArtisticRopeStrand.buildDefaultStrands(
          Size(boardWidth, boardHeight),
          math.max(rowCount, 3),
          const <String>[],
          isHorizontalMode: true,
        );

        final baseItems = n ~/ rowCount;
        final extra = n % rowCount;

        var currentIndex = 0;
        for (var r = 0; r < rowCount; r++) {
          final countInRow = baseItems + (r < extra ? 1 : 0);
          final strand = strands[r % strands.length];
          final leftPinX = strand.startPin.dx + 48.0;
          final rightPinX = strand.endPin.dx - 220.0;
          final spanWidth = math.max(100.0, rightPinX - leftPinX);

          for (var k = 0; k < countInRow; k++) {
            final m = sorted[currentIndex++];
            final hash = m.id.codeUnits.fold<int>(
              scatterSeed + currentIndex * 29,
              (a, c) => (a * 31 + c) & 0x7fffffff,
            );
            final step = spanWidth / (countInRow + 1);
            final cardCenterX = leftPinX + step * (k + 1);
            final jitterX = ((hash % 16) - 8).toDouble();
            final targetX = (cardCenterX - 96.0 + jitterX).clamp(
              48.0,
              boardWidth - 216.0,
            );

            // Exact catenary curve evaluation at card center
            final ropePt = strand.evaluatePointAtX(
              targetX + 96.0,
              0.0,
              const [],
            );
            final targetY = ropePt.dy - 6.0;

            _livePositions[m.id] = Offset(targetX, targetY);
          }
        }
      } else {
        for (var i = 0; i < sorted.length; i++) {
          final m = sorted[i];
          final hash = m.id.codeUnits.fold<int>(
            scatterSeed + i * 29,
            (a, c) => (a * 31 + c) & 0x7fffffff,
          );
          final jitterX = ((hash % 32) - 16).toDouble();
          final jitterY = (((hash ~/ 37) % 24) - 12).toDouble();
          final wp = i % waypointsX.length;
          final nextX = (waypointsX[wp] + jitterX).clamp(52.0, 420.0);
          final nextY = (128.0 + i * 246.0 + jitterY).clamp(80.0, 4800.0);
          _livePositions[m.id] = Offset(nextX, nextY);
        }
      }
      if (_isFlutterTest) {
        _windController.value = (_windController.value + 0.22) % 1.0;
      }
    });
    _boardViewportTick.value++;

    for (var i = 0; i < sorted.length; i++) {
      final m = sorted[i];
      final pos = _livePositions[m.id];
      if (pos == null) continue;
      final impulse = (i.isEven ? 0.14 : -0.14);
      _triggerPendulumSettle(m.id, impulse);
      final newRot = ((i.isEven ? -1 : 1) * (0.032 + (i % 3) * 0.014));
      try {
        await ref.read(momentsProvider(tripId).notifier).updateBoardLayout(
          m.id,
          boardX: pos.dx,
          boardY: pos.dy,
          boardRotation: newRot,
        );
      } catch (_) {}
    }
  }

  /// Snaps dragged card cleanly onto the nearest rope strand. If dropped away
  /// from the rope or floating in empty space, triggers a spring snap animation
  /// with tactile clothespin pin sound and haptic vibration.
  Future<void> _onPolaroidDragEnd({
    required String tripId,
    required Moment moment,
    required List<Moment> allMoments,
    required List<_ArtisticRopeStrand> strands,
    required Offset finalPos,
    required double baseRotation,
    required double lastVelocityAngle,
  }) async {
    // 1. Calculate nearest rope strand and exact catenary attachment point
    final clipX = finalPos.dx + 96.0;
    final clipY = finalPos.dy + 6.0;
    final strandIdx = _ArtisticRopeStrand.findBestStrandIndex(
      strands,
      Offset(clipX, clipY),
    );
    final strand = strands[strandIdx];

    // Card clothespin must stay securely on the rope span
    final minX = strand.startPin.dx + 16.0;
    final maxX = strand.endPin.dx - 200.0;
    final targetX = finalPos.dx.clamp(minX, maxX);
    final targetClipX = targetX + 96.0;

    // Evaluate exact rope catenary curve Y at targetClipX
    final ropePt = strand.evaluatePointAtX(targetClipX, 0.0, const []);
    final targetY = ropePt.dy - 6.0;
    final snappedPos = Offset(targetX, targetY);

    // 2. Check if the card was dropped away from the rope (needs pin & snap animation)
    final dyDiff = (finalPos.dy - targetY).abs();
    final dxDiff = (finalPos.dx - targetX).abs();
    final bool needsSnapAnim = dyDiff > 12.0 || dxDiff > 12.0;

    if (needsSnapAnim &&
        mounted &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false) &&
        !_isFlutterTest) {
      // Spring animation snapping card back onto the rope
      final snapCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320),
      );
      final curve = CurvedAnimation(
        parent: snapCtrl,
        curve: Curves.easeOutBack,
      );
      final startPos = finalPos;
      snapCtrl.addListener(() {
        if (!mounted) return;
        final t = curve.value;
        _livePositions[moment.id] = Offset(
          startPos.dx + (snappedPos.dx - startPos.dx) * t,
          startPos.dy + (snappedPos.dy - startPos.dy) * t,
        );
        _boardViewportTick.value++;
      });
      await snapCtrl.forward();
      snapCtrl.dispose();
    }

    if (!mounted) return;
    _livePositions[moment.id] = snappedPos;
    _boardViewportTick.value++;
    _audio.playPop();
    HapticFeedback.mediumImpact();
    _triggerPendulumSettle(moment.id, lastVelocityAngle);
    _triggerCoupledRopeWave(allMoments, moment.id, lastVelocityAngle);
    setState(() => _draggingMomentId = null);

    try {
      await ref.read(momentsProvider(tripId).notifier).updateBoardLayout(
        moment.id,
        boardX: snappedPos.dx,
        boardY: snappedPos.dy,
        boardRotation: baseRotation,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _livePositions.remove(moment.id));
      showGlobalSnack(
        e is ApiException ? e.message : 'moments.load_failed'.tr(),
        isError: true,
      );
    }
  }

  Future<void> _openSquadCam(String tripId, bool isDark) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SquadCamScreen(tripId: tripId, isDarkMode: isDark),
      ),
    );
    if (!mounted) return;
    ref.invalidate(momentsProvider(tripId));
    ref.invalidate(tripMomentsProvider(tripId));
  }

  Future<void> _pickAndUploadPhoto(String tripId, _BoardPalette pal) async {
    if (_uploading) return;
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 1920,
      );
    } catch (e) {
      showGlobalSnack('errors.unknown_error'.tr(), isError: true);
      return;
    }
    if (picked == null || !mounted) return;

    // Show Polaroid composer sheet to choose filter & caption before pinning.
    final config = await _showPhotoComposerSheet(File(picked.path), pal);
    if (config == null || !mounted) return;

    setState(() {
      _uploading = true;
      _uploadProgress = 0.05;
    });

    try {
      final uploaded = await ref.read(mediaUploaderProvider).uploadFile(
        tripId: tripId,
        file: File(picked.path),
        contentType: 'image/jpeg',
        onProgress: (p) {
          if (mounted) setState(() => _uploadProgress = p);
        },
      );

      final created = await ref.read(momentsRepositoryProvider).create(
        tripId: tripId,
        mediaUrl: uploaded.url,
        type: 'PHOTO',
        caption: config.caption.isEmpty ? null : config.caption,
        boardFilter: config.filter,
      );

      if (!mounted) return;
      _audio.playPop();
      ref.invalidate(momentsProvider(tripId));
      ref.invalidate(tripMomentsProvider(tripId));
      ref.invalidate(recentMomentsProvider);
      ref.invalidate(xpWalletProvider);
      await ref.read(widgetSyncProvider).refresh();

      if (!mounted) return;
      _triggerPendulumSettle(created.id, 0.16);
      showGlobalSnack('moments.added_xp'.tr());
    } catch (e) {
      if (!mounted) return;
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  Future<({String caption, String filter})?> _showPhotoComposerSheet(
    File file,
    _BoardPalette pal,
  ) async {
    final captionCtrl = TextEditingController();
    var selectedFilter = MemoryBoardFilters.classic;

    try {
      return await showModalBottomSheet<({String caption, String filter})>(
        context: context,
        isScrollControlled: true,
        backgroundColor: pal.isDark ? const Color(0xFF241310) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (sheetCtx) {
          return StatefulBuilder(
            builder: (sheetCtx, setModal) {
              final bottomInset = MediaQuery.viewInsetsOf(sheetCtx).bottom;
              final safeBottom = MediaQuery.paddingOf(sheetCtx).bottom;
              final filterMatrix = MemoryBoardFilters.colorFilterOf(
                selectedFilter,
              );
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  math.max(bottomInset, safeBottom) + 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: pal.textSecondary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'moments.wall_pin_title'.tr(),
                      style: AppFonts.heading(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: pal.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Polaroid preview frame
                    Container(
                      width: 210,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 26),
                      decoration: BoxDecoration(
                        color: pal.polaroidFrame,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: filterMatrix != null
                              ? ColorFiltered(
                                  colorFilter: filterMatrix,
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    cacheWidth: 600,
                                  ),
                                )
                              : Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  cacheWidth: 600,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Filter selector chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final f in MemoryBoardFilters.all)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  MemoryBoardFilters.labelOf(f),
                                  style: AppFonts.heading(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: selectedFilter == f
                                        ? pal.pillActiveText
                                        : pal.textPrimary,
                                  ),
                                ),
                                selected: selectedFilter == f,
                                selectedColor: pal.pillActive,
                                backgroundColor: pal.pillBg,
                                onSelected: (_) =>
                                    setModal(() => selectedFilter = f),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: captionCtrl,
                      maxLength: 90,
                      style: AppFonts.body(
                        fontSize: 14,
                        color: pal.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'moments.wall_caption_hint'.tr(),
                        hintStyle: AppFonts.body(
                          fontSize: 13,
                          color: pal.textSecondary,
                        ),
                        filled: true,
                        fillColor: pal.pillBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: pal.pillActive,
                          foregroundColor: pal.pillActiveText,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(sheetCtx).pop((
                          caption: captionCtrl.text.trim(),
                          filter: selectedFilter,
                        )),
                        icon: Icon(PhosphorIcons.pushPin(PhosphorIconsStyle.fill)),
                        label: Text(
                          'moments.wall_pin_button'.tr(),
                          style: AppFonts.heading(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: pal.pillActiveText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      captionCtrl.dispose();
    }
  }

  void _openPolaroidViewer(
    BuildContext context,
    String tripId,
    Moment moment,
    _BoardPalette pal,
  ) {
    _audio.playPop();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PolaroidDetailSheet(
        tripId: tripId,
        initialMoment: moment,
        palette: pal,
        audio: _audio,
      ),
    );
  }

  void _showTripSelectorSheet(
    BuildContext context,
    List<Trip> trips,
    String? currentTripId,
    _BoardPalette pal,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: pal.isDark ? const Color(0xFF241310) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: pal.textSecondary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'moments.wall_pick_board'.tr(),
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: pal.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: trips.length,
                    itemBuilder: (_, idx) {
                      final t = trips[idx];
                      final selected = t.id == currentTripId;
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        selected: selected,
                        selectedTileColor: pal.pillActive.withValues(alpha: 0.16),
                        leading: Icon(
                          selected
                              ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                              : PhosphorIcons.airplaneTilt(),
                          color: selected ? pal.pillActive : pal.textSecondary,
                        ),
                        title: Text(
                          t.name,
                          style: AppFonts.heading(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: pal.textPrimary,
                          ),
                        ),
                        subtitle: t.destination?.isNotEmpty == true
                            ? Text(
                                t.destination!,
                                style: AppFonts.body(
                                  fontSize: 12,
                                  color: pal.textSecondary,
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedTripId = t.id;
                            _selectedAuthorFilter = null;
                            _livePositions.clear();
                          });
                          Navigator.of(sheetCtx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = _BoardPalette.of(context, forceDark: widget.isDarkMode);
    final tripsAsync = ref.watch(tripsProvider);
    final trips = tripsAsync.valueOrNull ?? const <Trip>[];
    final tripId = _resolveTripId(trips);
    final activeTrip = _resolveTrip(trips, tripId);

    return Scaffold(
      backgroundColor: pal.canvasBgBottom,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.25),
            radius: 1.25,
            colors: [pal.canvasBgTop, pal.canvasBgBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopHeader(context, pal, trips, activeTrip, tripId),
              _buildModeSwitcherBar(context, pal, tripId),
              if (_uploading)
                LinearProgressIndicator(
                  value: _uploadProgress > 0 ? _uploadProgress : null,
                  minHeight: 3,
                  backgroundColor: pal.pillBg,
                  valueColor: AlwaysStoppedAnimation<Color>(pal.pillActive),
                ),
              Expanded(
                child: tripId == null
                    ? _buildNoTripState(context, pal, tripsAsync.isLoading)
                    : _buildTripMomentsBody(context, pal, tripId, activeTrip),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    _BoardPalette pal,
    List<Trip> trips,
    Trip? activeTrip,
    String? tripId,
  ) {
    final canPop = Navigator.of(context).canPop();
    final momentsList = tripId != null
        ? (ref.watch(momentsProvider(tripId)).valueOrNull ?? const <Moment>[])
        : const <Moment>[];
    final contributorCount = momentsList
        .map((m) => m.authorId ?? m.authorName)
        .toSet()
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          if (canPop)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _HeaderIconButton(
                icon: PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                tooltip: 'common.back'.tr(),
                palette: pal,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.tripId == null && trips.length > 1
                  ? () => _showTripSelectorSheet(context, trips, tripId, pal)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          activeTrip?.name.isNotEmpty == true
                              ? activeTrip!.name
                              : 'moments.wall_title'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: pal.textPrimary,
                          ),
                        ),
                      ),
                      if (widget.tripId == null && trips.length > 1) ...[
                        const SizedBox(width: 4),
                        Icon(
                          PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                          size: 14,
                          color: pal.accent,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    momentsList.isEmpty
                        ? 'SHARED MEMORY PHOTO BOARD'
                        : '${momentsList.length} POLAROIDS • ${math.max(1, contributorCount)} SQUAD MEMBERS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: pal.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Ambient music Play/Pause & Mute pill
          ListenableBuilder(
            listenable: _audio,
            builder: (context, _) {
              final playing = _audio.isPlaying;
              return Container(
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: playing
                      ? pal.pillActive.withValues(alpha: 0.2)
                      : pal.pillBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: playing ? pal.pillActive : pal.chromeBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      key: const Key('memory_board_music_toggle'),
                      borderRadius: BorderRadius.circular(999),
                      onTap: _audio.togglePlayPause,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              playing
                                  ? PhosphorIcons.waveform(
                                      PhosphorIconsStyle.bold,
                                    )
                                  : PhosphorIcons.musicNotes(
                                      PhosphorIconsStyle.fill,
                                    ),
                              size: 15,
                              color: playing ? pal.pillActive : pal.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              playing ? 'ON AIR' : 'AMBIENT',
                              style: AppFonts.heading(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: playing
                                    ? pal.pillActive
                                    : pal.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (playing || _audio.isMuted)
                      InkWell(
                        key: const Key('memory_board_music_mute'),
                        borderRadius: BorderRadius.circular(999),
                        onTap: _audio.toggleMute,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 7, 8, 7),
                          child: Icon(
                            _audio.isMuted
                                ? PhosphorIcons.speakerSlash(
                                    PhosphorIconsStyle.fill,
                                  )
                                : PhosphorIcons.speakerHigh(
                                    PhosphorIconsStyle.fill,
                                  ),
                            size: 14,
                            color: pal.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          if (tripId != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _HeaderIconButton(
                key: const Key('memory_board_widget_btn'),
                icon: PhosphorIcons.appWindow(PhosphorIconsStyle.fill),
                tooltip: 'moments.wall_widget_tooltip'.tr(),
                palette: pal,
                onTap: () => _openHomeWidgetSheet(
                  context: context,
                  pal: pal,
                  tripId: tripId,
                  activeTrip: activeTrip,
                  moments: momentsList,
                ),
              ),
            ),
            _HeaderIconButton(
              icon: PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
              tooltip: 'Recap Reel',
              palette: pal,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TripRecapReelScreen(
                    tripId: tripId,
                    isDarkMode: pal.isDark,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _lastWidgetSyncKey;

  void _autoSyncHomeWidget(
    String tripId,
    Trip? activeTrip,
    List<Moment> moments,
  ) {
    if (_isFlutterTest || moments.isEmpty) return;
    final key = '$tripId:${moments.length}:${moments.first.id}';
    if (_lastWidgetSyncKey == key) return;
    _lastWidgetSyncKey = key;
    final widgetMoments = _toWidgetMoments(tripId, activeTrip, moments);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(widgetSyncProvider).syncItems(widgetMoments);
    });
  }

  List<WidgetMoment> _toWidgetMoments(
    String tripId,
    Trip? activeTrip,
    List<Moment> moments,
  ) {
    try {
      final sorted = [...moments]
        ..sort(
          (a, b) => (b.takenAt ?? b.createdAt).compareTo(a.takenAt ?? a.createdAt),
        );
      final tripName = activeTrip?.name.trim().isNotEmpty == true
          ? activeTrip!.name.trim()
          : 'TripMate Squad';
      return sorted
          .map(
            (m) => WidgetMoment(
              id: m.id,
              tripId: tripId,
              imageUrl: m.mediaUrl,
              authorName: m.authorName,
              tripName: tripName,
              caption: m.caption,
              createdAt: m.takenAt ?? m.createdAt,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('[MemoryBoard] _toWidgetMoments error: $e');
      return const <WidgetMoment>[];
    }
  }

  Future<void> _openHomeWidgetSheet({
    required BuildContext context,
    required _BoardPalette pal,
    required String tripId,
    required Trip? activeTrip,
    required List<Moment> moments,
  }) async {
    HapticFeedback.selectionClick();
    _audio.playPop();
    try {
      final widgetMoments = _toWidgetMoments(tripId, activeTrip, moments);
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _HomeWidgetPreviewSheet(
          tripId: tripId,
          tripName: activeTrip?.name.trim().isNotEmpty == true
              ? activeTrip!.name.trim()
              : 'moments.wall_default_trip_name'.tr(),
          moments: widgetMoments,
          palette: pal,
          audio: _audio,
        ),
      );
    } catch (e, st) {
      debugPrint('[MemoryBoard] openHomeWidgetSheet error: $e\n$st');
    }
  }

  Widget _buildModeSwitcherBar(
    BuildContext context,
    _BoardPalette pal,
    String? tripId,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: Container(
        key: const Key('memory_board_mode_switcher'),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: pal.pillBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: pal.chromeBorder),
        ),
        child: Row(
          children: [
            _buildModeTab(
              key: const Key('memory_board_tab_board'),
              mode: MemoryBoardViewMode.board,
              icon: PhosphorIcons.pushPin(PhosphorIconsStyle.fill),
              label: 'BOARD',
              pal: pal,
            ),
            _buildModeTab(
              key: const Key('memory_board_tab_all'),
              mode: MemoryBoardViewMode.allPhotos,
              icon: PhosphorIcons.squaresFour(PhosphorIconsStyle.fill),
              label: 'ALL PHOTOS',
              pal: pal,
            ),
            _buildModeTab(
              key: const Key('memory_board_tab_favorites'),
              mode: MemoryBoardViewMode.favorites,
              icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
              label: 'FAVORITES',
              pal: pal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required Key key,
    required MemoryBoardViewMode mode,
    required IconData icon,
    required String label,
    required _BoardPalette pal,
  }) {
    final active = _viewMode == mode;
    return Expanded(
      child: GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_viewMode == mode) return;
          HapticFeedback.selectionClick();
          setState(() => _viewMode = mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? pal.pillActive : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: active ? pal.pillActiveText : pal.textSecondary,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: active ? pal.pillActiveText : pal.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoTripState(
    BuildContext context,
    _BoardPalette pal,
    bool isLoading,
  ) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: pal.pillActive, strokeWidth: 2),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.cameraRotate(PhosphorIconsStyle.duotone),
              size: 56,
              color: pal.accent,
            ),
            const SizedBox(height: 14),
            Text(
              'moments.wall_empty_title'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.heading(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: pal.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'moments.wall_empty_sub'.tr(),
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 14, color: pal.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripMomentsBody(
    BuildContext context,
    _BoardPalette pal,
    String tripId,
    Trip? activeTrip,
  ) {
    final momentsAsync = ref.watch(momentsProvider(tripId));
    return Stack(
      children: [
        Positioned.fill(
          child: momentsAsync.when(
            loading: () => Center(
              child: CircularProgressIndicator(
                color: pal.pillActive,
                strokeWidth: 2,
              ),
            ),
            error: (e, _) => _buildErrorView(pal, tripId),
            data: (moments) {
              if (moments.isEmpty) {
                return _buildEmptyBoardState(context, pal, tripId, activeTrip);
              }
              _autoSyncHomeWidget(tripId, activeTrip, moments);
              switch (_viewMode) {
                case MemoryBoardViewMode.board:
                  return _buildInteractiveBoardCanvas(
                    context,
                    pal,
                    tripId,
                    activeTrip,
                    moments,
                  );
                case MemoryBoardViewMode.allPhotos:
                  return _buildAllPhotosStampGrid(
                    context,
                    pal,
                    tripId,
                    moments,
                  );
                case MemoryBoardViewMode.favorites:
                  final favs = moments
                      .where((m) => m.isFavorite || m.isPinned)
                      .toList();
                  return _buildFavoritesGrid(context, pal, tripId, favs);
              }
            },
          ),
        ),
        // Bottom floating creation dock
        Positioned(
          left: 16,
          right: 16,
          bottom: math.max(MediaQuery.paddingOf(context).bottom, 12) + 8,
          child: _buildFloatingActionDock(context, pal, tripId),
        ),
      ],
    );
  }

  Widget _buildErrorView(_BoardPalette pal, String tripId) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.cloudSlash(), size: 42, color: pal.accent),
          const SizedBox(height: 12),
          Text(
            'moments.load_failed'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: pal.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: pal.pillActive,
              foregroundColor: pal.pillActiveText,
            ),
            onPressed: () => ref.invalidate(momentsProvider(tripId)),
            icon: Icon(PhosphorIcons.arrowsClockwise()),
            label: Text('general.retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBoardState(
    BuildContext context,
    _BoardPalette pal,
    String tripId,
    Trip? activeTrip,
  ) {
    return AnimatedBuilder(
      animation: _windController,
      builder: (context, child) {
        final windPhase = _breezeEnabled
            ? _windController.value * 2 * math.pi
            : 0.0;
        return CustomPaint(
          painter: _CatenaryRopePainter(
            palette: pal,
            strands: _ArtisticRopeStrand.buildDefaultStrands(
              const Size(1200, 900),
              2,
              const ['TODAY • PIN YOUR FIRST MEMORY', 'DRAG & ZOOM 360° CANVAS'],
            ),
            cardAnchors: const [],
            windPhase: windPhase,
            fairyLightsEnabled: _fairyLightsEnabled,
          ),
          child: child,
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: pal.chromeSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: pal.chromeBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.camera(PhosphorIconsStyle.duotone),
                  size: 48,
                  color: pal.pillActive,
                ),
                const SizedBox(height: 12),
                Text(
                  'moments.empty'.tr(),
                  textAlign: TextAlign.center,
                  style: AppFonts.heading(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: pal.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'moments.wall_empty_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: AppFonts.body(fontSize: 13, color: pal.textSecondary),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: pal.pillActive,
                        foregroundColor: pal.pillActiveText,
                      ),
                      onPressed: () => _openSquadCam(tripId, pal.isDark),
                      icon: Icon(
                        PhosphorIcons.camera(PhosphorIconsStyle.fill),
                        size: 18,
                      ),
                      label: Text('moments.wall_open_cam'.tr()),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: pal.textPrimary,
                        side: BorderSide(color: pal.chromeBorder),
                      ),
                      onPressed: () => _pickAndUploadPhoto(tripId, pal),
                      icon: Icon(PhosphorIcons.image(), size: 18),
                      label: Text('moments.wall_upload'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the expansive 2D interactive board with two switchable rope layouts:
  /// 1. [MemoryBoardRopeLayout.verticalJourney] — Vertical Winding Journey Rope
  ///    Trail ("Dây dọc: Hành trình kéo từ trên xuống")
  /// 2. [MemoryBoardRopeLayout.horizontalStages] — Horizontal Stage Rope Rows
  ///    ("Dây ngang từng hành trình")
  /// with smart rope/pin anchoring, pan inertia physics, and 2D viewport frustum culling.
  Widget _buildInteractiveBoardCanvas(
    BuildContext context,
    _BoardPalette pal,
    String tripId,
    Trip? activeTrip,
    List<Moment> moments,
  ) {
    final isHorizontal =
        _ropeLayout == MemoryBoardRopeLayout.horizontalStages;
    final itemsPerStrand = isHorizontal ? 5 : 2;

    // Sort chronologically from oldest/first at top to latest at bottom
    final sortedMoments = [...moments]
      ..sort(
        (a, b) => (a.takenAt ?? a.createdAt).compareTo(b.takenAt ?? b.createdAt),
      );

    // Group moments by calendar day for journey stage banners
    final grouped = <String, List<Moment>>{};
    for (final m in sortedMoments) {
      final dt = m.takenAt ?? m.createdAt;
      final key = DateFormat('yyyy-MM-dd').format(dt);
      grouped.putIfAbsent(key, () => []).add(m);
    }

    final dateLabels = <String>[];
    final basePlacements =
        <({Moment moment, Offset basePos, double baseRotation, int index})>[];

    var currentStrandIndex = 0;
    var globalIndex = 0;
    var stageNumber = 1;
    for (final entry in grouped.entries) {
      final dayMoments = entry.value;
      final firstDate = dayMoments.first.takenAt ?? dayMoments.first.createdAt;
      final now = DateTime.now();
      final isToday =
          firstDate.year == now.year &&
          firstDate.month == now.month &&
          firstDate.day == now.day;
      final dateStr = DateFormat('dd/MM/yyyy').format(firstDate);
      final loc =
          dayMoments
              .map((m) => m.placeName)
              .where((p) => p != null && p.trim().isNotEmpty)
              .firstOrNull ??
          activeTrip?.destination ??
          '';
      final headerLabel = [
        'moments.wall_stage_label'.tr(namedArgs: {'n': stageNumber.toString()}),
        if (isToday) 'moments.wall_today_label'.tr(namedArgs: {'date': dateStr}) else dateStr,
        if (loc.isNotEmpty) loc.toUpperCase(),
      ].join(' • ');
      stageNumber++;

      final subStrands = (dayMoments.length / itemsPerStrand).ceil().clamp(
        1,
        99,
      );
      for (var r = 0; r < subStrands; r++) {
        dateLabels.add(r == 0 ? headerLabel : '');
      }

      for (var i = 0; i < dayMoments.length; i++) {
        final m = dayMoments[i];
        final resolved = m.resolveBoardPosition(
          i,
          currentStrandIndex,
          isHorizontalRopeMode: isHorizontal,
          forceAlgorithmic: _forceRopeLayoutPositions,
        );
        final liveOffset = _livePositions[m.id];
        final pos = liveOffset ?? Offset(resolved.x, resolved.y);
        basePlacements.add((
          moment: m,
          basePos: pos,
          baseRotation: resolved.rotation,
          index: globalIndex++,
        ));
      }
      currentStrandIndex += subStrands;
    }

    // Board dimensions adapt to vertical corridor vs horizontal stage rows
    final maxCardRight = basePlacements.isEmpty
        ? (isHorizontal ? 1620.0 : 920.0)
        : basePlacements
                  .map((c) => c.basePos.dx + 250.0)
                  .reduce((a, b) => a > b ? a : b) +
              240.0;
    final maxCardBottom = basePlacements.isEmpty
        ? 1480.0
        : basePlacements
                  .map((c) => c.basePos.dy + 340.0)
                  .reduce((a, b) => a > b ? a : b) +
              320.0;
    final boardWidth = math.max(isHorizontal ? 1680.0 : 960.0, maxCardRight);
    final boardHeight = math.max(isHorizontal ? 1280.0 : 1560.0, maxCardBottom);

    final strandStepY = isHorizontal ? 408.0 : 472.0;
    final strandCount = math.max(
      math.max(3, dateLabels.length),
      ((boardHeight - 160.0) / strandStepY).ceil(),
    );
    final strands = _ArtisticRopeStrand.buildDefaultStrands(
      Size(boardWidth, boardHeight),
      strandCount,
      dateLabels,
      isHorizontalMode: isHorizontal,
    );

    // Keep dragged card on top of z-order
    final orderedBase = [...basePlacements];
    if (_draggingMomentId != null) {
      orderedBase.sort((a, b) {
        if (a.moment.id == _draggingMomentId) return 1;
        if (b.moment.id == _draggingMomentId) return -1;
        return 0;
      });
    }

    // Precompute strand index, formatted dates, GestureDetector, and static GPU
    // RepaintBoundary ONCE per build (outside the 60/120Hz AnimatedBuilder loop!)
    // so that during pan, zoom, inertia, and wind frames, Flutter sees the exact
    // same `cachedInteractiveCard` reference (`identical(oldWidget, newWidget)`)
    // right under `Transform` and skips GestureDetector + RepaintBoundary + 45
    // child elements in O(1)!
    final badgeDateFmt = DateFormat('dd/MM • HH:mm');
    final fullCreatedFmt = DateFormat('HH:mm, dd/MM/yyyy');
    final memoizedPlacements = <({
      Moment moment,
      Offset basePos,
      double baseRotation,
      int index,
      int baseStrandIndex,
      Widget cachedInteractiveCard,
    })>[
      for (final item in orderedBase)
        () {
          final m = item.moment;
          final dt = m.takenAt ?? m.createdAt;
          final bStrandIdx = _ArtisticRopeStrand.findBestStrandIndex(
            strands,
            Offset(item.basePos.dx + 96.0, item.basePos.dy + 6.0),
          );
          final isDragging = _draggingMomentId == m.id;
          return (
            moment: m,
            basePos: item.basePos,
            baseRotation: item.baseRotation,
            index: item.index,
            baseStrandIndex: bStrandIdx,
            cachedInteractiveCard: GestureDetector(
              key: ValueKey('board_polaroid_${m.id}'),
              behavior: HitTestBehavior.opaque,
              dragStartBehavior: DragStartBehavior.down,
              onTap: () => _openPolaroidViewer(context, tripId, m, pal),
              onPanStart: (_) {
                HapticFeedback.selectionClick();
                _swayControllers[m.id]?.stop();
                setState(() {
                  _draggingMomentId = m.id;
                  _livePositions[m.id] = _livePositions[m.id] ?? item.basePos;
                });
              },
              onPanUpdate: (d) {
                final delta = d.delta;
                final cur = _livePositions[m.id] ?? item.basePos;
                final nextX = (cur.dx + delta.dx).clamp(
                  20.0,
                  boardWidth - 216.0,
                );
                final nextY = (cur.dy + delta.dy).clamp(
                  36.0,
                  boardHeight - 260.0,
                );
                final tilt = (delta.dx * 0.015).clamp(-0.26, 0.26);
                _livePositions[m.id] = Offset(nextX, nextY);
                _liveSwayAngles[m.id] = tilt;
                _boardViewportTick.value++;
              },
              onPanEnd: (_) {
                final finalPos = _livePositions[m.id] ?? item.basePos;
                final lastTilt = _liveSwayAngles[m.id] ?? 0.14;
                final baseRot = m.boardRotation ?? item.baseRotation;
                _onPolaroidDragEnd(
                  tripId: tripId,
                  moment: m,
                  allMoments: moments,
                  strands: strands,
                  finalPos: finalPos,
                  baseRotation: baseRot,
                  lastVelocityAngle: lastTilt == 0 ? 0.14 : lastTilt,
                );
              },
              child: RepaintBoundary(
                child: _StaticPolaroidCardContent(
                  moment: m,
                  palette: pal,
                  journeyOrder: item.index + 1,
                  isDragging: isDragging,
                  dateAndTimeBadge: badgeDateFmt.format(dt),
                  fullCreatedLabel: fullCreatedFmt.format(dt),
                  onFavoriteToggle: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(momentsProvider(tripId).notifier)
                        .toggleFavorite(m.id);
                  },
                ),
              ),
            ),
          );
        }(),
    ];

    final memoizedDateBadges = <int, Widget>{
      for (var s = 0; s < strands.length; s++)
        if (!strands[s].isCrossStrand && strands[s].label.isNotEmpty)
          s: RepaintBoundary(
            child: _DateBannerBadge(label: strands[s].label, palette: pal),
          ),
    };

    final memoizedSilhouetteBody = RepaintBoundary(
      child: _StaticSilhouetteBody(palette: pal),
    );

    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        final viewportSize = Size(
          viewportConstraints.maxWidth.isFinite
              ? viewportConstraints.maxWidth
              : MediaQuery.sizeOf(context).width,
          viewportConstraints.maxHeight.isFinite
              ? viewportConstraints.maxHeight
              : MediaQuery.sizeOf(context).height,
        );

        return InteractiveViewer(
          key: const Key('memory_board_interactive_viewer'),
          transformationController: _boardTransform,
          constrained: false,
          panEnabled: _draggingMomentId == null,
          minScale: 0.35,
          maxScale: 2.8,
          boundaryMargin: const EdgeInsets.all(340),
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Static Cork Board Grain Texture isolated in its own GPU RepaintBoundary
                // (Painted ONCE, never repainted during wind or pan inertia!)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _StaticCorkBoardPainter(palette: pal),
                    ),
                  ),
                ),

                // 2. Dynamic Ropes & Viewport-Culled Polaroids driven by lightweight ValueNotifier
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      if (_breezeEnabled) _windController,
                      _panInertiaController,
                      _boardViewportTick,
                    ]),
                    builder: (context, _) {
                      final visibleCanvasRect = _computeVisibleCanvasRect(
                        viewportSize,
                      );
                      final quantizedCullRect = _quantizeRect(
                        visibleCanvasRect.inflate(360.0),
                        160.0,
                      );
                      final prefetchViewportRect = _quantizeRect(
                        visibleCanvasRect.inflate(600.0),
                        240.0,
                      );
                      final windPhase = _breezeEnabled
                          ? _windController.value * 2 * math.pi
                          : 0.0;
                      final maxRopeCorridorX = isHorizontal
                          ? boardWidth
                          : 630.0;

                      final liveAnchors = <({
                        Offset clipCenter,
                        int strandIndex,
                        bool isDragging,
                      })>[];
                      final attachedByStrand = <int, List<Offset>>{};
                      final activeCards = <({
                        Moment moment,
                        Offset basePos,
                        Matrix4 swayMatrix,
                        Widget cachedInteractiveCard,
                      })>[];
                      final prefetchCards = <({
                        Moment moment,
                        Offset basePos,
                        Matrix4 swayMatrix,
                      })>[];

                      for (final item in memoizedPlacements) {
                        final isDragging = _draggingMomentId == item.moment.id;
                        final liveOverride = _livePositions[item.moment.id];
                        final liveBasePos = liveOverride ?? item.basePos;

                        // Fast 2D frustum check BEFORE computing trigonometry or
                        // allocating per-frame anchor/card structures!
                        final cardRect = Rect.fromLTWH(
                          liveBasePos.dx,
                          liveBasePos.dy,
                          196.0,
                          268.0,
                        );
                        final inActive =
                            isDragging || quantizedCullRect.overlaps(cardRect);
                        final inPrefetch =
                            !inActive &&
                            prefetchViewportRect.overlaps(cardRect);

                        if (!inActive && !inPrefetch) {
                          continue;
                        }

                        if (inPrefetch) {
                          _prefetchMomentThumbIfNeeded(context, item.moment);
                        }

                        final rawClipX = liveBasePos.dx + 96.0;
                        final rawClipY = liveBasePos.dy + 6.0;
                        final strandIdx = liveOverride != null
                            ? _ArtisticRopeStrand.findBestStrandIndex(
                                strands,
                                Offset(rawClipX, rawClipY),
                              )
                            : item.baseStrandIndex;
                        final strand = strands[strandIdx];

                        final waveArg =
                            windPhase +
                            strand.phaseOffset +
                            rawClipY * 0.0035 +
                            item.index * 0.55;
                        final windBobX = (_breezeEnabled && !isDragging)
                            ? math.cos(waveArg) * 2.8
                            : 0.0;
                        final windBobY = (_breezeEnabled && !isDragging)
                            ? math.sin(waveArg * 1.15) * 3.6
                            : 0.0;
                        final windTilt = (_breezeEnabled && !isDragging)
                            ? math.sin(waveArg) * 0.028
                            : 0.0;
                        final springSway =
                            _liveSwayAngles[item.moment.id] ?? 0.0;

                        final inertiaDx = isDragging
                            ? 0.0
                            : _panInertiaLateralShift * 0.42;
                        final inertiaDy = isDragging
                            ? 0.0
                            : _panInertiaSag * 0.36;
                        final inertiaRot = isDragging ? 0.0 : _panInertiaAngle;

                        final swayDx = windBobX + inertiaDx;
                        final swayDy = windBobY + inertiaDy;
                        final totalRot =
                            item.baseRotation +
                            windTilt +
                            springSway +
                            inertiaRot;

                        final swayMatrix = Matrix4.identity()
                          ..translateByDouble(swayDx + 96.0, swayDy, 0.0, 1.0)
                          ..rotateZ(totalRot)
                          ..translateByDouble(-96.0, 0.0, 0.0, 1.0);

                        if (inActive) {
                          final clipPt = Offset(
                            liveBasePos.dx + swayDx + 96.0,
                            liveBasePos.dy + swayDy + 6.0,
                          );
                          liveAnchors.add((
                            clipCenter: clipPt,
                            strandIndex: strandIdx,
                            isDragging: isDragging,
                          ));
                          if (clipPt.dx <= maxRopeCorridorX) {
                            (attachedByStrand[strandIdx] ??= <Offset>[]).add(
                              clipPt,
                            );
                          }
                          activeCards.add((
                            moment: item.moment,
                            basePos: liveBasePos,
                            swayMatrix: swayMatrix,
                            cachedInteractiveCard: item.cachedInteractiveCard,
                          ));
                        } else {
                          prefetchCards.add((
                            moment: item.moment,
                            basePos: liveBasePos,
                            swayMatrix: swayMatrix,
                          ));
                        }
                      }

                      return RepaintBoundary(
                        child: CustomPaint(
                          painter: _CatenaryRopePainter(
                          palette: pal,
                          strands: strands,
                          cardAnchors: liveAnchors,
                          attachedByStrand: attachedByStrand,
                          windPhase: windPhase,
                          fairyLightsEnabled: _fairyLightsEnabled,
                          panInertiaLateralShift: _panInertiaLateralShift,
                          panInertiaSag: _panInertiaSag,
                          cullRect: quantizedCullRect,
                          zoomScale: _boardZoomScale,
                          isHorizontalMode: isHorizontal,
                          activeDragId: _draggingMomentId,
                          liveOverrideCount: _livePositions.length,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Viewport-culled, pre-memoized Kraft Journey Milestone Tags
                            for (final entry in memoizedDateBadges.entries)
                              if (quantizedCullRect.overlaps(
                                strands[entry.key].approximateBounds(),
                              ))
                                Builder(
                                  builder: (_) {
                                    final s = entry.key;
                                    final st = strands[s];
                                    final tagX = isHorizontal
                                        ? 64.0
                                        : (st.isReverseSlope ? 360.0 : 54.0);
                                    final ropePt = st.evaluatePointAtX(
                                      tagX,
                                      windPhase,
                                      attachedByStrand[s] ?? const <Offset>[],
                                      inertiaLateral: _panInertiaLateralShift,
                                      inertiaSag: _panInertiaSag,
                                    );
                                    final tagTilt =
                                        (_breezeEnabled
                                            ? math.sin(
                                                        windPhase +
                                                            st.phaseOffset,
                                                      ) *
                                                      0.035 -
                                                  0.02
                                            : -0.02) +
                                        _panInertiaAngle * 0.65;
                                    final tagMatrix = Matrix4.identity()
                                      ..translateByDouble(
                                        ropePt.dx - 12 - st.startPin.dx,
                                        ropePt.dy - 34 - st.startPin.dy,
                                        0.0,
                                        1.0,
                                      )
                                      ..rotateZ(tagTilt);
                                    return Positioned(
                                      key: ValueKey('board_date_badge_$s'),
                                      left: st.startPin.dx,
                                      top: st.startPin.dy,
                                      child: Transform(
                                        transform: tagMatrix,
                                        child: entry.value,
                                      ),
                                    );
                                  },
                                ),

                            // Viewport-culled, wind & inertia-swaying Polaroids.
                            // Positioned stays anchored at `item.basePos` and
                            // `item.cachedInteractiveCard` is identical across
                            // frames -> zero layout passes & zero child rebuilds!
                            for (final item in activeCards)
                              Positioned(
                                key: ValueKey(
                                  'board_positioned_${item.moment.id}',
                                ),
                                left: item.basePos.dx,
                                top: item.basePos.dy,
                                child: Transform(
                                  transform: item.swayMatrix,
                                  child: item.cachedInteractiveCard,
                                ),
                              ),

                            for (final item in prefetchCards)
                              Positioned(
                                key: ValueKey(
                                  'board_culled_${item.moment.id}',
                                ),
                                left: item.basePos.dx,
                                top: item.basePos.dy,
                                child: IgnorePointer(
                                  child: Transform(
                                    transform: item.swayMatrix,
                                    child: memoizedSilhouetteBody,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mode 2: Nostalgic Postage-Stamp & Polaroid Grid (`ALL PHOTOS`).
  Widget _buildAllPhotosStampGrid(
    BuildContext context,
    _BoardPalette pal,
    String tripId,
    List<Moment> moments,
  ) {
    final authors = <String>{
      for (final m in moments)
        if (m.authorName.trim().isNotEmpty) m.authorName.trim(),
    }.toList();

    final filtered = _selectedAuthorFilter == null
        ? moments
        : moments
              .where((m) => m.authorName.trim() == _selectedAuthorFilter)
              .toList();

    return Column(
      children: [
        if (authors.length > 1)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      'ALL (${moments.length})',
                      style: AppFonts.heading(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _selectedAuthorFilter == null
                            ? pal.pillActiveText
                            : pal.textPrimary,
                      ),
                    ),
                    selected: _selectedAuthorFilter == null,
                    selectedColor: pal.pillActive,
                    backgroundColor: pal.pillBg,
                    onSelected: (_) =>
                        setState(() => _selectedAuthorFilter = null),
                  ),
                ),
                for (final author in authors)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        author,
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedAuthorFilter == author
                              ? pal.pillActiveText
                              : pal.textPrimary,
                        ),
                      ),
                      selected: _selectedAuthorFilter == author,
                      selectedColor: pal.pillActive,
                      backgroundColor: pal.pillBg,
                      onSelected: (_) => setState(
                        () => _selectedAuthorFilter =
                            _selectedAuthorFilter == author ? null : author,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Expanded(
          child: GridView.builder(
            key: const Key('memory_board_all_photos_grid'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.76,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final m = filtered[index];
              final isStampStyle = index.isOdd;
              return _StampOrPolaroidGridTile(
                moment: m,
                palette: pal,
                isStampStyle: isStampStyle,
                onTap: () => _openPolaroidViewer(context, tripId, m, pal),
                onFavoriteToggle: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(momentsProvider(tripId).notifier)
                      .toggleFavorite(m.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Mode 3: Favorites & Pinned Collection (`FAVORITES`).
  Widget _buildFavoritesGrid(
    BuildContext context,
    _BoardPalette pal,
    String tripId,
    List<Moment> favs,
  ) {
    if (favs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.heartStraight(PhosphorIconsStyle.duotone),
                size: 48,
                color: pal.pillActive,
              ),
              const SizedBox(height: 12),
              Text(
                'moments.wall_no_favorites'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: pal.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'moments.wall_no_favorites_desc'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 13, color: pal.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      key: const Key('memory_board_favorites_grid'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.76,
      ),
      itemCount: favs.length,
      itemBuilder: (context, index) {
        final m = favs[index];
        return _StampOrPolaroidGridTile(
          moment: m,
          palette: pal,
          isStampStyle: false,
          onTap: () => _openPolaroidViewer(context, tripId, m, pal),
          onFavoriteToggle: () {
            HapticFeedback.selectionClick();
            ref.read(momentsProvider(tripId).notifier).toggleFavorite(m.id);
          },
        );
      },
    );
  }

  Widget _buildFloatingActionDock(
    BuildContext context,
    _BoardPalette pal,
    String tripId,
  ) {
    final momentsAsync = ref.watch(momentsProvider(tripId));
    final currentMoments = momentsAsync.valueOrNull ?? const <Moment>[];
    final isVerticalRope =
        _ropeLayout == MemoryBoardRopeLayout.verticalJourney;

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: pal.chromeSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: pal.chromeBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: pal.isDark ? 0.45 : 0.14),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary Squad Cam button
              FilledButton.icon(
                key: const Key('memory_board_squad_cam_btn'),
                style: FilledButton.styleFrom(
                  backgroundColor: pal.pillActive,
                  foregroundColor: pal.pillActiveText,
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () => _openSquadCam(tripId, pal.isDark),
                icon: Icon(
                  PhosphorIcons.camera(PhosphorIconsStyle.fill),
                  size: 16,
                ),
                label: Text(
                  'Squad Cam',
                  style: AppFonts.heading(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: pal.pillActiveText,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Upload photo from library button
              IconButton(
                key: const Key('memory_board_upload_btn'),
                tooltip: 'moments.wall_pin_from_library'.tr(),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: pal.pillBg,
                  foregroundColor: pal.textPrimary,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _uploading
                    ? null
                    : () => _pickAndUploadPhoto(tripId, pal),
                icon: Icon(
                  PhosphorIcons.imageSquare(PhosphorIconsStyle.fill),
                  size: 18,
                ),
              ),
              if (_viewMode == MemoryBoardViewMode.board) ...[
                const SizedBox(width: 4),
                // Switchable Rope Layout Style Toggle ("Dây dọc" <-> "Dây ngang")
                Tooltip(
                  message: isVerticalRope
                      ? 'moments.wall_rope_vertical_tip'.tr()
                      : 'moments.wall_rope_horizontal_tip'.tr(),
                  child: InkWell(
                    key: const Key('memory_board_rope_layout_toggle_btn'),
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _toggleRopeLayoutStyle(currentMoments),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: pal.pillActive.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: pal.pillActive.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerticalRope
                                ? PhosphorIcons.arrowsDownUp(
                                    PhosphorIconsStyle.bold,
                                  )
                                : PhosphorIcons.arrowsLeftRight(
                                    PhosphorIconsStyle.bold,
                                  ),
                            size: 14,
                            color: pal.pillActive,
                          ),
                          const SizedBox(width: 4),
                          // Giới hạn rộng: bản dịch dài (EN) không được đẩy
                          // nút zoom ra khỏi màn hình.
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 96),
                            child: Text(
                              isVerticalRope
                                  ? 'moments.wall_rope_vertical'.tr()
                                  : 'moments.wall_rope_horizontal'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.heading(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: pal.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Artistic Scatter / Collage Auto-Arrange button
                IconButton(
                  key: const Key('memory_board_artistic_scatter_btn'),
                  tooltip: 'moments.wall_scatter_tooltip'.tr(),
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: pal.pillBg,
                    foregroundColor: pal.pinGold,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: currentMoments.isEmpty
                      ? null
                      : () => _artisticScatterBoard(tripId, currentMoments),
                  icon: Icon(
                    PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 4),
                // Wind breeze & fairy lights toggle
                IconButton(
                  key: const Key('memory_board_wind_toggle_btn'),
                  tooltip: _breezeEnabled
                      ? 'moments.wall_breeze_on'.tr()
                      : 'moments.wall_breeze_enable'.tr(),
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: _breezeEnabled
                        ? pal.pillActive.withValues(alpha: 0.22)
                        : pal.pillBg,
                    foregroundColor: _breezeEnabled
                        ? pal.pillActive
                        : pal.textSecondary,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _toggleWindBreeze,
                  icon: Icon(
                    PhosphorIcons.wind(
                      _breezeEnabled
                          ? PhosphorIconsStyle.fill
                          : PhosphorIconsStyle.regular,
                    ),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 4),
                // Canva-style Zoom % / Fit-All toggle button
                InkWell(
                  key: const Key('memory_board_reset_zoom_btn'),
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final currentScale = _boardTransform.value.storage[0];
                    if ((currentScale - 1.0).abs() < 0.08) {
                      // Zoom out to wide Canva overview
                      _boardTransform.value = Matrix4.identity()
                        ..scaleByDouble(0.58, 0.58, 0.58, 1.0);
                    } else {
                      // Reset to 100%
                      _boardTransform.value = Matrix4.identity();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: pal.pillBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: pal.chromeBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.cornersOut(),
                          size: 14,
                          color: pal.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        ValueListenableBuilder<int>(
                          valueListenable: _boardZoomPct,
                          builder: (_, zoomPct, _) => Text(
                            '$zoomPct%',
                            style: AppFonts.heading(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: pal.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final _BoardPalette palette;
  final VoidCallback onTap;

  const _HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: palette.pillBg,
            shape: BoxShape.circle,
            border: Border.all(color: palette.chromeBorder),
          ),
          child: Icon(icon, size: 18, color: palette.textPrimary),
        ),
      ),
    );
  }
}

/// Vintage Kraft luggage tag hanging directly from a hemp rope strand.
class _DateBannerBadge extends StatelessWidget {
  final String label;
  final _BoardPalette palette;

  const _DateBannerBadge({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    final kraftBg = palette.isDark
        ? const Color(0xFF332219)
        : const Color(0xFFF3E5CE);
    final kraftBorder = palette.isDark
        ? const Color(0xFF6B4C35)
        : const Color(0xFFC8A97E);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 13, 5),
      decoration: BoxDecoration(
        color: kraftBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        border: Border.all(color: kraftBorder, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: palette.isDark ? 0.35 : 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brass eyelet ring
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: palette.canvasBgBottom,
              shape: BoxShape.circle,
              border: Border.all(color: palette.pinGold, width: 2.0),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppFonts.heading(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Static painter for the cork/wood board grain dots — wrapped in its own
/// [RepaintBoundary] so the background texture is raster-cached ONCE on the GPU
/// and never redrawn during pan inertia or rope oscillation.
class _StaticCorkBoardPainter extends CustomPainter {
  final _BoardPalette palette;

  const _StaticCorkBoardPainter({required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = palette.corkDot;
    const step = 56.0;
    for (var y = 32.0; y < size.height; y += step) {
      for (var x = 32.0; x < size.width; x += step) {
        final offsetX = ((y.toInt() * 17) % 11) - 5.0;
        final offsetY = ((x.toInt() * 23) % 11) - 5.0;
        canvas.drawCircle(Offset(x + offsetX, y + offsetY), 1.4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StaticCorkBoardPainter oldDelegate) {
    return oldDelegate.palette.isDark != palette.isDark;
  }
}

/// Represents a segment of the Vertical Winding Journey Hemp Rope Trail
/// ("Hành trình kéo từ trên xuống") draped down the 2D board.
class _ArtisticRopeStrand {
  final int index;
  final Offset startPin;
  final Offset? midPin;
  final Offset endPin;
  final double sag;
  final double phaseOffset;
  final String label;
  final bool isReverseSlope;
  final bool isCrossStrand;

  const _ArtisticRopeStrand({
    required this.index,
    required this.startPin,
    this.midPin,
    required this.endPin,
    required this.sag,
    required this.phaseOffset,
    this.label = '',
    this.isReverseSlope = false,
    this.isCrossStrand = false,
  });

  /// Generates either:
  /// - Vertical Winding / Zig-Zagging Hemp Rope Trail (`isHorizontalMode == false`)
  ///   flowing from TOP to BOTTOM down the journey corridor (`x: 34 .. 588`), OR
  /// - Classic Horizontal Stage Catenary Ropes (`isHorizontalMode == true`)
  ///   spanning across the board (`x: 36 .. w - 36`) per stage/day row.
  static List<_ArtisticRopeStrand> buildDefaultStrands(
    Size canvasSize,
    int primaryCount,
    List<String> dateLabels, {
    bool isHorizontalMode = false,
  }) {
    final strands = <_ArtisticRopeStrand>[];
    final w = canvasSize.width;
    final h = canvasSize.height;

    if (isHorizontalMode) {
      const leftPinX = 36.0;
      final midPinX = (w * 0.52).clamp(480.0, w - 180.0);
      final rightPinX = (w - 36.0).clamp(640.0, w - 24.0);
      const rowStepY = 408.0;

      for (var i = 0; i < primaryCount; i++) {
        final baseY = 122.0 + i * rowStepY;
        final slopeSign = i.isEven ? 1.0 : -1.0;
        final leftY = (baseY - 12.0 * slopeSign).clamp(42.0, h - 72.0);
        final midY = (baseY + 8.0 * slopeSign).clamp(48.0, h - 72.0);
        final rightY = (baseY + 14.0 * slopeSign).clamp(42.0, h - 72.0);

        strands.add(
          _ArtisticRopeStrand(
            index: i,
            startPin: Offset(leftPinX, leftY),
            midPin: Offset(midPinX, midY),
            endPin: Offset(rightPinX, rightY),
            sag: 34.0 + (i % 2) * 8.0,
            phaseOffset: i * 1.15,
            label: i < dateLabels.length ? dateLabels[i] : '',
            isReverseSlope: false,
          ),
        );
      }

      strands.add(
        _ArtisticRopeStrand(
          index: primaryCount,
          startPin: const Offset(leftPinX, 46.0),
          endPin: Offset(rightPinX, 54.0),
          sag: 22.0,
          phaseOffset: 2.1,
          isCrossStrand: true,
        ),
      );
      return strands;
    }

    const leftRailX = 34.0;
    const midRailX = 310.0;
    const rightRailX = 588.0;
    const stageStepY = 472.0;

    for (var i = 0; i < primaryCount; i++) {
      final isOddTurn = i.isOdd;
      // Even i: slopes downward from top-left (34, topY) -> bottom-right (588, botY)
      // Odd i: slopes downward from top-right (588, topY) -> bottom-left (34, botY)
      // (Note: startPin is always on leftRailX and endPin on rightRailX so X is monotonic)
      final segTopY = 92.0 + i * stageStepY;
      final segMidY = segTopY + stageStepY * 0.48;
      final segBotY = segTopY + stageStepY * 0.94;

      final leftY = isOddTurn ? segBotY : segTopY;
      final rightY = isOddTurn ? segTopY : segBotY;

      strands.add(
        _ArtisticRopeStrand(
          index: i,
          startPin: Offset(leftRailX, leftY.clamp(42.0, h - 72.0)),
          midPin: Offset(
            midRailX + (isOddTurn ? -18.0 : 18.0),
            segMidY.clamp(48.0, h - 72.0),
          ),
          endPin: Offset(rightRailX, rightY.clamp(42.0, h - 72.0)),
          sag: 38.0 + (i % 2) * 8.0,
          phaseOffset: i * 1.25,
          label: i < dateLabels.length ? dateLabels[i] : '',
          isReverseSlope: isOddTurn,
        ),
      );
    }

    // Decorative top header rope framing the start of the vertical journey
    strands.add(
      _ArtisticRopeStrand(
        index: primaryCount,
        startPin: const Offset(leftRailX, 46.0),
        endPin: const Offset(rightRailX, 54.0),
        sag: 22.0,
        phaseOffset: 2.1,
        isCrossStrand: true,
      ),
    );

    return strands;
  }

  /// Finds the nearest vertical journey rope segment passing above (or closest to)
  /// a Polaroid's top clothespin at [clipCenter].
  static int findBestStrandIndex(
    List<_ArtisticRopeStrand> strands,
    Offset clipCenter,
  ) {
    var bestIdx = 0;
    var bestScore = double.infinity;

    for (var i = 0; i < strands.length; i++) {
      final s = strands[i];
      if (s.isCrossStrand) continue;
      final ropePt = s.evaluatePointAtX(clipCenter.dx, 0.0, const []);
      final dy = clipCenter.dy - ropePt.dy;
      final score = dy >= -42.0 ? dy.abs() : dy.abs() * 2.2 + 90.0;
      if (score < bestScore) {
        bestScore = score;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  /// Evaluates the live `(x, y)` coordinate on this rope strand at horizontal
  /// coordinate [targetX], incorporating wind wave, pan inertia, and card weight.
  Offset evaluatePointAtX(
    double targetX,
    double windPhase,
    List<Offset> attachedClips, {
    double inertiaLateral = 0.0,
    double inertiaSag = 0.0,
  }) {
    final clampedX = targetX.clamp(startPin.dx, endPin.dx);
    if (midPin != null) {
      final mid = midPin!;
      if (clampedX <= mid.dx) {
        return _evalSpanAtX(
          startPin,
          mid,
          clampedX,
          sag * 0.85,
          windPhase,
          attachedClips,
          inertiaLateral: inertiaLateral,
          inertiaSag: inertiaSag,
        );
      } else {
        return _evalSpanAtX(
          mid,
          endPin,
          clampedX,
          sag,
          windPhase + 0.75,
          attachedClips,
          inertiaLateral: inertiaLateral,
          inertiaSag: inertiaSag,
        );
      }
    }
    return _evalSpanAtX(
      startPin,
      endPin,
      clampedX,
      sag,
      windPhase,
      attachedClips,
      inertiaLateral: inertiaLateral,
      inertiaSag: inertiaSag,
    );
  }

  Offset _evalSpanAtX(
    Offset a,
    Offset b,
    double x,
    double spanSag,
    double windPhase,
    List<Offset> attachedClips, {
    double inertiaLateral = 0.0,
    double inertiaSag = 0.0,
  }) {
    final spanW = (b.dx - a.dx).abs() < 1.0 ? 1.0 : (b.dx - a.dx);
    final t = ((x - a.dx) / spanW).clamp(0.0, 1.0);

    final windDy = windPhase == 0.0
        ? 0.0
        : math.sin(windPhase + phaseOffset + (a.dy + b.dy) * 0.002) * 6.5;
    final windDx = windPhase == 0.0
        ? 0.0
        : math.cos(windPhase + phaseOffset) * 3.5;

    var weightPull = 0.0;
    for (final clip in attachedClips) {
      if (clip.dx >= a.dx - 24 && clip.dx <= b.dx + 24) {
        final distNorm = ((clip.dx - x).abs() / (spanW * 0.48)).clamp(0.0, 1.0);
        final pullFactor = (1.0 - distNorm * distNorm) * 11.0;
        weightPull += pullFactor;
      }
    }
    weightPull = weightPull.clamp(0.0, 28.0);

    final ctrl = Offset(
      (a.dx + b.dx) * 0.5 + windDx + inertiaLateral * 1.1,
      (a.dy + b.dy) * 0.5 + spanSag + windDy + weightPull + inertiaSag * 0.85,
    );

    final oneMinusT = 1.0 - t;
    final px =
        oneMinusT * oneMinusT * a.dx + 2 * oneMinusT * t * ctrl.dx + t * t * b.dx;
    final py =
        oneMinusT * oneMinusT * a.dy + 2 * oneMinusT * t * ctrl.dy + t * t * b.dy;
    return Offset(px, py);
  }

  /// Builds the `Path` of this rope segment with 18 fast samples (zero `computeMetrics`).
  Path buildPath(
    double windPhase,
    List<Offset> attachedClips, {
    double inertiaLateral = 0.0,
    double inertiaSag = 0.0,
  }) {
    final path = Path();
    const samples = 18;
    final totalW = endPin.dx - startPin.dx;
    for (var s = 0; s <= samples; s++) {
      final x = startPin.dx + (totalW * s / samples);
      final pt = evaluatePointAtX(
        x,
        windPhase,
        attachedClips,
        inertiaLateral: inertiaLateral,
        inertiaSag: inertiaSag,
      );
      if (s == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    return path;
  }

  /// Bounding box of this vertical rope segment for fast 2D frustum culling.
  Rect approximateBounds() {
    final minY = math.min(
      startPin.dy,
      math.min(endPin.dy, midPin?.dy ?? startPin.dy),
    ) - 48.0;
    final maxY = math.max(
      startPin.dy,
      math.max(endPin.dy, midPin?.dy ?? endPin.dy),
    ) + sag + 96.0;
    return Rect.fromLTRB(
      math.min(startPin.dx, endPin.dx) - 32.0,
      minY,
      math.max(startPin.dx, endPin.dx) + 32.0,
      maxY,
    );
  }
}

/// Ultra-fast 60/120fps GPU CustomPainter for the Vertical Winding Hemp Rope
/// Journey Trail and Horizontal Stage Ropes. Avoids all `MaskFilter.blur` and
/// `path.computeMetrics()` calls so iOS Impeller/Skia renders every frame in
/// <0.5ms without raster thread jank.
class _CatenaryRopePainter extends CustomPainter {
  final _BoardPalette palette;
  final List<_ArtisticRopeStrand> strands;
  final List<({Offset clipCenter, int strandIndex, bool isDragging})>
  cardAnchors;
  final Map<int, List<Offset>> attachedByStrand;
  final double windPhase;
  final bool fairyLightsEnabled;
  final double panInertiaLateralShift;
  final double panInertiaSag;
  final Rect? cullRect;
  final double zoomScale;
  final bool isHorizontalMode;
  final String? activeDragId;
  final int liveOverrideCount;

  const _CatenaryRopePainter({
    required this.palette,
    required this.strands,
    required this.cardAnchors,
    this.attachedByStrand = const <int, List<Offset>>{},
    this.windPhase = 0.0,
    this.fairyLightsEnabled = true,
    this.panInertiaLateralShift = 0.0,
    this.panInertiaSag = 0.0,
    this.cullRect,
    this.zoomScale = 1.0,
    this.isHorizontalMode = false,
    this.activeDragId,
    this.liveOverrideCount = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activeCullRect = cullRect ?? (Offset.zero & size).inflate(260.0);
    final maxRopeCorridorX = isHorizontalMode ? size.width : 630.0;

    // Fast GPU stroke paints (zero MaskFilter.blur!)
    final ropeShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: palette.isDark ? 0.34 : 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.2
      ..strokeCap = StrokeCap.round;

    final ropeCorePaint = Paint()
      ..color = palette.isDark
          ? const Color(0xFF9E7348)
          : const Color(0xFF8C5D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    final ropeHighlightPaint = Paint()
      ..color = palette.isDark
          ? const Color(0xFFE5C79B).withValues(alpha: 0.65)
          : const Color(0xFFF3DEC0).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(
        0xFFFFC970,
      ).withValues(alpha: palette.isDark ? 0.22 : 0.16);
    final bulbCorePaint = Paint()..color = const Color(0xFFFFEAB5);

    // 1. Draw rope segments (& vertical turn connectors when in vertical mode)
    for (var i = 0; i < strands.length; i++) {
      final strand = strands[i];
      if (!activeCullRect.overlaps(strand.approximateBounds())) {
        continue;
      }
      final attached = attachedByStrand[i] ?? const <Offset>[];

      final path = strand.buildPath(
        windPhase,
        attached,
        inertiaLateral: panInertiaLateralShift,
        inertiaSag: panInertiaSag,
      );

      // Connect vertical turn loop to next segment in Vertical Journey mode
      // so the rope forms a single unbroken top-to-bottom trail!
      if (!isHorizontalMode &&
          !strand.isCrossStrand &&
          i + 1 < strands.length &&
          !strands[i + 1].isCrossStrand) {
        final nextStrand = strands[i + 1];
        final turnFrom = strand.isReverseSlope ? strand.startPin : strand.endPin;
        final turnTo = nextStrand.isReverseSlope
            ? nextStrand.endPin
            : nextStrand.startPin;
        final turnCtrl = Offset(
          (turnFrom.dx + turnTo.dx) * 0.5 +
              (strand.isReverseSlope ? -16.0 : 16.0) +
              panInertiaLateralShift * 0.4,
          (turnFrom.dy + turnTo.dy) * 0.5 + panInertiaSag * 0.4,
        );
        path.moveTo(turnFrom.dx, turnFrom.dy);
        path.quadraticBezierTo(turnCtrl.dx, turnCtrl.dy, turnTo.dx, turnTo.dy);
      }

      canvas.drawPath(path.shift(const Offset(1.5, 5.0)), ropeShadowPaint);
      canvas.drawPath(path, ropeCorePaint);
      canvas.drawPath(path.shift(const Offset(0, -1.0)), ropeHighlightPaint);

      // O(1) warm fairy-light bulbs along the rope segment (no computeMetrics!)
      if (fairyLightsEnabled && !strand.isCrossStrand && zoomScale >= 0.45) {
        final bulbFractions = isHorizontalMode
            ? const <double>[0.15, 0.35, 0.55, 0.75, 0.90]
            : const <double>[0.22, 0.50, 0.78];
        final totalW = strand.endPin.dx - strand.startPin.dx;
        for (var b = 0; b < bulbFractions.length; b++) {
          final bx = strand.startPin.dx + totalW * bulbFractions[b];
          final ropePt = strand.evaluatePointAtX(
            bx,
            windPhase,
            attached,
            inertiaLateral: panInertiaLateralShift,
            inertiaSag: panInertiaSag,
          );
          if (!activeCullRect.contains(ropePt)) continue;
          final bulbPos = ropePt + const Offset(0, 5.0);
          canvas.drawCircle(bulbPos, 6.8, glowPaint);
          canvas.drawCircle(bulbPos, 2.5, bulbCorePaint);
        }
      }

      // Brass Wall Pins at the segment turn anchors
      _drawBrassPinAndKnot(canvas, strand.startPin);
      if (strand.midPin != null) {
        _drawBrassPinAndKnot(canvas, strand.midPin!);
      }
      _drawBrassPinAndKnot(canvas, strand.endPin);
    }

    // 2. Dynamic twine tethers for each visible Polaroid clip
    final tetherShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: palette.isDark ? 0.28 : 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final tetherPaint = Paint()
      ..color = palette.isDark
          ? const Color(0xFFC29666)
          : const Color(0xFF8C5D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (final anchor in cardAnchors) {
      if (anchor.strandIndex < 0 || anchor.strandIndex >= strands.length) {
        continue;
      }
      if (!activeCullRect.contains(anchor.clipCenter)) continue;

      final Offset ropeAnchor;
      if (anchor.clipCenter.dx > maxRopeCorridorX) {
        // Cards dragged far outside the vertical rope corridor get their own
        // brass wall pin directly above their clothespin
        ropeAnchor = Offset(anchor.clipCenter.dx, anchor.clipCenter.dy - 22.0);
        _drawBrassPinAndKnot(canvas, ropeAnchor);
      } else {
        final strand = strands[anchor.strandIndex];
        final attached =
            attachedByStrand[anchor.strandIndex] ?? const <Offset>[];
        ropeAnchor = strand.evaluatePointAtX(
          anchor.clipCenter.dx,
          windPhase,
          attached,
          inertiaLateral: panInertiaLateralShift,
          inertiaSag: panInertiaSag,
        );
      }

      final bowX = panInertiaLateralShift * 0.3;
      final midCtrl = Offset(
        (ropeAnchor.dx + anchor.clipCenter.dx) * 0.5 + bowX,
        (ropeAnchor.dy + anchor.clipCenter.dy) * 0.5 + 6.0,
      );

      final tetherPath = Path()
        ..moveTo(ropeAnchor.dx, ropeAnchor.dy)
        ..quadraticBezierTo(
          midCtrl.dx,
          midCtrl.dy,
          anchor.clipCenter.dx,
          anchor.clipCenter.dy,
        );

      canvas.drawPath(
        tetherPath.shift(const Offset(1.2, 2.4)),
        tetherShadowPaint,
      );
      canvas.drawPath(tetherPath, tetherPaint);
    }
  }

  void _drawBrassPinAndKnot(Canvas canvas, Offset center) {
    final loopPaint = Paint()
      ..color = palette.isDark
          ? const Color(0xFF8C6239)
          : const Color(0xFF7A4E25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;
    canvas.drawCircle(center, 6.2, loopPaint);

    // Fast translucent pin shadow (no MaskFilter.blur!)
    canvas.drawCircle(
      center + const Offset(1.2, 2.2),
      5.8,
      Paint()..color = Colors.black.withValues(alpha: 0.32),
    );

    canvas.drawCircle(center, 5.4, Paint()..color = const Color(0xFF9C732B));
    canvas.drawCircle(center, 4.0, Paint()..color = palette.pinGold);
    canvas.drawCircle(
      center + const Offset(-1.3, -1.3),
      1.4,
      Paint()..color = const Color(0xFFFFF3D1),
    );
  }

  @override
  bool shouldRepaint(covariant _CatenaryRopePainter oldDelegate) {
    return oldDelegate.palette.isDark != palette.isDark ||
        oldDelegate.isHorizontalMode != isHorizontalMode ||
        oldDelegate.windPhase != windPhase ||
        oldDelegate.panInertiaLateralShift != panInertiaLateralShift ||
        oldDelegate.panInertiaSag != panInertiaSag ||
        oldDelegate.cullRect != cullRect ||
        oldDelegate.fairyLightsEnabled != fairyLightsEnabled ||
        oldDelegate.strands.length != strands.length ||
        oldDelegate.cardAnchors.length != cardAnchors.length ||
        oldDelegate.activeDragId != activeDragId ||
        oldDelegate.liveOverrideCount != liveOverrideCount ||
        activeDragId != null;
  }
}

/// Static, GPU-cached Polaroid card body (wrapped in a [RepaintBoundary] and
/// memoized outside the 120Hz `AnimatedBuilder` loop).
/// During pan, zoom, inertia, or wind sway, `identical(oldWidget, newWidget)`
/// is `true`, so Flutter skips rebuilding and re-rasterizing this widget in O(1)!
class _StaticPolaroidCardContent extends StatelessWidget {
  /// Diagnostic counter used by performance tests to verify zero redundant
  /// Polaroid card rebuilds during 120Hz pan/inertia/sway frames.
  @visibleForTesting
  static int debugBuildCount = 0;

  final Moment moment;
  final _BoardPalette palette;
  final int journeyOrder;
  final bool isDragging;
  final String dateAndTimeBadge;
  final String fullCreatedLabel;
  final VoidCallback onFavoriteToggle;

  const _StaticPolaroidCardContent({
    required this.moment,
    required this.palette,
    required this.journeyOrder,
    required this.isDragging,
    required this.dateAndTimeBadge,
    required this.fullCreatedLabel,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    debugBuildCount++;
    final filterMatrix = MemoryBoardFilters.colorFilterOf(moment.boardFilter);

    return SizedBox(
      width: 192,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Polaroid paper body
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            decoration: BoxDecoration(
              color: palette.polaroidFrame,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDragging ? 0.38 : 0.24,
                  ),
                  blurRadius: isDragging ? 16 : 9,
                  offset: Offset(0, isDragging ? 10 : 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Square Polaroid photo window
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.5),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _FilteredMomentImage(
                          mediaUrl: moment.mediaUrl,
                          filterMatrix: filterMatrix,
                          memCacheWidth: 480,
                        ),
                        // Journey step badge at top-left (#1, #2, ...)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.58),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '#$journeyOrder',
                              style: AppFonts.heading(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFFD584),
                              ),
                            ),
                          ),
                        ),
                        // Creation date & time stamp pill at bottom-left
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.58),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.clock(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  size: 9.5,
                                  color: const Color(0xFFFFB74D),
                                ),
                                const SizedBox(width: 3.5),
                                Text(
                                  dateAndTimeBadge,
                                  style: AppFonts.heading(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: const Color(0xFFFFB74D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Favorite heart button
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: onFavoriteToggle,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: 0.38,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                moment.isFavorite
                                    ? PhosphorIcons.heart(
                                        PhosphorIconsStyle.fill,
                                      )
                                    : PhosphorIcons.heart(),
                                size: 14,
                                color: moment.isFavorite
                                    ? const Color(0xFFFF5252)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (moment.type == 'VIDEO')
                          Center(
                            child: Icon(
                              PhosphorIcons.playCircle(
                                PhosphorIconsStyle.fill,
                              ),
                              size: 36,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Caption line
                Text(
                  moment.caption?.trim().isNotEmpty == true
                      ? moment.caption!.trim()
                      : (moment.placeName?.trim().isNotEmpty == true
                            ? moment.placeName!.trim()
                            : 'moments.wall_memorable'.tr()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: palette.polaroidInk,
                  ),
                ),
                const SizedBox(height: 2),
                // Explicit creation time subline on Polaroid paper
                Text(
                  'moments.wall_created_at'.tr(namedArgs: {'time': fullCreatedLabel}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.polaroidSubInk.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 5),
                // Contributor & reactions footer
                Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: palette.polaroidSubInk.withValues(
                        alpha: 0.18,
                      ),
                      backgroundImage:
                          moment.authorAvatar != null &&
                              moment.authorAvatar!.isNotEmpty
                          ? CachedNetworkImageProvider(
                              MediaUploader.cdnUrlForTier(
                                moment.authorAvatar!,
                                CdnTier.avatar,
                              ),
                              cacheKey: MediaUploader.cdnCacheKey(
                                moment.authorAvatar!,
                                tier: CdnTier.avatar,
                              ),
                              maxWidth: CdnTier.avatar.width,
                              maxHeight: CdnTier.avatar.width,
                            )
                          : null,
                      child:
                          moment.authorAvatar == null ||
                              moment.authorAvatar!.isEmpty
                          ? Text(
                              moment.authorName.isNotEmpty
                                  ? moment.authorName.characters.first
                                  : '?',
                              style: AppFonts.heading(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: palette.polaroidInk,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        moment.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: palette.polaroidSubInk,
                        ),
                      ),
                    ),
                    if (moment.reactionCount > 0) ...[
                      Icon(
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        size: 11,
                        color: const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${moment.reactionCount}',
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: palette.polaroidSubInk,
                        ),
                      ),
                    ],
                    if (moment.commentCount > 0) ...[
                      const SizedBox(width: 6),
                      Icon(
                        PhosphorIcons.chatCircle(PhosphorIconsStyle.fill),
                        size: 11,
                        color: palette.polaroidSubInk,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${moment.commentCount}',
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: palette.polaroidSubInk,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Wooden clothespin / brass push-pin at top center
          Positioned(
            top: 0,
            child: Container(
              width: 14,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: moment.isPinned
                      ? const [Color(0xFFFFD54F), Color(0xFFC88A32)]
                      : const [Color(0xFFD7A16E), Color(0xFFA8703E)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 2,
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight paper silhouette rendered for Polaroids in the outer prefetch
/// ring (outside the active viewport), avoiding GPU texture decoding, shadows,
/// and gesture detectors until the user pans/scrolls into that region.
class _StaticSilhouetteBody extends StatelessWidget {
  final _BoardPalette palette;

  const _StaticSilhouetteBody({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 192,
      height: 238,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 38),
      decoration: BoxDecoration(
        color: palette.polaroidFrame.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ColoredBox(
        color: palette.isDark
            ? const Color(0xFF2B211E)
            : const Color(0xFFE9E0D2),
      ),
    );
  }
}

/// Grid tile used in `ALL PHOTOS` and `FAVORITES` modes, supporting both
/// perforated Postage-Stamp framing and Classic Polaroid framing.
class _StampOrPolaroidGridTile extends StatelessWidget {
  final Moment moment;
  final _BoardPalette palette;
  final bool isStampStyle;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _StampOrPolaroidGridTile({
    required this.moment,
    required this.palette,
    required this.isStampStyle,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final filterMatrix = MemoryBoardFilters.colorFilterOf(moment.boardFilter);
    final dateStr = DateFormat('dd/MM • HH:mm').format(
      moment.takenAt ?? moment.createdAt,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          10,
          10,
          10,
          isStampStyle ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: palette.polaroidFrame,
          borderRadius: BorderRadius.circular(isStampStyle ? 2 : 6),
          border: isStampStyle
              ? Border.all(
                  color: palette.ropeColor.withValues(alpha: 0.45),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.5),
                    child: _FilteredMomentImage(
                      mediaUrl: moment.mediaUrl,
                      filterMatrix: filterMatrix,
                      memCacheWidth: 480,
                    ),
                  ),
                  if (isStampStyle)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.52),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'POSTAGE • $dateStr',
                          style: AppFonts.heading(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color(0xFFF5D08A),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.36),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          moment.isFavorite
                              ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                              : PhosphorIcons.heart(),
                          size: 14,
                          color: moment.isFavorite
                              ? const Color(0xFFFF5252)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              moment.caption?.trim().isNotEmpty == true
                  ? moment.caption!.trim()
                  : moment.authorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.heading(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: palette.polaroidInk,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${moment.authorName} • $dateStr',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      fontSize: 12,
                      color: palette.polaroidSubInk,
                    ),
                  ),
                ),
                if (moment.reactionCount > 0) ...[
                  Icon(
                    PhosphorIcons.heart(PhosphorIconsStyle.fill),
                    size: 11,
                    color: const Color(0xFFE53935),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${moment.reactionCount}',
                    style: AppFonts.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: palette.polaroidSubInk,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilteredMomentImage extends StatelessWidget {
  final String mediaUrl;
  final ColorFilter? filterMatrix;
  final int memCacheWidth;

  const _FilteredMomentImage({
    required this.mediaUrl,
    required this.filterMatrix,
    required this.memCacheWidth,
  });

  CdnTier _resolveTier() {
    if (memCacheWidth <= 240) return CdnTier.avatar;
    if (memCacheWidth <= 540) return CdnTier.boardThumb;
    if (memCacheWidth <= 1000) return CdnTier.background;
    return CdnTier.full;
  }

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (mediaUrl.startsWith('assets/')) {
      img = Image.asset(
        mediaUrl,
        fit: BoxFit.cover,
        cacheWidth: memCacheWidth,
      );
    } else if (mediaUrl.startsWith('http')) {
      final tier = _resolveTier();
      final cdnUrl = MediaUploader.cdnUrlForTier(mediaUrl, tier);
      final cacheKey = MediaUploader.cdnCacheKey(mediaUrl, tier: tier);
      img = CachedNetworkImage(
        imageUrl: cdnUrl,
        cacheKey: cacheKey,
        fit: BoxFit.cover,
        memCacheWidth: tier.width,
        maxWidthDiskCache: tier.width,
        placeholder: (_, _) => Container(color: const Color(0xFF2B211E)),
        errorWidget: (_, _, _) => Container(
          color: const Color(0xFF2B211E),
          child: Icon(
            PhosphorIcons.image(),
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      );
    } else {
      img = Container(
        color: const Color(0xFFFFF3B0),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        child: Icon(
          PhosphorIcons.note(PhosphorIconsStyle.duotone),
          size: 36,
          color: const Color(0xFF5D4037),
        ),
      );
    }

    if (filterMatrix != null) {
      return ColorFiltered(colorFilter: filterMatrix!, child: img);
    }
    return img;
  }
}

/// Expanded Polaroid Detail Sheet — displays `1x / 2x / 3x` zoom selector,
/// `POLAROID • B&W FILM` filter switcher, prominent creation/taken timestamp
/// card ("Thời gian tạo ảnh"), reactions, comments, caption edit, share, and report/delete.
class _PolaroidDetailSheet extends ConsumerStatefulWidget {
  final String tripId;
  final Moment initialMoment;
  final _BoardPalette palette;
  final MemoryBoardAudioController audio;

  const _PolaroidDetailSheet({
    required this.tripId,
    required this.initialMoment,
    required this.palette,
    required this.audio,
  });

  @override
  ConsumerState<_PolaroidDetailSheet> createState() =>
      _PolaroidDetailSheetState();
}

class _PolaroidDetailSheetState extends ConsumerState<_PolaroidDetailSheet> {
  int _zoomLevel = 1; // 1x, 2x, or 3x
  late String _activeFilter = widget.initialMoment.boardFilter;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _sendingComment = false;

  static const _emojis = ['❤️', '😂', '😮', '🔥', '🥹', '👏'];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Moment _currentMoment() {
    final list = ref.watch(momentsProvider(widget.tripId)).valueOrNull;
    return list
            ?.where((m) => m.id == widget.initialMoment.id)
            .firstOrNull ??
        widget.initialMoment;
  }

  String _formatRelativeCreated(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final isSameDay =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    if (isSameDay) {
      if (diff.inMinutes < 1) return 'moments.wall_rel_just_now_today'.tr();
      if (diff.inHours < 1) return 'moments.wall_rel_min_today'.tr(namedArgs: {'n': diff.inMinutes.toString()});
      return 'moments.wall_rel_hour_today'.tr(namedArgs: {'n': diff.inHours.toString()});
    }
    final days = diff.inDays.abs();
    if (days == 1) return 'moments.wall_rel_yesterday'.tr();
    return 'moments.wall_rel_days'.tr(namedArgs: {'n': days.toString()});
  }

  void _setZoom(int zoom) {
    HapticFeedback.selectionClick();
    setState(() => _zoomLevel = zoom);
  }

  Future<void> _selectFilter(Moment m, String filter) async {
    if (_activeFilter == filter) return;
    widget.audio.playPop();
    setState(() => _activeFilter = filter);
    try {
      await ref.read(momentsProvider(widget.tripId).notifier).updateBoardLayout(
        m.id,
        boardFilter: filter,
      );
    } catch (_) {}
  }

  Future<void> _shareMoment(Moment m) async {
    HapticFeedback.mediumImpact();
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);
    final dt = m.takenAt ?? m.createdAt;
    final formattedTime = DateFormat('HH:mm, dd/MM/yyyy').format(dt);
    final text = [
      if (m.caption?.trim().isNotEmpty == true) '"${m.caption!.trim()}"',
      'moments.wall_share_text'.tr(namedArgs: {'author': m.authorName, 'time': formattedTime}),
      if (m.mediaUrl.startsWith('http')) m.mediaUrl,
    ].join('\n');
    await Share.share(text, sharePositionOrigin: origin);
  }

  Future<void> _editCaption(Moment m) async {
    final ctrl = TextEditingController(text: m.caption ?? '');
    try {
      final updated = await showDialog<String>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: Text('moments.wall_edit_caption_title'.tr()),
          content: TextField(
            controller: ctrl,
            maxLength: 90,
            autofocus: true,
            decoration: InputDecoration(hintText: 'moments.wall_edit_caption_hint'.tr()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
              child: Text('common.save'.tr()),
            ),
          ],
        ),
      );
      if (updated == null || !mounted) return;
      await ref.read(momentsProvider(widget.tripId).notifier).updateBoardLayout(
        m.id,
        caption: updated,
      );
    } finally {
      ctrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = widget.palette;
    final m = _currentMoment();
    final myUserId = ref.watch(profileDataProvider).profile?['id']?.toString();
    final isMine = m.authorId != null && m.authorId == myUserId;
    final createdDt = m.takenAt ?? m.createdAt;
    final exactDateStr = DateFormat('dd/MM/yyyy').format(createdDt);
    final exactTimeStr = DateFormat('HH:mm').format(createdDt);
    final relativeStr = _formatRelativeCreated(createdDt);
    final filterMatrix = MemoryBoardFilters.colorFilterOf(_activeFilter);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: pal.isDark ? const Color(0xFF1A0D0B) : const Color(0xFFF7F0E4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: pal.chromeBorder),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: pal.textSecondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),

            // Top action bar: Creation Timestamp + Favorite + Share + Report/Delete + Close
            Row(
              children: [
                IconButton(
                  tooltip: 'common.close'.tr(),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(PhosphorIcons.x(), color: pal.textPrimary),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'moments.wall_date_line'.tr(namedArgs: {'date': exactDateStr, 'time': exactTimeStr}),
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: pal.textPrimary,
                        ),
                      ),
                      Text(
                        'moments.wall_created_by'.tr(namedArgs: {'author': m.authorName, 'when': relativeStr}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(
                          fontSize: 12,
                          color: pal.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('polaroid_viewer_favorite_btn'),
                  tooltip: 'moments.wall_favorite'.tr(),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(momentsProvider(widget.tripId).notifier)
                        .toggleFavorite(m.id);
                  },
                  icon: Icon(
                    m.isFavorite
                        ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                        : PhosphorIcons.heart(),
                    color: m.isFavorite
                        ? const Color(0xFFFF5252)
                        : pal.textPrimary,
                  ),
                ),
                IconButton(
                  tooltip: 'invites.share'.tr(),
                  onPressed: () => _shareMoment(m),
                  icon: Icon(
                    PhosphorIcons.shareNetwork(),
                    color: pal.textPrimary,
                  ),
                ),
                if (isMine)
                  IconButton(
                    tooltip: 'common.delete'.tr(),
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await ref
                          .read(momentsProvider(widget.tripId).notifier)
                          .deleteMoment(m.id);
                      if (mounted) nav.pop();
                    },
                    icon: Icon(PhosphorIcons.trash(), color: GenZTokens.danger),
                  )
                else
                  IconButton(
                    tooltip: 'report.title'.tr(),
                    onPressed: () => ReportSheet.show(
                      context,
                      target: ReportTarget.moment,
                      targetId: m.id,
                    ),
                    icon: Icon(PhosphorIcons.flag(), color: pal.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Large Polaroid Frame with 1x / 2x / 3x Zoom Selector
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              decoration: BoxDecoration(
                color: pal.polaroidFrame,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedScale(
                            key: Key('polaroid_zoom_scale_${_zoomLevel}x'),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            scale: _zoomLevel.toDouble(),
                            child: _FilteredMomentImage(
                              mediaUrl: m.mediaUrl,
                              filterMatrix: filterMatrix,
                              memCacheWidth: 1080,
                            ),
                          ),
                          // 1x / 2x / 3x Zoom pill selector at bottom-right
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              key: const Key('polaroid_zoom_selector'),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.62),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (final z in const [1, 2, 3])
                                    GestureDetector(
                                      key: Key('polaroid_zoom_${z}x'),
                                      onTap: () => _setZoom(z),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _zoomLevel == z
                                              ? pal.pillActive
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${z}x',
                                          style: AppFonts.heading(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: _zoomLevel == z
                                                ? pal.pillActiveText
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.caption?.trim().isNotEmpty == true
                              ? m.caption!.trim()
                              : 'moments.wall_moment_of'.tr(namedArgs: {'author': m.authorName}),
                          style: AppFonts.heading(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: pal.polaroidInk,
                          ),
                        ),
                      ),
                      if (isMine)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'moments.wall_edit_caption'.tr(),
                          onPressed: () => _editCaption(m),
                          icon: Icon(
                            PhosphorIcons.pencilSimple(),
                            size: 18,
                            color: pal.polaroidSubInk,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'POLAROID • ${MemoryBoardFilters.labelOf(_activeFilter)}',
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: pal.polaroidSubInk,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$exactTimeStr • $exactDateStr',
                        style: AppFonts.heading(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: pal.polaroidSubInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Dedicated Creation Timestamp & Journey Metadata Card
            Container(
              key: const Key('polaroid_creation_info_card'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: pal.pillBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: pal.chromeBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: pal.pillActive.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIcons.clockCountdown(PhosphorIconsStyle.fill),
                      size: 18,
                      color: pal.pillActive,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'moments.wall_time_taken'.tr(namedArgs: {'time': exactTimeStr, 'date': exactDateStr}),
                          style: AppFonts.heading(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: pal.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            'moments.wall_posted_by'.tr(namedArgs: {'author': m.authorName}),
                            if (m.placeName?.trim().isNotEmpty == true)
                              'moments.wall_at_place'.tr(namedArgs: {'place': m.placeName!.trim()}),
                            relativeStr,
                          ].join(' • '),
                          style: AppFonts.body(
                            fontSize: 12,
                            color: pal.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Film Filter Switcher Pill Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in MemoryBoardFilters.all)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: Key('polaroid_filter_$f'),
                        label: Text(
                          'POLAROID • ${MemoryBoardFilters.labelOf(f)}',
                          style: AppFonts.heading(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _activeFilter == f
                                ? pal.pillActiveText
                                : pal.textPrimary,
                          ),
                        ),
                        selected: _activeFilter == f,
                        selectedColor: pal.pillActive,
                        backgroundColor: pal.pillBg,
                        onSelected: (_) => _selectFilter(m, f),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Quick Emoji Reaction Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pal.pillBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: pal.chromeBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final emoji in _emojis)
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref
                            .read(momentsProvider(widget.tripId).notifier)
                            .react(m.id, emoji: emoji);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Comments list & composer
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'moments.wall_notes_count'.tr(namedArgs: {'n': m.commentCount.toString()}),
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: pal.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (m.comments.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: pal.pillBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: pal.chromeBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final c in m.comments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: RichText(
                          text: TextSpan(
                            style: AppFonts.body(
                              fontSize: 13,
                              color: pal.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: '${c.authorName}: ',
                                style: AppFonts.heading(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: pal.accent,
                                ),
                              ),
                              TextSpan(text: c.content),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    style: AppFonts.body(fontSize: 14, color: pal.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'moments.wall_comment_hint'.tr(),
                      hintStyle: AppFonts.body(
                        fontSize: 13,
                        color: pal.textSecondary,
                      ),
                      filled: true,
                      fillColor: pal.pillBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(color: pal.chromeBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(color: pal.chromeBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: pal.pillActive,
                    foregroundColor: pal.pillActiveText,
                  ),
                  onPressed: _sendingComment
                      ? null
                      : () async {
                          final text = _commentCtrl.text.trim();
                          if (text.isEmpty) return;
                          setState(() => _sendingComment = true);
                          try {
                            await ref
                                .read(momentsProvider(widget.tripId).notifier)
                                .addComment(m.id, text);
                            _commentCtrl.clear();
                          } finally {
                            if (mounted) {
                              setState(() => _sendingComment = false);
                            }
                          }
                        },
                  icon: Icon(
                    PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Flutter Home Screen Widget Preview & Sync Sheet for iOS & Android.
/// Supports both Dark and Light themes and renders a live replica of the
/// 3-layer Stacked Polaroid Widget (`2x2 Small` and `4x2 Medium`).
class _HomeWidgetPreviewSheet extends ConsumerStatefulWidget {
  final String tripId;
  final String tripName;
  final List<WidgetMoment> moments;
  final _BoardPalette palette;
  final MemoryBoardAudioController audio;

  const _HomeWidgetPreviewSheet({
    required this.tripId,
    required this.tripName,
    required this.moments,
    required this.palette,
    required this.audio,
  });

  @override
  ConsumerState<_HomeWidgetPreviewSheet> createState() =>
      _HomeWidgetPreviewSheetState();
}

class _HomeWidgetPreviewSheetState
    extends ConsumerState<_HomeWidgetPreviewSheet> {
  bool _isMediumSize = false;
  late bool _previewDark = widget.palette.isDark;
  bool _syncing = false;
  bool _syncedSuccess = false;
  bool _autoPinSupported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkPinSupportAndAutoSync();
    });
  }

  Future<void> _checkPinSupportAndAutoSync() async {
    try {
      final supported = await WidgetPin.isSupported().timeout(
        const Duration(milliseconds: 600),
        onTimeout: () => false,
      );
      if (mounted) {
        setState(() => _autoPinSupported = supported);
      }
      if (widget.moments.isNotEmpty) {
        unawaited(_syncNow(silent: true));
      }
    } catch (_) {}
  }

  Future<void> _syncNow({bool silent = false}) async {
    if (_syncing) return;
    if (mounted) setState(() => _syncing = true);
    try {
      if (widget.moments.isNotEmpty) {
        await ref
            .read(widgetSyncProvider)
            .syncItems(widget.moments)
            .timeout(const Duration(milliseconds: 1200), onTimeout: () => false);
      } else {
        await ref
            .read(widgetSyncProvider)
            .refresh()
            .timeout(
              const Duration(milliseconds: 1200),
              onTimeout: () => const <WidgetMoment>[],
            );
      }
      if (!mounted) return;
      setState(() {
        _syncing = false;
        _syncedSuccess = true;
      });
      if (!silent) {
        widget.audio.playPop();
        HapticFeedback.mediumImpact();
        showGlobalSnack('moments.wall_widget_synced'.tr());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _syncing = false);
    }
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return 'moments.wall_rel_now'.tr();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 2) return 'moments.wall_rel_now'.tr();
    if (diff.inMinutes < 60) return 'moments.wall_rel_min_short'.tr(namedArgs: {'n': diff.inMinutes.toString()});
    if (diff.inHours < 24) return 'moments.wall_rel_hour_short'.tr(namedArgs: {'n': diff.inHours.toString()});
    return 'moments.wall_rel_days'.tr(namedArgs: {'n': diff.inDays.toString()});
  }

  @override
  Widget build(BuildContext context) {
    final pal = widget.palette;
    final bottomInset = math.max(
      MediaQuery.viewInsetsOf(context).bottom,
      MediaQuery.paddingOf(context).bottom,
    );
    final topMoment = widget.moments.firstOrNull;
    final extraCount = math.max(0, widget.moments.length - 3);

    return Container(
      key: const Key('home_widget_preview_sheet'),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: pal.chromeSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: pal.chromeBorder),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: pal.textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: pal.pillActive.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.appWindow(PhosphorIconsStyle.fill),
                    size: 20,
                    color: pal.pillActive,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'moments.wall_widget_title'.tr(),
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: pal.textPrimary,
                        ),
                      ),
                      Text(
                        'moments.wall_widget_desc'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          color: pal.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(PhosphorIcons.x(), color: pal.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Size & Theme preview controls
            Row(
              children: [
                _buildToggleChip(
                  key: const Key('widget_preview_size_small'),
                  label: 'moments.wall_size_small'.tr(),
                  active: !_isMediumSize,
                  pal: pal,
                  onTap: () => setState(() => _isMediumSize = false),
                ),
                const SizedBox(width: 8),
                _buildToggleChip(
                  key: const Key('widget_preview_size_medium'),
                  label: 'moments.wall_size_medium'.tr(),
                  active: _isMediumSize,
                  pal: pal,
                  onTap: () => setState(() => _isMediumSize = true),
                ),
                const Spacer(),
                _buildToggleChip(
                  key: const Key('widget_preview_theme_toggle'),
                  label: _previewDark ? 'moments.wall_theme_dark'.tr() : 'moments.wall_theme_light'.tr(),
                  active: true,
                  pal: pal,
                  onTap: () => setState(() => _previewDark = !_previewDark),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Stacked Polaroid Widget Preview Box
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MomentViewerScreen(),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: _isMediumSize ? 320 : 186,
                  height: 186,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _previewDark
                        ? const Color(0xFF1C1613)
                        : const Color(0xFFFDF6D3),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _previewDark
                          ? const Color(0xFF3E302A)
                          : const Color(0xFFE5D8A8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _isMediumSize
                      ? _buildMediumPreviewContent(topMoment, extraCount)
                      : _buildSmallPreviewContent(topMoment, extraCount),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons: Sync to Widget & Open Widget Viewer
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('home_widget_sync_now_btn'),
                    style: FilledButton.styleFrom(
                      backgroundColor: pal.pillActive,
                      foregroundColor: pal.pillActiveText,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _syncing ? null : () => _syncNow(silent: false),
                    icon: _syncing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: pal.pillActiveText,
                            ),
                          )
                        : Icon(
                            _syncedSuccess
                                ? PhosphorIcons.checkCircle(
                                    PhosphorIconsStyle.fill,
                                  )
                                : PhosphorIcons.arrowsClockwise(
                                    PhosphorIconsStyle.bold,
                                  ),
                            size: 18,
                          ),
                    label: Text(
                      _syncedSuccess
                          ? 'moments.wall_synced_count'.tr(namedArgs: {'n': widget.moments.length.toString()})
                          : 'moments.wall_sync_now'.tr(),
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  key: const Key('home_widget_open_viewer_btn'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: pal.textPrimary,
                    side: BorderSide(color: pal.chromeBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MomentViewerScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                    size: 16,
                    color: pal.accent,
                  ),
                  label: Text(
                    'moments.wall_preview'.tr(),
                    style: AppFonts.heading(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            if (_autoPinSupported) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await WidgetPin.request();
                    if (!context.mounted) return;
                    if (ok) Navigator.of(context).pop();
                  },
                  icon: Icon(PhosphorIcons.pushPin(PhosphorIconsStyle.fill)),
                  label: Text('moments.pin_widget'.tr()),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Step-by-step iOS & Android setup instructions
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: pal.pillBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: pal.chromeBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.deviceMobileCamera(
                          PhosphorIconsStyle.fill,
                        ),
                        size: 16,
                        color: pal.accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'moments.wall_howto_title'.tr(),
                          style: AppFonts.heading(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: pal.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildStepRow(
                    pal,
                    '1',
                    'moments.wall_howto_1'.tr(),
                  ),
                  const SizedBox(height: 6),
                  _buildStepRow(
                    pal,
                    '2',
                    'moments.wall_howto_2'.tr(),
                  ),
                  const SizedBox(height: 6),
                  _buildStepRow(
                    pal,
                    '3',
                    'moments.wall_howto_3'.tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip({
    required Key key,
    required String label,
    required bool active,
    required _BoardPalette pal,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? pal.pillActive : pal.pillBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? pal.pillActive : pal.chromeBorder,
          ),
        ),
        child: Text(
          label,
          style: AppFonts.heading(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? pal.pillActiveText : pal.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPreviewContent(WidgetMoment? top, int extraCount) {
    final frameColor = _previewDark
        ? const Color(0xFF2C2420)
        : const Color(0xFFFFFDF5);
    const tilts = <double>[-0.10, 0.07, 0.0];
    final count = math.max(1, math.min(3, widget.moments.length));
    final activeTilts = tilts.sublist(tilts.length - count);

    return Stack(
      alignment: Alignment.center,
      children: [
        for (var depth = count - 1; depth >= 0; depth--)
          Transform.rotate(
            angle: activeTilts[count - 1 - depth],
            child: Container(
              width: 148 * (1 - depth * 0.045),
              height: 148 * (1 - depth * 0.045),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: frameColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (depth < widget.moments.length &&
                        widget.moments[depth].imageUrl.isNotEmpty)
                      _FilteredMomentImage(
                        mediaUrl: widget.moments[depth].imageUrl,
                        filterMatrix: null,
                        memCacheWidth: 240,
                      )
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          PhosphorIcons.camera(PhosphorIconsStyle.duotone),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    if (depth == 0)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        // Top time pill + extra badge
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _relativeTime(top?.createdAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (extraCount > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.5,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD84D),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.black, width: 1.4),
                  ),
                  child: Text(
                    '+$extraCount',
                    style: AppFonts.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF141210),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Bottom author & caption
        Positioned(
          left: 12,
          right: 12,
          bottom: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                top?.authorName.isNotEmpty == true
                    ? top!.authorName
                    : 'moments.wall_squad_moment'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                top?.caption?.trim().isNotEmpty == true
                    ? top!.caption!
                    : widget.tripName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediumPreviewContent(WidgetMoment? top, int extraCount) {
    final primaryInk = _previewDark
        ? const Color(0xFFFAF5EA)
        : const Color(0xFF141210);
    final secondaryInk = _previewDark
        ? const Color(0xFFC7BAA8)
        : const Color(0xFF5D5146);

    return Row(
      children: [
        SizedBox(
          width: 142,
          height: 142,
          child: _buildSmallPreviewContent(top, extraCount),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD84D),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.tripName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF141210),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                top?.authorName.isNotEmpty == true
                    ? top!.authorName
                    : 'TripMate Squad',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: primaryInk,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                top?.caption?.trim().isNotEmpty == true
                    ? top!.caption!
                    : 'moments.wall_widget_tap_hint'.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(fontSize: 12, color: secondaryInk),
              ),
              const SizedBox(height: 10),
              Text(
                'moments.wall_react_hint'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryInk.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(_BoardPalette pal, String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pal.pillActive,
            shape: BoxShape.circle,
          ),
          child: Text(
            step,
            style: AppFonts.heading(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: pal.pillActiveText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppFonts.body(fontSize: 12, color: pal.textSecondary),
          ),
        ),
      ],
    );
  }
}

