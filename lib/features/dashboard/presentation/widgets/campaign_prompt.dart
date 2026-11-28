import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../social/data/notifications_repository.dart';

class CampaignPrompt extends ConsumerStatefulWidget {
  const CampaignPrompt({
    super.key,
    required this.isHome,
    required this.onOpen,
    required this.child,
  });

  final bool isHome;
  final ValueChanged<String> onOpen;
  final Widget child;

  @override
  ConsumerState<CampaignPrompt> createState() => _CampaignPromptState();
}

class _CampaignPromptState extends ConsumerState<CampaignPrompt> {
  late final Timer _refresh;
  late final AppLifecycleListener _lifecycle;
  bool _checking = false;
  Map? _pending;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_check()));
    _refresh = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_check()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_check()));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _refresh.cancel();
    super.dispose();
  }

  bool get _canShow =>
      mounted &&
      widget.isHome &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
      ModalRoute.of(context)?.isCurrent == true;

  Future<void> _check() async {
    if (_checking || !_canShow) return;
    _checking = true;
    try {
      final campaign =
          _pending ??
          await ref
              .read(apiClientProvider)
              .postData('/notifications/events/claim', {});
      if (!mounted || campaign is! Map || campaign['title'] is! String) return;
      if (!_canShow) {
        _pending = campaign;
        return;
      }
      _pending = null;
      ref.invalidate(notificationsProvider);
      await _show(campaign);
    } catch (_) {
      // The inbox remains available if this request fails.
    } finally {
      _checking = false;
    }
  }

  Future<void> _show(Map campaign) async {
    final vi = context.locale.languageCode == 'vi';
    final cta = campaign['cta'] as String? ?? 'home';
    final open = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        clipBehavior: Clip.antiAlias,
        title: Text(campaign['title'] as String),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (campaign['imageUrl'] case final String image) ...[
                AspectRatio(
                  aspectRatio: 1.6,
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    memCacheWidth: 640,
                    errorWidget: (_, _, _) =>
                        const ColoredBox(color: Colors.transparent),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(campaign['body'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(vi ? 'Đóng' : 'Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(switch (cta) {
              'trips' => vi ? 'Mở chuyến đi' : 'Open trips',
              'templates' => vi ? 'Xem lịch trình mẫu' : 'Explore templates',
              _ => vi ? 'Về Home' : 'Go to Home',
            }),
          ),
        ],
      ),
    );
    if (mounted && open == true) widget.onOpen(cta);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
