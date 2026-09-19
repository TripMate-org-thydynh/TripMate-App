import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';

import '../../../core/app_messenger.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/gen_z_tokens.dart';
import '../../gamification/data/games_repository.dart';
import '../../premium/presentation/paywall_sheet.dart';
import '../data/ai_repository.dart';

class MateyAiEmotionalChaosScreen extends ConsumerStatefulWidget {
  final bool? isDarkMode;
  final VoidCallback? onThemeToggle;

  const MateyAiEmotionalChaosScreen({
    super.key,
    this.isDarkMode,
    this.onThemeToggle,
  });

  @override
  ConsumerState<MateyAiEmotionalChaosScreen> createState() =>
      _MateyAiEmotionalChaosScreenState();
}

class _MateyAiEmotionalChaosScreenState
    extends ConsumerState<MateyAiEmotionalChaosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _typingController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool get _isDarkMode =>
      widget.isDarkMode ?? (Theme.of(context).brightness == Brightness.dark);

  final List<Map<String, dynamic>> _messages = [];

  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _typingController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isThinking) return;
    setState(() {
      _messages.add({
        'type': 'user',
        'text': text,
        'time': 'ai.just_now'.tr(),
      });
      _textController.clear();
      _isThinking = true;
    });
    _scrollToBottom();

    try {
      final tripId = ref.read(activeTripIdProvider);
      final reply = await ref
          .read(mateyChatProvider)
          .ask(prompt: text, tripId: tripId);
      if (!mounted) return;
      setState(() {
        _messages.add({
          'type': 'ai',
          'text': reply,
          'time': 'ai.just_now'.tr(),
          'likes': 0,
        });
        _isThinking = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isThinking = false);
      if (await PaywallSheet.maybeShow(context, e)) return;
      if (!mounted) return;
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

  void _showPromptPicker(BuildContext context) {
    final isDark = _isDarkMode;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = Theme.of(context).colorScheme.primary;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final promptsAsync = ref.watch(suggestedPromptsProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ai.suggested_prompts_title'.tr(),
                          style: AppFonts.heading(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: ink,
                          ),
                        ),
                        IconButton(
                          icon: Icon(PhosphorIcons.x(), color: ink, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    promptsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'errors.load_failed'.tr(),
                            style: AppFonts.body(
                              fontSize: 13,
                              color: danger,
                            ),
                          ),
                        ),
                      ),
                      data: (prompts) {
                        if (prompts.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'ai.prompts_empty'.tr(),
                                style: AppFonts.body(
                                  fontSize: 13,
                                  color: inkSoft,
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: prompts.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final p = prompts[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  GenZTokens.radiusButton,
                                ),
                                side: BorderSide(color: line),
                              ),
                              leading: Icon(
                                PhosphorIcons.lightbulb(
                                  PhosphorIconsStyle.fill,
                                ),
                                color: accent,
                                size: 20,
                              ),
                              title: Text(
                                p.title,
                                style: AppFonts.heading(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: ink,
                                ),
                              ),
                              subtitle: Text(
                                p.prompt,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.body(
                                  fontSize: 13,
                                  color: inkSoft,
                                ),
                              ),
                              onTap: () {
                                _textController.text = p.prompt;
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    final accent = Theme.of(context).colorScheme.primary;
    final accentSoft =
        isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    final backgroundColor = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final textPrimary = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final textSecondary = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(surface, line, textPrimary, isDark),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: GenZTokens.space4,
                    ),
                    child: Column(
                      children: [
                        _buildOrbHero(
                          accent,
                          accentSoft,
                          textPrimary,
                          line,
                        ),

                        const SizedBox(height: 16),

                        if (_messages.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'ai.matey_intro'.tr(),
                              textAlign: TextAlign.center,
                              style: AppFonts.body(
                                fontSize: 15,
                                color: textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),

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
                                  surface,
                                  line,
                                  textPrimary,
                                  textSecondary,
                                );
                              case 'user':
                                return _buildUserBubble(
                                  msg,
                                  accentSoft,
                                  line,
                                  textPrimary,
                                  textSecondary,
                                );
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),

                        if (_isThinking)
                          _buildTypingIndicator(surface, line, accent),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 96,
            left: 20,
            right: 20,
            child: _buildMessageInput(
              surface,
              line,
              accent,
              onAccent,
              textPrimary,
              textSecondary,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    Color surface,
    Color line,
    Color textPrimary,
    bool isDark,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
              color: textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            tooltip: 'common.back'.tr(),
          ),
          Text(
            'trip.mate',
            style: AppFonts.heading(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
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
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildOrbHero(
    Color accent,
    Color accentSoft,
    Color textPrimary,
    Color line,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentSoft,
            border: Border.all(
              color: line,
              width: GenZTokens.borderWidthThin,
            ),
          ),
          child: Center(
            child: Icon(
              PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
              size: 44,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ai.matey_greeting'.tr(),
          style: AppFonts.heading(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAiBubble(
    Map<String, dynamic> msg,
    Color surface,
    Color line,
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
              padding: const EdgeInsets.all(GenZTokens.space4),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(GenZTokens.radiusCard),
                  topRight: Radius.circular(GenZTokens.radiusCard),
                  bottomRight: Radius.circular(GenZTokens.radiusCard),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Text(
                msg['text'],
                style: AppFonts.body(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                msg['time'] as String,
                style: AppFonts.body(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(
    Map<String, dynamic> msg,
    Color accentSoft,
    Color line,
    Color textPrimary,
    Color textSecondary,
  ) {
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
            Container(
              padding: const EdgeInsets.all(GenZTokens.space4),
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(GenZTokens.radiusCard),
                  topRight: Radius.circular(GenZTokens.radiusCard),
                  bottomLeft: Radius.circular(GenZTokens.radiusCard),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              child: Text(
                msg['text'],
                style: AppFonts.body(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg['time'] as String,
              style: AppFonts.body(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(
    Color surface,
    Color line,
    Color accent,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
          border: Border.all(
            color: line,
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
                    color: accent.withValues(alpha: wave.clamp(0.2, 1.0)),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    Color surface,
    Color line,
    Color accent,
    Color onAccent,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
        boxShadow: GenZTokens.hardShadow(textPrimary, isDark),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              PhosphorIcons.lightbulb(PhosphorIconsStyle.bold),
              color: textSecondary,
            ),
            onPressed: () => _showPromptPicker(context),
            tooltip: 'ai.suggested_prompts_title'.tr(),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              style: AppFonts.body(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'ai.matey_hint'.tr(),
                hintStyle: AppFonts.body(
                  fontSize: 15,
                  color: textSecondary.withValues(alpha: 0.6),
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
              color: accent,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                color: onAccent,
                size: 18,
              ),
              onPressed: _sendMessage,
              tooltip: 'ai.send'.tr(),
            ),
          ),
        ],
      ),
    );
  }
}
