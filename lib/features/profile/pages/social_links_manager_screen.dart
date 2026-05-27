import 'package:flutter/material.dart';
import '../../../core/api_service.dart';

class SocialLinksManagerScreen extends StatefulWidget {
  const SocialLinksManagerScreen({super.key});

  @override
  State<SocialLinksManagerScreen> createState() => _SocialLinksManagerScreenState();
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
        // Fallback offline mock values
        setState(() {
          _fbController.text = 'https://facebook.com/minhnhatchaos';
          _igController.text = 'https://instagram.com/minhnhat.travel';
          _ttController.text = 'https://tiktok.com/@minhnhat.phuot';
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
          const SnackBar(
            content: Text('🎉 Lưu liên kết mạng xã hội thành công!'),
            backgroundColor: Colors.purple,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Không thể kết nối tới server. Vui lòng kiểm tra lại!'),
            backgroundColor: Colors.redAccent,
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
          'Liên Kết Mạng Xã Hội 🔗',
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
                  Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _fbController,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Facebook',
                              labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                              prefixIcon: Icon(Icons.link, color: isDark ? Colors.white60 : Colors.black54),
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
                            controller: _igController,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Instagram',
                              labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                              prefixIcon: Icon(Icons.link, color: isDark ? Colors.white60 : Colors.black54),
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
                            controller: _ttController,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'TikTok',
                              labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                              prefixIcon: Icon(Icons.link, color: isDark ? Colors.white60 : Colors.black54),
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

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveSocialLinks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Lưu Liên Kết', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
