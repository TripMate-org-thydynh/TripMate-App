import 'package:flutter/material.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  final List<Map<String, String>> _friends = const [
    {'name': 'Alex Nguyễn', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex'},
    {'name': 'Trần Bình', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Binh'},
    {'name': 'Lê Minh', 'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Minh'},
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
        title: const Text('Danh Sách Bạn Bè 👥', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List friends
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend['avatar']!),
                      ),
                      title: Text(
                        friend['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Cực kỳ uy tín 🛡️'),
                      trailing: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã gửi tin nhắn đến ${friend['name']}!'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                        },
                        child: const Text('Nhắn tin', style: TextStyle(color: Colors.purpleAccent)),
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
