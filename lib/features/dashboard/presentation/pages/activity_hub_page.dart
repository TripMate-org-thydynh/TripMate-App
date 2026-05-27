import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityHubPage extends StatefulWidget {
  const ActivityHubPage({super.key});

  @override
  State<ActivityHubPage> createState() => _ActivityHubPageState();
}

class _ActivityHubPageState extends State<ActivityHubPage> {
  String _activeFilter = "All";

  final List<String> _filters = const ["All", "AI Alerts", "Social", "Payments", "Trips"];

  final List<Map<String, dynamic>> _notifications = [
    {
      "type": "AI Alerts",
      "icon": Icons.auto_awesome,
      "title": "activity_hub.system_alert",
      "body": "We found a group heading to Tokyo that matches your chaotic-fun energy. Check them out!",
      "time": "Just now",
      "gradient": [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      "hasAction": true,
      "actionLabel": "activity_hub.view_match"
    },
    {
      "type": "Social",
      "icon": Icons.favorite,
      "title": "Thảo Ly",
      "body": "reacted to your photo from Bali Trip. 😂",
      "time": "2 hours ago",
      "gradient": [Color(0xFFEF4444), Color(0xFFDC2626)],
      "hasAction": false
    },
    {
      "type": "Payments",
      "icon": Icons.payments,
      "title": "Nam Trung",
      "body": "paid for BBQ Night. +\$45.00 settled",
      "time": "5 hours ago",
      "gradient": [Color(0xFF10B981), Color(0xFF059669)],
      "hasAction": false
    },
    {
      "type": "Trips",
      "icon": Icons.flight_takeoff,
      "title": "Reminder",
      "body": "3 Days until Paris! Don't forget to pack your adapters.",
      "time": "3 days ago",
      "gradient": [Color(0xFF3B82F6), Color(0xFF2563EB)],
      "hasAction": false
    },
    {
      "type": "Trips",
      "icon": Icons.map,
      "title": "Seoul Weekend",
      "body": "Itinerary updated by Hana.",
      "time": "Yesterday",
      "gradient": [Color(0xFFEC4899), Color(0xFFDB2777)],
      "hasAction": false
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Filter items
    final filteredNotifications = _activeFilter == "All"
        ? _notifications
        : _notifications.where((n) => n["type"] == _activeFilter).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "activity_hub.notifications".tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  "activity_hub.sub_heading".tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Filters selector row
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _activeFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Notifications lists
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: filteredNotifications.isEmpty
                ? SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(
                        "No new notifications in this category.",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      final gradientColors = item["gradient"] as List<Color>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white,
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon background circle
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [gradientColors[0], gradientColors[1]],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                item["icon"] as IconData,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        (item["title"] as String).tr(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        item["time"] as String,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item["body"] as String,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  if (item["hasAction"] == true) ...[
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: gradientColors[0],
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Launching group match finder!"),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        (item["actionLabel"] as String).tr(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
