import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import '../../../core/app_messenger.dart';
import '../../../core/widgets/gen_z_widgets.dart';

class MateyAiEmotionalChaosScreen extends StatefulWidget {
  const MateyAiEmotionalChaosScreen({super.key});

  @override
  State<MateyAiEmotionalChaosScreen> createState() =>
      _MateyAiEmotionalChaosScreenState();
}

class _MateyAiEmotionalChaosScreenState
    extends State<MateyAiEmotionalChaosScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbFloatController;
  late final AnimationController _typingController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isDarkMode =
      true; // State of theme, will default to system or manual switch

  final List<Map<String, dynamic>> _messages = [
    {
      'type': 'ai',
      'text':
          'You probably shouldn’t schedule 5 cafes in 2 hours 😭 Trừ khi các bồ muốn cả team xỉu up xỉu down vibrating through the streets of Tokyo. Let\'s space it out a bit?',
      'time': 'just now',
      'likes': 12,
    },
    {
      'type': 'alert_broke',
      'title': 'broke alert',
      'text':
          'That omakase place is gonna eat 40% of the daily budget. Tìm quán khác hạt dẻ hơn nha?',
    },
    {
      'type': 'alert_weather',
      'title': 'weather savior',
      'text':
          'rain detected ☔ saving the vibe... Trời sắp mưa rào rùi, tui đổi Tsukiji Market sang chiều nha?',
    },
    {
      'type': 'user',
      'text':
          'Fair point. What\'s a good alternative near Shibuya right now? Cần chỗ nào aesthetic xíu để sống ảo nha.',
      'time': 'just now',
    },
    {
      'type': 'vibe_match',
      'title': 'vibe match',
      'placeName': 'Neon Light Cafe',
      'match': '98% match',
      'text':
          '"Đỉnh chóp luôn. Góc này lên hình bao cháy, matches your squad\'s chaotic energy perfectly."',
      'imageUrl':
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&auto=format&fit=crop&q=80',
    },
  ];

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

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'type': 'user',
        'text': _textController.text.trim(),
        'time': 'just now',
      });
      _textController.clear();
    });

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Mock bot quick response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'type': 'ai',
          'text':
              'OMG 😱 Đã ghi nhận ý kiến! Để tui tính toán lại lịch trình tối nay cho cả đội quẩy tẹt ga nha! ⚡🕺',
          'time': 'just now',
          'likes': 0,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Token Gen Z Neo-Brutalist — nền cream phẳng, viền/chữ ink
    const primaryColor = GenZTokens.purple;
    const secondaryColor = GenZTokens.green;
    const tertiaryColor = GenZTokens.orange;

    final backgroundColor = _isDarkMode
        ? GenZTokens.creamDark
        : GenZTokens.cream;
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
                              case 'alert_broke':
                                return _buildBrokeAlert(
                                  msg,
                                  glassBg,
                                  textPrimary,
                                );
                              case 'alert_weather':
                                return _buildWeatherSavior(
                                  msg,
                                  glassBg,
                                  secondaryColor,
                                  textPrimary,
                                );
                              case 'user':
                                return _buildUserBubble(msg, primaryColor);
                              case 'vibe_match':
                                return _buildVibeMatchCard(
                                  msg,
                                  glassBg,
                                  glassBorder,
                                  primaryColor,
                                  tertiaryColor,
                                  textPrimary,
                                  textSecondary,
                                );
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),

                        // Typing indicator
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

          // 4. Breathtaking Floating Bottom Nav Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildBottomNav(
              glassBg,
              glassBorder,
              secondaryColor,
              primaryColor,
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
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.wb_sunny_outlined : Icons.mode_night_outlined,
              color: primaryColor,
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
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
        const SizedBox(height: 8),
        const PillTag(
          text: 'Squad Energy: Chaotic Good 85%',
          color: GenZTokens.lilac,
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
                  fontSize: 9,
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
  Widget _buildBrokeAlert(
    Map<String, dynamic> msg,
    Color glassBg,
    Color textPrimary,
  ) {
    final ink = _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GenZTokens.red,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
        boxShadow: GenZTokens.hardShadow(ink),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GenZTokens.paper,
              border: Border.all(
                color: GenZTokens.ink,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: const Icon(Icons.warning, color: GenZTokens.ink, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (msg['title'] as String).toUpperCase(),
                  style: AppFonts.mono(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: GenZTokens.paper,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg['text'],
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: GenZTokens.paper,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Weather Savior Card
  Widget _buildWeatherSavior(
    Map<String, dynamic> msg,
    Color glassBg,
    Color secondaryColor,
    Color textPrimary,
  ) {
    final ink = _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GenZTokens.green,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
        boxShadow: GenZTokens.hardShadow(ink),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GenZTokens.paper,
              border: Border.all(
                color: GenZTokens.ink,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: const Icon(
              Icons.thunderstorm,
              color: GenZTokens.ink,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (msg['title'] as String).toUpperCase(),
                  style: AppFonts.mono(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: GenZTokens.ink,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  msg['text'],
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: GenZTokens.ink,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ChunkyButton(
                        color: GenZTokens.yellow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Rerouting squad itinerary to dry aesthetic spots...',
                              ),
                            ),
                          );
                        },
                        child: const Text('reroute itinerary'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusInput,
                        ),
                        color: GenZTokens.paper,
                        border: Border.all(
                          color: GenZTokens.ink,
                          width: GenZTokens.borderWidthThin,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => showGlobalSnack(
                          'Tính năng đang được hoàn thiện 🚧',
                        ),
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusInput,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: GenZTokens.ink,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                fontSize: 9,
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
  Widget _buildVibeMatchCard(
    Map<String, dynamic> msg,
    Color glassBg,
    Color glassBorder,
    Color primaryColor,
    Color tertiaryColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColorBorderGuard(),
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: glassBorder, width: GenZTokens.borderWidth),
        boxShadow: GenZTokens.hardShadow(glassBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              PillTag(
                text: msg['title'] as String,
                icon: Icons.group,
                color: GenZTokens.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(msg['imageUrl'], fit: BoxFit.cover),
                      Container(color: Colors.black.withValues(alpha: 0.2)),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: GenZTokens.yellow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: GenZTokens.ink,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            (msg['match'] as String).toUpperCase(),
                            style: AppFonts.mono(
                              color: GenZTokens.ink,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg['placeName'],
                      style: AppFonts.heading(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg['text'],
                      style: AppFonts.body(
                        fontSize: 12,
                        color: textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${msg['placeName']} to Dalat trip!',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: GenZTokens.lilac,
                          borderRadius: BorderRadius.circular(
                            GenZTokens.radiusPill,
                          ),
                          border: Border.all(
                            color: GenZTokens.ink,
                            width: GenZTokens.borderWidthThin,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ADD TO ITINERARY',
                              style: AppFonts.mono(
                                color: GenZTokens.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.add,
                              color: GenZTokens.ink,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                showGlobalSnack('Tính năng đang được hoàn thiện 🚧'),
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
                hintText: 'ask matey anything...',
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
  Widget _buildBottomNav(
    Color glassBg,
    Color glassBorder,
    Color secondaryColor,
    Color primaryColor,
  ) {
    final ink = _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: _isDarkMode ? GenZTokens.paperDark : GenZTokens.paper,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
        boxShadow: GenZTokens.hardShadow(ink),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(Icons.map_outlined, false, secondaryColor),
          _buildNavButton(Icons.search_outlined, false, secondaryColor),
          _buildNavButton(Icons.add_circle_outline, false, secondaryColor),

          // Tab Assistant active — viên vàng viền ink
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GenZTokens.yellow,
              border: Border.all(
                color: GenZTokens.ink,
                width: GenZTokens.borderWidthThin,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: GenZTokens.ink,
              size: 24,
            ),
          ),

          _buildNavButton(Icons.person_outline, false, secondaryColor),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive, Color activeColor) {
    final ink = _isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    return Icon(
      icon,
      color: isActive ? activeColor : ink.withValues(alpha: 0.55),
      size: 24,
    );
  }

  Color surfaceColorBorderGuard() {
    return _isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
  }
}
