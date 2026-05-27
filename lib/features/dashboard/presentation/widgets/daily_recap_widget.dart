import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/api_service.dart';
import '../../../../core/theme/theme.dart';

class DailyRecapWidget extends StatefulWidget {
  const DailyRecapWidget({super.key});

  @override
  State<DailyRecapWidget> createState() => _DailyRecapWidgetState();
}

class _DailyRecapWidgetState extends State<DailyRecapWidget> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  static const _fallbackActivities = [
    {
      "title": "Day 1 Summary",
      "time": "Yesterday, 2:00 AM",
      "chaosVibe": "💀 Pranked Phú Khang",
      "details": "Placed a fake spider on Phú Khang's pillow. He screamed at 100dB!",
      "colorHex": 0xFFE0533C,
    },
    {
      "title": "Night Market Feast",
      "time": "Yesterday, 8:30 PM",
      "chaosVibe": "🍢 Grilled Food Attack",
      "details": "Minh Nhật devoured 5 plates of skewers. Total spending went to 450k VND.",
      "colorHex": 0xFF06B6D4,
    },
    {
      "title": "Morning Hike",
      "time": "Today, 7:00 AM",
      "chaosVibe": "🌲 Langbiang Summit",
      "details": "Squad hiked 5km to the peak. Breathtaking panoramic view of Đà Lạt valley.",
      "colorHex": 0xFF8B5CF6,
    },
  ];

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
          0xFFE0533C, 0xFF06B6D4, 0xFF8B5CF6,
          0xFFEBA83A, 0xFF10B981, 0xFFEF4444,
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
        setState(() {
          _activities = _fallbackActivities
              .map((a) => Map<String, dynamic>.from(a))
              .toList();
          _isLoading = false;
        });
      }
    }
  }

  String _activityTitle(String type) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return 'Chi Phí Mới 💸';
      case 'MOMENT_SHARED':
        return 'Khoảnh Khắc 📸';
      case 'GAME_STARTED':
        return 'Trò Chơi 🎮';
      case 'CHAT_SENT':
        return 'Tin Nhắn 💬';
      case 'ITINERARY_ADDED':
        return 'Kế Hoạch 🗺️';
      case 'MEMBER_JOINED':
        return 'Thành Viên Mới 👋';
      default:
        return 'Hoạt Động ⚡';
    }
  }

  String _activityVibe(String type) {
    switch (type) {
      case 'EXPENSE_ADDED':
        return '💳 Squad spending update';
      case 'MOMENT_SHARED':
        return '📷 New memory captured';
      case 'GAME_STARTED':
        return '🎮 Let the chaos begin';
      case 'CHAT_SENT':
        return '💬 Squad conversation';
      case 'ITINERARY_ADDED':
        return '🗺️ Plan updated';
      default:
        return '⚡ Squad activity';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "Squad Daily Recap",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
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
                      width: 250,
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isDark
                            ? TripMateTheme.darkSurface.withValues(alpha: 0.7)
                            : TripMateTheme.lightSurface,
                        border: Border.all(
                          color: themeColor.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['title'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                              Text(
                                item['time'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['chaosVibe'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDark
                                  ? TripMateTheme.darkTextPrimary
                                  : TripMateTheme.lightTextPrimary,
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
