import 'dart:math';
import 'package:flutter/material.dart';

class RandomDareGeneratorScreen extends StatefulWidget {
  const RandomDareGeneratorScreen({super.key});

  @override
  State<RandomDareGeneratorScreen> createState() => _RandomDareGeneratorScreenState();
}

class _RandomDareGeneratorScreenState extends State<RandomDareGeneratorScreen> {
  final List<String> _dares = [
    'Uống hết ly nước này trong 5 giây! 🍺',
    'Hát một bài hát thiếu nhi bằng giọng em bé! 🎤',
    'Chụp ảnh dìm hàng Lê Minh và post lên Realtime Feed! 📸',
    'Nắm tay Alex Nguyễn trong vòng 1 phút! 🤝',
    'Để cả nhóm vẽ bậy lên mặt bằng son! 💄',
  ];

  String _currentDare = 'Nhấn nút đỏ bên dưới để bốc thử thách!';
  bool _isGenerating = false;

  void _generateDare() {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final random = Random();
        setState(() {
          _currentDare = _dares[random.nextInt(_dares.length)];
          _isGenerating = false;
        });
      }
    });
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
        title: const Text('Bốc Dare Ngẫu Nhiên 🎲', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing neon dare card container
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      blurRadius: 30,
                    ),
                  ],
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 64),
                    const SizedBox(height: 24),
                    AnimatedOpacity(
                      opacity: _isGenerating ? 0.3 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentDare,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Giant Neon Red Trigger Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _generateDare,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGenerating)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      const Icon(Icons.flash_on),
                    const SizedBox(width: 10),
                    const Text(
                      'BỐC THỬ THÁCH NGAY!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
