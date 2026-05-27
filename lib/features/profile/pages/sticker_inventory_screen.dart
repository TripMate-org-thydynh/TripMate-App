import 'package:flutter/material.dart';
import '../../../core/api_service.dart';

class StickerInventoryScreen extends StatefulWidget {
  const StickerInventoryScreen({super.key});

  @override
  State<StickerInventoryScreen> createState() => _StickerInventoryScreenState();
}

class _StickerInventoryScreenState extends State<StickerInventoryScreen> {
  final List<Map<String, dynamic>> _mockMyStickers = const [
    {'id': 'stk-1', 'label': 'Cười ra nước mắt 😂', 'count': 5},
    {'id': 'stk-2', 'label': 'Cà khịa hết nấc 😜', 'count': 2},
  ];

  List<dynamic> _myStickers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    final response = await ApiService.get('/users/me/stickers');
    if (mounted) {
      if (response is List) {
        setState(() {
          _myStickers = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _myStickers = List.from(_mockMyStickers);
          _isLoading = false;
        });
      }
    }
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
          'Kho Sticker Của Tôi 📦',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sticker Inventory',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Xem các sticker cưng đã mua để tự do biểu cảm trong hội nhóm.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  _myStickers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 48.0),
                            child: Column(
                              children: [
                                const Text('🎭', style: TextStyle(fontSize: 64)),
                                const SizedBox(height: 16),
                                Text(
                                  'Cưng chưa sở hữu sticker nào!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Vào Cửa Hàng để mua ngay sticker xịn sò bằng điểm phượt thủ nhé.',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: _myStickers.length,
                          itemBuilder: (context, index) {
                            final item = _myStickers[index];
                            final label = item['label'] as String;
                            final count = item['count'] ?? 1;
                            
                            // Safely extract the emoji
                            final emoji = label.split(' ').last;

                            return Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Sở hữu: $count',
                                      style: const TextStyle(
                                        color: Colors.purpleAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
