import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquadPresenceLiveVibesScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const SquadPresenceLiveVibesScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<SquadPresenceLiveVibesScreen> createState() => _SquadPresenceLiveVibesScreenState();
}

class _SquadPresenceLiveVibesScreenState extends State<SquadPresenceLiveVibesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  // Mock notes state
  final List<Map<String, dynamic>> _notes = [
    {
      'name': 'Nam Trung',
      'emoji': '☕',
      'note': 'cafe hopping',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150',
      'online': 'true',
    },
    {
      'name': 'Thảo Ly',
      'emoji': '😴',
      'note': 'sleeping',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
      'online': 'false',
    },
    {
      'name': 'Phú Khang',
      'emoji': '🎮',
      'note': 'clutching 1v5',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150',
      'online': 'true',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    String selectedEmoji = '✨';
    final isDark = widget.isDarkMode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: isDark ? const Color(0xFF171F33) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  ),
                ),
                title: Text(
                  'Share your Vibe Note',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'What are you doing?',
                        hintStyle: GoogleFonts.inter(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['☕', '😴', '🚗', '🎮', '🍔', '✨'].map((emoji) {
                        final isSelected = selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedEmoji = emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C)).withValues(alpha: 0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          _notes.insert(0, {
                            'name': 'You',
                            'emoji': selectedEmoji,
                            'note': controller.text,
                            'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
                            'online': 'true',
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Post Note',
                      style: GoogleFonts.inter(
                        color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Theme values
    final bgStart = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);
    final bgEnd = isDark ? const Color(0xFF060E20) : const Color(0xFFF1EDE6);
    final surface = isDark ? const Color(0xFF171F33) : Colors.white;
    final primary = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFE0533C);
    final secondary = isDark ? const Color(0xFF34D399) : const Color(0xFFEBA83A);
    final textPrimary = isDark ? const Color(0xFFDAE2FD) : const Color(0xFF1E2022);
    final textMuted = isDark ? const Color(0xFFCBC3D7) : const Color(0xFF686D76);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Glowing Orbs
            if (isDark) ...[
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ],

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Top App Bar ───────────────────────────────────────────
                  _buildTopBar(textPrimary, primary),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),

                          // ── Header Title & Tagline ────────────────────────
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'the squad is alive',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'democracy but emotionally unstable',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Horizontal Vibes Notes Row ───────────────────
                          _buildNotesRow(surface, primary, secondary, textPrimary, textMuted),

                          const SizedBox(height: 28),

                          // ── Live Activity List ────────────────────────────
                          Text(
                            'LIVE ACTIVITY',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Card 1: Nam Trung (Highly Active)
                          _buildPresenceCard(
                            isDark: isDark,
                            name: 'Nam Trung',
                            avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150',
                            status: 'Online',
                            statusColor: secondary,
                            description: '🗺 Editing tomorrow\'s chaos',
                            detailIcon: Icons.battery_charging_full_rounded,
                            detailText: '12%',
                            vibeText: '🔥 92% Vibe',
                            onPrimaryAction: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Poke sent to Nam Trung 👋'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            primaryActionLabel: 'Poke',
                            primaryActionIcon: Icons.back_hand_rounded,
                            onSecondaryAction: () {},
                            secondaryActionLabel: 'Chat',
                            secondaryActionIcon: Icons.chat_bubble_rounded,
                            hasPulse: true,
                            surface: surface,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                            primaryColor: primary,
                          ),

                          const SizedBox(height: 16),

                          // Card 2: Thảo Ly (Moving)
                          _buildPresenceCard(
                            isDark: isDark,
                            name: 'Thảo Ly',
                            avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=150',
                            status: '🚕 Moving',
                            statusColor: isDark ? const Color(0xFFFB923C) : const Color(0xFFEBA83A),
                            description: '8 mins away from chaos',
                            detailIcon: Icons.battery_full_rounded,
                            detailText: '84%',
                            onPrimaryAction: () {},
                            primaryActionLabel: 'View Map',
                            primaryActionIcon: Icons.location_on_rounded,
                            hasPulse: false,
                            surface: surface,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                            primaryColor: primary,
                          ),

                          const SizedBox(height: 16),

                          // Card 3: Phú Khang (Offline/Ghosting)
                          _buildPresenceCard(
                            isDark: isDark,
                            name: 'Phú Khang',
                            avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=150',
                            status: 'Offline',
                            statusColor: textMuted,
                            description: 'ignoring the group chat 😭',
                            detailText: 'Last seen 3h ago',
                            onPrimaryAction: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('SOS Signal Broadcasted 🚨'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            },
                            primaryActionLabel: 'Send SOS',
                            primaryActionIcon: Icons.crisis_alert_rounded,
                            isEmergency: true,
                            hasPulse: false,
                            surface: surface,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                            primaryColor: primary,
                          ),

                          const SizedBox(height: 100), // Spacing for bottom navigation
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Floating Custom Bottom Navigation Bar ──────────────────
            _buildFloatingNavbar(surface, primary, secondary, textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textPrimary, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // arrow_back button
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Back',
          ),
          // Logo text
          Text(
            'trip.mate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              color: textPrimary,
            ),
          ),
          // Actions
          Row(
            children: [
              if (widget.onThemeToggle != null)
                IconButton(
                  icon: Icon(
                    widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: textPrimary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: widget.onThemeToggle,
                  tooltip: 'Toggle Theme',
                ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: textPrimary, size: 24),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesRow(Color surface, Color primary, Color secondary, Color textPrimary, Color textMuted) {
    final isDark = widget.isDarkMode;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Add Note button
          GestureDetector(
            onTap: _showAddNoteDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 12),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          color: surface.withValues(alpha: isDark ? 0.3 : 0.8),
                        ),
                        child: Icon(Icons.add_rounded, color: primary, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Note',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Render other notes
          ..._notes.map((note) {
            final isOnline = note['online'] == 'true';
            return Container(
              margin: const EdgeInsets.only(right: 16, top: 12),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Avatar
                      Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isOnline
                                ? [primary, secondary]
                                : [Colors.transparent, Colors.transparent],
                          ),
                          border: isOnline
                              ? null
                              : Border.all(color: (isDark ? Colors.white24 : Colors.black12), width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(note['avatar']!),
                        ),
                      ),
                      // Online badge
                      if (isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: surface, width: 2),
                            ),
                          ),
                        ),
                      // Floating Note Card
                      Positioned(
                        top: -16,
                        left: -10,
                        right: -10,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: surface.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (isDark ? Colors.white10 : Colors.black12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(note['emoji']!, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    note['note']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note['name']!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPresenceCard({
    required bool isDark,
    required String name,
    required String avatar,
    required String status,
    required Color statusColor,
    required String description,
    IconData? detailIcon,
    required String detailText,
    String? vibeText,
    required VoidCallback onPrimaryAction,
    required String primaryActionLabel,
    required IconData primaryActionIcon,
    VoidCallback? onSecondaryAction,
    String? secondaryActionLabel,
    IconData? secondaryActionIcon,
    bool isEmergency = false,
    required bool hasPulse,
    required Color surface,
    required Color textPrimary,
    required Color textMuted,
    required Color primaryColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: surface.withValues(alpha: isDark ? 0.45 : 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isEmergency
                  ? Colors.redAccent.withValues(alpha: 0.3)
                  : (isDark ? Colors.white10 : Colors.black12),
              width: isEmergency ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with optional pulse ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (hasPulse)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 1 - _pulseController.value),
                                  width: 4 * _pulseController.value,
                                ),
                              ),
                            );
                          },
                        ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: statusColor, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(avatar),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Name & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: textMuted,
                          ),
                        ),

                        // Chips
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (detailIcon != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(detailIcon, size: 14, color: textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      detailText,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  detailText,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            if (vibeText != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  vibeText,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Button Panel
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onPrimaryAction,
                      icon: Icon(primaryActionIcon, size: 18),
                      label: Text(primaryActionLabel),
                      style: TextButton.styleFrom(
                        foregroundColor: isEmergency ? Colors.redAccent : textPrimary,
                        backgroundColor: isEmergency
                            ? Colors.redAccent.withValues(alpha: 0.15)
                            : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  if (onSecondaryAction != null && secondaryActionLabel != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onSecondaryAction,
                        icon: Icon(secondaryActionIcon, size: 18, color: primaryColor),
                        label: Text(secondaryActionLabel),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          backgroundColor: primaryColor.withValues(alpha: 0.15),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavbar(Color surface, Color primary, Color secondary, Color textMuted) {
    final isDark = widget.isDarkMode;
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
              if (isDark)
                BoxShadow(
                  color: secondary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavbarItem(Icons.explore_outlined, false, textMuted, secondary),
              _buildNavbarItem(Icons.group_rounded, true, textMuted, secondary),
              _buildNavbarItem(Icons.add_circle_outline_rounded, false, textMuted, secondary),
              _buildNavbarItem(Icons.chat_bubble_outline_rounded, false, textMuted, secondary),
              _buildNavbarItem(Icons.person_outline_rounded, false, textMuted, secondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbarItem(IconData icon, bool isActive, Color textMuted, Color secondary) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isActive
          ? BoxDecoration(
              color: secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: secondary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: Icon(
        icon,
        color: isActive ? secondary : textMuted,
        size: 24,
      ),
    );
  }
}
