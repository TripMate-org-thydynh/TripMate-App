import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../application/trips_providers.dart';
import '../domain/trip.dart';
import 'trip_hub_screen.dart';

/// Tham gia một chuyến bằng mã mời hoặc link chia sẻ.
///
/// Chấp nhận cả 3 dạng người dùng thường dán vào: mã trần (`ABC123`), link
/// `https://tripmate.app/join/ABC123`, hoặc mã cố định của chuyến. Việc phân
/// biệt loại mã do repository lo (`joinByAnyCode`).
class JoinTripScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  /// Mã điền sẵn (ví dụ khi mở từ deep link).
  final String? initialCode;

  const JoinTripScreen({super.key, required this.isDarkMode, this.initialCode});

  @override
  ConsumerState<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends ConsumerState<JoinTripScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: _extractCode(widget.initialCode ?? ''),
  );
  bool _submitting = false;
  String? _error;

  /// Người dùng hay dán nguyên link thay vì mã — lấy đoạn cuối đường dẫn.
  static String _extractCode(String input) {
    final v = input.trim();
    if (v.isEmpty) return '';
    final uri = Uri.tryParse(v);
    if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return v;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _ink => widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _surface =>
      widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) return;
    _controller.text = _extractCode(text);
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    setState(() => _error = null);
  }

  Future<void> _submit() async {
    final code = _extractCode(_controller.text);
    if (code.isEmpty) {
      setState(() => _error = 'Nhập mã mời hoặc dán link được chia sẻ nhé.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final Trip trip = await ref
          .read(tripsProvider.notifier)
          .joinByAnyCode(code);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      final messenger = ScaffoldMessenger.of(context);
      // Thay màn hiện tại bằng hub của chuyến vừa tham gia — back không rơi
      // ngược về form join nữa.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TripHubScreen(trip: trip, isDarkMode: widget.isDarkMode),
        ),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã tham gia "${trip.name}"! 🎉'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendly(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Có lỗi xảy ra. Thử lại giúp mình nhé.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Đổi lỗi kỹ thuật từ BE sang câu người dùng hiểu được.
  String _friendly(ApiException e) {
    if (e.isNetwork) return 'Mất mạng rồi. Kiểm tra kết nối rồi thử lại nhé.';
    if (e.statusCode == 404) {
      return 'Mã này không tồn tại. Kiểm tra lại xem có gõ nhầm không nhé.';
    }
    final msg = e.message.toLowerCase();
    if (msg.contains('already') || msg.contains('alreadymember')) {
      return 'Bạn đã là thành viên của chuyến này rồi!';
    }
    if (msg.contains('expired')) return 'Link mời đã hết hạn.';
    if (msg.contains('max uses')) return 'Link mời đã hết lượt sử dụng.';
    if (e.isServer) return 'Server đang trục trặc. Thử lại sau ít phút nhé.';
    return e.message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: IconThemeData(color: _ink),
        // Mở từ deep link thì stack rỗng — back phải về dashboard chứ không
        // để người dùng kẹt ở màn này.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          'Tham gia chuyến',
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GenZTokens.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(GenZTokens.space5),
                decoration: BoxDecoration(
                  color: GenZTokens.yellow,
                  borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                  border: Border.all(
                    color: _ink,
                    width: GenZTokens.borderWidth,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.ticket(PhosphorIconsStyle.fill),
                      size: 40,
                      color: GenZTokens.ink,
                    ),
                    const SizedBox(height: GenZTokens.space3),
                    Text(
                      'Có mã mời từ hội bạn?',
                      textAlign: TextAlign.center,
                      style: AppFonts.heading(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: GenZTokens.ink,
                      ),
                    ),
                    const SizedBox(height: GenZTokens.space2),
                    Text(
                      'Dán mã hoặc link chia sẻ vào ô bên dưới để vào chuyến.',
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        fontSize: 13,
                        color: GenZTokens.ink.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GenZTokens.space5),
              TextField(
                controller: _controller,
                enabled: !_submitting,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                style: AppFonts.heading(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: 'VD: ABC123 hoặc dán link',
                  hintStyle: AppFonts.body(
                    fontSize: 14,
                    color: _ink.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: _surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: GenZTokens.space4,
                    vertical: GenZTokens.space4,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Dán từ clipboard',
                    onPressed: _submitting ? null : _pasteFromClipboard,
                    icon: Icon(PhosphorIcons.clipboardText(), color: _ink),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                    borderSide: BorderSide(
                      color: _ink,
                      width: GenZTokens.borderWidth,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                    borderSide: BorderSide(
                      color: _ink,
                      width: GenZTokens.borderWidthFocus,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                    borderSide: BorderSide(
                      color: _ink.withValues(alpha: 0.4),
                      width: GenZTokens.borderWidth,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: GenZTokens.space3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                      size: 18,
                      color: GenZTokens.danger,
                    ),
                    const SizedBox(width: GenZTokens.space2),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppFonts.body(
                          fontSize: 13,
                          color: GenZTokens.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: GenZTokens.space5),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GenZTokens.green,
                  disabledBackgroundColor: _ink.withValues(alpha: 0.2),
                  foregroundColor: GenZTokens.ink,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(color: _ink, width: GenZTokens.borderWidth),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GenZTokens.radiusButton,
                    ),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: GenZTokens.ink,
                        ),
                      )
                    : Text(
                        'Tham gia ngay',
                        style: AppFonts.heading(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: GenZTokens.ink,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
