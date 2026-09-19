import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/api_service.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

class SocialLinksManagerScreen extends StatefulWidget {
  const SocialLinksManagerScreen({super.key});

  @override
  State<SocialLinksManagerScreen> createState() =>
      _SocialLinksManagerScreenState();
}

class _SocialLinksManagerScreenState extends State<SocialLinksManagerScreen> {
  final _fbController = TextEditingController();
  final _igController = TextEditingController();
  final _ttController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
  }

  Future<void> _loadSocialLinks() async {
    final response = await ApiService.get('/users/me/social-links');
    if (mounted) {
      if (response != null) {
        setState(() {
          _fbController.text = response['facebook'] ?? '';
          _igController.text = response['instagram'] ?? '';
          _ttController.text = response['tiktok'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _fbController.text = '';
          _igController.text = '';
          _ttController.text = '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSocialLinks() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final success = isDark ? GenZTokens.successDark : GenZTokens.success;
    final danger = isDark ? GenZTokens.dangerDark : GenZTokens.danger;

    setState(() {
      _isLoading = true;
    });

    final payload = {
      'facebook': _fbController.text.trim(),
      'instagram': _igController.text.trim(),
      'tiktok': _ttController.text.trim(),
    };

    final response = await ApiService.patch('/users/me/social-links', payload);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.social_saved'.tr()),
            backgroundColor: success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.server_unreachable'.tr()),
            backgroundColor: danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fbController.dispose();
    _igController.dispose();
    _ttController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final line = isDark ? GenZTokens.lineDark : GenZTokens.line;
    final accent = isDark ? GenZTokens.accentDark : GenZTokens.accent;
    final onAccent = isDark ? GenZTokens.onAccentDark : GenZTokens.onAccent;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(),
            color: ink,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.social_title'.tr(),
          style: AppFonts.heading(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: ink,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: accent,
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(GenZTokens.space4),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    color: surface,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(GenZTokens.radiusCard),
                      side: BorderSide(
                        color: line,
                        width: GenZTokens.borderWidthThin,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(GenZTokens.space4),
                      child: Column(
                        children: [
                          TextField(
                            controller: _fbController,
                            style: AppFonts.body(fontSize: 15, color: ink),
                            decoration: InputDecoration(
                              labelText: 'Facebook',
                              labelStyle: AppFonts.body(
                                fontSize: 13,
                                color: inkSoft,
                              ),
                              prefixIcon: Icon(
                                PhosphorIcons.link(),
                                color: inkSoft,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: line,
                                  width: GenZTokens.borderWidthThin,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accent,
                                  width: GenZTokens.borderWidthFocus,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: GenZTokens.space4),
                          TextField(
                            controller: _igController,
                            style: AppFonts.body(fontSize: 15, color: ink),
                            decoration: InputDecoration(
                              labelText: 'Instagram',
                              labelStyle: AppFonts.body(
                                fontSize: 13,
                                color: inkSoft,
                              ),
                              prefixIcon: Icon(
                                PhosphorIcons.link(),
                                color: inkSoft,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: line,
                                  width: GenZTokens.borderWidthThin,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accent,
                                  width: GenZTokens.borderWidthFocus,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: GenZTokens.space4),
                          TextField(
                            controller: _ttController,
                            style: AppFonts.body(fontSize: 15, color: ink),
                            decoration: InputDecoration(
                              labelText: 'TikTok',
                              labelStyle: AppFonts.body(
                                fontSize: 13,
                                color: inkSoft,
                              ),
                              prefixIcon: Icon(
                                PhosphorIcons.link(),
                                color: inkSoft,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: line,
                                  width: GenZTokens.borderWidthThin,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accent,
                                  width: GenZTokens.borderWidthFocus,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: GenZTokens.space5),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveSocialLinks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: onAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(GenZTokens.radiusButton),
                        ),
                      ),
                      child: Text(
                        'profile.social_save'.tr(),
                        style: AppFonts.heading(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: onAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
