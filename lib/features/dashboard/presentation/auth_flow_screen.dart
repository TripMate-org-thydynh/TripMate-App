import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/network/error_message.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/gen_z_tokens.dart';
import 'password_auth_screen.dart';

/// Chuẩn hoá SĐT về dạng quốc tế +84 (UI luôn hiển thị +84).
/// Fix bug cũ: số không có '0'/'+' đứng đầu bị thiếu mã quốc gia 84.
String _formatVnPhone(String raw) {
  final s = raw.trim().replaceAll(' ', '');
  if (s.startsWith('+')) return s;
  final digits = s.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0')) return '+84${digits.substring(1)}';
  if (digits.startsWith('84')) return '+$digits';
  return '+84$digits';
}

class AuthFlowScreen extends ConsumerStatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const AuthFlowScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ConsumerState<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends ConsumerState<AuthFlowScreen>
    with TickerProviderStateMixin {
  int _currentStep =
      0; // 0: Vibe Onboarding, 1: Auth/Forgot, 2: Verification, 3: Profile, 4: Permissions, 5: Success

  // State variables for inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _instaController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();

  final List<String> _selectedVibes = [];
  bool _isForgotPasswordMode = false;
  bool _isEmailInput = false;

  // serverClientId KHÔNG được hỗ trợ trên Web (client ID lấy từ meta tag
  // google-signin-client_id trong web/index.html). Chỉ truyền trên mobile.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: kIsWeb
        ? null
        : '1072006483967-ivo0843uk7j8a557l18eevr4q2clargm.apps.googleusercontent.com',
    scopes: const ['email', 'profile'],
  );
  String? _tempSupabaseId;
  String? _tempEmail;
  String? _tempAuthToken;
  Map<String, dynamic>? _tempUser;
  int _otpTimer = 30;
  Timer? _timer;

  late PageController _pageController;
  late AnimationController _bouncingController;
  late AnimationController _meshController;

  // Premium High-Fidelity Vibes — PhosphorIcons (no hardcoded emoji)
  final List<Map<String, dynamic>> _vibeOptions = [
    {
      'name': 'Chill',
      'desc': 'Resorts, spas, and slow mornings in Hội An.',
      'icon1': PhosphorIcons.leaf(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.coffee(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuASmUw0WNmnNpHadDogcZUgXrjs6I-bWPczGA7YXzboabdRCE4x2ucpr-rlcHtJOqMkRPHvQ7jfuNOOyvolEQ3g9sD1pN0AIeKq5HQW1oaHU8Q_D__1RhpGFMthOsgU-gQntyeBysmb9GDwUrZtACvinE9dawLVs8qvHa3KORAfaz4DCFJzvbIafzVn7qCJgmXw7WDt2M4ExXkcbFBl8VJZj_3op0Z14zMOYLvkFW0UO2oqIDQ3ucy3HgbdpM-EUlKBSLVraywz-XJw',
    },
    {
      'name': 'Party',
      'desc': 'Bùi Viện nights and rooftop bars in Saigon.',
      'icon1': PhosphorIcons.confetti(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.martini(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA71vJUK5sVuU14_UX3NCLQgDFwvVTrmg75CeIBMkP7BhRezGjIXjQXjU9gHbyiREBFTkjDpTnu7c4gbgJyl9aLkvR-eR1WmesWgvL7ojln3HmNiDD6nM__Yzk6nQauA3NJKkJDRBbSW5J2ONzxgV-IgTUZ4mQ5Re2DFm0O-tmLsZ8jp0Vgwos0fb6BvVUzbg1_xV70x9gCD6_XPIqALeLAkaKv5VTewB79LOwrAvVGv6Z-z0-6LUoCeYjjTkPoCi2E4YRUOzb89LGV',
    },
    {
      'name': 'Foodie',
      'desc': 'Street food tours and hidden Pho spots in Hanoi.',
      'icon1': PhosphorIcons.forkKnife(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.flame(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAKnOyCAdHjlxooUW1ElYcNPUVGBsy0hMJG6KlBH-wAxUhVgf5fWccFC2zSkU72m8F91eab7q1okYfePlzR7L9gXex_jd5bH41oNvwc8-NA-EXEBQvB_7LMv-1rmaFdjag8VpM_NxkzJMKCuT5kfVXKWb7hYz9-VbdwUKSvuf8ZBi9gI5k0ggMI1fBhUT61eP6gq1OWPueQFC1YcNm09zlVS37G3I-rWkPJ_VjBw0vg-cKC4iirGwz8-93d3DKJ7wQmjPfq8VE6eE_P',
    },
    {
      'name': 'Nature',
      'desc': 'Ha Long Bay cruises and Sapa rice terraces.',
      'icon1': PhosphorIcons.mountains(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.tree(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAOJAn865X2oV_wxI03YpNqwVLe_s1ihBcLfPDB9KjzKYiWHdsWGIW8RKNiRIU2cI5nNUSUKXtgwzeQlqrPqEUqrBJKDh9e59gtDBrNQiWG84213WKSkjd_z9xzuvo6pfYoGRhneGRC29s3gay2LT-BvYO6ZgTPjSAoHx4NxOJVVMpZu-zcBwwZuCoKKdN0wEpN_GQ4tkIHeCPrE0ysLb1iLu9IXovBwDNC8322GooBX-MdAW8pPsPPygxWWJsvv96UF8nSKdRRKxAI',
    },
    {
      'name': 'Adventure',
      'desc': 'Ha Giang loop and exploring Son Doong cave.',
      'icon1': PhosphorIcons.compass(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.backpack(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAFHi6VoKpw5K_xKZ6YruS2o3QejCMoBXiYBdgIiq18216st17gBSU3zbjHf9RNCpby9b7bxqfKg2-W0htgSUF2V8BsxTpQ27yI2vLDmD3N6v072ExHY5ZHTW5DPDdQxSogk3MtuNHLf8MKGdePieA0GEXbWzjSt6m0mUTgc83WqGmK8Jbh331Ryz7ZKDxLL0xyLq3J0ssDe-qDi9tdWPI1gR7kL6IkqrCcU_nKr2EU3WrxlqB9uuUrfEH4CoNr3zZiJr8lW395lYYm',
    },
  ];

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailInputChanged);
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

  void _onEmailInputChanged() {
    final text = _emailController.text.trim();
    if (text.isEmpty) return;
    final isEmail = text.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(text);
    if (isEmail != _isEmailInput) {
      setState(() {
        _isEmailInput = isEmail;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailInputChanged);
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
    final accent = ref.watch(accentProvider);
    final primaryColor = accent.accent;
    final secondaryColor = accent.lightSoft;

    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? const Color(0xFF1A1712)
          : accent.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0 && _currentStep < 5
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: widget.isDarkMode
                      ? Colors.white
                      : const Color(0xFF141210),
                  size: 20,
                ),
                onPressed: _prevStep,
              )
            : null,
        title: _currentStep == 0
            ? Text(
                'trip.mate',
                style: AppFonts.heading(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: widget.isDarkMode
                      ? const Color(0xFFFDF6D3)
                      : const Color(0xFF141210),
                  letterSpacing: -1,
                ),
              )
            : null,
        centerTitle: true,
        actions: [
          if (_currentStep < 5)
            TextButton(
              onPressed: () {
                // Skip vibe selection only — still need to sign in
                setState(() {
                  _currentStep = 1;
                });
              },
              child: Text(
                'auth.skip'.tr(),
                style: AppFonts.heading(
                  color: widget.isDarkMode ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Nền khối màu phẳng cho Step 0 (không mesh gradient)
          if (_currentStep == 0)
            Positioned.fill(
              child: Container(
                color: widget.isDarkMode
                    ? const Color(0xFF1A1712)
                    : accent.lightBackground,
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _currentStep == 0 ? 0 : 24,
                  ),
                  child: _buildActiveStepWidget(
                    theme,
                    primaryColor,
                    secondaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStepWidget(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
  ) {
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
  Widget _buildVibeOnboarding(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
  ) {
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
                "squad muốn đi kiểu gì?",
                textAlign: TextAlign.center,
                style: AppFonts.heading(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: widget.isDarkMode
                      ? Colors.white
                      : const Color(0xFF141210),
                  letterSpacing: -1.2,
                  height: 1.25,
                  shadows: widget.isDarkMode
                      ? [
                          const Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'auth.pick_vibe_sub'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  color: widget.isDarkMode
                      ? const Color(0xFFCBC3D7)
                      : const Color(0xFF4A453E),
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
              final vibeName = item['name'] as String;
              final vibeDesc = item['desc'] as String;
              final vibeIcon1 = item['icon1'] as IconData;
              final vibeIcon2 = item['icon2'] as IconData;
              final vibeImage = item['image'] as String;
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
                            color: const Color(0xFFFFFDF5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: widget.isDarkMode
                                  ? const Color(0xFFFDF6D3)
                                  : const Color(0xFF141210),
                              width: isSelected ? 3 : 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.isDarkMode
                                    ? const Color(0xFFFDF6D3)
                                    : const Color(0xFF141210),
                                offset: Offset(0, isSelected ? 6 : 4),
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
                                    fadeInDuration: const Duration(
                                      milliseconds: 400,
                                    ),
                                    placeholder: (context, url) =>
                                        Container(color: Colors.black12),
                                    errorWidget: (context, url, error) =>
                                        Container(color: Colors.black54),
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
                                        Color(
                                          0xD9060E20,
                                        ), // surface-container-lowest
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
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primaryColor,
                                      border: Border.all(
                                        color: const Color(0xFF141210),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Color(0xFF141210),
                                      size: 22,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Bobbing Bouncing Icons (PhosphorIcons)
                                      AnimatedBuilder(
                                        animation: _bouncingController,
                                        builder: (context, child) {
                                          final value1 =
                                              math.sin(
                                                _bouncingController.value *
                                                    math.pi *
                                                    2,
                                              ) *
                                              8;
                                          final value2 =
                                              math.cos(
                                                (_bouncingController.value *
                                                        math.pi *
                                                        2) +
                                                    0.5,
                                              ) *
                                              6;
                                          return Row(
                                            children: [
                                              Transform.translate(
                                                offset: Offset(0, value1),
                                                child: Icon(
                                                  vibeIcon1,
                                                  size: 28,
                                                  color: isSelected
                                                      ? secondaryColor
                                                      : Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Transform.translate(
                                                offset: Offset(0, value2),
                                                child: Icon(
                                                  vibeIcon2,
                                                  size: 24,
                                                  color: isSelected
                                                      ? secondaryColor
                                                      : Colors.white70,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        vibeName,
                                        style: AppFonts.heading(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? secondaryColor
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vibeDesc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.body(
                                          fontSize: 13.5,
                                          color: const Color(
                                            0xFFCBC3D7,
                                          ), // on-surface-variant
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
              borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              color: hasSelection
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.4),
              border: Border.all(
                color: widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink,
                width: GenZTokens.borderWidth,
              ),
              boxShadow: hasSelection
                  ? GenZTokens.hardShadow(
                      widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink,
                    )
                  : null,
            ),
            child: ElevatedButton(
              onPressed: hasSelection ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'auth.lets_go'.tr(),
                    style: AppFonts.heading(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: hasSelection
                          ? GenZTokens.ink
                          : GenZTokens.ink.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: hasSelection
                        ? GenZTokens.ink
                        : GenZTokens.ink.withValues(alpha: 0.5),
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
  Widget _buildAuthentication(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final fInk = widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    final fSub = widget.isDarkMode
        ? GenZTokens.inkSoftDark
        : GenZTokens.inkSoft;
    if (_isForgotPasswordMode) {
      return Column(
        key: const ValueKey('forgot_step'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'auth.forgot_title'.tr(),
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: fInk,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'auth.forgot_sub'.tr(),
            style: AppFonts.body(color: fSub, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildGlassField(
            _emailController,
            'Nhập email của bạn',
            Icons.mail_outline,
          ),
          const SizedBox(height: 24),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: fInk, width: GenZTokens.borderWidth),
              boxShadow: GenZTokens.hardShadow(fInk),
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (_emailController.text.isNotEmpty) {
                  final email = _emailController.text.trim();
                  setState(() {
                    _isEmailInput = true;
                  });

                  final sendRes = await ApiService.post('/auth/send-otp', {
                    'phoneNumber': email,
                  });

                  if (sendRes != null && sendRes['success'] == true) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mã OTP đã được gửi đến email $email!'),
                          backgroundColor: secondaryColor,
                        ),
                      );
                      setState(() {
                        _isForgotPasswordMode = false;
                        _nextStep(); // Goes to verification code screen
                      });
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('auth.otp_send_failed'.tr()),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: fInk,
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'auth.reset_password'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: fInk,
                ),
              ),
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
                'auth.back_to_login'.tr(),
                style: AppFonts.heading(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final isDark = widget.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF141210);
    final subTextColor = isDark ? Colors.white54 : const Color(0xFF4A453E);
    final dividerColor = isDark ? Colors.white10 : Colors.black12;
    final dividerTextColor = isDark ? Colors.white30 : const Color(0xFFB8AE9C);

    return Column(
      key: const ValueKey('auth_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Display title đen đậm
        Text(
          'trip.mate',
          style: AppFonts.heading(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink,
            letterSpacing: -1.5,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'auth.welcome'.tr(),
          style: AppFonts.heading(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 32),

        // Phone/Email input pill row — paper viền ink
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isDark ? GenZTokens.inkDark : GenZTokens.ink,
              width: GenZTokens.borderWidthThin,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                _isEmailInput
                    ? Icons.mail_outline
                    : Icons.phone_android_outlined,
                size: 20,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              if (!_isEmailInput) ...[
                const SizedBox(width: 8),
                Text(
                  '+84',
                  style: AppFonts.heading(
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
              ] else
                const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppFonts.heading(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _isEmailInput ? 'Email của bạn' : 'Số điện thoại',
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
                    final input = _emailController.text.trim();
                    final target = _isEmailInput
                        ? input
                        : _formatVnPhone(input);

                    final sendRes = await ApiService.post('/auth/send-otp', {
                      'phoneNumber': target,
                    });

                    if (sendRes != null && sendRes['success'] == true) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isEmailInput
                                  ? 'Mã OTP đã được gửi đến email $target!'
                                  : 'Mã OTP đã được gửi đến số điện thoại $target!',
                            ),
                            backgroundColor: secondaryColor,
                          ),
                        );
                        _nextStep();
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('auth.otp_send_failed'.tr()),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'auth.send_code'.tr(),
                    style: AppFonts.heading(
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isEmailInput = !_isEmailInput;
                  _emailController.clear();
                });
              },
              child: Text(
                _isEmailInput ? 'Đăng nhập bằng SĐT' : 'Đăng nhập bằng Email',
                style: AppFonts.heading(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isForgotPasswordMode = true;
                });
              },
              child: Text(
                'auth.forgot_link'.tr(),
                style: AppFonts.heading(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'auth.or_sign_in_with'.tr(),
                style: AppFonts.body(color: dividerTextColor, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: dividerColor)),
          ],
        ),
        const SizedBox(height: 20),

        // Full-width Google button
        _buildSocialBtn(
          'auth.continue_google'.tr(),
          Icons.account_circle_outlined,
          () {
            _handleRealGoogleSignIn(context, primaryColor, secondaryColor);
          },
        ),
        const SizedBox(height: 12),
        // Đăng nhập / đăng ký bằng username + mật khẩu
        _buildSocialBtn(
          'Dùng tài khoản & mật khẩu',
          Icons.password_rounded,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PasswordAuthScreen(isDarkMode: widget.isDarkMode),
            ),
          ),
        ),

        const SizedBox(height: 28),
        // Footer
        Text.rich(
          TextSpan(
            text: 'Khi tiếp tục bạn đồng ý với ',
            style: AppFonts.body(color: subTextColor, fontSize: 11.5),
            children: [
              TextSpan(
                text: 'điều khoản',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' và '),
              TextSpan(
                text: 'chính sách bảo mật',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // --- STEP 2: OTP / EMAIL VERIFICATION ---
  Widget _buildOtpVerification(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final ink = widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = widget.isDarkMode ? GenZTokens.paperDark : GenZTokens.paper;
    final code = _otpController.text;

    return Column(
      key: const ValueKey('otp_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'auth.verify_title'.tr(),
          style: AppFonts.heading(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Nhập mã 4 chữ số vừa gửi tới ${_isEmailInput ? _emailController.text.trim() : _formatVnPhone(_emailController.text.trim())}.',
          style: AppFonts.body(color: sub, fontSize: 14),
        ),
        const SizedBox(height: 36),
        // Sticker minh hoạ để lấp khoảng trống giữa màn
        Center(
          child: Container(
            width: 78,
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: ink, width: GenZTokens.borderWidth),
              boxShadow: GenZTokens.hardShadow(ink),
            ),
            child: Icon(Icons.sms_rounded, size: 40, color: ink),
          ),
        ),
        const SizedBox(height: 32),
        // Ô nhập OTP dạng 4 khối brutalist — TextField ẩn bắt phím,
        // hiển thị từng chữ số lên các khối viền đậm ở trên.
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 260,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (i) {
                    final filled = i < code.length;
                    final active = i == code.length;
                    return Container(
                      width: 56,
                      height: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (active || filled) ? primaryColor : ink,
                          width: GenZTokens.borderWidth,
                        ),
                        boxShadow: GenZTokens.hardShadow(ink),
                      ),
                      child: Text(
                        filled ? code[i] : '',
                        style: AppFonts.heading(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // TextField trong suốt phủ lên, bắt input + focus khi chạm.
              SizedBox(
                width: 260,
                height: 68,
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  // keyboardType chỉ gợi ý bàn phím — vẫn dán/gõ được chữ nếu không lọc.
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  autofocus: true,
                  showCursor: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.transparent,
                    height: 0.01,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Text(
                'auth.no_code'.tr(),
                style: AppFonts.body(color: sub, fontSize: 13),
              ),
              const SizedBox(height: 4),
              _otpTimer > 0
                  ? Text(
                      'Gửi lại sau ${_otpTimer}s',
                      style: AppFonts.heading(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : TextButton(
                      onPressed: _startOtpTimer,
                      child: Text(
                        'auth.resend_otp'.tr(),
                        style: AppFonts.heading(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        const Spacer(),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ink, width: GenZTokens.borderWidth),
            boxShadow: GenZTokens.hardShadow(ink),
          ),
          child: ElevatedButton(
            onPressed: () async {
              if (_otpController.text.length == 4) {
                final input = _emailController.text.trim();
                final target = _isEmailInput ? input : _formatVnPhone(input);
                final code = _otpController.text.trim();

                final verifyRes = await ApiService.post('/auth/verify-otp', {
                  'phoneNumber': target,
                  'code': code,
                });

                // Backend bọc response trong {success, data:{...}} → unwrap data.
                final data = (verifyRes is Map && verifyRes['data'] is Map)
                    ? (verifyRes['data'] as Map).cast<String, dynamic>()
                    : (verifyRes is Map
                          ? verifyRes.cast<String, dynamic>()
                          : null);
                if (data != null) {
                  if (data['exists'] == true) {
                    _tempAuthToken = data['token']?.toString();
                    _tempUser = (data['user'] as Map?)?.cast<String, dynamic>();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Chào mừng trở lại, ${_tempUser?['name'] ?? ''}!',
                          ),
                          backgroundColor: secondaryColor,
                        ),
                      );
                      setState(() {
                        _currentStep = 5;
                      });
                    }
                  } else {
                    _tempSupabaseId = data['supabaseId']?.toString();
                    _tempEmail = data['email']?.toString();
                    _nextStep();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('auth.otp_invalid'.tr()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: GenZTokens.ink,
              elevation: 0,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'auth.verify_continue'.tr(),
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: GenZTokens.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STEP 3: USERNAME / PROFILE SETUP (EDIT IDENTITY) ---
  Widget _buildProfileSetup(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final ink = widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    return SingleChildScrollView(
      key: const ValueKey('profile_step'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'auth.main_character'.tr(),
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ink,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'auth.pick_username'.tr(),
            style: AppFonts.body(color: sub, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildGlassField(
            _nameController,
            'Tên hiển thị (vd: Minh)',
            Icons.face_outlined,
          ),
          const SizedBox(height: 16),
          _buildGlassField(
            _usernameController,
            'Username độc nhất',
            Icons.alternate_email,
          ),
          const SizedBox(height: 32),
          Text(
            'auth.social_links'.tr(),
            style: AppFonts.heading(
              color: secondaryColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassField(
            _instaController,
            'Username Instagram',
            Icons.camera_alt_outlined,
          ),
          const SizedBox(height: 12),
          _buildGlassField(
            _tiktokController,
            'Username TikTok',
            Icons.music_note_outlined,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty &&
                  _usernameController.text.isNotEmpty) {
                final rawInput = _emailController.text.trim();
                final String email;
                final String supabaseId;

                if (_tempEmail != null) {
                  email = _tempEmail!;
                } else if (_isEmailInput) {
                  email = rawInput;
                } else {
                  final formattedPhone = _formatVnPhone(rawInput);
                  email =
                      '${formattedPhone.replaceAll('+', '')}@phone.tripmate.com';
                }

                if (_tempSupabaseId != null) {
                  supabaseId = _tempSupabaseId!;
                } else if (_isEmailInput) {
                  supabaseId =
                      'sb-email-${rawInput.replaceAll('@', '-').replaceAll('.', '-')}';
                } else {
                  final formattedPhone = _formatVnPhone(rawInput);
                  supabaseId =
                      'sb-${formattedPhone.replaceAll('+', '').replaceAll(' ', '')}';
                }

                // Call Register API on the NestJS backend
                final regRes = await ApiService.post('/auth/register', {
                  'email': email,
                  'name': _nameController.text.trim(),
                  'username': _usernameController.text.trim(),
                  'supabaseId': supabaseId,
                  // Avatar sinh theo tên (không gán ảnh stock giả).
                  'avatarUrl':
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_nameController.text.trim())}&background=FFD84D&color=141210&bold=true&size=256',
                });

                // Backend bọc response trong {success, data:{...}} → unwrap.
                final regData = (regRes is Map && regRes['data'] is Map)
                    ? (regRes['data'] as Map).cast<String, dynamic>()
                    : (regRes is Map ? regRes.cast<String, dynamic>() : null);
                if (regData != null && regData['token'] != null) {
                  _tempAuthToken = regData['token'].toString();
                  _tempUser = (regData['user'] as Map?)
                      ?.cast<String, dynamic>();

                  // If social clout handles were entered, also sync them
                  if (_instaController.text.isNotEmpty ||
                      _tiktokController.text.isNotEmpty) {
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
                      SnackBar(
                        content: Text('auth.signup_failed'.tr()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: GenZTokens.ink,
              elevation: 0,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 56),
              side: BorderSide(color: ink, width: GenZTokens.borderWidth),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'auth.save_profile'.tr(),
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: GenZTokens.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 4: PERMISSIONS FLOW (DON'T LOSE THE SQUAD 😭) ---
  Widget _buildPermissionsFlow(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final ink = widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    return Column(
      key: const ValueKey('perms_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('😭', style: TextStyle(fontSize: 84)),
        const SizedBox(height: 24),
        Text(
          'auth.location_title'.tr(),
          style: AppFonts.heading(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'auth.location_sub'.tr(),
          style: AppFonts.body(color: sub, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 64),
        ElevatedButton.icon(
          onPressed: _nextStep,
          icon: Icon(Icons.location_on, color: GenZTokens.ink),
          label: Text(
            'auth.allow_location'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GenZTokens.ink,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: GenZTokens.ink,
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: ink, width: GenZTokens.borderWidth),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _nextStep,
          child: Text(
            'auth.later'.tr(),
            style: AppFonts.heading(color: sub, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- STEP 5: WELCOME SUCCESS SCREEN ---
  Widget _buildWelcomeSuccess(
    ThemeData theme,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final ink = widget.isDarkMode ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = widget.isDarkMode ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    return Column(
      key: const ValueKey('success_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: ink, width: GenZTokens.borderWidth),
          ),
          child: Icon(
            PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill),
            size: 52,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'auth.done_title'.tr(),
          style: AppFonts.heading(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'auth.done_sub'.tr(),
          style: AppFonts.body(color: sub, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 64),
        ElevatedButton(
          onPressed: () {
            if (_tempAuthToken == null) {
              // No real token — redirect back to sign in
              setState(() => _currentStep = 1);
              return;
            }
            final user =
                _tempUser ??
                {
                  'email': _tempEmail ?? _emailController.text.trim(),
                  'name': _nameController.text.trim().isEmpty
                      ? 'Traveller'
                      : _nameController.text.trim(),
                  'username': _usernameController.text.trim().isEmpty
                      ? 'traveller'
                      : _usernameController.text.trim(),
                };
            ref.read(authProvider.notifier).setSession(_tempAuthToken!, user);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: GenZTokens.ink,
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: ink, width: GenZTokens.borderWidth),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Colors.transparent,
            elevation: 0,
          ),
          child: Text(
            'auth.enter_app'.tr(),
            style: AppFonts.heading(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GenZTokens.ink,
            ),
          ),
        ),
      ],
    );
  }

  // Helpers
  Widget _buildGlassField(
    TextEditingController controller,
    String placeholder,
    IconData icon,
  ) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
        borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
        border: Border.all(color: ink, width: GenZTokens.borderWidthThin),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        style: AppFonts.body(
          color: ink,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: ink.withValues(alpha: 0.5), size: 20),
          hintText: placeholder,
          hintStyle: AppFonts.body(
            color: ink.withValues(alpha: 0.4),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSocialBtn(String label, IconData icon, VoidCallback onTap) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
          border: Border.all(color: ink, width: GenZTokens.borderWidth),
          boxShadow: GenZTokens.hardShadow(ink),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ink, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppFonts.heading(
                color: ink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRealGoogleSignIn(
    BuildContext context,
    Color primaryColor,
    Color secondaryColor,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return;

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('auth.google_no_token'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final response = await ApiService.post('/auth/google', {
        'idToken': idToken,
        'email': account.email,
        'name': account.displayName ?? '',
        'avatarUrl': account.photoUrl ?? '',
      });

      // Backend bọc response trong {success, data:{...}} → unwrap data.
      final data = (response is Map && response['data'] is Map)
          ? (response['data'] as Map).cast<String, dynamic>()
          : (response is Map ? response.cast<String, dynamic>() : null);
      if (data != null) {
        if (data['exists'] == true) {
          _tempAuthToken = data['token']?.toString();
          _tempUser = (data['user'] as Map?)?.cast<String, dynamic>();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Chào mừng trở lại, ${account.displayName}!'),
              backgroundColor: secondaryColor,
            ),
          );
          if (mounted) setState(() => _currentStep = 5);
        } else {
          _tempSupabaseId = data['supabaseId']?.toString();
          _tempEmail = data['email']?.toString() ?? account.email;
          _nameController.text =
              data['name']?.toString() ?? account.displayName ?? '';
          // Google đã xác thực danh tính → BỎ QUA bước OTP (step 2),
          // sang thẳng bước hồ sơ (step 3).
          if (mounted) setState(() => _currentStep = 3);
        }
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('auth.google_failed'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi Google Sign-In: ${friendlyError(e)}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

class MeshBackgroundPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  MeshBackgroundPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Center 1 - accent blob
    final center1 = Offset(
      size.width * 0.15 + math.sin(progress * math.pi * 2) * 20,
      size.height * 0.5 + math.cos(progress * math.pi * 2) * 40,
    );
    final radius1 = size.width * 0.8;
    paint.shader = RadialGradient(
      colors: [accentColor.withValues(alpha: 0.18), Colors.transparent],
    ).createShader(Rect.fromCircle(center: center1, radius: radius1));
    canvas.drawCircle(center1, radius1, paint);

    // Center 2 - accent lighter blob
    final center2 = Offset(
      size.width * 0.85 - math.cos(progress * math.pi * 2) * 30,
      size.height * 0.3 + math.sin(progress * math.pi * 2) * 20,
    );
    final radius2 = size.width * 0.7;
    paint.shader = RadialGradient(
      colors: [accentColor.withValues(alpha: 0.10), Colors.transparent],
    ).createShader(Rect.fromCircle(center: center2, radius: radius2));
    canvas.drawCircle(center2, radius2, paint);

    // Center 3 - accent warm blob
    final center3 = Offset(
      size.width * 0.5 + math.sin(progress * math.pi * 2 + 1) * 40,
      size.height * 0.8 - math.cos(progress * math.pi * 2) * 30,
    );
    final radius3 = size.width * 0.75;
    paint.shader = RadialGradient(
      colors: [accentColor.withValues(alpha: 0.08), Colors.transparent],
    ).createShader(Rect.fromCircle(center: center3, radius: radius3));
    canvas.drawCircle(center3, radius3, paint);
  }

  @override
  bool shouldRepaint(covariant MeshBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor;
}
