import 'package:flutter/material.dart';

class MateyAiEmotionalChaosScreen extends StatefulWidget {
  const MateyAiEmotionalChaosScreen({super.key});

  @override
  State<MateyAiEmotionalChaosScreen> createState() => _MateyAiEmotionalChaosScreenState();
}

class _MateyAiEmotionalChaosScreenState extends State<MateyAiEmotionalChaosScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'matey',
      'text': 'YAHOOO! 👋 Ta là Matey AI đây! Đang ở trạng thái cực kỳ hỗn loạn! Hôm nay cưng muốn hỏi gì nào? 🤪💥',
      'time': '10:00 AM'
    },
    {
      'sender': 'user',
      'text': 'Chúng tôi đang đi Kyoto, gợi ý quán cafe chill nhất với!',
      'time': '10:01 AM'
    },
    {
      'sender': 'matey',
      'text': 'Gợi ý: Cafe The Hill Station! ☕ Đạt 92% vibe match với sự lười biếng của nhóm cưng! Đảm bảo tha hồ romanticize như phim điện ảnh nhé! 🎬✨',
      'time': '10:01 AM'
    },
  ];

  final _textController = TextEditingController();

  void _sendMessage() {
    if (_textController.text.isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': _textController.text,
        'time': 'Hôm nay',
      });
      _textController.clear();
    });

    // Mock quick chaos reply from bot
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'matey',
            'text': 'KHOAN ĐÃ! 😱 Phân tích tính cách cho thấy cưng đang tiêu quá tay! Tránh xa các trung tâm mua sắm ra trước khi ví tiền kêu cứu nha cưng! 💸🔥',
            'time': 'Vừa xong',
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
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
        title: const Text('Matey AI — Emotional Chaos 🔮', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Chat history feed
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.purple
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg['time'] as String,
                            style: TextStyle(
                              color: isUser ? Colors.white70 : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: const InputDecoration(
                      hintText: 'Nhắn gì đó cực kỳ hỗn loạn...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purpleAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
