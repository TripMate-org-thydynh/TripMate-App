import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/gen_z_tokens.dart';

class SocialChaosMarquee extends StatefulWidget {
  const SocialChaosMarquee({super.key});

  @override
  State<SocialChaosMarquee> createState() => _SocialChaosMarqueeState();
}

class _SocialChaosMarqueeState extends State<SocialChaosMarquee> {
  late final ScrollController _scrollController;
  Timer? _timer;

  final List<String> _marqueeItems = [
    "Nam Trung added a coffee spot",
    "Thảo Ly reacted to a moment",
    "Phú Khang owes 420k",
    "Minh Nhật voted for BBQ",
    "Squad Energy: Chaotic Good (85%)",
    "3 days left until Dalat adventure!",
    "Packing check list updated by creator",
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
    // Dải marquee brutalist: khối vàng đặc, viền ink trên/dưới, chữ mono.
    return Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        border: Border.symmetric(
          horizontal: BorderSide(color: GenZTokens.ink, width: GenZTokens.borderWidthThin),
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
                    item.toUpperCase(),
                    style: AppFonts.mono(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: GenZTokens.ink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, size: 10, color: GenZTokens.ink),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
