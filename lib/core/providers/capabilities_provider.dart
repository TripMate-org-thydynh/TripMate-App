import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

class CapabilityPolicy {
  const CapabilityPolicy({this.mode = 'enabled', this.message = ''});

  final String mode;
  final String message;

  bool get hidden => mode == 'hidden';
  bool get canRead => mode == 'enabled' || mode == 'readOnly';
  bool get canWrite => mode == 'enabled';

  String label(BuildContext context) => message.isNotEmpty
      ? message
      : context.locale.languageCode == 'vi'
      ? 'Tính năng đang tạm dừng.'
      : 'This feature is temporarily unavailable.';
}

final capabilitiesProvider =
    NotifierProvider.autoDispose<
      CapabilitiesNotifier,
      Map<String, CapabilityPolicy>
    >(CapabilitiesNotifier.new);

final capabilityProvider = Provider.autoDispose
    .family<CapabilityPolicy, String>(
      (ref, key) =>
          ref.watch(capabilitiesProvider)[key] ??
          CapabilityPolicy(
            mode: const {'receiptDrafts', 'publishTemplate'}.contains(key)
                ? 'hidden'
                : 'enabled',
          ),
    );

class CapabilitiesNotifier
    extends AutoDisposeNotifier<Map<String, CapabilityPolicy>> {
  bool _loading = false;

  @override
  Map<String, CapabilityPolicy> build() {
    final listener = AppLifecycleListener(onResume: () => unawaited(refresh()));
    final timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        unawaited(refresh());
      }
    });
    ref.onDispose(listener.dispose);
    ref.onDispose(timer.cancel);
    Future.microtask(refresh);
    return const {};
  }

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final api = ref.read(apiClientProvider);
      final config = await api.getData('/app-config');
      if (config is! Map || config['capabilities'] is! Map) return;
      final features = config['capabilities'] as Map;
      final policies = <String, CapabilityPolicy>{};
      for (final entry in features.entries) {
        final value = entry.value;
        if (entry.key is String && value is Map && value['mode'] is String) {
          policies[entry.key as String] = CapabilityPolicy(
            mode: value['mode'] as String,
            message: value['message'] as String? ?? '',
          );
        }
      }
      state = policies;
    } catch (_) {
      // Keep the last confirmed policy while the network is unavailable.
    } finally {
      _loading = false;
    }
  }
}
