import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_messenger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../premium/presentation/paywall_sheet.dart';
import '../../../../core/services/media_uploader.dart';
import '../../../../core/services/widget_sync.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../profile/data/xp_repository.dart';
import '../../application/moments_providers.dart';
import '../../data/moments_repository.dart';

/// Camera nhanh cho squad — ý tưởng mượn từ Locket.
///
/// Ba điều làm nên Locket, giữ nguyên ở đây:
///   1. **Mở là khung ngắm chạy sẵn** — không qua dialog chọn ảnh của hệ thống.
///      Khoảng cách từ "nghĩ tới" đến "đã gửi" ngắn nhất có thể.
///   2. **Bấm chụp, giữ để quay** — một cử chỉ, hai kiểu nội dung.
///   3. **Gửi xong quay lại khung ngắm ngay**, không đá về màn khác.
///
/// Khác Locket ở chỗ vòng bạn không phải danh sách bạn bè vĩnh viễn mà là
/// **squad của chuyến** — thứ TripMate vốn đã có thật.
class SquadCamScreen extends ConsumerStatefulWidget {
  final String tripId;
  final bool isDarkMode;

  const SquadCamScreen({
    super.key,
    required this.tripId,
    this.isDarkMode = false,
  });

  @override
  ConsumerState<SquadCamScreen> createState() => _SquadCamScreenState();
}

class _SquadCamScreenState extends ConsumerState<SquadCamScreen>
    with WidgetsBindingObserver {
  CameraController? _cam;
  List<CameraDescription> _cameras = const [];
  int _camIndex = 0;
  bool _initializing = true;
  Object? _initError;

  /// Đang quay video (do giữ nút chụp).
  bool _recording = false;

  /// Ảnh/video vừa chụp, đang chờ xác nhận gửi.
  File? _shot;
  bool _shotIsVideo = false;

  bool _sending = false;
  double _progress = 0;
  final TextEditingController _caption = TextEditingController();

  /// Video ngắn — dài hơn thì vừa tốn data vừa mất tính "khoảnh khắc".
  static const Duration _maxClip = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _caption.dispose();
    _cam?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) return;
    // Nhả camera khi app xuống nền, dựng lại khi quay lên — nếu không, app khác
    // không mở được camera và lúc quay lại khung ngắm sẽ đen.
    if (state == AppLifecycleState.inactive) {
      cam.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _start(_camIndex);
    }
  }

  Future<void> _boot() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw ApiException('moments.cam_none'.tr());
      }
      // Ưu tiên camera sau: chụp cảnh nhiều hơn chụp mặt.
      final back = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      await _start(back >= 0 ? back : 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = e;
        _initializing = false;
      });
    }
  }

  Future<void> _start(int index) async {
    final old = _cam;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: true,
    );
    try {
      await controller.initialize();
      await old?.dispose();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cam = controller;
        _camIndex = index;
        _initializing = false;
        _initError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = e;
        _initializing = false;
      });
    }
  }

  Future<void> _flip() async {
    if (_cameras.length < 2 || _recording) return;
    HapticFeedback.selectionClick();
    await _start((_camIndex + 1) % _cameras.length);
  }

  Future<void> _capture() async {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized || _recording) return;
    HapticFeedback.mediumImpact();
    try {
      final file = await cam.takePicture();
      if (!mounted) return;
      setState(() {
        _shot = File(file.path);
        _shotIsVideo = false;
      });
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _startRecording() async {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized || _recording) return;
    HapticFeedback.heavyImpact();
    try {
      await cam.startVideoRecording();
      if (!mounted) return;
      setState(() => _recording = true);
      // Tự dừng ở mốc tối đa, kể cả khi người dùng quên nhả tay.
      Future.delayed(_maxClip, () {
        if (mounted && _recording) _stopRecording();
      });
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _stopRecording() async {
    final cam = _cam;
    if (cam == null || !_recording) return;
    try {
      final file = await cam.stopVideoRecording();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _shot = File(file.path);
        _shotIsVideo = true;
      });
    } catch (e) {
      if (mounted) setState(() => _recording = false);
      _showError(e);
    }
  }

  /// Gửi cho squad rồi quay lại khung ngắm ngay.
  Future<void> _send() async {
    final file = _shot;
    if (file == null || _sending) return;
    setState(() {
      _sending = true;
      _progress = 0;
    });

    try {
      final uploaded = await ref
          .read(mediaUploaderProvider)
          .uploadFile(
            tripId: widget.tripId,
            file: file,
            contentType: _shotIsVideo ? 'video/mp4' : 'image/jpeg',
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );

      final caption = _caption.text.trim();
      await ref
          .read(momentsRepositoryProvider)
          .create(
            tripId: widget.tripId,
            mediaUrl: uploaded.url,
            type: _shotIsVideo ? 'VIDEO' : 'PHOTO',
            caption: caption.isEmpty ? null : caption,
          );

      if (!mounted) return;
      ref.invalidate(momentsProvider(widget.tripId));
      ref.invalidate(recentMomentsProvider);
      ref.invalidate(xpWalletProvider);
      // Đẩy sang widget màn hình chính ngay — đây chính là vòng lặp của Locket:
      // gửi xong là bạn bè thấy trên home mà không cần mở app.
      await ref.read(widgetSyncProvider).refresh();

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      showGlobalSnack('moments.sent_to_squad'.tr());
      setState(() {
        _shot = null;
        _sending = false;
        _progress = 0;
        _caption.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      // Chuyến đã đầy 100 khoảnh khắc → paywall, không phải snackbar lỗi.
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
      _showError(e);
    }
  }

  void _showError(Object e) {
    showGlobalSnack(
      e is ApiException ? e.message : 'errors.unknown_error'.tr(),
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _initError != null
            ? AppErrorState(
                isDark: true,
                error: _initError,
                onRetry: () {
                  setState(() {
                    _initializing = true;
                    _initError = null;
                  });
                  _boot();
                },
              )
            : _initializing
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _shot != null
            ? _reviewView()
            : _cameraView(),
      ),
    );
  }

  // ── Khung ngắm ───────────────────────────────────────────────────────────
  Widget _cameraView() {
    final cam = _cam!;
    return Stack(
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: cam.value.previewSize?.height ?? 1,
              height: cam.value.previewSize?.width ?? 1,
              child: CameraPreview(cam),
            ),
          ),
        ),

        // Thanh trên: đóng + nhắc đang gửi cho squad nào
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              if (_recording)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: GenZTokens.danger,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'moments.recording'.tr(),
                    style: AppFonts.heading(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Gợi ý cách dùng — Locket không có nhãn nào, nhưng cử chỉ "giữ để quay"
        // không tự hiện ra được nên phải nói một lần.
        Positioned(
          left: 0,
          right: 0,
          bottom: 148,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'moments.cam_hint'.tr(),
                style: AppFonts.body(fontSize: 12.5, color: Colors.white),
              ),
            ),
          ),
        ),

        // Hàng nút dưới
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 56),
              // Bấm = ảnh, giữ = video.
              GestureDetector(
                onTap: _capture,
                onLongPressStart: (_) => _startRecording(),
                onLongPressEnd: (_) => _stopRecording(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: _recording ? 92 : 82,
                  height: _recording ? 92 : 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _recording
                        ? GenZTokens.danger
                        : Colors.white.withValues(alpha: 0.25),
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                ),
              ),
              SizedBox(
                width: 56,
                child: _cameras.length > 1
                    ? IconButton(
                        icon: const Icon(
                          Icons.cameraswitch_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: _flip,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Xem lại trước khi gửi ────────────────────────────────────────────────
  Widget _reviewView() {
    return Stack(
      children: [
        Positioned.fill(
          child: _shotIsVideo
              // Video: hiện nền tối + biểu tượng thay vì phát lại — người dùng
              // vừa quay xong nên đã biết nội dung; phát lại chỉ làm chậm.
              ? Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(
                      Icons.videocam_rounded,
                      color: Colors.white54,
                      size: 72,
                    ),
                  ),
                )
              : Image.file(_shot!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: _sending
                ? null
                : () => setState(() {
                    _shot = null;
                    _caption.clear();
                  }),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _caption,
                enabled: !_sending,
                textAlign: TextAlign.center,
                maxLength: 60,
                style: AppFonts.body(fontSize: 15, color: Colors.white),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'moments.caption_short'.tr(),
                  hintStyle: AppFonts.body(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.45),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_sending) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      GenZTokens.green,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GenZTokens.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  label: Text(
                    'moments.send_to_squad'.tr(),
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
