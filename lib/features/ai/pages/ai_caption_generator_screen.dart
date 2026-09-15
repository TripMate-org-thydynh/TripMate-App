import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../gamification/data/games_repository.dart';
import '../../moments/data/moments_repository.dart';
import '../../premium/presentation/paywall_sheet.dart';
import '../data/ai_repository.dart';

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

  String _selectedVibeKey = 'ai.vibe_chaotic_genz';
  int _selectedOptionIndex = 0;
  final TextEditingController _editorController = TextEditingController();

  final List<String> _vibes = const [
    'ai.vibe_chaotic_genz',
    'ai.vibe_funny',
    'ai.vibe_cinematic',
    'ai.vibe_aesthetic',
  ];

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

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

  /// Caption cho vibe đang chọn — chỉ có khi AI đã sinh.
  List<Map<String, dynamic>> get _currentOptions =>
      _aiOptions[_selectedVibeKey] ?? const [];

  /// Gọi AI sinh caption thật cho vibe đang chọn.
  Future<void> _generate() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    try {
      final tripId = ref.read(activeTripIdProvider);
      final vibeName = _selectedVibeKey.tr();
      final lines =
          (await ref
                  .read(mateyChatProvider)
                  .captions(
                    prompt:
                        'Ảnh du lịch theo vibe "$vibeName", kèm 2 hashtag mỗi caption.',
                    tripId: tripId,
                  ))
              .take(5)
              .toList();
      if (!mounted) return;
      setState(() {
        _aiOptions[_selectedVibeKey] = lines
            .map((l) => {'text': l, 'tags': const <String>[]})
            .toList();
        _selectedOptionIndex = 0;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
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
            Icon(
              PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              color: GenZTokens.paper,
            ),
            const SizedBox(width: 8),
            Text(
              'common.copied'.tr(),
              style: AppFonts.body(
                fontWeight: FontWeight.bold,
                color: GenZTokens.paper,
              ),
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
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    // Theme Tokens
    final bgStart = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final primary = isDark ? GenZTokens.lilac : GenZTokens.purple;
    final secondary = GenZTokens.yellow;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textMuted = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final border = textPrimary;

    final currentOptions = _currentOptions;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: bgStart),
        child: Stack(
          children: [
            // Dynamic Aurora Glow Orb
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
                        decoration: const BoxDecoration(
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
                  _buildTopBar(textPrimary, primary, isDark),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          Center(
                            child: _buildPhotoMockup(
                              surface,
                              secondary,
                              textPrimary,
                              primary,
                              border,
                              isDark,
                            ),
                          ),

                          const SizedBox(height: 24),

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

                          Text(
                            'ai.vibe_check'.tr(),
                            style: AppFonts.heading(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildVibeSelectors(
                            primary,
                            textPrimary,
                            textMuted,
                            surface,
                            border,
                            isDark,
                          ),

                          const SizedBox(height: 24),

                          if (currentOptions.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: border.withValues(alpha: 0.25),
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
                                    final tagsStr = optionTags.isEmpty
                                        ? ''
                                        : ' ${optionTags.join(" ")}';
                                    _editorController.text =
                                        '$optionText$tagsStr';
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primary.withValues(alpha: 0.15)
                                        : surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? primary
                                          : border.withValues(alpha: 0.25),
                                      width: isSelected
                                          ? GenZTokens.borderWidth
                                          : GenZTokens.borderWidthThin,
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
                                          if (optionTags.isNotEmpty) ...[
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
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: AppFonts.body(
                                                      fontSize: 12,
                                                      color: primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: Icon(
                                            PhosphorIcons.copy(),
                                            size: 18,
                                            color: isSelected
                                                ? primary
                                                : textMuted,
                                          ),
                                          onPressed: () =>
                                              _copyToClipboard(optionText),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          tooltip: 'common.copy'.tr(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          _buildEditorPanel(
                            surface,
                            primary,
                            secondary,
                            textPrimary,
                            textMuted,
                            border,
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

  Widget _buildTopBar(Color textPrimary, Color primary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'common.back'.tr(),
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
                    isDark
                        ? PhosphorIcons.sun(PhosphorIconsStyle.bold)
                        : PhosphorIcons.moon(PhosphorIconsStyle.bold),
                    color: textPrimary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                  tooltip: isDark
                      ? 'theme.switch_light'.tr()
                      : 'theme.switch_dark'.tr(),
                ),
              IconButton(
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
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
    Color primary,
    Color border,
    bool isDark,
  ) {
    return Container(
      width: 240,
      height: 300,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: border,
          width: GenZTokens.borderWidth,
        ),
        boxShadow: GenZTokens.hardShadow(border),
      ),
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
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
                        PhosphorIcons.image(),
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
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(
                      color: border,
                      width: GenZTokens.borderWidthThin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                        color: GenZTokens.purple,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ai.analyzing'.tr(),
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
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
    Color border,
    bool isDark,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _vibes.map((vibeKey) {
          final isSelected = _selectedVibeKey == vibeKey;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVibeKey = vibeKey;
                _selectedOptionIndex = 0;
                final opts = _currentOptions;
                _editorController.text = opts.isEmpty
                    ? ''
                    : '${opts.first["text"]} ${List<String>.from(opts.first["tags"] ?? []).join(" ")}';
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withValues(alpha: 0.2)
                    : surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primary : border.withValues(alpha: 0.3),
                  width: isSelected
                      ? GenZTokens.borderWidth
                      : GenZTokens.borderWidthThin,
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
                vibeKey.tr(),
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
    Color border,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: border,
            width: GenZTokens.borderWidth,
          ),
          boxShadow: GenZTokens.hardShadow(border),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 14),
            Divider(color: textMuted.withValues(alpha: 0.2)),
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
                Semantics(
                  button: true,
                  label: 'common.refresh'.tr(),
                  child: GestureDetector(
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
                      child: Icon(
                        PhosphorIcons.arrowsClockwise(),
                        color: GenZTokens.paper,
                        size: 20,
                      ),
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
