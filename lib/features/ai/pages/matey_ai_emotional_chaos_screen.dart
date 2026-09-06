import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../premium/presentation/paywall_sheet.dart';
import '../../gamification/data/games_repository.dart';
import '../data/ai_repository.dart';

import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../core/widgets/gen_z_widgets.dart';

class MateyAiEmotionalChaosScreen extends ConsumerStatefulWidget {
  const MateyAiEmotionalChaosScreen({super.key});

  @override
  ConsumerState<MateyAiEmotionalChaosScreen> createState() =>
      _MateyAiEmotionalChaosScreenState();
}

class _MateyAiEmotionalChaosScreenState
    extends ConsumerState<MateyAiEmotionalChaosScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbFloatController;
  late final AnimationController _typingController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Theo đúng chế độ sáng/tối của app.
  ///
  /// Trước đây màn này giữ cờ riêng `_isDarkMode = true` cùng một nút bật/tắt
  /// chỉ đổi màu trong màn này, nên chữ luôn vẽ màu kem — đặt trên nền sáng
  /// của theme thì gần như không đọc được.
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  /// Hội thoại bắt đầu rỗng.
  ///
  /// Trước đây danh sách này dựng sẵn 5 tin nhắn về Tokyo/Shibuya/omakase —
  /// cùng "vibe match 98%" cho Neon Light Cafe — nên ai mở Matey AI cũng thấy
  /// một cuộc trò chuyện mình chưa từng có, về một chuyến không tồn tại.
  final List<Map<String, dynamic>> _messages = [];

  /// Đang chờ AI trả lời — dùng để hiện chấm gõ phím và khoá nút gửi.
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _orbFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbFloatController.dispose();
    _typingController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isThinking) return;
    setState(() {
      _messages.add({'type': 'user', 'text': text, 'time': 'just now'});
      _textController.clear();
      _isThinking = true;
    });
    _scrollToBottom();

    try {
      // Gọi AI thật. Trước đây chỗ này chỉ `Future.delayed(1s)` rồi thêm một
      // câu trả lời in cứng — Matey "trả lời" y hệt nhau bất kể hỏi gì.
      final tripId = ref.read(activeTripIdProvider);
      final reply = await ref
          .read(mateyChatProvider)
          .ask(prompt: text, tripId: tripId);
      if (!mounted) return;
      setState(() {
        _messages.add({
          'type': 'ai',
          'text': reply,
          'time': 'just now',
          'likes': 0,
        });
        _isThinking = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isThinking = false);
      // Hết lượt AI trong tháng → paywall nêu đúng con số, không phải một lỗi
      // 403 mà người dùng không hiểu vì sao.
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
      // Nói rõ AI đang bận thay vì im lặng hoặc bịa câu trả lời.
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Token Gen Z Neo-Brutalist — nền cream phẳng, viền/chữ ink
    const primaryColor = GenZTokens.purple;
    const secondaryColor = GenZTokens.green;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = _isDarkMode
        ? GenZTokens.inkSoftDark
        : GenZTokens.inkSoft;

    final glassBg = _isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
    final glassBorder = textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1. Custom Scroll View accommodating Hero & Chat bubbles
          SafeArea(
            child: Column(
              children: [
                // Top Custom Header App Bar
                _buildHeader(primaryColor, glassBg, glassBorder, textPrimary),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Orb Hero section
                        _buildOrbHero(
                          primaryColor,
                          secondaryColor,
                          glassBg,
                          glassBorder,
                          textSecondary,
                        ),

                        const SizedBox(height: 16),

                        // Lời mời mở đầu khi chưa hỏi gì — trước đây chỗ này
                        // là 5 tin nhắn dựng sẵn về một chuyến Tokyo không có
                        // thật.
                        if (_messages.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'ai.matey_intro'.tr(),
                              textAlign: TextAlign.center,
                              style: AppFonts.body(
                                fontSize: 14,
                                color: textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),

                        // Chat Flow list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            switch (msg['type']) {
                              case 'ai':
                                return _buildAiBubble(
                                  msg,
                                  glassBg,
                                  glassBorder,
                                  textPrimary,
                                  textSecondary,
                                );
                              case 'user':
                                return _buildUserBubble(msg, primaryColor);
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),

                        // Chấm gõ phím chỉ hiện khi ĐANG chờ AI — trước đây
                        // nó chạy vĩnh viễn, làm như Matey luôn sắp trả lời.
                        if (_isThinking)
                          _buildTypingIndicator(
                            glassBg,
                            glassBorder,
                            primaryColor,
                          ),

                        const SizedBox(height: 120), // Bottom input spacing
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Bottom Message Input Bar
          Positioned(
            bottom: 96,
            left: 20,
            right: 20,
            child: _buildMessageInput(
              glassBg,
              glassBorder,
              primaryColor,
              textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Header App Bar
  Widget _buildHeader(
    Color primaryColor,
    Color glassBg,
    Color glassBorder,
    Color textPrimary,
  ) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: glassBg.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: glassBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'trip.mate',
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Floating Animated AI Orb Hero
  Widget _buildOrbHero(
    Color primaryColor,
    Color secondaryColor,
    Color glassBg,
    Color glassBorder,
    Color textSecondary,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _orbFloatController,
          builder: (context, child) {
            final dy = _orbFloatController.value * -12.0;
            return Transform.translate(offset: Offset(0, dy), child: child);
          },
          // Orb sticker brutalist: khối tím viền ink + hard shadow
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
              border: Border.all(
                color: _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink,
                width: GenZTokens.borderWidth,
              ),
              boxShadow: GenZTokens.hardShadow(
                _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                size: 48,
                color: GenZTokens.paper,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'hey, i\'m matey ✧',
          style: AppFonts.heading(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink,
            letterSpacing: -0.5,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // AI Advice Bubble
  Widget _buildAiBubble(
    Map<String, dynamic> msg,
    Color glassBg,
    Color glassBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColorBorderGuard(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: glassBorder,
                  width: GenZTokens.borderWidthThin,
                ),
                boxShadow: GenZTokens.hardShadow(glassBorder),
              ),
              child: Text(
                msg['text'],
                style: AppFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                (msg['time'] as String).toUpperCase(),
                style: AppFonts.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Broke Alert Card — khối đỏ sticker, viền ink, hard shadow

  // Weather Savior Card

  // User message bubble
  Widget _buildUserBubble(Map<String, dynamic> msg, Color primaryColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Bubble user: nền VÀNG, chữ ink, viền ink + hard shadow (spec)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GenZTokens.yellow,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink,
                  width: GenZTokens.borderWidthThin,
                ),
                boxShadow: GenZTokens.hardShadow(
                  _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink,
                ),
              ),
              child: Text(
                msg['text'],
                style: AppFonts.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: GenZTokens.ink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (msg['time'] as String).toUpperCase(),
              style: AppFonts.mono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _isDarkMode
                    ? GenZTokens.inkSoftDark
                    : GenZTokens.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Vibe Match Cafe Card

  // Typing indicator dots
  Widget _buildTypingIndicator(
    Color glassBg,
    Color glassBorder,
    Color primaryColor,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColorBorderGuard(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: glassBorder,
            width: GenZTokens.borderWidthThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                final wave =
                    (1.0 +
                        double.parse(
                          ((index - _typingController.value * 2) % 3)
                              .toStringAsFixed(2),
                        )) /
                    3.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: wave.clamp(0.2, 1.0)),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  // Thanh nhập tin nhắn brutalist: nền paper, viền ink dày, hard shadow
  Widget _buildMessageInput(
    Color glassBg,
    Color glassBorder,
    Color primaryColor,
    Color textPrimary,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: glassBorder, width: GenZTokens.borderWidth),
        boxShadow: GenZTokens.hardShadow(glassBorder),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: textPrimary),
            onPressed: () =>
                showGlobalSnack('common.feature_wip'.tr()),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              style: AppFonts.body(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'ai.matey_hint'.tr(),
                hintStyle: AppFonts.body(
                  fontWeight: FontWeight.w600,
                  color: textPrimary.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GenZTokens.yellow,
              border: Border.all(
                color: GenZTokens.ink,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.send, color: GenZTokens.ink, size: 18),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // Floating Glass bottom navigation bar

  Color surfaceColorBorderGuard() {
    return _isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  }
}
