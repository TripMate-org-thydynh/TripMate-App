import 'package:flutter/material.dart';

class AiSavedPromptsScreen extends StatelessWidget {
  const AiSavedPromptsScreen({super.key});

  final List<Map<String, String>> _prompts = const [
    {
      'title': 'Tối ưu hóa hóa đơn của tôi 💸',
      'prompt': 'Hãy quét và chỉ ra ai đang nợ tiền tôi nhiều nhất và đưa ra gợi ý đòi nợ hài hước.',
    },
    {
      'title': 'Lịch trình chill mây sớm 🌲',
      'prompt': 'Gợi ý lịch trình ngắm mây 5h sáng tại Đà Lạt ít người nhất và địa điểm ăn sáng gần nhất.',
    },
  ];

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
        title: const Text('Các Câu Lệnh Đã Lưu 📌', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List prompts
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _prompts.length,
              itemBuilder: (context, index) {
                final item = _prompts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.bookmark_outline, color: Colors.purpleAccent),
                      title: Text(
                        item['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['prompt']!),
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
