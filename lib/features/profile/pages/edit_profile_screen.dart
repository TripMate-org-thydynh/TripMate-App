import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/api_service.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/gen_z_tokens.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  String _avatarUrl = '';
  bool _isLoading = true;

  // Avatar sinh theo tên (PNG — NetworkImage render được, khác dicebear SVG).
  String _genAvatar(String name) =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name.isEmpty ? "TripMate" : name)}'
      '&background=FFD84D&color=141210&bold=true&size=256';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final response = await ApiService.get('/users/me');
    if (mounted) {
      if (response != null) {
        setState(() {
          _nameController.text = response['name'] ?? '';
          _usernameController.text = response['username'] ?? '';
          _bioController.text = response['bio'] ?? '';
          final av = response['avatarUrl'] as String?;
          _avatarUrl = (av != null && av.isNotEmpty)
              ? av
              : _genAvatar(_nameController.text);
          _isLoading = false;
        });
      } else {
        // Offline: để trống cho user tự nhập, avatar sinh theo tên.
        setState(() {
          _avatarUrl = _genAvatar('');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfileData() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.name_required'.tr()),
          backgroundColor: isDark ? GenZTokens.warningDark : GenZTokens.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final payload = {
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'bio': _bioController.text.trim(),
      'avatarUrl': _avatarUrl,
    };

    final response = await ApiService.patch('/users/me', payload);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.updated'.tr()),
            backgroundColor: isDark ? GenZTokens.successDark : GenZTokens.success,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate profile was updated
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile.update_failed'.tr()),
            backgroundColor: isDark ? GenZTokens.dangerDark : GenZTokens.danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? GenZTokens.creamDark : GenZTokens.cream;
    final ink = isDark ? GenZTokens.inkDark : GenZTokens.ink;
    final inkSoft = isDark ? GenZTokens.inkSoftDark : GenZTokens.inkSoft;
    final surface = isDark ? GenZTokens.paperDark : GenZTokens.paper;
    final fill = isDark ? GenZTokens.fillDark : GenZTokens.fill;
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
          icon: Icon(PhosphorIcons.arrowLeft(), color: ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile.edit_title'.tr(),
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
                  // Avatar picker preview
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: line,
                              width: GenZTokens.borderWidth,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: fill,
                            backgroundImage: _avatarUrl.isEmpty
                                ? null
                                : NetworkImage(_avatarUrl),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Avatar ngẫu nhiên dạng PNG (SVG dicebear cũ không
                              // render được trong NetworkImage → avatar trống).
                              final randomSeed = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              setState(() {
                                _avatarUrl =
                                    'https://api.dicebear.com/7.x/fun-emoji/png?seed=$randomSeed';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('profile.avatar_changed'.tr()),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: line,
                                  width: GenZTokens.borderWidthThin,
                                ),
                              ),
                              child: Icon(
                                PhosphorIcons.arrowsClockwise(),
                                color: ink,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: GenZTokens.space5),

                  // Profile info inputs
                  Card(
                    elevation: 0,
                    color: surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GenZTokens.radiusCard),
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
                            controller: _nameController,
                            style: AppFonts.body(fontSize: 15, color: ink),
                            decoration: InputDecoration(
                              labelText: 'profile.full_name'.tr(),
                              labelStyle: AppFonts.body(fontSize: 13, color: inkSoft),
                              prefixIcon: Icon(
                                PhosphorIcons.user(),
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
                            controller: _usernameController,
                            style: AppFonts.body(fontSize: 15, color: ink),
                            decoration: InputDecoration(
                              labelText: 'profile.username'.tr(),
                              labelStyle: AppFonts.body(fontSize: 13, color: inkSoft),
                              prefixIcon: Icon(
                                PhosphorIcons.at(),
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
                            controller: _bioController,
                            style: AppFonts.body(fontSize: 15, color: ink),
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'profile.bio'.tr(),
                              labelStyle: AppFonts.body(fontSize: 13, color: inkSoft),
                              prefixIcon: Icon(
                                PhosphorIcons.article(),
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

                  // Save profile changes button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saveProfileData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: onAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            GenZTokens.radiusButton,
                          ),
                        ),
                      ),
                      child: Text(
                        'profile.save'.tr(),
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
