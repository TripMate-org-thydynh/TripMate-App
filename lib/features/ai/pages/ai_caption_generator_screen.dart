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
    extends ConsumerState<AICaptionGeneratorScreen> {
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
  void dispose() {
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
    showGlobalSnack('common.copied'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.isDarkMode || Theme.of(context).brightness == Brightness.dark;

    // Theme Tokens
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textMuted = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    final currentOptions = _currentOptions;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(textPrimary, isDark),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: GenZTokens.space4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    Center(
                      child: _buildPhotoMockup(
                        surface,
                        textPrimary,
                        accent,
                        line,
                        fill,
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
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ai.caption_loading'.tr(),
                            textAlign: TextAlign.center,
                            style: AppFonts.body(
                              fontSize: 15,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'ai.vibe_check'.tr(),
                      style: AppFonts.heading(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildVibeSelectors(
                      accent,
                      accentSoft,
                      textMuted,
                      fill,
                      line,
                    ),

                    const SizedBox(height: 24),

                    if (currentOptions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(GenZTokens.space5),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(
                            GenZTokens.radiusCard,
                          ),
                          border: Border.all(
                            color: line,
                            width: GenZTokens.borderWidthThin,
                          ),
                        ),
                        child: Text(
                          'ai.caption_empty'.tr(),
                          textAlign: TextAlign.center,
                          style: AppFonts.body(
                            fontSize: 15,
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
                            padding: const EdgeInsets.all(GenZTokens.space4),
                            decoration: BoxDecoration(
                              color: isSelected ? accentSoft : surface,
                              borderRadius: BorderRadius.circular(
                                GenZTokens.radiusCard,
                              ),
                              border: Border.all(
                                color: isSelected ? accent : line,
                                width: isSelected
                                    ? GenZTokens.borderWidth
                                    : GenZTokens.borderWidthThin,
                              ),
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
                                        style: AppFonts.body(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
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
                                              color: fill,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    GenZTokens.radiusPill,
                                                  ),
                                            ),
                                            child: Text(
                                              tag,
                                              style: AppFonts.body(
                                                fontSize: 12,
                                                color: textMuted,
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
                                          ? accent
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
                      accent,
                      onAccent,
                      textPrimary,
                      textMuted,
                      line,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textPrimary, bool isDark) {
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
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
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
    Color textPrimary,
    Color accent,
    Color line,
    Color fill,
    bool isDark,
  ) {
    return Container(
      width: 240,
      height: 300,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
                      color: fill,
                      alignment: Alignment.center,
                      child: Icon(
                        PhosphorIcons.image(),
                        size: 40,
                        color: textPrimary.withValues(alpha: 0.3),
                      ),
                    );
                  }
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(color: fill),
                  );
                },
              ),
            ),
          ),

          if (_isGenerating)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(
                    GenZTokens.radiusPill,
                  ),
                  border: Border.all(
                    color: line,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                      color: accent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ai.analyzing'.tr(),
                      style: AppFonts.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVibeSelectors(
    Color accent,
    Color accentSoft,
    Color textMuted,
    Color fill,
    Color line,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected ? accentSoft : fill,
                borderRadius: BorderRadius.circular(
                  GenZTokens.radiusPill,
                ),
                border: Border.all(
                  color: isSelected ? accent : line,
                  width: isSelected
                      ? GenZTokens.borderWidth
                      : GenZTokens.borderWidthThin,
                ),
              ),
              child: Text(
                vibeKey.tr(),
                style: AppFonts.body(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? accent : textMuted,
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
    Color accent,
    Color onAccent,
    Color textPrimary,
    Color textMuted,
    Color line,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(
          color: line,
          width: GenZTokens.borderWidthThin,
        ),
      ),
      padding: const EdgeInsets.all(GenZTokens.space4),
      child: Stack(
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
                fontSize: 15,
                color: textMuted.withValues(alpha: 0.6),
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
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.arrowsClockwise(),
                  color: onAccent,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
