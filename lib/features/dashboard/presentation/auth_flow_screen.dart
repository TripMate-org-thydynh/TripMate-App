import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dashboard_screen.dart';
import '../../../core/api_service.dart';

class AuthFlowScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const AuthFlowScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> with TickerProviderStateMixin {
  int _currentStep = 0; // 0: Vibe Onboarding, 1: Auth/Forgot, 2: Verification, 3: Profile, 4: Permissions, 5: Success
  
  // State variables for inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _instaController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();

  final List<String> _selectedVibes = [];
  bool _isForgotPasswordMode = false;
  String? _tempSupabaseId;
  String? _tempEmail;
  int _otpTimer = 30;
  Timer? _timer;

  late PageController _pageController;
  late AnimationController _bouncingController;
  late AnimationController _meshController;

  // Premium High-Fidelity Vibes matching Stitch HTML
  final List<Map<String, String>> _vibeOptions = [
    {
      'name': 'Chill',
      'desc': 'Resorts, spas, and slow mornings in Hội An.',
      'emojis': '🧘‍♀️🍹',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuASmUw0WNmnNpHadDogcZUgXrjs6I-bWPczGA7YXzboabdRCE4x2ucpr-rlcHtJOqMkRPHvQ7jfuNOOyvolEQ3g9sD1pN0AIeKq5HQW1oaHU8Q_D__1RhpGFMthOsgU-gQntyeBysmb9GDwUrZtACvinE9dawLVs8qvHa3KORAfaz4DCFJzvbIafzVn7qCJgmXw7WDt2M4ExXkcbFBl8VJZj_3op0Z14zMOYLvkFW0UO2oqIDQ3ucy3HgbdpM-EUlKBSLVraywz-XJw',
    },
    {
      'name': 'Party',
      'desc': 'Bùi Viện nights and rooftop bars in Saigon.',
      'emojis': '🪩🍻',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA71vJUK5sVuU14_UX3NCLQgDFwvVTrmg75CeIBMkP7BhRezGjIXjQXjU9gHbyiREBFTkjDpTnu7c4gbgJyl9aLkvR-eR1WmesWgvL7ojln3HmNiDD6nM__Yzk6nQauA3NJKkJDRBbSW5J2ONzxgV-IgTUZ4mQ5Re2DFm0O-tmLsZ8jp0Vgwos0fb6BvVUzbg1_xV70x9gCD6_XPIqALeLAkaKv5VTewB79LOwrAvVGv6Z-z0-6LUoCeYjjTkPoCi2E4YRUOzb89LGV',
    },
    {
      'name': 'Foodie',
      'desc': 'Street food tours and hidden Pho spots in Hanoi.',
      'emojis': '🍜🌶️',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAKnOyCAdHjlxooUW1ElYcNPUVGBsy0hMJG6KlBH-wAxUhVgf5fWccFC2zSkU72m8F91eab7q1okYfePlzR7L9gXex_jd5bH41oNvwc8-NA-EXEBQvB_7LMv-1rmaFdjag8VpM_NxkzJMKCuT5kfVXKWb7hYz9-VbdwUKSvuf8ZBi9gI5k0ggMI1fBhUT61eP6gq1OWPueQFC1YcNm09zlVS37G3I-rWkPJ_VjBw0vg-cKC4iirGwz8-93d3DKJ7wQmjPfq8VE6eE_P',
    },
    {
      'name': 'Nature',
      'desc': 'Ha Long Bay cruises and Sapa rice terraces.',
      'emojis': '⛰️🌿',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAOJAn865X2oV_wxI03YpNqwVLe_s1ihBcLfPDB9KjzKYiWHdsWGIW8RKNiRIU2cI5nNUSUKXtgwzeQlqrPqEUqrBJKDh9e59gtDBrNQiWG84213WKSkjd_z9xzuvo6pfYoGRhneGRC29s3gay2LT-BvYO6ZgTPjSAoHx4NxOJVVMpZu-zcBwwZuCoKKdN0wEpN_GQ4tkIHeCPrE0ysLb1iLu9IXovBwDNC8322GooBX-MdAW8pPsPPygxWWJsvv96UF8nSKdRRKxAI',
    },
    {
      'name': 'Adventure',
      'desc': 'Ha Giang loop and exploring Son Doong cave.',
      'emojis': '🏍️🎒',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFHi6VoKpw5K_xKZ6YruS2o3QejCMoBXiYBdgIiq18216st17gBSU3zbjHf9RNCpby9b7bxqfKg2-W0htgSUF2V8BsxTpQ27yI2vLDmD3N6v072ExHY5ZHTW5DPDdQxSogk3MtuNHLf8MKGdePieA0GEXbWzjSt6m0mUTgc83WqGmK8Jbh331Ryz7ZKDxLL0xyLq3J0ssDe-qDi9tdWPI1gR7kL6IkqrCcU_nKr2EU3WrxlqB9uuUrfEH4CoNr3zZiJr8lW395lYYm',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _bouncingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _instaController.dispose();
    _tiktokController.dispose();
    _pageController.dispose();
    _bouncingController.dispose();
    _meshController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpTimer == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _otpTimer--;
        });
      }
    });
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
      if (_currentStep == 2) {
        _startOtpTimer();
      }
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = widget.isDarkMode ? const Color(0xFFD0BCFF) : const Color(0xFF8B5CF6);
    final secondaryColor = widget.isDarkMode ? const Color(0xFF45DFA4) : const Color(0xFF34D399);

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF0B1326) : const Color(0xFFFCFAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0 && _currentStep < 5
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: widget.isDarkMode ? Colors.white : const Color(0xFF1E2022),
                  size: 20,
                ),
                onPressed: _prevStep,
              )
            : null,
        title: _currentStep == 0
            ? ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFFD0BCFF), Color(0xFF45DFA4)],
                  ).createShader(bounds);
                },
                child: Text(
                  'trip.mate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              )
            : null,
        centerTitle: true,
        actions: [
          if (_currentStep < 5)
            TextButton(
              onPressed: () {
                // Skip directly to Success
                setState(() {
                  _currentStep = 5;
                });
              },
              child: Text(
                'Skip',
                style: GoogleFonts.plusJakartaSans(
                  color: widget.isDarkMode ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Glowing Mesh Background for Step 0
          if (_currentStep == 0)
            Positioned.fill(
              child: widget.isDarkMode
                  ? RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _meshController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: MeshBackgroundPainter(progress: _meshController.value),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFF8F0),
                            Color(0xFFFCEDE0),
                            Color(0xFFF3E8FF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _currentStep == 0 ? 0 : 24),
                  child: _buildActiveStepWidget(theme, colorScheme, primaryColor, secondaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStepWidget(ThemeData theme, ColorScheme colorScheme, Color primaryColor, Color secondaryColor) {
    switch (_currentStep) {
      case 0:
        return _buildVibeOnboarding(theme, primaryColor, secondaryColor);
      case 1:
        return _buildAuthentication(theme, primaryColor, secondaryColor);
      case 2:
        return _buildOtpVerification(theme, primaryColor, secondaryColor);
      case 3:
        return _buildProfileSetup(theme, primaryColor, secondaryColor);
      case 4:
        return _buildPermissionsFlow(theme, primaryColor, secondaryColor);
      case 5:
        return _buildWelcomeSuccess(theme, primaryColor, secondaryColor);
      default:
        return const SizedBox();
    }
  }

  // --- STEP 0: CHOOSE YOUR VIBE ONBOARDING (SNAPPING CAROUSEL VIBE SELECTION) ---
  Widget _buildVibeOnboarding(ThemeData theme, Color primaryColor, Color secondaryColor) {
    final hasSelection = _selectedVibes.isNotEmpty;

    return Column(
      key: const ValueKey('vibe_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text(
                "what's the vibe for the squad?",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: widget.isDarkMode ? Colors.white : const Color(0xFF1E2022),
                  letterSpacing: -1.2,
                  height: 1.25,
                  shadows: widget.isDarkMode
                      ? [
                          const Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a vibe to help us tailor your trip to Vietnam.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: widget.isDarkMode
                      ? const Color(0xFFCBC3D7)
                      : const Color(0xFF6B7280),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Carousel snapping slider PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _vibeOptions.length,
            itemBuilder: (context, index) {
              final item = _vibeOptions[index];
              final vibeName = item['name']!;
              final vibeDesc = item['desc']!;
              final vibeEmojis = item['emojis']!;
              final vibeImage = item['image']!;
              final isSelected = _selectedVibes.contains(vibeName);

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.12)).clamp(0.0, 1.0);
                  } else {
                    // Initial load offset
                    value = index == 0 ? 1.0 : 0.88;
                  }

                  return Transform.scale(
                    scale: value,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedVibes.remove(vibeName);
                            } else {
                              // Standard Gen Z choice allows select multiple up to 3, but let's toggle beautifully
                              if (_selectedVibes.length < 3) {
                                _selectedVibes.add(vibeName);
                              }
                            }
                          });
                        },
                        child: Container(
                          width: 280,
                          height: 400,
                          decoration: BoxDecoration(
                            color: const Color(0x0EFFFFFF), // bg-white/5
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isSelected
                                  ? secondaryColor // Mint checked border
                                  : Colors.white.withValues(alpha: 0.1),
                              width: isSelected ? 2.5 : 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                              if (isSelected)
                                BoxShadow(
                                  color: secondaryColor.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              // 1. Premium vibe image
                              Positioned.fill(
                                child: Opacity(
                                  opacity: isSelected ? 0.95 : 0.75,
                                  child: CachedNetworkImage(
                                    imageUrl: vibeImage,
                                    fit: BoxFit.cover,
                                    fadeInDuration: const Duration(milliseconds: 400),
                                    placeholder: (context, url) => Container(color: Colors.black12),
                                    errorWidget: (context, url, error) => Container(color: Colors.black54),
                                  ),
                                ),
                              ),

                              // 2. Linear dark background fade for readability
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xD9060E20), // surface-container-lowest
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),

                              // 3. Checked circle overlay in top-right
                              if (isSelected)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black45,
                                    ),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: secondaryColor,
                                      size: 24,
                                    ),
                                  ),
                                ),

                              // 4. Emojis bouncing headers + title & description at the bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Bobbing Bouncing Emojis
                                      AnimatedBuilder(
                                        animation: _bouncingController,
                                        builder: (context, child) {
                                          final value1 = math.sin(_bouncingController.value * math.pi * 2) * 8;
                                          final value2 = math.cos((_bouncingController.value * math.pi * 2) + 0.5) * 6;
                                          
                                          return Row(
                                            children: [
                                              Transform.translate(
                                                offset: Offset(0, value1),
                                                child: Text(
                                                  vibeEmojis.isNotEmpty ? vibeEmojis.substring(0, vibeEmojis.length ~/ 2) : '',
                                                  style: const TextStyle(fontSize: 28),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Transform.translate(
                                                offset: Offset(0, value2),
                                                child: Text(
                                                  vibeEmojis.isNotEmpty ? vibeEmojis.substring(vibeEmojis.length ~/ 2) : '',
                                                  style: const TextStyle(fontSize: 24),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        vibeName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? secondaryColor : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vibeDesc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 13.5,
                                          color: const Color(0xFFCBC3D7), // on-surface-variant
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
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
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Glowing Floating Active Let's Go Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: hasSelection
                  ? const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)], // Soft neon pink to purple
                    )
                  : null,
              color: hasSelection ? null : Colors.white10,
              boxShadow: hasSelection
                  ? [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: hasSelection ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Let's gooo",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasSelection ? Colors.white : Colors.white38,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: hasSelection ? Colors.white : Colors.white38,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  // --- STEP 1: AUTHENTICATION / JOIN THE SQUAD & FORGOT PASSWORD ---
  Widget _buildAuthentication(ThemeData theme, Color primaryColor, Color secondaryColor) {
    if (_isForgotPasswordMode) {
      return Column(
        key: const ValueKey('forgot_step'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'forgot password? 🥺',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "No worries! Enter your email address and we'll send you an OTP code to reset your password.",
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildGlassField(_emailController, 'Enter your email', Icons.mail_outline),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isForgotPasswordMode = false;
                _nextStep(); // Goes to verification code screen
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              'Reset Password',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isForgotPasswordMode = false;
                });
              },
              child: Text(
                'Back to Login',
                style: GoogleFonts.plusJakartaSans(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    final isDark = widget.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2022);
    final subTextColor = isDark ? Colors.white54 : const Color(0xFF6B7280);
    final dividerColor = isDark ? Colors.white10 : Colors.black12;
    final dividerTextColor = isDark ? Colors.white30 : const Color(0xFF9CA3AF);

    return Column(
      key: const ValueKey('auth_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Gradient title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF34D399)],
          ).createShader(bounds),
          child: Text(
            'trip.mate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'welcome to the squad.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 32),

        // Phone input pill row
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.phone_android_outlined,
                  size: 20,
                  color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 8),
              Text(
                '+84',
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? Colors.white70 : const Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: isDark
                    ? Colors.white24
                    : Colors.black.withValues(alpha: 0.15),
              ),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white24 : Colors.black26,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  if (_emailController.text.isNotEmpty) {
                    final phone = _emailController.text.trim();
                    String formattedPhone = phone;
                    if (formattedPhone.startsWith('0')) {
                      formattedPhone = '+84${formattedPhone.substring(1)}';
                    } else if (!formattedPhone.startsWith('+')) {
                      formattedPhone = '+$formattedPhone';
                    }

                    final sendRes = await ApiService.post(
                        '/auth/send-otp', {'phoneNumber': formattedPhone});

                    if (sendRes != null && sendRes['success'] == true) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Mã OTP đã được gửi đến số điện thoại $formattedPhone!'),
                            backgroundColor: secondaryColor,
                          ),
                        );
                        _nextStep();
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Gửi mã OTP thất bại. Vui lòng thử lại.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF34D399)],
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'send code',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: GoogleFonts.inter(color: dividerTextColor, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: dividerColor)),
          ],
        ),
        const SizedBox(height: 20),

        // Full-width Google button
        _buildSocialBtn('Continue with Google', Icons.account_circle_outlined, () {
          _showGoogleLoginSheet(context, primaryColor, secondaryColor);
        }),
        const SizedBox(height: 12),
        // Full-width Apple button
        _buildSocialBtn(
            'Continue with Apple', Icons.apple, () => _nextStep()),

        const SizedBox(height: 28),
        // Footer
        Text.rich(
          TextSpan(
            text: 'By continuing you agree to our ',
            style: GoogleFonts.inter(
              color: subTextColor,
              fontSize: 11.5,
            ),
            children: [
              TextSpan(
                text: 'terms',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'privacy policy',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --- STEP 2: OTP / EMAIL VERIFICATION ---
  Widget _buildOtpVerification(ThemeData theme, Color primaryColor, Color secondaryColor) {
    return Column(
      key: const ValueKey('otp_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'verify code. 🛡️',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the 4-digit verification code we just sent to your account.',
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 48),
        Center(
          child: SizedBox(
            width: 240,
            child: TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 20,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '0000',
                hintStyle: TextStyle(color: Colors.white12, letterSpacing: 20),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24, width: 2)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 3)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Text(
                'Didn\'t receive code?',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 4),
              _otpTimer > 0
                  ? Text(
                      'Resend in ${_otpTimer}s',
                      style: GoogleFonts.plusJakartaSans(color: secondaryColor, fontWeight: FontWeight.bold),
                    )
                  : TextButton(
                      onPressed: _startOtpTimer,
                      child: Text(
                        'Resend OTP Code',
                        style: GoogleFonts.plusJakartaSans(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () async {
            if (_otpController.text.length == 4) {
              final phone = _emailController.text.trim();
              String formattedPhone = phone;
              if (formattedPhone.startsWith('0')) {
                formattedPhone = '+84${formattedPhone.substring(1)}';
              } else if (!formattedPhone.startsWith('+')) {
                formattedPhone = '+$formattedPhone';
              }
              final code = _otpController.text.trim();

              final verifyRes = await ApiService.post('/auth/verify-otp', {
                'phoneNumber': formattedPhone,
                'code': code,
              });

              if (verifyRes != null) {
                if (verifyRes['exists'] == true) {
                  ApiService.authToken = verifyRes['token'];
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '🎉 Welcome back, ${verifyRes['user']['name']}!'),
                        backgroundColor: secondaryColor,
                      ),
                    );
                    setState(() {
                      _currentStep = 5;
                    });
                  }
                } else {
                  _tempSupabaseId = verifyRes['supabaseId'] as String;
                  _tempEmail = verifyRes['email'] as String;
                  _nextStep();
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Xác minh mã OTP thất bại. Mã không đúng hoặc đã hết hạn.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(
            'Verify & Continue',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- STEP 3: USERNAME / PROFILE SETUP (EDIT IDENTITY) ---
  Widget _buildProfileSetup(ThemeData theme, Color primaryColor, Color secondaryColor) {
    return SingleChildScrollView(
      key: const ValueKey('profile_step'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'main character energy. ✨',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Claim your unique travel handles and setup your alter ego name.',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildGlassField(_nameController, 'Alter Ego Name (e.g. Alex)', Icons.face_outlined),
          const SizedBox(height: 16),
          _buildGlassField(_usernameController, 'Unique Username', Icons.alternate_email),
          const SizedBox(height: 32),
          Text(
            'SOCIAL CLOUT',
            style: GoogleFonts.plusJakartaSans(
              color: secondaryColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassField(_instaController, 'Instagram Username', Icons.camera_alt_outlined),
          const SizedBox(height: 12),
          _buildGlassField(_tiktokController, 'TikTok Username', Icons.music_note_outlined),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && _usernameController.text.isNotEmpty) {
                final email = _tempEmail ?? _emailController.text.trim();
                final supabaseId = _tempSupabaseId ?? 'sb-${email.replaceAll('@', '-').replaceAll('.', '-')}';
                
                // Call Register API on the NestJS backend
                final regRes = await ApiService.post('/auth/register', {
                  'email': email,
                  'name': _nameController.text.trim(),
                  'username': _usernameController.text.trim(),
                  'supabaseId': supabaseId,
                  'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDLEui7EjvkHqpOtxT75qvmlSCJ9wccTxZHFnkqbQ7m--E6HGrhKnsJtrL2GDihf2FhhrrhdSQNucxZbDJAO6aLatXSt85bB-l6x9IM5ATjoFNpWUBr8XexKHp-UAg1uq87dPwg4PWZ5YNCMSEEHcd0e_x7apUYsHB94fhhpnv3cua0_DqPuc2VvBOglqhzvDWgph7OzMrHd71mBP4_IYyAJES--uo8nLNq161e_1nhMmkf9ZNHQheEn4QZJGsbcFzUQrlWbUYmDTLA',
                });
                
                if (regRes != null && regRes['token'] != null) {
                  ApiService.authToken = regRes['token'];
                  
                  // If social clout handles were entered, also sync them
                  if (_instaController.text.isNotEmpty || _tiktokController.text.isNotEmpty) {
                    await ApiService.patch('/users/me/social-links', {
                      'instagram': _instaController.text.isNotEmpty
                          ? 'https://instagram.com/${_instaController.text.trim()}'
                          : null,
                      'tiktok': _tiktokController.text.isNotEmpty
                          ? 'https://tiktok.com/@${_tiktokController.text.trim()}'
                          : null,
                    });
                  }
                  
                  _nextStep();
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Alter Ego registration failed. Try a different username.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              'Save Alter Ego',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 4: PERMISSIONS FLOW (DON'T LOSE THE SQUAD 😭) ---
  Widget _buildPermissionsFlow(ThemeData theme, Color primaryColor, Color secondaryColor) {
    return Column(
      key: const ValueKey('perms_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('😭', style: TextStyle(fontSize: 84)),
        const SizedBox(height: 24),
        Text(
          'don\'t lose the squad.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Enable location permissions so the travel group can track your location realtime on the map during the Phú Quốc trip.',
          style: GoogleFonts.inter(color: Colors.white60, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 64),
        ElevatedButton.icon(
          onPressed: _nextStep,
          icon: const Icon(Icons.location_on, color: Colors.white),
          label: Text(
            'Allow Location',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _nextStep,
          child: Text(
            'maybe later.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 5: WELCOME SUCCESS SCREEN ---
  Widget _buildWelcomeSuccess(ThemeData theme, Color primaryColor, Color secondaryColor) {
    return Column(
      key: const ValueKey('success_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🚀', style: TextStyle(fontSize: 84)),
        const SizedBox(height: 24),
        Text(
          'you\'re in the squad!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Onboarding complete! Your alter ego profile is registered. Let\'s start building awesome group travel plans.',
          style: GoogleFonts.inter(color: Colors.white60, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 64),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  isDarkMode: widget.isDarkMode,
                  onThemeToggle: widget.onThemeToggle,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor, // Dynamic Success theme check
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            shadowColor: secondaryColor.withValues(alpha: 0.3),
            elevation: 10,
          ),
          child: Text(
            'Enter the Squad',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Helpers
  Widget _buildGlassField(TextEditingController controller, String placeholder, IconData icon) {
    final isDark = widget.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x0FFFFFFF)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        style: GoogleFonts.plusJakartaSans(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: isDark ? Colors.white30 : Colors.black38,
            size: 20,
          ),
          hintText: placeholder,
          hintStyle: TextStyle(
            color: isDark ? Colors.white24 : Colors.black26,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSocialBtn(String label, IconData icon, VoidCallback onTap) {
    final isDark = widget.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white : Colors.black87,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoogleLoginSheet(BuildContext context, Color primaryColor, Color secondaryColor) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose a Google account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              Text(
                'to continue to trip.mate',
                style: GoogleFonts.inter(fontSize: 13, color: textMuted),
              ),
              const SizedBox(height: 20),
              _buildGoogleProfileRow(
                context,
                'Alex Nguyễn',
                'alex.nguyen@gmail.com',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDLEui7EjvkHqpOtxT75qvmlSCJ9wccTxZHFnkqbQ7m--E6HGrhKnsJtrL2GDihf2FhhrrhdSQNucxZbDJAO6aLatXSt85bB-l6x9IM5ATjoFNpWUBr8XexKHp-UAg1uq87dPwg4PWZ5YNCMSEEHcd0e_x7apUYsHB94fhhpnv3cua0_DqPuc2VvBOglqhzvDWgph7OzMrHd71mBP4_IYyAJES--uo8nLNq161e_1nhMmkf9ZNHQheEn4QZJGsbcFzUQrlWbUYmDTLA',
                primaryColor,
                secondaryColor,
              ),
              const Divider(height: 24),
              _buildGoogleProfileRow(
                context,
                'Minh Thư',
                'minhthu.travels@gmail.com',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuASmUw0WNmnNpHadDogcZUgXrjs6I-bWPczGA7YXzboabdRCE4x2ucpr-rlcHtJOqMkRPHvQ7jfuNOOyvolEQ3g9sD1pN0AIeKq5HQW1oaHU8Q_D__1RhpGFMthOsgU-gQntyeBysmb9GDwUrZtACvinE9dawLVs8qvHa3KORAfaz4DCFJzvbIafzVn7qCJgmXw7WDt2M4ExXkcbFBl8VJZj_3op0Z14zMOYLvkFW0UO2oqIDQ3ucy3HgbdpM-EUlKBSLVraywz-XJw',
                primaryColor,
                secondaryColor,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoogleProfileRow(
    BuildContext context,
    String name,
    String email,
    String avatarUrl,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final isDark = widget.isDarkMode;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? Colors.white60 : Colors.black54;

    return InkWell(
      onTap: () async {
        Navigator.pop(context); // Close bottom sheet
        final response = await ApiService.post('/auth/google', {
          'idToken': 'mock-google-token',
          'email': email,
          'name': name,
          'avatarUrl': avatarUrl,
        });

        if (response != null) {
          if (response['exists'] == true) {
            ApiService.authToken = response['token'];
            if (mounted) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Google Login: Welcome back, $name!'),
                  backgroundColor: secondaryColor,
                ),
              );
              setState(() {
                _currentStep = 5; // Dashboard transition step
              });
            }
          } else {
            // New Google user - store credentials, prefill and go to profile setup
            _tempSupabaseId = response['supabaseId'] as String;
            _tempEmail = response['email'] as String;
            _nameController.text = response['name'] as String;
            _nextStep(); // Goes to Profile setup
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(
                content: Text('❌ Đăng nhập bằng Google thất bại. Vui lòng thử lại.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    email,
                    style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class MeshBackgroundPainter extends CustomPainter {
  final double progress;

  MeshBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Center 1 - Violet
    final center1 = Offset(
      size.width * 0.15 + math.sin(progress * math.pi * 2) * 20,
      size.height * 0.5 + math.cos(progress * math.pi * 2) * 40,
    );
    final radius1 = size.width * 0.8;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF6D3BD7).withValues(alpha: 0.15),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center1, radius: radius1));
    canvas.drawCircle(center1, radius1, paint);

    // Center 2 - Emerald Mint
    final center2 = Offset(
      size.width * 0.85 - math.cos(progress * math.pi * 2) * 30,
      size.height * 0.3 + math.sin(progress * math.pi * 2) * 20,
    );
    final radius2 = size.width * 0.7;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF00BD85).withValues(alpha: 0.1),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center2, radius: radius2));
    canvas.drawCircle(center2, radius2, paint);

    // Center 3 - Coral Orange
    final center3 = Offset(
      size.width * 0.5 + math.sin(progress * math.pi * 2 + 1) * 40,
      size.height * 0.8 - math.cos(progress * math.pi * 2) * 30,
    );
    final radius3 = size.width * 0.75;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFFD97722).withValues(alpha: 0.1),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center3, radius: radius3));
    canvas.drawCircle(center3, radius3, paint);
  }

  @override
  bool shouldRepaint(covariant MeshBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
