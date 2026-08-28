import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/api_service.dart';
import '../../../../core/widgets/gen_z_widgets.dart';

class DailyRecapWidget extends StatefulWidget {
  const DailyRecapWidget({super.key});

  @override
  State<DailyRecapWidget> createState() => _DailyRecapWidgetState();
}

class _DailyRecapWidgetState extends State<DailyRecapWidget> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    final data = await ApiService.get('/dashboard/recent-activities');
    if (mounted) {
      if (data != null && data['activities'] != null) {
        final raw = data['activities'] as List<dynamic>;
        final colors = [
          0xFFF5822B,
          0xFF3D8BFF,
          0xFF1FA85C,
          0xFFFFD84D,
          0xFF8B4DE8,
          0xFFD8422B,
        ];
        setState(() {
          _activities = raw.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value as Map<String, dynamic>;
            return {
              'title': _activityTitle(a['type'] as String? ?? ''),
              'time': _formatTime(a['createdAt'] as String? ?? ''),
              'chaosVibe': _activityVibe(a['type'] as String? ?? ''),
              'details': a['description'] as String? ?? '',
              'colorHex': colors[i % colors.length],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        // Chưa có hoạt động nào → danh sách rỗng (widget đã có empty state).
        // Trước đây nhánh này đổ vào 3 hoạt động bịa ("Pranked Phú Khang",
        // "Minh Nhật devoured 5 plates of skewers"...) cho mọi tài khoản.
        setState(() {
          _activities = const [];
          _isLoading = false;
        });
      }
    }
  }

  String _activityTitle(String type) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return 'dashboard.act_expense'.tr();
      case 'MOMENT_SHARED':
        return 'dashboard.act_moment'.tr();
      case 'GAME_STARTED':
        return 'dashboard.act_game'.tr();
      case 'CHAT_SENT':
        return 'dashboard.act_chat'.tr();
      case 'ITINERARY_ADDED':
        return 'dashboard.act_itinerary'.tr();
      case 'MEMBER_JOINED':
        return 'dashboard.act_member'.tr();
      default:
        return 'dashboard.act_default'.tr();
    }
  }

  String _activityVibe(String type) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return 'Squad spending update';
      case 'MOMENT_SHARED':
        return 'New memory captured';
      case 'GAME_STARTED':
        return 'Let the chaos begin';
      case 'CHAT_SENT':
        return 'Squad conversation';
      case 'ITINERARY_ADDED':
        return 'Plan updated';
      default:
        return 'Squad activity';
    }
  }

  String _formatTime(String isoStr) {
    try {
      final dt = DateTime.parse(isoStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'dashboard.recap_title'.tr(),
            style: AppFonts.heading(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.5,
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : _activities.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          GenZTokens.radiusCard,
                        ),
                        color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
                        border: Border.all(
                          color: ink,
                          width: GenZTokens.borderWidthThin,
                        ),
                        boxShadow: [
                          BoxShadow(color: ink, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history_toggle_off,
                            size: 38,
                            color: GenZTokens.orange,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'dashboard.recap_empty_title'.tr(),
                                  style: AppFonts.heading(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'dashboard.recap_empty_sub'.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                    color: isDark
                                        ? GenZTokens.inkSoftDark
                                        : GenZTokens.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final item = _activities[index];
                        final themeColor = Color(item['colorHex'] as int);

                        return Container(
                          width: 270,
                          margin: const EdgeInsets.only(right: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              GenZTokens.radiusCard,
                            ),
                            color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
                            border: Border.all(
                              color: ink,
                              width: GenZTokens.borderWidthThin,
                            ),
                            boxShadow: [
                              BoxShadow(color: ink, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  PillTag(
                                    text: item['title'] as String,
                                    color: themeColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      (item['time'] as String).toUpperCase(),
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: AppFonts.mono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? GenZTokens.inkSoftDark
                                            : GenZTokens.inkSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['chaosVibe'] as String,
                                style: AppFonts.heading(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  item['details'] as String,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
