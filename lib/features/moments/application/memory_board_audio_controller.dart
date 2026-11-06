import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

/// Manages tactile sound effects (`polaroid_pop.wav`) and user-controlled
/// ambient background music (`ambient_warm.wav`) for the Shared Memory Photo Board.
///
/// Uses `video_player` (already linked in the native iOS/Android runner) with
/// standard `AVAudioSessionCategoryPlayback` so ambient music plays clearly
/// even if the iPhone's hardware mute switch is engaged, and degrades
/// gracefully in headless widget test environments.
class MemoryBoardAudioController extends ChangeNotifier {
  static const String _prefMutedKey = 'memory_board_music_muted';
  static const String _prefPlayingKey = 'memory_board_music_playing';

  VideoPlayerController? _ambientController;
  VideoPlayerController? _popController;

  bool _isPlaying = false;
  bool _isMuted = false;
  bool _initialized = false;
  bool _disposed = false;
  bool _wasPlayingBeforeBackground = false;

  bool get isPlaying => _isPlaying && !_isMuted;
  bool get isMuted => _isMuted;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized || _disposed) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool(_prefMutedKey) ?? false;
      final savedPlaying = prefs.getBool(_prefPlayingKey) ?? true;

      // Initialize warm ambient music safely without blocking
      try {
        final amb = VideoPlayerController.asset(
          'assets/audio/ambient_warm.wav',
        );
        _ambientController = amb;
        await amb.initialize().timeout(
          const Duration(milliseconds: 1200),
          onTimeout: () {},
        );
        if (amb.value.isInitialized) {
          await amb.setLooping(true);
          await amb.setVolume(_isMuted ? 0.0 : 0.35);
          _initialized = true;

          if (savedPlaying && !_isMuted && !_disposed) {
            await amb.play();
            _isPlaying = true;
          }
        }
      } catch (e) {
        debugPrint('[MemoryBoardAudio] ambient init fallback: $e');
      }

      if (!_disposed) notifyListeners();
    } catch (e) {
      debugPrint('[MemoryBoardAudio] general init error: $e');
      _initialized = false;
    }
  }

  /// Plays a subtle tactile paper/clip pop when tapping or dropping a Polaroid.
  /// Uses instant native [SystemSound] and [HapticFeedback] which never block or deadlock.
  Future<void> playPop() async {
    HapticFeedback.lightImpact();
    if (_isMuted || _disposed) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    HapticFeedback.selectionClick();
    if (_disposed) return;
    try {
      var amb = _ambientController;
      if (amb == null || !amb.value.isInitialized) {
        try {
          amb = VideoPlayerController.asset('assets/audio/ambient_warm.wav');
          _ambientController = amb;
          await amb.initialize().timeout(
            const Duration(milliseconds: 1200),
            onTimeout: () {},
          );
          if (amb.value.isInitialized) {
            await amb.setLooping(true);
            _initialized = true;
          }
        } catch (_) {}
      }

      if (amb != null && amb.value.isInitialized) {
        if (_isPlaying) {
          await amb.pause();
          _isPlaying = false;
        } else {
          if (_isMuted) {
            _isMuted = false;
          }
          await amb.setVolume(0.35);
          await amb.play();
          _isPlaying = true;
        }
      } else {
        // Fallback state toggle when audio asset is unavailable
        _isPlaying = !_isPlaying;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefPlayingKey, _isPlaying);
      await prefs.setBool(_prefMutedKey, _isMuted);
    } catch (e) {
      debugPrint('[MemoryBoardAudio] togglePlayPause error: $e');
      _isPlaying = !_isPlaying;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> toggleMute() async {
    HapticFeedback.selectionClick();
    if (_disposed) return;
    _isMuted = !_isMuted;
    try {
      final amb = _ambientController;
      if (amb != null && amb.value.isInitialized) {
        await amb.setVolume(_isMuted ? 0.0 : 0.35);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefMutedKey, _isMuted);
    } catch (_) {}
    if (!_disposed) notifyListeners();
  }

  Future<void> handleLifecycle(
    bool isBackgrounded,
  ) async {
    if (_disposed) return;
    try {
      final amb = _ambientController;
      if (amb == null || !amb.value.isInitialized) return;
      if (isBackgrounded) {
        _wasPlayingBeforeBackground = _isPlaying;
        if (_isPlaying) {
          await amb.pause();
          _isPlaying = false;
          if (!_disposed) notifyListeners();
        }
      } else if (_wasPlayingBeforeBackground && !_isMuted) {
        _wasPlayingBeforeBackground = false;
        await amb.play();
        _isPlaying = true;
        if (!_disposed) notifyListeners();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    final amb = _ambientController;
    final pop = _popController;
    _ambientController = null;
    _popController = null;
    amb?.dispose();
    pop?.dispose();
    super.dispose();
  }
}
