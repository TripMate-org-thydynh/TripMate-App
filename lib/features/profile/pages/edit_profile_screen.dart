import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/api_service.dart';

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
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.name_required'.tr()),
          backgroundColor: Colors.orangeAccent,
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
            backgroundColor: Color(0xFF1FA85C),
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
            backgroundColor: Colors.redAccent,
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

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF141210)
          : const Color(0xFFFDF6D3),
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
          'profile.edit_title'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF5A623)),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
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
                              color: isDark
                                  ? const Color(0xFFFDF6D3)
                                  : const Color(0xFF141210),
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: const Color(0xFFFFD84D),
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
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD84D),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF141210),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Color(0xFF141210),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Profile info inputs
                  Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF262019) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFFFDF6D3)
                            : const Color(0xFF141210),
                        width: 2.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Họ và tên',
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF5A623),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _usernameController,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              prefixIcon: Icon(
                                Icons.alternate_email,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF5A623),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _bioController,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'profile.bio'.tr(),
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              prefixIcon: Icon(
                                Icons.article_outlined,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF5A623),
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

                  // Save profile changes button
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF141210),
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF141210),
                          blurRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveProfileData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD84D),
                          foregroundColor: const Color(0xFF141210),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'profile.save'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF141210),
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
