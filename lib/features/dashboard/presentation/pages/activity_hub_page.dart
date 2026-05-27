import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityHubPage extends StatefulWidget {
  final bool? isDarkMode;
  const ActivityHubPage({super.key, this.isDarkMode});

  @override
  State<ActivityHubPage> createState() => _ActivityHubPageState();
}

class _ActivityHubPageState extends State<ActivityHubPage> {
  String _activeFilter = "All";

  final List<String> _filters = const ["All", "AI Alerts", "Social", "Payments", "Trips"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode ?? (theme.brightness == Brightness.dark);

    // Dynamic styles matching guidelines
    final primaryColor = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondaryColor = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final backgroundColor = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final surfaceColor = isDark ? const Color(0xFF171F33) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E2022);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF686D76);

    // List of notifications designed to match the specs perfectly
    final List<Map<String, dynamic>> notificationsList = [
      {
        "type": "AI Alerts",
        "icon": Icons.auto_awesome,
        "title": "AI Vibe Match system alert",
        "body": "We found a group heading to Tokyo that matches your chaotic-fun energy. Check them out!",
        "time": "Just now",
        "gradient": isDark ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)] : [const Color(0xFFE0533C), const Color(0xFFC23E28)],
        "hasAction": true,
        "actionLabel": "activity_hub.view_match".tr() != "activity_hub.view_match" ? "activity_hub.view_match".tr() : "View Match"
      },
      {
        "type": "Social",
        "icon": Icons.favorite,
        "title": "Thảo Ly reacted comment",
        "body": "reacted to your photo from Bali Trip: \"OMG this BBQ night was absolute chaos! 😂\"",
        "time": "2 hours ago",
        "gradient": [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        "hasAction": false
      },
      {
        "type": "Payments",
        "icon": Icons.check_circle_outline,
        "title": "Nam Trung paid BBQ settled",
        "body": "successfully settled payment for BBQ Night. +\$45.00 wallet updated.",
        "time": "5 hours ago",
        "gradient": [const Color(0xFF10B981), const Color(0xFF059669)],
        "hasAction": false
      },
      {
        "type": "Trips",
        "icon": Icons.map_outlined,
        "title": "Seoul Weekend Itinerary updated",
        "body": "New lodging coordinates and cafe spots updated by Hana.",
        "time": "Yesterday",
        "gradient": [const Color(0xFFEC4899), const Color(0xFFDB2777)],
        "hasAction": false
      },
      {
        "type": "Trips",
        "icon": Icons.flight_takeoff,
        "title": "3 Days until Paris trip!",
        "body": "Universal travel adapter and warm clothing packing reminders active.",
        "time": "3 days ago",
        "gradient": [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        "hasAction": false
      }
    ];

    final filteredNotifications = _activeFilter == "All"
        ? notificationsList
        : notificationsList.where((n) => n["type"] == _activeFilter).toList();

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ).createShader(bounds);
                    },
                    child: Text(
                      "Notifications",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Stay in sync with your crew chaos & AI recommendations",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filters Row
            SizedBox(
              height: 44,
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
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : surfaceColor.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.transparent 
                                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          filter,
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected ? Colors.white : textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // List of Notifications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: filteredNotifications.isEmpty
                  ? SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          "No notifications in this category yet.",
                          style: GoogleFonts.plusJakartaSans(
                            color: textSecondary,
                            fontSize: 14,
                          ),
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

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon background circle with custom gradients
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradientColors[0].withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Icon(
                                  item["icon"] as IconData,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Notification details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["title"] as String,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item["time"] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: textSecondary.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item["body"] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                    
                                    // Custom visual layout action buttons
                                    if (item["hasAction"] == true) ...[
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: gradientColors[0],
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Launching interactive group match finder... 🎯"),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              item["actionLabel"] as String,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                                          ],
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
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
