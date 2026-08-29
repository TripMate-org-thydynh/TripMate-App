import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../../../core/widgets/state_views.dart';
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

    return Scaffold(
      backgroundColor: isDark ? GenZTokens.creamDark : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: ink),
        title: Text(
          'ai.vibe_title'.tr(),
          style: AppFonts.heading(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GenZTokens.space5),
        children: [
          _searchBox(isDark),
          const SizedBox(height: GenZTokens.space5),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_error != null)
            AppErrorState(
              isDark: isDark,
              error: _error,
              onRetry: _run,
            )
          else if (_result != null)
            _resultCard(isDark, _result!)
          else
            AppEmptyState(
              isDark: isDark,
              icon: Icons.favorite_border,
              title: 'ai.vibe_title'.tr(),
              body: 'ai.vibe_hint'.tr(),
            ),
        ],
      ),
    );
  }

  Widget _searchBox(bool isDark) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _input,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _run(),
            style: AppFonts.body(fontSize: 14, color: ink),
            decoration: InputDecoration(
              hintText: 'ai.vibe_placeholder'.tr(),
              filled: true,
              fillColor: surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: GenZTokens.space4,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                borderSide: BorderSide(
                  color: ink,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                borderSide: BorderSide(
                  color: ink,
                  width: GenZTokens.borderWidthThin,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: GenZTokens.space3),
        ElevatedButton(
          onPressed: _loading ? null : _run,
          style: ElevatedButton.styleFrom(
            backgroundColor: GenZTokens.pink,
            foregroundColor: GenZTokens.ink,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            elevation: 0,
            side: BorderSide(color: ink, width: GenZTokens.borderWidth),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
            ),
          ),
          child: const Icon(Icons.auto_awesome, size: 20),
        ),
      ],
    );
  }

  Widget _resultCard(bool isDark, VibeMatch m) {
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final pct = m.matchPercentage.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(GenZTokens.space5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
        border: Border.all(color: ink, width: GenZTokens.borderWidth),
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
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                    ),
                    if (m.locationAddress.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        m.locationAddress,
                        style: AppFonts.body(fontSize: 12.5, color: inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: GenZTokens.space3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  // Hợp gu thì xanh, tàm tạm thì vàng, lệch thì cam.
                  color: pct >= 80
                      ? GenZTokens.green
                      : pct >= 60
                      ? GenZTokens.yellow
                      : GenZTokens.orange,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: GenZTokens.ink,
                    width: GenZTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  '$pct%',
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: GenZTokens.ink,
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
                      color: GenZTokens.lilac,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: GenZTokens.ink,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Text(
                      t,
                      style: AppFonts.body(
                        fontSize: 12,
                        color: GenZTokens.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (m.analysis.isNotEmpty) ...[
            const SizedBox(height: GenZTokens.space4),
            Text(
              m.analysis,
              style: AppFonts.body(fontSize: 14, color: ink, height: 1.45),
            ),
          ],
          const SizedBox(height: GenZTokens.space5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addToItinerary(m),
              icon: const Icon(Icons.add, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: GenZTokens.yellow,
                foregroundColor: GenZTokens.ink,
                elevation: 0,
                side: BorderSide(color: ink, width: GenZTokens.borderWidth),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              label: Text(
                'ai.vibe_add'.tr(),
                style: AppFonts.heading(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: GenZTokens.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
