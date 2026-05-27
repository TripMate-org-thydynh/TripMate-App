import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme.dart';

class InviteFriendsScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;

  const InviteFriendsScreen({
    super.key,
    this.isDarkMode = true,
    this.onThemeToggle,
  });

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isSyncing = false;
  bool _isCopied = false;
  bool _hasSynced = false;

  // Mock initial squad members who joined
  final List<Map<String, String>> _squadMembers = [
    {'name': 'Alex', 'vibe': '🔥 chaos', 'avatar': '👨‍🎤', 'color': '0xFFEC4899'},
    {'name': 'Chloe', 'vibe': '✈️ chill', 'avatar': '👩‍🎨', 'color': '0xFF3B82F6'},
    {'name': 'Jordan', 'vibe': '🥂 foodie', 'avatar': '🧑‍🚀', 'color': '0xFF10B981'},
  ];

  // Mock contacts list to sync
  final List<Map<String, String>> _mockContacts = [
    {'name': 'Daniel', 'vibe': '📸 photo hunter', 'avatar': '🦁', 'color': '0xFFF59E0B'},
    {'name': 'Emma', 'vibe': '🍜 foodie energy', 'avatar': '🦊', 'color': '0xFF8B5CF6'},
    {'name': 'Sophia', 'vibe': '🌿 chill traveler', 'avatar': '🦄', 'color': '0xFF10B981'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _shareInviteLink() async {
    // Copy a funny mock invite link to clipboard
    const inviteLink = 'https://tripmate.app/join/chaos-squad-99';
    await Clipboard.setData(const ClipboardData(text: inviteLink));
    
    setState(() {
      _isCopied = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: (widget.isDarkMode ? const Color(0xFF171F33) : Colors.white).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (widget.isDarkMode ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🔗', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Squad link copied!',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: widget.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Send it to your favorite travel idiots.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isCopied = false;
      });
    }
  }

  void _syncContacts() async {
    if (_isSyncing || _hasSynced) return;

    setState(() {
      _isSyncing = true;
    });

    // Simulate contact synchronization with delay
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _hasSynced = true;
        // Add one of the contacts to the squad for absolute wow factor!
        _squadMembers.add(_mockContacts[0]);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: (widget.isDarkMode ? const Color(0xFF171F33) : Colors.white).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF34D399).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Contacts Synchronized!',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: widget.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Daniel joined the squad queue!',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    // Theme responsive color assignments
    final Color bg = isDark ? TripMateTheme.darkBackground : TripMateTheme.lightBackground;
    final Color surface = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final Color primary = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final Color secondary = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final Color textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final Color textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Background Ambient Blobs ──────────────────────────────────────────
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondary.withValues(alpha: 0.12),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ],

          // ── Main Layout ───────────────────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // [Interactive] Text: "arrow_back"
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 22,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        // Logo title
                        Text(
                          'trip.mate',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: primary,
                          ),
                        ),
                        // Theme Toggle
                        if (widget.onThemeToggle != null)
                          GestureDetector(
                            onTap: widget.onThemeToggle,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                              ),
                              child: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                size: 20,
                                color: textSecondary,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 42),
                      ],
                    ),
                  ),
                ),

                // Main content column
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Title Block
                        Text(
                          'assemble the squad.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.15,
                            color: textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Animated Count badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_squadMembers.length} idiots joined already ✨',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Central Squad Glassmorphism Card ─────────────────────────
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: surface.withValues(alpha: isDark ? 0.35 : 0.65),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: primary.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Floating vibe badges
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'THE SQUAD QUEUE',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          color: textSecondary.withValues(alpha: 0.7),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          _vibeBubble('🔥'),
                                          const SizedBox(width: 6),
                                          _vibeBubble('✈️'),
                                          const SizedBox(width: 6),
                                          _vibeBubble('🥂'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 20),

                                  // List of members with smooth anim
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _squadMembers.length,
                                    itemBuilder: (context, index) {
                                      final member = _squadMembers[index];
                                      final memberColor = Color(int.parse(member['color']!));
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: bg.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: textSecondary.withValues(alpha: 0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Circular avatar
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    memberColor.withValues(alpha: 0.8),
                                                    memberColor.withValues(alpha: 0.4),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                border: Border.all(
                                                  color: memberColor.withValues(alpha: 0.8),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  member['avatar']!,
                                                  style: const TextStyle(fontSize: 22),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    member['name']!,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    member['vibe']!,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF34D399).withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'READY',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF34D399),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 12),

                                  // Core paragraph
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('🔮 ', style: TextStyle(fontSize: 16)),
                                      Expanded(
                                        child: Text(
                                          "the trip isn't complete without the chaos.",
                                          style: GoogleFonts.inter(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 13.5,
                                            color: textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 32),

                        // [Interactive] Share Invite Link Button
                        GestureDetector(
                          onTap: _shareInviteLink,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final glowScale = 1.0 + (_pulseController.value * 0.05);
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [primary, const Color(0xFFEC4899)]
                                        : [primary, primary.withValues(alpha: 0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.4),
                                      blurRadius: 18 * glowScale,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isCopied)
                                      const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22)
                                    else
                                      const Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isCopied ? 'Link Copied!' : 'Share Invite Link',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // [Interactive] Sync Contacts Button
                        GestureDetector(
                          onTap: _syncContacts,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                decoration: BoxDecoration(
                                  color: surface.withValues(alpha: isDark ? 0.2 : 0.6),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: primary.withValues(alpha: _hasSynced ? 0.15 : 0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.06),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isSyncing)
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                                        ),
                                      )
                                    else
                                      Icon(
                                        _hasSynced ? Icons.contacts_rounded : Icons.contacts_outlined,
                                        color: _hasSynced ? textSecondary.withValues(alpha: 0.5) : primary,
                                        size: 18,
                                      ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isSyncing
                                          ? 'Syncing squad...'
                                          : (_hasSynced ? 'Contacts Synced' : 'Sync Contacts'),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: _hasSynced ? textSecondary.withValues(alpha: 0.7) : primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vibeBubble(String emoji) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.04),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isDarkMode ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
