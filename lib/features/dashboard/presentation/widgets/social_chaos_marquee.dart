import 'dart:async';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gen_z_tokens.dart';
import '../../data/home_feed_repository.dart';

/// Dải marquee chạy các hoạt động THẬT của squad.
///
/// Trước đây widget này chạy một mảng câu cứng ("Phú Khang owes 420k"...) nên
/// mọi tài khoản đều thấy y hệt nhau. Nay đọc `/users/me/activities/recent`;
/// chưa có hoạt động nào thì dải tự ẩn thay vì bịa nội dung.
class SocialChaosMarquee extends ConsumerWidget {
  const SocialChaosMarquee({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(squadActivitiesProvider);
    return async.maybeWhen(
      data: (items) => items.isEmpty
          ? const SizedBox.shrink()
          : _MarqueeStrip(labels: items.map((a) => a.label).toList()),
      // Đang tải hoặc lỗi: ẩn hẳn. Dải này là trang trí, không đáng để chiếm
      // chỗ bằng spinner hay thông báo lỗi ở ngay đầu màn hình.
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _MarqueeStrip extends StatefulWidget {
  final List<String> labels;
  const _MarqueeStrip({required this.labels});

  @override
  State<_MarqueeStrip> createState() => _MarqueeStripState();
}

class _MarqueeStripState extends State<_MarqueeStrip> {
  late final ScrollController _scrollController;
  Timer? _timer;

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
          horizontal: BorderSide(
            color: GenZTokens.ink,
            width: GenZTokens.borderWidthThin,
          ),
        ),
      ),
      child: Center(
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.labels.length * 10, // Loop list
          itemBuilder: (context, index) {
            final item = widget.labels[index % widget.labels.length];
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
