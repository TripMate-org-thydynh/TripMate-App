import 'dart:ui';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../gamification/data/games_repository.dart';
import '../data/ai_repository.dart';
import '../../../core/app_messenger.dart';
import 'package:flutter/services.dart';
class AICaptionGeneratorScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const AICaptionGeneratorScreen({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
  });

  @override
  ConsumerState<AICaptionGeneratorScreen> createState() =>
      _AICaptionGeneratorScreenState();
}

class _AICaptionGeneratorScreenState extends ConsumerState<AICaptionGeneratorScreen>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _pulseController;

  String _selectedVibe = 'Chaotic Gen Z';
  int _selectedOptionIndex = 0;
  final TextEditingController _editorController = TextEditingController(
    text: 'financially ruined. emotionally healed. 💸✨',
  );

  final List<String> _vibes = [
    'Funny',
    'Chaotic Gen Z',
    'Cinematic',
    'Aesthetic',
  ];

  final List<Map<String, dynamic>> _captionsList = [
    {
      'vibe': 'Chaotic Gen Z',
      'options': [
        {
          'text': 'financially ruined. emotionally healed.',
          'tags': ['#broke', '#worthit'],
        },
        {
          'text': '6 idiots. 1 unforgettable trip.',
          'tags': ['#tokyodrift', '#squad'],
        },
        {
          'text': 'the vibes survived somehow.',
          'tags': ['#blessed', '#chaos'],
        },
      ],
    },
    {
      'vibe': 'Funny',
      'options': [
        {
          'text': 'My bank account is crying, but my soul is singing.',
          'tags': ['#noregrets', '#traveldiaries'],
        },
        {
          'text': 'Lost in Tokyo, please don\'t find us.',
          'tags': ['#wherearewe', '#lost'],
        },
        {
          'text': 'I followed my heart and it led me to a ramen shop.',
          'tags': ['#ramen', '#foodie'],
        },
      ],
    },
    {
      'vibe': 'Cinematic',
      'options': [
        {
          'text': 'Under neon lights, our stories found their rhythm.',
          'tags': ['#nightwalk', '#cityscape'],
        },
        {
          'text': 'A beautiful blur of neon and laughter.',
          'tags': ['#tokyo', '#nights'],
        },
        {
          'text': 'We exist in the spaces between the flashes.',
          'tags': ['#cinematic', '#aesthetic'],
        },
      ],
    },
    {
      'vibe': 'Aesthetic',
      'options': [
        {
          'text': 'stardust & neon signs.',
          'tags': ['#moody', '#vibes'],
        },
        {
          'text': 'chasing shadows in the city.',
          'tags': ['#tokyoaesthetic', '#retro'],
        },
        {
          'text': 'soft glowing memories.',
          'tags': ['#vibecheck', '#dreamy'],
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Aurora glow oscillation animation
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _pulseController.dispose();
    _editorController.dispose();
    super.dispose();
  }

  /// Caption do AI sinh cho vibe đang chọn. Rỗng thì dùng mẫu có sẵn.
  final Map<String, List<Map<String, dynamic>>> _aiOptions = {};
  bool _isGenerating = false;

  List<Map<String, dynamic>> get _currentOptions {
    final ai = _aiOptions[_selectedVibe];
    if (ai != null && ai.isNotEmpty) return ai;
    final match = _captionsList.firstWhere(
      (element) => element['vibe'] == _selectedVibe,
      orElse: () => _captionsList.first,
    );
    return List<Map<String, dynamic>>.from(match['options']);
  }

  /// Gọi AI sinh caption thật cho vibe đang chọn.
  ///
  /// Trước đây màn "AI Caption Studio" chỉ đọc một danh mục viết sẵn trong
  /// app — không có lời gọi AI nào, dù tên màn nói ngược lại.
  Future<void> _generate() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final tripId = ref.read(activeTripIdProvider);
      final text = await ref
          .read(mateyChatProvider)
          .ask(
            prompt:
                'Viết 3 caption ngắn cho ảnh du lịch theo vibe "$_selectedVibe", '
                'kèm 2 hashtag mỗi caption. Mỗi caption một dòng.',
            tripId: tripId,
          );
      final lines = text
          .split(RegExp(r'\n+'))
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .take(5)
          .toList();
      if (!mounted) return;
      setState(() {
        _aiOptions[_selectedVibe] = lines
            .map((l) => {'text': l, 'tags': const <String>[]})
            .toList();
        _selectedOptionIndex = 0;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      showGlobalSnack(
        e is ApiException ? e.message : 'errors.unknown_error'.tr(),
        isError: true,
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Copied to clipboard!',
              style: AppFonts.body(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Theme Tokens
    final bgStart = isDark ? const Color(0xFF1A1712) : const Color(0xFFFDF6D3);
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final primary = isDark ? const Color(0xFFF5822B) : const Color(0xFFF5822B);
    final secondary = isDark
        ? const Color(0xFF1FA85C)
        : const Color(0xFFFFD84D);
    final textPrimary = isDark
        ? const Color(0xFFDAE2FD)
        : const Color(0xFF141210);
    final textMuted = isDark
        ? const Color(0xFFCBC3D7)
        : const Color(0xFF4A453E);

    final currentOptions = _currentOptions;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: bgStart),
        child: Stack(
          children: [
            // ── Dynamic Aurora Glow Orb ─────────────────────────────────────
            AnimatedBuilder(
              animation: _auroraController,
              builder: (context, child) {
                final scale = 1.0 + (_auroraController.value * 0.15);
                final rotation = _auroraController.value * 0.2;
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.15,
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Container(
                        height: 320,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Custom Top Header Bar ─────────────────────────────────
                  _buildTopBar(textPrimary, primary),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          // ── Social Photo Preview Container ─────────────────
                          Center(
                            child: _buildPhotoMockup(
                              surface,
                              secondary,
                              textPrimary,
                              isDark,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Heading & Tagline ──────────────────────────────
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'turning chaos into poetry ✨',
                                  textAlign: TextAlign.center,
                                  style: AppFonts.heading(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'generating emotional damage in 3... 2...',
                                  textAlign: TextAlign.center,
                                  style: AppFonts.body(
                                    fontSize: 14,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Vibe Selectors (Horizontal list) ───────────────
                          Text(
                            'VIBE CHECK',
                            style: AppFonts.heading(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildVibeSelectors(
                            primary,
                            textPrimary,
                            textMuted,
                            surface,
                          ),

                          const SizedBox(height: 24),

                          // ── Bento-ish Caption Selection Bento Grid ────────
                          Column(
                            children: List.generate(currentOptions.length, (
                              index,
                            ) {
                              final item = currentOptions[index];
                              final isSelected = _selectedOptionIndex == index;
                              final optionText = item['text'] as String;
                              final optionTags = List<String>.from(
                                item['tags'] ?? [],
                              );

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedOptionIndex = index;
                                    _editorController.text =
                                        '$optionText ${optionTags.join(" ")} ✨';
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primary.withValues(alpha: 0.15)
                                        : surface.withValues(
                                            alpha: isDark ? 0.45 : 0.75,
                                          ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? primary
                                          : (isDark
                                                ? Colors.white10
                                                : Colors.black12),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.1),
                                          blurRadius: 0,
                                        ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 32,
                                            ),
                                            child: Text(
                                              optionText,
                                              style: AppFonts.heading(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: textPrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: optionTags.map((tag) {
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: primary.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  tag,
                                                  style: AppFonts.body(
                                                    fontSize: 11,
                                                    color: primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.content_copy_rounded,
                                            size: 18,
                                            color: isSelected
                                                ? primary
                                                : textMuted,
                                          ),
                                          onPressed: () =>
                                              _copyToClipboard(optionText),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          tooltip: 'Copy',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          // ── Suggested Audio & Interactive Editor Panel ─────
                          _buildEditorPanel(
                            surface,
                            primary,
                            secondary,
                            textPrimary,
                            textMuted,
                            isDark,
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Custom Floating Bottom Navigation Bar ────────────────────────
            _buildFloatingNavbar(surface, primary, secondary, textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textPrimary, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
          Text(
            'trip.mate',
            style: AppFonts.heading(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          Row(
            children: [
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: textPrimary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                  tooltip: 'Toggle Theme',
                ),
              IconButton(
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.auto_awesome,
                        color: textPrimary,
                        size: 24,
                      ),
                onPressed: _isGenerating ? null : _generate,
                tooltip: 'ai.generate_captions'.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoMockup(
    Color surface,
    Color secondary,
    Color textPrimary,
    bool isDark,
  ) {
    return Container(
      width: 240,
      height: 300,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.3 : 0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 0,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          // Simulated Travel Photo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                'https://images.unsplash.com/photo-1540959733332-eab4deceeaf7?auto=format&fit=crop&q=80&w=600',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Glowing Vibe Indicator Badge
          Positioned(
            bottom: 12,
            left: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: secondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Analyzing Vibes...',
                        style: AppFonts.body(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeSelectors(
    Color primary,
    Color textPrimary,
    Color textMuted,
    Color surface,
  ) {
    final isDark = widget.isDarkMode;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _vibes.map((vibe) {
          final isSelected = _selectedVibe == vibe;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVibe = vibe;
                _selectedOptionIndex = 0;
                final firstOpt = _currentOptions.first;
                _editorController.text =
                    '${firstOpt["text"]} ${List<String>.from(firstOpt["tags"] ?? []).join(" ")} ✨';
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withValues(alpha: 0.15)
                    : surface.withValues(alpha: isDark ? 0.45 : 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : (isDark ? Colors.white10 : Colors.black12),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: primary.withValues(alpha: 0.2),
                      blurRadius: 0,
                    ),
                ],
              ),
              child: Text(
                vibe,
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primary : textMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEditorPanel(
    Color surface,
    Color primary,
    Color secondary,
    Color textPrimary,
    Color textMuted,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Audio Suggestion row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        color: secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Suggested Audio',
                        style: AppFonts.heading(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '"Pink + White" - Frank Ocean',
                    style: AppFonts.body(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: Colors.white10),
              const SizedBox(height: 14),

              // Textarea Editor
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  TextField(
                    controller: _editorController,
                    maxLines: 3,
                    style: AppFonts.body(
                      fontSize: 15,
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Edit your caption...',
                      hintStyle: AppFonts.body(
                        color: textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Trigger mock generation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vibes re-analyzed! Fresh poetry cooked up. 🍳',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavbar(
    Color surface,
    Color primary,
    Color secondary,
    Color textMuted,
  ) {
    final isDark = widget.isDarkMode;
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 0,
                offset: const Offset(0, 10),
              ),
              if (isDark)
                BoxShadow(
                  color: secondary.withValues(alpha: 0.1),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavbarItem(
                Icons.explore_outlined,
                false,
                textMuted,
                secondary,
              ),
              _buildNavbarItem(
                Icons.group_outlined,
                false,
                textMuted,
                secondary,
              ),
              _buildNavbarItem(
                Icons.add_circle_rounded,
                true,
                textMuted,
                secondary,
              ),
              _buildNavbarItem(
                Icons.chat_bubble_outline_rounded,
                false,
                textMuted,
                secondary,
              ),
              _buildNavbarItem(
                Icons.person_outline_rounded,
                false,
                textMuted,
                secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbarItem(
    IconData icon,
    bool isActive,
    Color textMuted,
    Color secondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isActive
          ? BoxDecoration(
              color: secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: secondary.withValues(alpha: 0.25),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: Icon(icon, color: isActive ? secondary : textMuted, size: 24),
    );
  }
}
