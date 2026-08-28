import 'package:flutter/material.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
class SquadGroupSettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final String crewName;

  const SquadGroupSettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.crewName,
  });

  @override
  State<SquadGroupSettingsScreen> createState() =>
      _SquadGroupSettingsScreenState();
}

class _SquadGroupSettingsScreenState extends State<SquadGroupSettingsScreen> {
  late TextEditingController _nameController;
  bool _notificationsMuted = false;

  final List<Map<String, String>> _members = [
    {
      'name': 'Alex Nguyễn',
      'username': '@alex_escapes',
      'role': 'CREATOR',
      'avatar': '🦊',
      'status': '🟢 Active Online',
    },
    {
      'name': 'Minh Nhật',
      'username': '@minh_nhat',
      'role': 'MEMBER',
      'avatar': '🐱',
      'status': '🟡 In Trip • Kyoto',
    },
    {
      'name': 'Thảo Ly',
      'username': '@thao_ly',
      'role': 'MEMBER',
      'avatar': '🦄',
      'status': '🔴 Offline • 3h ago',
    },
    {
      'name': 'Nam Trung',
      'username': '@nam_trung',
      'role': 'MEMBER',
      'avatar': '🦖',
      'status': '🟢 Active Online',
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.crewName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showMemberActions(Map<String, String> member) {
    final isDark = widget.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262019) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Manage ${member['name']}',
                style: AppFonts.body(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              if (member['role'] != 'CREATOR') ...[
                _buildActionTile(
                  icon: Icons.vpn_key_outlined,
                  title: 'Transfer Creator Ownership',
                  subtitle: 'Give absolute group control to this user',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Transferred control to ${member['name']}! 🔑',
                        ),
                      ),
                    );
                  },
                ),
                _buildActionTile(
                  icon: Icons.person_remove_outlined,
                  title: 'Kick out of Squad 😭',
                  subtitle: 'Remove user from this group chat and trip',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _members.removeWhere(
                        (m) => m['username'] == member['username'],
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Removed ${member['name']} from the squad.',
                        ),
                      ),
                    );
                  },
                ),
              ] else ...[
                Text(
                  'No actions available for group creator.',
                  style: AppFonts.heading(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? color,
  }) {
    final isDark = widget.isDarkMode;
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? (isDark ? Colors.white70 : Colors.black87),
      ),
      title: Text(
        title,
        style: AppFonts.body(
          fontWeight: FontWeight.bold,
          color: color ?? (isDark ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppFonts.heading(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgGradStart = isDark
        ? const Color(0xFF1A1712)
        : const Color(0xFFFDF6D3);
    final cardBg = isDark ? const Color(0xFF262019) : const Color(0xFFFFFDF5);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    final primaryColor = isDark
        ? const Color(0xFFF5822B)
        : const Color(0xFFF5822B);
    final neonCyan = const Color(0xFF00F5FF);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: bgGradStart),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Settings Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Squad Settings',
                          style: AppFonts.body(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: textPrimary,
                      ),
                      onPressed: widget.onThemeToggle,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo and Name Box
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 0,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🌴',
                                      style: TextStyle(fontSize: 48),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 250,
                              child: TextField(
                                controller: _nameController,
                                textAlign: TextAlign.center,
                                style: AppFonts.body(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Group Crew Name',
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: neonCyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: neonCyan, width: 2),
                              ),
                              child: Text(
                                '🔥 Coastal Vibe Match',
                                style: AppFonts.heading(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? neonCyan : Colors.teal[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Crew Share Code Invite
                      Text(
                        'INVITE CODE',
                        style: AppFonts.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KYOTODRIFT',
                                  style: AppFonts.body(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Share this code with your friends to join.',
                                  style: AppFonts.heading(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invite Code Copied! 📋'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 14),
                              label: const Text('Copy'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Quick Toggle Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mute Group Notifications',
                                style: AppFonts.body(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mutes message alert notifications.',
                                style: AppFonts.heading(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _notificationsMuted,
                            onChanged: (val) {
                              setState(() {
                                _notificationsMuted = val;
                              });
                            },
                            activeThumbColor: primaryColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Squad Members Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SQUAD MEMBERS (${_members.length})',
                            style: AppFonts.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: textSecondary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Opening friend lists to invite... 🦖',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Add Friend'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Members list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          final isCreator = member['role'] == 'CREATOR';
                          return GestureDetector(
                            onTap: () => _showMemberActions(member),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    member['avatar']!,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              member['name']!,
                                              style: AppFonts.body(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (isCreator)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: primaryColor
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'creator',
                                                  style:
                                                      AppFonts.heading(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: primaryColor,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          member['status']!,
                                          style: AppFonts.heading(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.more_vert,
                                    color: textSecondary.withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
