import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/theme.dart';

class CreateTripScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const CreateTripScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCoverId = 'cover-1';

  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;
  late AnimationController _glowController;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    _glowController.dispose();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = widget.isDarkMode;

    final primaryColor = isDark ? TripMateTheme.darkPrimary : TripMateTheme.lightPrimary;
    final secondaryColor = isDark ? TripMateTheme.darkSecondary : TripMateTheme.lightSecondary;
    final surfaceColor = isDark ? TripMateTheme.darkSurface : TripMateTheme.lightSurface;
    final textPrimary = isDark ? TripMateTheme.darkTextPrimary : TripMateTheme.lightTextPrimary;
    final textSecondary = isDark ? TripMateTheme.darkTextSecondary : TripMateTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0x800B1326) 
                    : const Color(0x9EFFFFFF),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile Image
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
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAYuhPfyZzfcN2JegmHnBxGvOCKnrEtjaku-5tEJoinZOkOXk8m_OM7CwRTUshXnd4BOW4tfuUznAzaz33W7zM-MDh_TMm0Lhuohv7JRN4pLmQtv1fgr4BiQTD14twErTdOOeNkN5eEi3p0_yaY__OKZmnU-AaGj_blzuqS2esbiyBbNYJhlw-c_BwNKKA_RdG_I7Tj1FyNmgHhKQLoQyVCwyYXV2hF5rjXUVZ8yGFBZp4UdR4guzZeDzbG92qPjlR9_Kv1XBQt17Em',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                          ),
                        ),
                      ),
                      // Title "trip.mate"
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
                      // Actions (Theme toggle + Reaction)
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              color: isDark ? const Color(0xFFD0BCFF) : const Color(0xFFE0533C),
                              size: 22,
                            ),
                            onPressed: widget.onThemeToggle,
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.add_reaction,
                              color: isDark ? const Color(0xFFCBC3D7) : const Color(0xFF494454),
                              size: 22,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Reacting to the trip vibe... 😊'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: primaryColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120), // Push down below customized glass appbar

              // Header Title
              Text(
                'set the vibe.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'where to next?',
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
                        hintText: 'name your trip (e.g., Đà Lạt Chill)',
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
                                  _startDate == null ? 'start date' : _formatDate(_startDate),
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
                                  _endDate == null ? 'end date' : _formatDate(_endDate),
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
                'cover mood.',
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
                                  child: Image.network(
                                    cover['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.black38),
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
                          'invite the crew.',
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
                                        child: Image.network(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvvXCbKfRu2mzCCcj60yFk9h01zv9Y9WCkOQodi1hFQWMDsFvlCdf6jjjGOJkkl8FtzL01xY7osHpDkE0cA4vAEJYAKtdufhxCA2V2Ezx3UxPouPfHiBWB9v8tBozIG4GJGcSYsBIre_8YrIPmbWDS42Vxclf6sWOOS4PnEmVECcbLfzVGsnFdNZ5w06zWYpaDAVxS8TEJNwVCIVCAhsfKriZh6Xnp_NuTNkK5Z1_Be50boL73EHsRRxcCJDOK7t5yH1MbugEcUzBo',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
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
                                        child: Image.network(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAUx6IWymkdIblIS-PiUXn_mSj3uaQEevZF_NDNmvxyQC_lqIFJV6bEkhsaomN1IGAWDiV8r-WgtyFEellRP6Pp6INrq2wUdr89T0QFCJfhrJgE-QWeK3c9XJYUq4ig9xKwtBV33Y90QnVSQB1LRcpgjjd-PrgIir8pBrgu0QqwZh7gn8dhEKS81oVf2yzui-bPxwJBT1Foj69OGa6FipK7ET-Ss-NVPCk1xxqAXeCcJwff74QgE7lTc_idtIGq-AmuznOK7n3hAVJK',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
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
                                        child: Image.network(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDO6trzSB6WVsxSDDPyupdf81TZO4gi-9_vSNkDxY2yjDf_Wq1TeQgb4jBNNUiJ3NwpgEiPsvMAXwsZB85_Jh5wi4_wg8RzlFJOtqJm7hWXXiMtL7W1pdRU9Oq4hYKTHgbnAJ5x3NDH-JflDnKbHOtkWV9y9-I3mGmkeP0C0yRS4pBLsKwXc3YhXHS6YOaiOpBs6PfdrgISrAjDeU-4bP58IQdnqPNJwvMTsuas8IliAu5vDrlIcotOe8QzT1Ri05ccGsNQQT6urm5-',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
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
                          'OR SHARE LINK',
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
                        'initialize',
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
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
