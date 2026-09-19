import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../core/theme/responsive.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/network/error_message.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api_service.dart';
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

class _AuthFlowScreenState extends ConsumerState<AuthFlowScreen> {
  int _currentStep =
      0; // 0: Vibe Onboarding, 1: Auth/Forgot, 2: Verification, 3: Profile, 4: Success

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
  bool _isSubmitting = false;

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

  // Premium High-Fidelity Vibes — PhosphorIcons (no hardcoded emoji)
  final List<Map<String, dynamic>> _vibeOptions = [
    {
      'name': 'Chill',
      'desc': 'auth.vibe_chill',
      'icon1': PhosphorIcons.leaf(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.coffee(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuASmUw0WNmnNpHadDogcZUgXrjs6I-bWPczGA7YXzboabdRCE4x2ucpr-rlcHtJOqMkRPHvQ7jfuNOOyvolEQ3g9sD1pN0AIeKq5HQW1oaHU8Q_D__1RhpGFMthOsgU-gQntyeBysmb9GDwUrZtACvinE9dawLVs8qvHa3KORAfaz4DCFJzvbIafzVn7qCJgmXw7WDt2M4ExXkcbFBl8VJZj_3op0Z14zMOYLvkFW0UO2oqIDQ3ucy3HgbdpM-EUlKBSLVraywz-XJw',
    },
    {
      'name': 'Party',
      'desc': 'auth.vibe_party',
      'icon1': PhosphorIcons.confetti(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.martini(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA71vJUK5sVuU14_UX3NCLQgDFwvVTrmg75CeIBMkP7BhRezGjIXjQXjU9gHbyiREBFTkjDpTnu7c4gbgJyl9aLkvR-eR1WmesWgvL7ojln3HmNiDD6nM__Yzk6nQauA3NJKkJDRBbSW5J2ONzxgV-IgTUZ4mQ5Re2DFm0O-tmLsZ8jp0Vgwos0fb6BvVUzbg1_xV70x9gCD6_XPIqALeLAkaKv5VTewB79LOwrAvVGv6Z-z0-6LUoCeYjjTkPoCi2E4YRUOzb89LGV',
    },
    {
      'name': 'Foodie',
      'desc': 'auth.vibe_foodie',
      'icon1': PhosphorIcons.forkKnife(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.flame(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAKnOyCAdHjlxooUW1ElYcNPUVGBsy0hMJG6KlBH-wAxUhVgf5fWccFC2zSkU72m8F91eab7q1okYfePlzR7L9gXex_jd5bH41oNvwc8-NA-EXEBQvB_7LMv-1rmaFdjag8VpM_NxkzJMKCuT5kfVXKWb7hYz9-VbdwUKSvuf8ZBi9gI5k0ggMI1fBhUT61eP6gq1OWPueQFC1YcNm09zlVS37G3I-rWkPJ_VjBw0vg-cKC4iirGwz8-93d3DKJ7wQmjPfq8VE6eE_P',
    },
    {
      'name': 'Nature',
      'desc': 'auth.vibe_nature',
      'icon1': PhosphorIcons.mountains(PhosphorIconsStyle.fill),
      'icon2': PhosphorIcons.tree(PhosphorIconsStyle.fill),
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAOJAn865X2oV_wxI03YpNqwVLe_s1ihBcLfPDB9KjzKYiWHdsWGIW8RKNiRIU2cI5nNUSUKXtgwzeQlqrPqEUqrBJKDh9e59gtDBrNQiWG84213WKSkjd_z9xzuvo6pfYoGRhneGRC29s3gay2LT-BvYO6ZgTPjSAoHx4NxOJVVMpZu-zcBwwZuCoKKdN0wEpN_GQ4tkIHeCPrE0ysLb1iLu9IXovBwDNC8322GooBX-MdAW8pPsPPygxWWJsvv96UF8nSKdRRKxAI',
    },
    {
      'name': 'Adventure',
      'desc': 'auth.vibe_adventure',
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
    final isDark = widget.isDarkMode;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    return Scaffold(
      backgroundColor: isDark
          ? GenZTokens.creamDark
          : GenZTokens.cream,
      appBar: AppBar(
        backgroundColor: GenZTokens.paper.withValues(alpha: 0),
        elevation: 0,
        leading: _currentStep > 0 && _currentStep < 4
            ? IconButton(
                icon: Icon(
                  PhosphorIcons.arrowLeft(),
                  color: isDark
                      ? GenZTokens.inkDark
                      : GenZTokens.ink,
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
                  color: isDark
                      ? GenZTokens.inkDark
                      : GenZTokens.ink,
                  letterSpacing: -1,
                ),
              )
            : null,
        centerTitle: true,
        actions: [
          if (_currentStep < 4)
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
                  color: isDark
                      ? GenZTokens.inkSoftDark
                      : GenZTokens.inkSoft,
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
                color: isDark
                    ? GenZTokens.creamDark
                    : GenZTokens.cream,
              ),
            ),

          // Cuon duoc khi ban phim bat len.
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: GenZTokens.durationBase),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _currentStep == 0 ? 0 : 24,
                  ),
                  child: _buildActiveStepWidget(
                    theme,
                    accent,
                    onAccent,
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
    Color accent,
    Color onAccent,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildVibeOnboarding(theme, accent, onAccent);
      case 1:
        return _buildAuthentication(theme, accent, onAccent);
      case 2:
        return _buildOtpVerification(theme, accent, onAccent);
      case 3:
        return _buildProfileSetup(theme, accent, onAccent);
      case 4:
        return _buildWelcomeSuccess(theme, accent, onAccent);
      default:
        return const SizedBox();
    }
  }

  // --- STEP 0: CHOOSE YOUR VIBE ONBOARDING (SNAPPING CAROUSEL VIBE SELECTION) ---
  Widget _buildVibeOnboarding(
    ThemeData theme,
    Color accent,
    Color onAccent,
  ) {
    final hasSelection = _selectedVibes.isNotEmpty;
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
    final paper = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return Column(
      key: const ValueKey('vibe_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text(
                'onboarding.vibe_question'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.heading(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: ink,
                  letterSpacing: -0.5,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'auth.pick_vibe_sub'.tr(),
                textAlign: TextAlign.center,
                style: AppFonts.body(
                  color: inkSoft,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.52,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _vibeOptions.length,
            itemBuilder: (context, index) {
              final item = _vibeOptions[index];
              final vibeName = item['name'] as String;
              final vibeDesc = (item['desc'] as String).tr();
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
                              if (_selectedVibes.length < 3) {
                                _selectedVibes.add(vibeName);
                              }
                            }
                          });
                        },
                        child: Container(
                          width: context.rs(280),
                          height: context.rs(400),
                          decoration: BoxDecoration(
                            color: paper,
                            borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
                            border: Border.all(
                              color: isSelected ? accent : line,
                              width: isSelected
                                  ? GenZTokens.borderWidth
                                  : GenZTokens.borderWidthThin,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: isSelected ? 0.95 : 0.75,
                                  child: CachedNetworkImage(
                                    imageUrl: vibeImage,
                                    fit: BoxFit.cover,
                                    fadeInDuration: const Duration(
                                      milliseconds: GenZTokens.durationFast,
                                    ),
                                    placeholder: (context, url) => Container(
                                      color: fill,
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: fill,
                                      child: Center(
                                        child: Icon(
                                          vibeIcon1,
                                          size: 64,
                                          color: inkSoft,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Scrim 40% duoi de doc chu tren anh (spec muc 8)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      stops: const [0.6, 1.0],
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.55),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),

                              if (isSelected)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accent,
                                      border: Border.all(
                                        color: onAccent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      PhosphorIcons.check(PhosphorIconsStyle.bold),
                                      color: onAccent,
                                      size: 20,
                                    ),
                                  ),
                                ),

                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            vibeIcon1,
                                            size: 24,
                                            color: isSelected ? accent : Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            vibeIcon2,
                                            size: 20,
                                            color: isSelected
                                                ? accent
                                                : Colors.white.withValues(alpha: 0.85),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        vibeName,
                                        style: AppFonts.heading(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? accent : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vibeDesc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFonts.body(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.85),
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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: hasSelection ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                disabledBackgroundColor: accent.withValues(
                  alpha: isDark ? 0.35 : 0.45,
                ),
                disabledForegroundColor: onAccent.withValues(alpha: 0.7),
                elevation: 0,
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
                          ? onAccent
                          : onAccent.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    PhosphorIcons.arrowRight(),
                    color: hasSelection
                        ? onAccent
                        : onAccent.withValues(alpha: 0.7),
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
    Color accent,
    Color onAccent,
  ) {
    final isDark = widget.isDarkMode;
    final fInk = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final fSub = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

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
              letterSpacing: -0.5,
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
            'auth.email_hint'.tr(),
            PhosphorIcons.envelope(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                if (_isSubmitting) return;
                if (_emailController.text.isNotEmpty) {
                  setState(() {
                    _isSubmitting = true;
                    _isEmailInput = true;
                  });
                  try {
                    final email = _emailController.text.trim();

                    final sendRes = await ApiService.post('/auth/send-otp', {
                      'phoneNumber': email,
                    });

                    if (!mounted) return;
                    if (sendRes != null && sendRes['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('auth.otp_sent_email'.tr(namedArgs: {'email': email})),
                        ),
                      );
                      setState(() {
                        _isForgotPasswordMode = false;
                        _nextStep(); // Goes to verification code screen
                      });
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              child: Text(
                'auth.reset_password'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onAccent,
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
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final textColor = fInk;
    final subTextColor = fSub;
    final dividerColor = line;
    final dividerTextColor = fSub;

    return Column(
      key: const ValueKey('auth_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Official TripMate Logo Mark
        Image.asset(
          isDark
              ? 'assets/images/symbol_dark.png'
              : 'assets/images/symbol_light.png',
          width: 64,
          height: 54,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        // Display title
        Text(
          'trip.mate',
          style: AppFonts.heading(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'auth.welcome'.tr(),
          style: AppFonts.heading(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 32),

        // Phone/Email input row
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
            border: Border.all(
              color: line,
              width: GenZTokens.borderWidthThin,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                _isEmailInput
                    ? PhosphorIcons.envelope()
                    : PhosphorIcons.deviceMobile(),
                size: 20,
                color: subTextColor,
              ),
              if (!_isEmailInput) ...[
                const SizedBox(width: 8),
                Text(
                  '+84',
                  style: AppFonts.heading(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  width: 1,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: line,
                ),
              ] else
                const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppFonts.body(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: _isEmailInput
                        ? 'auth.your_email'.tr()
                        : 'auth.phone_number'.tr(),
                    hintStyle: AppFonts.body(
                      color: subTextColor.withValues(alpha: 0.5),
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
                  if (_isSubmitting) return;
                  if (_emailController.text.isNotEmpty) {
                    setState(() => _isSubmitting = true);
                    try {
                      final input = _emailController.text.trim();
                      final target = _isEmailInput
                          ? input
                          : _formatVnPhone(input);

                      final sendRes = await ApiService.post('/auth/send-otp', {
                        'phoneNumber': target,
                      });

                      if (!mounted) return;
                      if (sendRes != null && sendRes['success'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isEmailInput
                                  ? 'auth.otp_sent_email'.tr(namedArgs: {'email': target})
                                  : 'auth.otp_sent_phone'.tr(namedArgs: {'phone': target}),
                            ),
                          ),
                        );
                        _nextStep();
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                  ),
                  child: Text(
                    'auth.send_code'.tr(),
                    style: AppFonts.heading(
                      color: onAccent,
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
                _isEmailInput ? 'auth.use_phone'.tr() : 'auth.use_email'.tr(),
                style: AppFonts.heading(
                  color: accent,
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
                  color: accent,
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
          PhosphorIcons.userCircle(),
          () {
            _handleRealGoogleSignIn(context, accent, onAccent);
          },
        ),
        const SizedBox(height: 12),
        // Đăng nhập / đăng ký bằng username + mật khẩu
        _buildSocialBtn(
          'auth.use_password'.tr(),
          PhosphorIcons.password(),
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
            text: 'auth.agree_prefix'.tr(),
            style: AppFonts.body(color: subTextColor, fontSize: 12),
            children: [
              TextSpan(
                text: 'auth.terms'.tr(),
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: 'auth.and_sep'.tr()),
              TextSpan(
                text: 'auth.privacy'.tr(),
                style: TextStyle(
                  color: accent,
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
    Color accent,
    Color onAccent,
  ) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
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
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'auth.enter_otp_sent_to'.tr(
            namedArgs: {
              'target': _isEmailInput
                  ? _emailController.text.trim()
                  : _formatVnPhone(_emailController.text.trim()),
            },
          ),
          style: AppFonts.body(color: sub, fontSize: 14),
        ),
        const SizedBox(height: 32),
        // Sticker minh hoạ
        Center(
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft,
              borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
              border: Border.all(color: line, width: GenZTokens.borderWidthThin),
            ),
            child: Icon(
              PhosphorIcons.chatTeardropDots(PhosphorIconsStyle.fill),
              size: 32,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Ô nhập OTP dạng 4 khối
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (i) {
                    final filled = i < code.length;
                    final active = i == code.length;
                    return Container(
                      width: 52,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
                        border: Border.all(
                          color: (active || filled) ? accent : line,
                          width: (active || filled)
                              ? GenZTokens.borderWidth
                              : GenZTokens.borderWidthThin,
                        ),
                      ),
                      child: Text(
                        filled ? code[i] : '',
                        style: AppFonts.heading(
                          fontSize: 24,
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
                width: 250,
                height: 58,
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  autofocus: true,
                  showCursor: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: GenZTokens.paper.withValues(alpha: 0),
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
        const SizedBox(height: 32),
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
                      'auth.otp_resend_in'.tr(namedArgs: {'s': '$_otpTimer'}),
                      style: AppFonts.heading(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                  : TextButton(
                      onPressed: _startOtpTimer,
                      child: Text(
                        'auth.resend_otp'.tr(),
                        style: AppFonts.heading(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              if (_isSubmitting) return;
              if (_otpController.text.length == 4) {
                setState(() => _isSubmitting = true);
                try {
                  final input = _emailController.text.trim();
                  final target = _isEmailInput ? input : _formatVnPhone(input);
                  final code = _otpController.text.trim();

                  final verifyRes = await ApiService.post('/auth/verify-otp', {
                    'phoneNumber': target,
                    'code': code,
                  });

                  if (!mounted) return;

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
                              'auth.welcome_back'.tr(
                                namedArgs: {
                                  'name': '${_tempUser?['name'] ?? ''}',
                                },
                              ),
                            ),
                          ),
                        );
                        setState(() {
                          _currentStep = 4;
                        });
                      }
                    } else {
                      _tempSupabaseId = data['supabaseId']?.toString();
                      _tempEmail = data['email']?.toString();
                      if (mounted) {
                        _nextStep();
                      }
                    }
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isSubmitting = false);
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            child: Text(
              'auth.verify_continue'.tr(),
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onAccent,
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
    Color accent,
    Color onAccent,
  ) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
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
              letterSpacing: -0.5,
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
            'auth.display_name_hint'.tr(),
            PhosphorIcons.smiley(),
          ),
          const SizedBox(height: 16),
          _buildGlassField(
            _usernameController,
            'auth.username_hint'.tr(),
            PhosphorIcons.at(),
          ),
          const SizedBox(height: 32),
          Text(
            'auth.social_links'.tr(),
            style: AppFonts.heading(
              color: sub,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassField(
            _instaController,
            'auth.instagram_hint'.tr(),
            PhosphorIcons.camera(),
          ),
          const SizedBox(height: 12),
          _buildGlassField(
            _tiktokController,
            'auth.tiktok_hint'.tr(),
            PhosphorIcons.musicNote(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                if (_isSubmitting) return;
                if (_nameController.text.isNotEmpty &&
                    _usernameController.text.isNotEmpty) {
                  setState(() => _isSubmitting = true);
                  try {
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
                      'avatarUrl':
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_nameController.text.trim())}&background=FFD84D&color=141210&bold=true&size=256',
                    });

                    if (!mounted) return;

                    final regData = (regRes is Map && regRes['data'] is Map)
                        ? (regRes['data'] as Map).cast<String, dynamic>()
                        : (regRes is Map ? regRes.cast<String, dynamic>() : null);
                    if (regData != null && regData['token'] != null) {
                      _tempAuthToken = regData['token'].toString();
                      _tempUser = (regData['user'] as Map?)
                          ?.cast<String, dynamic>();

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
                        if (!mounted) return;
                      }

                      _nextStep();
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
                ),
              ),
              child: Text(
                'auth.save_profile'.tr(),
                style: AppFonts.heading(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 4: WELCOME SUCCESS SCREEN ---
  Widget _buildWelcomeSuccess(
    ThemeData theme,
    Color accent,
    Color onAccent,
  ) {
    final isDark = widget.isDarkMode;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final sub = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;

    return Column(
      key: const ValueKey('success_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? GenZTokens.accentSoftDark : GenZTokens.accentSoft,
            shape: BoxShape.circle,
            border: Border.all(color: line, width: GenZTokens.borderWidthThin),
          ),
          child: Icon(
            PhosphorIcons.rocketLaunch(PhosphorIconsStyle.fill),
            size: 40,
            color: accent,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'auth.done_title'.tr(),
          style: AppFonts.heading(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'auth.done_sub'.tr(),
          style: AppFonts.body(color: sub, fontSize: 14, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (_tempAuthToken == null) {
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
              backgroundColor: accent,
              foregroundColor: onAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
              ),
            ),
            child: Text(
              'auth.enter_app'.tr(),
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onAccent,
              ),
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
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(GenZTokens.radiusInput),
        border: Border.all(color: line, width: GenZTokens.borderWidthThin),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        style: AppFonts.body(
          color: ink,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          icon: Icon(icon, color: inkSoft, size: 20),
          hintText: placeholder,
          hintStyle: AppFonts.body(
            color: inkSoft.withValues(alpha: 0.5),
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
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? GenZTokens.paperDark : GenZTokens.paper,
          borderRadius: BorderRadius.circular(GenZTokens.radiusButton),
          border: Border.all(color: line, width: GenZTokens.borderWidthThin),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ink, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppFonts.heading(
                color: ink,
                fontWeight: FontWeight.w600,
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
    Color accent,
    Color onAccent,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null || !mounted) return;

      final auth = await account.authentication;
      if (!mounted) return;
      final idToken = auth.idToken;

      if (idToken == null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('auth.google_no_token'.tr()),
            backgroundColor: widget.isDarkMode
                ? GenZTokens.dangerDark
                : GenZTokens.danger,
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

      if (!mounted) return;

      final data = (response is Map && response['data'] is Map)
          ? (response['data'] as Map).cast<String, dynamic>()
          : (response is Map ? response.cast<String, dynamic>() : null);
      if (data != null) {
        if (data['exists'] == true) {
          _tempAuthToken = data['token']?.toString();
          _tempUser = (data['user'] as Map?)?.cast<String, dynamic>();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'auth.welcome_back'.tr(
                  namedArgs: {'name': account.displayName ?? ''},
                ),
              ),
            ),
          );
          if (mounted) setState(() => _currentStep = 4);
        } else {
          _tempSupabaseId = data['supabaseId']?.toString();
          _tempEmail = data['email']?.toString() ?? account.email;
          _nameController.text =
              data['name']?.toString() ?? account.displayName ?? '';
          if (mounted) setState(() => _currentStep = 3);
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('auth.google_signin_failed'.tr(namedArgs: {'err': friendlyError(e)})),
            backgroundColor: widget.isDarkMode
                ? GenZTokens.dangerDark
                : GenZTokens.danger,
          ),
        );
      }
    }
  }
}
