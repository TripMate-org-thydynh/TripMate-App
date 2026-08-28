import 'package:flutter/material.dart';
import 'sticker_inventory_screen.dart';
import '../../../core/api_service.dart';

class StickerStoreScreen extends StatefulWidget {
  const StickerStoreScreen({super.key});

  @override
  State<StickerStoreScreen> createState() => _StickerStoreScreenState();
}

class _StickerStoreScreenState extends State<StickerStoreScreen> {
  final List<Map<String, dynamic>> _mockStickers = const [
    {'id': 'stk-1', 'label': 'Cười ra nước mắt 😂', 'costXP': 100},
    {'id': 'stk-2', 'label': 'Cà khịa hết nấc 😜', 'costXP': 200},
    {'id': 'stk-3', 'label': 'Mệt mỏi vì tiền 💸', 'costXP': 150},
    {'id': 'stk-4', 'label': 'Đang bay lắc 🚀', 'costXP': 180},
  ];

  List<dynamic> _liveStickers = [];
  List<dynamic> _ownedStickers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStickers();
  }

  Future<void> _fetchStickers() async {
    try {
      final response = await ApiService.get('/users/sticker-store');
      final ownedResponse = await ApiService.get('/users/me/stickers');
      if (mounted) {
        setState(() {
          if (response is List) {
            _liveStickers = response;
          } else {
            _liveStickers = List.from(_mockStickers);
          }
          if (ownedResponse is List) {
            _ownedStickers = ownedResponse;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _liveStickers = List.from(_mockStickers);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _purchaseSticker(String stickerId, String label) async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.post('/users/me/stickers/purchase', {
      'stickerId': stickerId,
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // ApiService đã unwrap envelope → thành công khi response khác null.
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Mua thành công sticker: $label!'),
            backgroundColor: Colors.purple,
          ),
        );
        _fetchStickers(); // Refresh store/inventory ownership status!
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Giao dịch thất bại. Vui lòng thử lại sau!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
          'Cửa Hàng Sticker 🎭',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.inventory_2_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StickerInventoryScreen(),
                ),
              );
            },
          ),
        ],
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
                    'Expressive Chaos Stickers',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mua sticker độc lạ để thả thính hoặc cà khịa cực mạnh trong chat nhóm.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stickers Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: _liveStickers.length,
                    itemBuilder: (context, index) {
                      final item = _liveStickers[index];
                      final id = item['id'] as String;
                      final label = item['label'] as String;
                      final costXP = item['costXP'] ?? item['cost'] ?? 150;

                      // Safely extract the emoji (last word or character)
                      final emoji = label.split(' ').last;

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262019)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 48)),
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
                            Text(
                              '$costXP XP',
                              style: const TextStyle(
                                color: Colors.purpleAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            (() {
                              final isOwned = _ownedStickers.any(
                                (s) => s['id'] == id || s['stickerId'] == id,
                              );
                              return ElevatedButton(
                                onPressed: isOwned ? null : () => _purchaseSticker(id, label),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isOwned ? Colors.grey : Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isOwned ? 'Đã Sở Hữu' : 'Mua Ngay',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            })(),
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
