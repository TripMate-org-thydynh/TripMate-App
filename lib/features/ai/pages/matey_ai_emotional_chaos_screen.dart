import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MateyAiEmotionalChaosScreen extends StatefulWidget {
  const MateyAiEmotionalChaosScreen({super.key});

  @override
  State<MateyAiEmotionalChaosScreen> createState() => _MateyAiEmotionalChaosScreenState();
}

class _MateyAiEmotionalChaosScreenState extends State<MateyAiEmotionalChaosScreen> with TickerProviderStateMixin {
  late final AnimationController _orbFloatController;
  late final AnimationController _typingController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isDarkMode = true; // State of theme, will default to system or manual switch

  final List<Map<String, dynamic>> _messages = [
    {
      'type': 'ai',
      'text': 'You probably shouldn’t schedule 5 cafes in 2 hours 😭 Trừ khi các bồ muốn cả team xỉu up xỉu down vibrating through the streets of Tokyo. Let\'s space it out a bit?',
      'time': 'just now',
      'likes': 12,
    },
    {
      'type': 'alert_broke',
      'title': '💸 broke alert',
      'text': 'That omakase place is gonna eat 40% of the daily budget. Tìm quán khác hạt dẻ hơn nha?',
    },
    {
      'type': 'alert_weather',
      'title': 'weather savior',
      'text': 'rain detected ☔ saving the vibe... Trời sắp mưa rào rùi, tui đổi Tsukiji Market sang chiều nha?',
    },
    {
      'type': 'user',
      'text': 'Fair point. What\'s a good alternative near Shibuya right now? Cần chỗ nào aesthetic xíu để sống ảo nha.',
      'time': 'just now',
    },
    {
      'type': 'vibe_match',
      'title': 'vibe match ✧',
      'placeName': 'Neon Light Cafe',
      'match': '98% match',
      'text': '"Đỉnh chóp luôn. Góc này lên hình bao cháy, matches your squad\'s chaotic energy perfectly."',
      'imageUrl': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&auto=format&fit=crop&q=80',
    }
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
          'text': 'OMG 😱 Đã ghi nhận ý kiến! Để tui tính toán lại lịch trình tối nay cho cả đội quẩy tẹt ga nha! ⚡🕺',
          'time': 'just now',
          'likes': 0,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine dynamic theme properties based on internal state
    final primaryColor = _isDarkMode ? const Color(0xFFD0BCFF) : const Color(0xFF8B5CF6);
    final secondaryColor = _isDarkMode ? const Color(0xFF45DFA4) : const Color(0xFF34D399);
    final tertiaryColor = _isDarkMode ? const Color(0xFFFFB783) : const Color(0xFFF59E0B);
    
    final backgroundColor = _isDarkMode ? const Color(0xFF040914) : const Color(0xFFFCFAF6);
    final textPrimary = _isDarkMode ? const Color(0xFFDAE2FD) : const Color(0xFF1E293B);
    final textSecondary = _isDarkMode ? const Color(0xFFCBC3D7) : const Color(0xFF6B7280);
    
    final glassBg = _isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);
    final glassBorder = _isDarkMode ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 1. Aurora gradients flowing in background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: _isDarkMode
                      ? [const Color(0xFF6D3BD7).withValues(alpha: 0.15), Colors.transparent]
                      : [const Color(0xFFE9DDFF).withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomRight,
                  radius: 1.2,
                  colors: _isDarkMode
                      ? [const Color(0xFF45DFA4).withValues(alpha: 0.08), Colors.transparent]
                      : [const Color(0xFFE8FFF5).withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
            ),
          ),

          // 2. Custom Scroll View accommodating Hero & Chat bubbles
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
                        _buildOrbHero(primaryColor, secondaryColor, glassBg, glassBorder, textSecondary),
                        
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
                                return _buildAiBubble(msg, glassBg, glassBorder, textPrimary, textSecondary);
                              case 'alert_broke':
                                return _buildBrokeAlert(msg, glassBg, textPrimary);
                              case 'alert_weather':
                                return _buildWeatherSavior(msg, glassBg, secondaryColor, textPrimary);
                              case 'user':
                                return _buildUserBubble(msg, primaryColor);
                              case 'vibe_match':
                                return _buildVibeMatchCard(msg, glassBg, glassBorder, primaryColor, tertiaryColor, textPrimary, textSecondary);
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),

                        // Typing indicator
                        _buildTypingIndicator(glassBg, glassBorder, primaryColor),

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
            child: _buildMessageInput(glassBg, glassBorder, primaryColor, textPrimary),
          ),

          // 4. Breathtaking Floating Bottom Nav Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildBottomNav(glassBg, glassBorder, secondaryColor, primaryColor),
          ),
        ],
      ),
    );
  }

  // Header App Bar
  Widget _buildHeader(Color primaryColor, Color glassBg, Color glassBorder, Color textPrimary) {
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
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFD0BCFF), Color(0xFF45DFA4), Color(0xFFFFB783)],
            ).createShader(bounds),
            child: Text(
              'trip.mate',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.5,
              ),
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
  Widget _buildOrbHero(Color primaryColor, Color secondaryColor, Color glassBg, Color glassBorder, Color textSecondary) {
    return Column(
      children: [
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _orbFloatController,
          builder: (context, child) {
            final dy = _orbFloatController.value * -12.0;
            return Transform.translate(
              offset: Offset(0, dy),
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Planning Glow Aura
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Inner glowing core
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isDarkMode ? const Color(0xFF060E20) : Colors.white,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'hey, i\'m matey ✧',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _isDarkMode ? Colors.white : const Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SQUAD ENERGY: CHAOTIC GOOD (85%)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // AI Advice Bubble
  Widget _buildAiBubble(Map<String, dynamic> msg, Color glassBg, Color glassBorder, Color textPrimary, Color textSecondary) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
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
                border: Border.all(color: glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                msg['text'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                msg['time'],
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Broke Alert Card
  Widget _buildBrokeAlert(Map<String, dynamic> msg, Color glassBg, Color textPrimary) {
    final alertRed = const Color(0xFFFFB4AB);
    final alertRedBg = const Color(0x22FFB4AB);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _isDarkMode ? alertRedBg : Colors.red.shade50.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: alertRed.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: alertRed.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: alertRed.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.warning, color: _isDarkMode ? alertRed : Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg['title'],
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: _isDarkMode ? alertRed : Colors.red.shade800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg['text'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: textPrimary,
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
  Widget _buildWeatherSavior(Map<String, dynamic> msg, Color glassBg, Color secondaryColor, Color textPrimary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.teal.withValues(alpha: 0.08) : Colors.teal.shade50.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: secondaryColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondaryColor.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.thunderstorm, color: secondaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      msg['title'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: secondaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  msg['text'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [secondaryColor, secondaryColor.withValues(alpha: 0.8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: secondaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Rerouting squad itinerary to dry aesthetic spots... 🗺️⚡')),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              'reroute itinerary',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isDarkMode ? Colors.white24 : Colors.black12),
                      ),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Icon(Icons.close, color: textPrimary, size: 18),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                msg['text'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg['time'],
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _isDarkMode ? Colors.white60 : Colors.black45,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tertiaryColor.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.group, color: tertiaryColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                msg['title'],
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: tertiaryColor,
                ),
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
                      Image.network(
                        msg['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            msg['match'],
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg['text'],
                      style: GoogleFonts.inter(
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
                          SnackBar(content: Text('Added ${msg['placeName']} to Dalat trip! 🌲')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'add to itinerary',
                              style: GoogleFonts.plusJakartaSans(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.add, color: primaryColor, size: 10),
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
  Widget _buildTypingIndicator(Color glassBg, Color glassBorder, Color primaryColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColorBorderGuard(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                final wave = (1.0 + double.parse(((index - _typingController.value * 2) % 3).toStringAsFixed(2))) / 3.0;
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

  // Custom pill input text field
  Widget _buildMessageInput(Color glassBg, Color glassBorder, Color primaryColor, Color textPrimary) {
    return Stack(
      children: [
        // Aura glow underneath
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xDD171F33) : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: glassBorder),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: textPrimary.withValues(alpha: 0.6)),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'ask matey anything...',
                        hintStyle: GoogleFonts.inter(color: textPrimary.withValues(alpha: 0.4)),
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
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Floating Glass bottom navigation bar
  Widget _buildBottomNav(Color glassBg, Color glassBorder, Color secondaryColor, Color primaryColor) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xCC171F33) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavButton(Icons.map_outlined, false, secondaryColor),
          _buildNavButton(Icons.search_outlined, false, secondaryColor),
          _buildNavButton(Icons.add_circle_outline, false, secondaryColor),
          
          // Active Assistant Tab with sparkling glow
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [secondaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0.2)],
                  ),
                  border: Border.all(color: secondaryColor.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: secondaryColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: secondaryColor,
                  size: 24,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          
          _buildNavButton(Icons.person_outline, false, secondaryColor),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isActive, Color activeColor) {
    return Icon(
      icon,
      color: isActive ? activeColor : (_isDarkMode ? Colors.white60 : Colors.black54),
      size: 24,
    );
  }

  Color surfaceColorBorderGuard() {
    return _isDarkMode ? const Color(0xFF171F33) : Colors.white;
  }
}
