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
  String _avatarUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuDLEui7EjvkHqpOtxT75qvmlSCJ9wccTxZHFnkqbQ7m--E6HGrhKnsJtrL2GDihf2FhhrrhdSQNucxZbDJAO6aLatXSt85bB-l6x9IM5ATjoFNpWUBr8XexKHp-UAg1uq87dPwg4PWZ5YNCMSEEHcd0e_x7apUYsHB94fhhpnv3cua0_DqPuc2VvBOglqhzvDWgph7OzMrHd71mBP4_IYyAJES--uo8nLNq161e_1nhMmkf9ZNHQheEn4QZJGsbcFzUQrlWbUYmDTLA';
  bool _isLoading = true;

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
          if (response['avatarUrl'] != null) {
            _avatarUrl = response['avatarUrl'];
          }
          _isLoading = false;
        });
      } else {
        // Fallback offline mock values
        setState(() {
          _nameController.text = 'Minh Nhật';
          _usernameController.text = 'minhnhat_chaos';
          _bioController.text = 'Phượt thủ thích chill, săn mây và phá hoại nợ nần nhóm! 🌲';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfileData() async {
    if (_nameController.text.trim().isEmpty || _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Tên và Username không được để trống!'),
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
          const SnackBar(
            content: Text('🎉 Cập nhật thông tin profile thành công!'),
            backgroundColor: Colors.purple,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate profile was updated
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Lỗi cập nhật profile hoặc trùng lặp Username!'),
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
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chỉnh Sửa Profile ✏️',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Avatar picker preview
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.purple.withValues(alpha: 0.1),
                          backgroundImage: NetworkImage(_avatarUrl),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Choose a random cool dicebear avatar for Gen Z dynamic profile
                              final randomSeed = DateTime.now().millisecondsSinceEpoch.toString();
                              setState(() {
                                _avatarUrl = 'https://api.dicebear.com/7.x/avataaars/svg?seed=$randomSeed';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🎨 Đổi avatar ngẫu nhiên mới thành công!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.purple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
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
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Họ và tên',
                              labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                              prefixIcon: Icon(Icons.person_outline, color: isDark ? Colors.white60 : Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _usernameController,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                              prefixIcon: Icon(Icons.alternate_email, color: isDark ? Colors.white60 : Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _bioController,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Tiểu sử / Bio',
                              labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                              prefixIcon: Icon(Icons.article_outlined, color: isDark ? Colors.white60 : Colors.black54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Save profile changes button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveProfileData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Lưu thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
