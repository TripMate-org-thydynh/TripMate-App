import '../../../core/theme/theme.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/api_service.dart';

class ReferralRewardsScreen extends StatefulWidget {
  const ReferralRewardsScreen({super.key});

  @override
  State<ReferralRewardsScreen> createState() => _ReferralRewardsScreenState();
}

class _ReferralRewardsScreenState extends State<ReferralRewardsScreen> {
  final _codeController = TextEditingController();
  bool _isSubmitting = false;

  // Rỗng: chưa có API danh sách người được giới thiệu. Trước đây liệt kê
  // "Hoàng Yến 🌸" và "Phú Khang 🍕" như thể user đã mời được 2 người.
  final List<Map<String, String>> _referrals = [];

  Future<void> _submitReferralCode() async {
    final text = _codeController.text.trim().toUpperCase();
    if (text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    // Call live NestJS referrals endpoint!
    final response = await ApiService.post('/premium/referrals', {
      'code': text,
    });

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    // ApiService đã unwrap envelope → thành công khi response khác null.
    if (response != null) {
      final String msg =
          (response is Map ? response['message'] : null) as String? ??
          'Mã giới thiệu hợp lệ! ⚡🏆';
      _codeController.clear();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF262019)
              : Colors.white,
          title: Text(
            'Thành công! 🎉',
            style: AppFonts.heading(fontWeight: FontWeight.bold),
          ),
          content: Text(msg, style: AppFonts.heading(fontSize: 13.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tuyệt vời!',
                style: AppFonts.heading(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Không thể tự giới thiệu bản thân hoặc mã không hợp lệ!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Brand design system tokens
    final primaryColor = isDark
        ? TripMateTheme.darkPrimary
        : TripMateTheme.lightPrimary;
    final backgroundColor = isDark
        ? TripMateTheme.darkBackground
        : TripMateTheme.lightBackground;
    final surfaceColor = isDark
        ? TripMateTheme.darkSurface
        : TripMateTheme.lightSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Giới Thiệu Bạn Bè 🎁',
          style: AppFonts.heading(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referral card using brand coloring gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'MÃ GIỚI THIỆU CỦA CƯNG 🎒',
                    style: AppFonts.heading(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    'MATEYCHILL',
                    style: AppFonts.heading(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chia sẻ mã này! Mỗi khi một đứa bạn nhập mã và đăng ký thành công, cả hai sẽ nhận ngay 500 XP bứt tốc cấp độ!',
                    textAlign: TextAlign.center,
                    style: AppFonts.heading(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '📋 Đã sao chép mã "MATEYCHILL" vào khay nhớ tạm!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Sao Chép Mã ⚡',
                      style: AppFonts.heading(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Submit friend's code block
            Text(
              'Nhập mã từ bạn bè 🎫',
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      style: AppFonts.heading(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mã của bạn bè (Ví dụ: SELF)',
                        hintStyle: AppFonts.heading(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.purpleAccent,
                          ),
                        )
                      : TextButton(
                          onPressed: _submitReferralCode,
                          child: Text(
                            'Gửi Mã',
                            style: AppFonts.heading(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Danh sách đã giới thiệu (${_referrals.length})',
              style: AppFonts.heading(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            if (_referrals.isEmpty)
              // Chưa mời được ai thì để trống, không bịa 2 người như trước.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'premium.no_referrals'.tr(),
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              )
            else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _referrals.length,
              itemBuilder: (context, index) {
                final ref = _referrals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.person_add_alt_1_outlined,
                        color: primaryColor,
                      ),
                      title: Text(
                        ref['name']!,
                        style: AppFonts.heading(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: Text(
                        ref['status']!,
                        style: AppFonts.heading(
                          fontSize: 11.5,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Text(
                        ref['xp']!,
                        style: AppFonts.heading(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
