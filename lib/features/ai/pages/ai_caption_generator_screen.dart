import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../gamification/data/games_repository.dart';
import '../data/ai_repository.dart';
import '../../../core/app_messenger.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../moments/data/moments_repository.dart';

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

class _AICaptionGeneratorScreenState
    extends ConsumerState<AICaptionGeneratorScreen>
    with TickerProviderStateMixin {
  late AnimationController _auroraController;
  late AnimationController _pulseController;

  String _selectedVibe = 'Chaotic Gen Z';
  int _selectedOptionIndex = 0;
  final TextEditingController _editorController = TextEditingController();

  final List<String> _vibes = [
    'Funny',
    'Chaotic Gen Z',
    'Cinematic',
    'Aesthetic',
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

  /// Caption cho vibe dang chon — chi co khi AI da sinh.
  ///
  /// Truoc day man nay tra ve mot danh muc caption tieng Anh viet san
  /// ("financially ruined. emotionally healed.") nen nhin nhu AI da chay
  /// trong khi chua goi gi ca.
  List<Map<String, dynamic>> get _currentOptions =>
      _aiOptions[_selectedVibe] ?? const [];

  /// Gọi AI sinh caption thật cho vibe đang chọn.
  ///
  /// Trước đây màn "AI Caption Studio" chỉ đọc một danh mục viết sẵn trong
  /// app — không có lời gọi AI nào, dù tên màn nói ngược lại.
  Future<void> _generate() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final tripId = ref.read(activeTripIdProvider);
      final lines =
          (await ref
                  .read(mateyChatProvider)
                  .captions(
                    prompt:
                        'Ảnh du lịch theo vibe "$_selectedVibe", kèm 2 hashtag mỗi caption.',
                    tripId: tripId,
                  ))
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
              'common.copied'.tr(),
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
    final bgStart = Theme.of(context).scaffoldBackgroundColor;
    final surface = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    // Accent theo theme dang chon: truoc day hai nhanh ternary y het nhau
    // va viet cung accent cua preset *grape*, nen doi theme khong an.
    final primary = Theme.of(context).colorScheme.primary;
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
                              primary,
                              isDark,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Heading & Tagline ──────────────────────────────
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'ai.caption_tagline'.tr(),
                                  textAlign: TextAlign.center,
                                  style: AppFonts.heading(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ai.caption_loading'.tr(),
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
                            'ai.vibe_check'.tr(),
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
                          if (currentOptions.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surface.withValues(
                                  alpha: isDark ? 0.45 : 0.75,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                ),
                              ),
                              child: Text(
                                'ai.caption_empty'.tr(),
                                textAlign: TextAlign.center,
                                style: AppFonts.body(
                                  fontSize: 14,
                                  color: textMuted,
                                  height: 1.45,
                                ),
                              ),
                            ),
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

                          // ── Interactive Editor Panel ──────────────────────
                          _buildEditorPanel(
                            surface,
                            primary,
                            secondary,
                            textPrimary,
                            textMuted,
                            isDark,
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                  tooltip: 'theme.toggle'.tr(),
                ),
              IconButton(
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.auto_awesome, color: textPrimary, size: 24),
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
    Color primary,
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
          // Anh xem truoc: lay khoanh khac moi nhat cua chinh user.
          // Truoc day day la mot URL Unsplash in cung da 404, Flutter ve nguyen
          // hop loi do kem ca duong dan len giua man.
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Consumer(
                builder: (context, ref, _) {
                  final url = ref
                      .watch(recentMomentsProvider)
                      .maybeWhen(
                        data: (m) => m.isEmpty ? null : m.first.posterUrl,
                        orElse: () => null,
                      );
                  if (url == null || url.isEmpty) {
                    return Container(
                      color: primary.withValues(alpha: 0.15),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.photo_camera_back_outlined,
                        size: 40,
                        color: primary,
                      ),
                    );
                  }
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) =>
                        Container(color: primary.withValues(alpha: 0.15)),
                  );
                },
              ),
            ),
          ),

          // Glowing Vibe Indicator Badge
          if (_isGenerating)
            Positioned(
              bottom: 12,
              left: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
                        'ai.analyzing'.tr(),
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
                final opts = _currentOptions;
                _editorController.text = opts.isEmpty
                    ? ''
                    : '${opts.first["text"]} ${List<String>.from(opts.first["tags"] ?? []).join(" ")} ✨';
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
                    hintText: 'ai.caption_edit_hint'.tr(),
                    hintStyle: AppFonts.body(
                      color: textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                GestureDetector(
                  // Truoc day nut nay chi hien thong bao "da nghi caption moi"
                  // ma khong he goi AI. Nay chay dung ham sinh caption that.
                  onTap: _isGenerating ? null : _generate,
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
    );
  }
}
