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
            backgroundColor: GenZTokens.purple,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errors.server_unreachable'.tr()),
            backgroundColor: GenZTokens.danger,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ink,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: GenZTokens.purple),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    color: surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: ink, width: 2.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _fbController,
                            style: AppFonts.body(color: ink),
                            decoration: InputDecoration(
                              labelText: 'Facebook',
                              labelStyle: AppFonts.body(color: inkSoft),
                              prefixIcon: Icon(
                                PhosphorIcons.link(),
                                color: inkSoft,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: inkSoft.withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: GenZTokens.purple,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _igController,
                            style: AppFonts.body(color: ink),
                            decoration: InputDecoration(
                              labelText: 'Instagram',
                              labelStyle: AppFonts.body(color: inkSoft),
                              prefixIcon: Icon(
                                PhosphorIcons.link(),
                                color: inkSoft,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: inkSoft.withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: GenZTokens.purple,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _ttController,
                            style: AppFonts.body(color: ink),
                            decoration: InputDecoration(
                              labelText: 'TikTok',
                              labelStyle: AppFonts.body(color: inkSoft),
                              prefixIcon: Icon(
                                PhosphorIcons.link(),
                                color: inkSoft,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: inkSoft.withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: GenZTokens.purple,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ink, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: ink,
                          blurRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveSocialLinks,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GenZTokens.yellow,
                          foregroundColor: GenZTokens.ink,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'profile.social_save'.tr(),
                          style: AppFonts.heading(
                            fontWeight: FontWeight.bold,
                            color: GenZTokens.ink,
                          ),
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
