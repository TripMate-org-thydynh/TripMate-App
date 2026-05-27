import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/theme.dart';

class CreateTripScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final bool hideNavigationBar;

  const CreateTripScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    this.hideNavigationBar = false,
  });

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCoverId = 'cover-1';
  bool _showEmptyState = true; // Stitch screen 29 empty state shown by default

  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;
  late AnimationController _glowController;
  late AnimationController _pulseController;

  final List<Map<String, String>> _covers = const [
    {
      'id': 'cover-1',
      'title': 'tokyo drift',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuARlm-NKedW1-CqQk_H3xXvsqq2gyd81dTiyeFzBZym3q1X9Qn4lbOz46JZ9RXiAa3q57B1nNICKwmQmUYFi0tlEQAsjtzTLDNXVrtWseXJ-iK0wjaKEtsAB91IMtYICmUvqZaDQR-NRJAQHr298JNifjqs0tN6y3suHijm-GMkxtAxQoLVundDSlannb6iWhGGsja3MaljKkSyjoCeCZ6B0pPqIiiTf5sUusUP3fAzO3qnUlVTD7nl0bPGU-10uD92oA7EgY-wWAvv',
    },
    {
      'id': 'cover-2',
      'title': 'island time',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC0EZZpWtPl4R59fD95E2JtdieXq-hUKsuxMIIECR3METZRDM4N18TrhA-nstSr9I3wjVFukb9LoNBXNkalX-hMXl7EVsvXokxJFxSABLqA51ugrSWtSPWIeqy1tRXnYpb0oLDdwS4h4uJOEDdfanoOqGtIWLxwRpan4MrXds8By-hqmyukSzCH1I9pEEgDn7pS2drlJ0lPeew1eFhJlOWMpH1sqxdHyg8tPx9hmpS3eYfqvivIjPWUDNS_bl5HFcwgTQy025IZo0GK',
    },
    {
      'id': 'cover-3',
      'title': 'alpine glow',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCtZzjUJJF2fLQodQpe9RotB86k2bf3LwAPDkiFUQMJToPc9ZlHjh49F965WIUiATCNjpWXervoevWXpTNp-XymU1BNhRkihubo4AES2RWJ76B1iSxQfCG-Q2N-sAtumOqWIu7oIcOSK7P9QUdR8Hyqq9fbk_qHZ42PY6ntY_mMThLeTdijAD1nvJybPeeht45WK20u6CRQ_sMAjPKeRbeFRhrh8Y8A65eNl9A2gAnWBuk38QRcTsp6xYABpkHFVvJ6ln0NrmwddE98',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Floating avatar animations
    _floatController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _floatController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Glowing border animations
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: widget.isDarkMode ? TripMateTheme.darkTheme : TripMateTheme.lightTheme,
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;

    final canvasBg = isDark ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6);

    return Scaffold(
      backgroundColor: canvasBg,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: _showEmptyState ? _buildEmptyState(context, primaryColor, secondaryColor, textPrimary, textSecondary, isDark) : _buildTripForm(context, primaryColor, secondaryColor, textPrimary, textSecondary, isDark),
      ),
      bottomNavigationBar: widget.hideNavigationBar ? null : _buildBottomNavigationBar(isDark, primaryColor, secondaryColor),
    );
  }

  // SCREEN 29: EMPTY STATE - NO TRIPS
  Widget _buildEmptyState(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return Container(
      key: const ValueKey('empty_state_view'),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 1.2,
          colors: isDark
              ? [
                  primaryColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ]
              : [
                  secondaryColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCustomAppBar(primaryColor, isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dynamic Pulsing Diamond Vibe Icon
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0x13FFFFFF) : const Color(0x0A000000),
                            border: Border.all(color: borderCol, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.15 * _pulseController.value),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.diamond,
                            size: 38 + (4 * _pulseController.value),
                            color: primaryColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    // Title "trip.mate" with high-impact font styling
                    Text(
                      'trip.mate',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: textPrimary,
                        letterSpacing: -2,
                        shadows: [
                          Shadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Roast Subtitle: "time to make financially irresponsible memories."
                    Text(
                      'trips.roast_tagline'.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textSecondary,
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Body text: "Your chaos squad is missing. No trips planned yet."
                    Text(
                      'trips.no_trips_body'.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: textSecondary.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // GLOWING CAPSULE ACTION: "start the chaos"
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showEmptyState = false;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 260 + (10 * _pulseController.value),
                                height: 66,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(33),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.25 * _pulseController.value),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Container(
                            width: 250,
                            height: 58,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(29),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, color: primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'trips.start_the_chaos'.tr(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STANDARD TRIP CREATION FORM VIEW
  Widget _buildTripForm(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;

    return Container(
      key: const ValueKey('trip_form_view'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // Push down below custom glass appbar

              // Header Title
              Text(
                'trips.set_the_vibe'.tr(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'trips.where_to_next_form'.tr(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Inputs Form
              Column(
                children: [
                  // Trip Name input
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x13FFFFFF) : const Color(0x0A000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'trips.name_your_trip'.tr(),
                        hintStyle: TextStyle(
                          color: textSecondary.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dates Split Row
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x13FFFFFF) : const Color(0x0A000000),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _startDate == null ? 'trips.start_date'.tr() : _formatDate(_startDate),
                                  style: TextStyle(
                                    color: _startDate == null
                                        ? textSecondary.withValues(alpha: 0.5)
                                        : textPrimary,
                                    fontSize: 13,
                                    fontWeight: _startDate == null ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: primaryColor.withValues(alpha: 0.8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // End Date
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x13FFFFFF) : const Color(0x0A000000),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endDate == null ? 'trips.end_date'.tr() : _formatDate(_endDate),
                                  style: TextStyle(
                                    color: _endDate == null
                                        ? textSecondary.withValues(alpha: 0.5)
                                        : textPrimary,
                                    fontSize: 13,
                                    fontWeight: _endDate == null ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.event,
                                  size: 16,
                                  color: primaryColor.withValues(alpha: 0.8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Cinematic Cover Selection
              Text(
                'trips.cover_mood'.tr(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _covers.length,
                  itemBuilder: (context, index) {
                    final cover = _covers[index];
                    final isSelected = _selectedCoverId == cover['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCoverId = cover['id']!;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Container(
                              width: 160,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: isSelected
                                    ? Border.all(color: secondaryColor, width: 2.0)
                                    : Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.05),
                                        width: 1.5,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: secondaryColor.withValues(alpha: 0.35),
                                          blurRadius: 15,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: child,
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CachedNetworkImage(
                                    imageUrl: cover['image']!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.black12,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(color: Colors.black38),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent, Colors.black87],
                                      ),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: secondaryColor,
                                      size: 20,
                                    ),
                                  ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Text(
                                    cover['title']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Invite Crew Card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x13FFFFFF) : const Color(0x0A000000),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'trips.invite_the_crew'.tr(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // QR Box & Floating profiles
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Middle QR Code
                              Container(
                                width: 140,
                                height: 140,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF171F33) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.25),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.15),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isDark ? Colors.white24 : Colors.black12,
                                      width: 3.0,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.qr_code_2,
                                      size: 54,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),

                              // Avatar 1: Minh Nhật (Left-Floating)
                              AnimatedBuilder(
                                animation: _floatController1,
                                builder: (context, child) {
                                  final offset = math.sin(_floatController1.value * math.pi * 2) * 8;
                                  return Positioned(
                                    left: screenWidth * 0.08,
                                    top: 15 + offset,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: surfaceColor, width: 2.0),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: CachedNetworkImage(
                                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAvvXCbKfRu2mzCCcj60yFk9h01zv9Y9WCkOQodi1hFQWMDsFvlCdf6jjjGOJkkl8FtzL01xY7osHpDkE0cA4vAEJYAKtdufhxCA2V2Ezx3UxPouPfHiBWB9v8tBozIG4GJGcSYsBIre_8YrIPmbWDS42Vxclf6sWOOS4PnEmVECcbLfzVGsnFdNZ5w06zWYpaDAVxS8TEJNwVCIVCAhsfKriZh6Xnp_NuTNkK5Z1_Be50boL73EHsRRxcCJDOK7t5yH1MbugEcUzBo',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: Colors.black12),
                                          errorWidget: (context, url, error) => const Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Avatar 2: Thảo Ly (Right-Floating)
                              AnimatedBuilder(
                                animation: _floatController2,
                                builder: (context, child) {
                                  final offset = math.cos(_floatController2.value * math.pi * 2) * 10;
                                  return Positioned(
                                    right: screenWidth * 0.06,
                                    top: 40 + offset,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: surfaceColor, width: 2.0),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: CachedNetworkImage(
                                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAUx6IWymkdIblIS-PiUXn_mSj3uaQEevZF_NDNmvxyQC_lqIFJV6bEkhsaomN1IGAWDiV8r-WgtyFEellRP6Pp6INrq2wUdr89T0QFCJfhrJgE-QWeK3c9XJYUq4ig9xKwtBV33Y90QnVSQB1LRcpgjjd-PrgIir8pBrgu0QqwZh7gn8dhEKS81oVf2yzui-bPxwJBT1Foj69OGa6FipK7ET-Ss-NVPCk1xxqAXeCcJwff74QgE7lTc_idtIGq-AmuznOK7n3hAVJK',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: Colors.black12),
                                          errorWidget: (context, url, error) => const Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Avatar 3: User (Bottom-Floating)
                              AnimatedBuilder(
                                animation: _floatController3,
                                builder: (context, child) {
                                  final offset = math.sin(_floatController3.value * math.pi * 2) * 6;
                                  return Positioned(
                                    left: screenWidth * 0.15,
                                    bottom: 15 + offset,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: surfaceColor, width: 2.0),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(19),
                                        child: CachedNetworkImage(
                                          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDO6trzSB6WVsxSDDPyupdf81TZO4gi-9_vSNkDxY2yjDf_Wq1TeQgb4jBNNUiJ3NwpgEiPsvMAXwsZB85_Jh5wi4_wg8RzlFJOtqJm7hWXXiMtL7W1pdRU9Oq4hYKTHgbnAJ5x3NDH-JflDnKbHOtkWV9y9-I3mGmkeP0C0yRS4pBLsKwXc3YhXHS6YOaiOpBs6PfdrgISrAjDeU-4bP58IQdnqPNJwvMTsuas8IliAu5vDrlIcotOe8QzT1Ri05ccGsNQQT6urm5-',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: Colors.black12),
                                          errorWidget: (context, url, error) => const Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'trips.or_share_link'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Magnetic Action Button "initialize"
              GestureDetector(
                onTap: () {
                  final tripName = _nameController.text.trim();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tripName.isEmpty
                          ? 'Initializing awesome trip... 🚀'
                          : 'Initializing $tripName... 🚀'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: primaryColor,
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'trips.initialize'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: widget.hideNavigationBar ? 40 : 120), // Extra space for floating bottom navbar
            ],
          ),
        ),
      ),
    );
  }

  // APP BAR FOR EMPTY STATE
  Widget _buildCustomAppBar(Color primaryColor, bool isDark) {
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x800B1326) : const Color(0x9EFFFFFF),
            border: Border(bottom: BorderSide(color: borderCol, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAYuhPfyZzfcN2JegmHnBxGvOCKnrEtjaku-5tEJoinZOkOXk8m_OM7CwRTUshXnd4BOW4tfuUznAzaz33W7zM-MDh_TMm0Lhuohv7JRN4pLmQtv1fgr4BiQTD14twErTdOOeNkN5eEi3p0_yaY__OKZmnU-AaGj_blzuqS2esbiyBbNYJhlw-c_BwNKKA_RdG_I7Tj1FyNmgHhKQLoQyVCwyYXV2hF5rjXUVZ8yGFBZp4UdR4guzZeDzbG92qPjlR9_Kv1XBQt17Em',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.black12),
                    errorWidget: (context, url, error) => const Icon(Icons.trip_origin),
                  ),
                ),
              ),
              // Brand
              Text(
                'trip.mate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: primaryColor,
                  letterSpacing: -1.5,
                ),
              ),
              // Actions
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? const Color(0xFFD0BCFF) : const Color(0xFFE0533C),
                      size: 22,
                    ),
                    onPressed: widget.onThemeToggle,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_reaction, color: Colors.grey, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar(bool isDark, Color primaryColor, Color secondaryColor) {
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x60171F33) : const Color(0xC0FFFFFF),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: borderCol, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.map, 'map', false, isDark, primaryColor),
                  _buildNavItem(Icons.search, 'search', false, isDark, primaryColor),
                  _buildNavItem(Icons.add_circle, 'add_circle', !_showEmptyState, isDark, primaryColor, onTap: () {
                    setState(() {
                      _showEmptyState = false;
                    });
                  }),
                  _buildNavItem(Icons.auto_awesome, 'auto_awesome', _showEmptyState, isDark, primaryColor, onTap: () {
                    setState(() {
                      _showEmptyState = true;
                    });
                  }),
                  _buildNavItem(Icons.person, 'person', false, isDark, primaryColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, bool isDark, Color primaryColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to bottom item: $label'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? primaryColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? primaryColor : (isDark ? Colors.white60 : Colors.black54),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
