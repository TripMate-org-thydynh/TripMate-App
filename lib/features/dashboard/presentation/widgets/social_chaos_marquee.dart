import 'dart:async';
import 'package:flutter/material.dart';

class SocialChaosMarquee extends StatefulWidget {
  const SocialChaosMarquee({super.key});

  @override
  State<SocialChaosMarquee> createState() => _SocialChaosMarqueeState();
}

class _SocialChaosMarqueeState extends State<SocialChaosMarquee> {
  late final ScrollController _scrollController;
  Timer? _timer;

  final List<String> _marqueeItems = [
    "Nam Trung added a coffee spot ☕️",
    "Thảo Ly reacted 😂",
    "Phú Khang owes 420k 💸",
    "Minh Nhật voted for BBQ 🍖",
    "🔥 Squad Energy: Chaotic Good (85%)",
    "😍 3 days left until Dalat adventure!",
    "✈️ Packing check list updated by creator"
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    
    const speed = 0.5; // Pixels per frame
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_scrollController.hasClients) return;
      
      final maxExtent = _scrollController.position.maxScrollExtent;
      final currentOffset = _scrollController.offset;
      
      if (currentOffset >= maxExtent) {
        _scrollController.jumpTo(0.0);
      } else {
        _scrollController.jumpTo(currentOffset + speed);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF8B5CF6).withValues(alpha: 0.08)
            : const Color(0xFFE0533C).withValues(alpha: 0.08),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: isDark
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                : const Color(0xFFE0533C).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _marqueeItems.length * 10, // Loop list
          itemBuilder: (context, index) {
            final item = _marqueeItems[index % _marqueeItems.length];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: [
                  Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? const Color(0xFFCBBFEE) : const Color(0xFF8C3E33),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: isDark
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                        : const Color(0xFFE0533C).withValues(alpha: 0.4),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
