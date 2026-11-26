import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/system_states/pages/status_screen.dart';
import '../app_gate.dart';

class AppGateBoundary extends StatefulWidget {
  const AppGateBoundary({
    super.key,
    required this.child,
    this.load = checkAppGate,
  });

  final Widget child;
  final Future<AppGateResult?> Function() load;

  @override
  State<AppGateBoundary> createState() => _AppGateBoundaryState();
}

class _AppGateBoundaryState extends State<AppGateBoundary>
    with WidgetsBindingObserver {
  AppGateResult? _policy;
  bool _loading = false;
  String? _dismissedVersion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    if (_loading) return;
    setState(() => _loading = true);
    final policy = await widget.load();
    if (!mounted) return;
    setState(() {
      _policy = policy ?? _policy ?? AppGateResult.ok;
      _loading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policy = _policy;
    if (policy == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (policy.status == GateStatus.maintenance) {
      return MaintenanceScreen(
        message: policy.message,
        onRetry: () => unawaited(_refresh()),
      );
    }
    if (policy.status == GateStatus.forceUpdate) {
      return ForceUpdateScreen(
        currentVersion: policy.currentVersion,
        storeUrl: policy.storeUrl,
        onRetry: _loading ? null : () => unawaited(_refresh()),
      );
    }
    final showUpdate =
        policy.status == GateStatus.softUpdate &&
        _dismissedVersion != policy.latestVersion;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (showUpdate)
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'system.update_soft_title'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'system.update_soft_body'.tr(
                          namedArgs: {'version': policy.latestVersion ?? ''},
                        ),
                      ),
                      Wrap(
                        children: [
                          TextButton(
                            onPressed: () => setState(
                              () => _dismissedVersion = policy.latestVersion,
                            ),
                            child: Text('system.later'.tr()),
                          ),
                          if (policy.storeUrl != null)
                            TextButton(
                              onPressed: () => launchUrl(
                                Uri.parse(policy.storeUrl!),
                                mode: LaunchMode.externalApplication,
                              ),
                              child: Text('system.update_cta'.tr()),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
