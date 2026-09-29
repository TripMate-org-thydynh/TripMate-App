import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../premium/presentation/paywall_sheet.dart';
import '../../../ai/data/ai_repository.dart';
import '../../../gamification/data/games_repository.dart';
import '../widgets/add_to_itinerary_sheet.dart';

/// Vibe Match — hỏi AI xem một địa điểm có hợp gu cả nhóm không.
///
/// Trước đây màn này chạy một màn "đang phân tích" giả với các dòng
/// "Minh Nhật is mapping coordinates...", "Thảo Ly is checking aesthetic
/// ratings..." — những người không tồn tại — rồi hiện kết quả in cứng
/// "The Hill Station · Old Town, Hội An · 98%", và nút thêm vào lịch trình chỉ
/// báo thành công chứ không lưu gì. Nay gọi AI thật với địa điểm người dùng
/// nhập, và thêm vào lịch trình là ghi thật.
class AIVibeMatchScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const AIVibeMatchScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  ConsumerState<AIVibeMatchScreen> createState() => _AIVibeMatchScreenState();
}

class _AIVibeMatchScreenState extends ConsumerState<AIVibeMatchScreen> {
  final TextEditingController _input = TextEditingController();
  VibeMatch? _result;
  bool _loading = false;
  Object? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final prompt = _input.text.trim();
    if (prompt.isEmpty || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ref
          .read(vibeMatchServiceProvider)
          .match(prompt: prompt, tripId: ref.read(activeTripIdProvider));
      if (!mounted) return;
      setState(() {
        _result = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
      // Hết lượt AI trong tháng là chuyện của gói cước, không phải lỗi kỹ
      // thuật — mở paywall thay vì để màn báo lỗi chung.
      if (await PaywallSheet.maybeShow(context, e) && mounted) {
        setState(() => _error = null);
      }
    }
  }

  void _addToItinerary(VibeMatch m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToItinerarySheet(
        placeName: m.locationName.isEmpty ? _input.text.trim() : m.locationName,
        placeAddress: m.locationAddress,
        isDarkMode: widget.isDarkMode,
        onAdded: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final cream = isDark ? GenZTokens.creamDark : GenZTokens.cream;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'ai.vibe_title'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GenZTokens.space4),
        children: [
          _searchBox(isDark),
          const SizedBox(height: GenZTokens.space4),
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? GenZTokens.accentDark : GenZTokens.accent,
                  ),
                ),
              ),
            )
          else if (_error != null)
            AppErrorState(isDark: isDark, error: _error, onRetry: _run)
          else if (_result != null)
            _resultCard(isDark, _result!)
          else
            AppEmptyState(
              isDark: isDark,
              icon: PhosphorIcons.heart(),
              title: 'ai.vibe_title'.tr(),
              body: 'ai.vibe_hint'.tr(),
            ),
        ],
      ),
    );
  }

  Widget _searchBox(bool isDark) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _input,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _run(),
            style: AppFonts.body(fontSize: 15, color: ink),
            decoration: InputDecoration(
              hintText: 'ai.vibe_placeholder'.tr(),
              hintStyle: AppFonts.body(fontSize: 15, color: inkSoft),
              filled: true,
              fillColor: surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: GenZTokens.space4,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                borderSide: BorderSide(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                borderSide: BorderSide(
                  color: line,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                borderSide: BorderSide(
                  color: accent,
                  width: GenZTokens.borderWidthFocus,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: GenZTokens.space3),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: _loading ? null : _run,
            style: OutlinedButton.styleFrom(
              backgroundColor: fill,
              foregroundColor: ink,
              side: BorderSide(color: line, width: GenZTokens.borderWidthThin),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            child: Icon(
              PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
              size: 20,
              color: ink,
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultCard(bool isDark, VibeMatch m) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;
    final pct = m.matchPercentage.clamp(0, 100);

    final statusColor = pct >= 80
        ? (isDark ? GenZTokens.successDark : GenZTokens.success)
        : pct >= 60
        ? (isDark ? GenZTokens.warningDark : GenZTokens.warning)
        : (isDark ? GenZTokens.dangerDark : GenZTokens.danger);

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.locationName.isEmpty
                          ? _input.text.trim()
                          : m.locationName,
                      style: AppFonts.heading(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    if (m.locationAddress.isNotEmpty) ...[
                      const SizedBox(height: GenZTokens.space1),
                      Text(
                        m.locationAddress,
                        style: AppFonts.body(fontSize: 13, color: inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: GenZTokens.space3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(GenZTokens.radiusPill),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  '$pct%',
                  style: AppFonts.heading(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (m.vibeTags.isNotEmpty) ...[
            const SizedBox(height: GenZTokens.space4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in m.vibeTags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(
                        GenZTokens.radiusPill,
                      ),
                      border: Border.all(
                        color: line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Text(
                      t,
                      style: AppFonts.body(fontSize: 12, color: inkSoft),
                    ),
                  ),
              ],
            ),
          ],
          if (m.analysis.isNotEmpty) ...[
            const SizedBox(height: GenZTokens.space4),
            Text(
              m.analysis,
              style: AppFonts.body(fontSize: 15, color: ink, height: 1.45),
            ),
          ],
          const SizedBox(height: GenZTokens.space5),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _addToItinerary(m),
              icon: Icon(PhosphorIcons.plus(), size: 18, color: onAccent),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              label: Text(
                'ai.vibe_add'.tr(),
                style: AppFonts.heading(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: onAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
