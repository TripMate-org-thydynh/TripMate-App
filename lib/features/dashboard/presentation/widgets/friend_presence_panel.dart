import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/api_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../social/presentation/pages/squad_chat_screen.dart';

class FriendPresencePanel extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const FriendPresencePanel({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<FriendPresencePanel> createState() => _FriendPresencePanelState();
}

class _FriendPresencePanelState extends State<FriendPresencePanel> {
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  String _tripName = '';

  // Fallback data nếu API chưa có data thật
  static const _fallbackMembers = [
    {
      "name": "Nam Trung",
      "status": "ONLINE",
      "vibe": "☕",
      "avatarChar": "N",
    },
    {
      "name": "Thảo Ly",
      "status": "ONLINE",
      "vibe": "📸",
      "avatarChar": "T",
    },
    {
      "name": "Minh Nhật",
      "status": "IN_TRIP",
      "vibe": "🚶",
      "avatarChar": "M",
    },
    {
      "name": "Phú Khang",
      "status": "IDLE",
      "vibe": "😴",
      "avatarChar": "P",
    },
    {
      "name": "Hana",
      "status": "OFFLINE",
      "vibe": "🏡",
      "avatarChar": "H",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchSquadOnline();
  }

  Future<void> _fetchSquadOnline() async {
    final data = await ApiService.get('/dashboard/squad-online');
    if (mounted) {
      if (data != null && data['members'] != null) {
        final raw = data['members'] as List<dynamic>;
        setState(() {
          _tripName = data['tripName'] as String? ?? '';
          _members = raw.map((m) {
            final map = m as Map<String, dynamic>;
            final name = (map['name'] as String? ?? '?');
            return {
              'name': name,
              'status': map['status'] ?? 'OFFLINE',
              'vibe': _vibeFromTags(map['vibeTags']),
              'avatarChar': name.isNotEmpty ? name[0].toUpperCase() : '?',
              'avatarUrl': map['avatarUrl'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        // Dùng fallback data có nghĩa
        setState(() {
          _members = _fallbackMembers
              .map((m) => Map<String, dynamic>.from(m))
              .toList();
          _isLoading = false;
        });
      }
    }
  }

  String _vibeFromTags(dynamic vibeTags) {
    if (vibeTags == null) return '✈️';
    final tags = vibeTags as List<dynamic>;
    if (tags.isEmpty) return '✈️';
    final tag = tags[0].toString().toLowerCase();
    if (tag.contains('chill')) return '🌿';
    if (tag.contains('chaos')) return '🔥';
    if (tag.contains('photo')) return '📸';
    if (tag.contains('food')) return '🍜';
    if (tag.contains('night')) return '🌃';
    if (tag.contains('nature')) return '🏕';
    return '✈️';
  }

  Color _statusColor(String status, bool isDark) {
    switch (status) {
      case 'ONLINE':
        return Colors.greenAccent;
      case 'IN_TRIP':
        return isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
      case 'IDLE':
        return Colors.amberAccent;
      default:
        return Colors.grey;
    }
  }

  int get _activeCount =>
      _members.where((m) => m['status'] == 'ONLINE' || m['status'] == 'IN_TRIP').length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tripName.isNotEmpty ? "$_tripName Squad" : "Squad Online Panel",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (!_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$_activeCount active",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final friend = _members[index];
                    final status = friend['status'] as String? ?? 'OFFLINE';
                    final isActive = status == 'ONLINE' || status == 'IN_TRIP' || status == 'IDLE';
                    final statusColor = _statusColor(status, isDark);

                    return Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SquadChatScreen(
                                isDarkMode: widget.isDarkMode,
                                onThemeToggle: widget.onThemeToggle,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                // Glow active circular avatar frame
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isActive
                                          ? statusColor.withValues(alpha: 0.8)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: statusColor.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundImage: friend['avatarUrl'] != null
                                        ? NetworkImage(friend['avatarUrl'] as String)
                                        : null,
                                    backgroundColor: isDark
                                        ? TripMateTheme.darkSurface
                                        : const Color(0xFFE2E8F0),
                                    child: friend['avatarUrl'] == null
                                        ? Text(
                                            friend['avatarChar'] as String,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                // Vibe emoji badge
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? TripMateTheme.darkBackground
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      friend['vibe'] as String,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              friend['name'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? TripMateTheme.darkTextPrimary
                                    : TripMateTheme.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
