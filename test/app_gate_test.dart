import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmate/core/app_gate.dart';
import 'package:tripmate/core/distribution_channel.dart';
import 'package:tripmate/core/widgets/app_gate_boundary.dart';
import 'package:tripmate/features/system_states/pages/status_screen.dart';

import 'helpers/localized.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initLocalization();
  });
  test('so sánh phiên bản theo số, không theo chuỗi', () {
    expect(compareVersions('1.2.10', '1.2.9'), 1);
    expect(compareVersions('1.0.0+5', '1.0.0'), 0);
    expect(compareVersions('1.0', '1.0.1'), -1);
  });

  final cfg = {
    'minVersion': '1.1.0',
    'latestVersion': '1.3.0',
    'maintenance': false,
    'storeUrl': {'ios': 'https://apps.apple.com/x', 'android': 'https://p/y'},
  };

  test('dưới min → bắt buộc cập nhật, kèm link đúng nền tảng', () {
    final r = decideGate(cfg, '1.0.9', true);
    expect(r.status, GateStatus.forceUpdate);
    expect(r.storeUrl, 'https://apps.apple.com/x');
  });

  test('giữa min và latest → popup bỏ qua được', () {
    expect(decideGate(cfg, '1.2.0', false).status, GateStatus.softUpdate);
  });

  test('bản mới nhất → vào app', () {
    expect(decideGate(cfg, '1.3.0', false).status, GateStatus.ok);
  });

  test('bảo trì thắng mọi trường hợp', () {
    final r = decideGate({...cfg, 'maintenance': true}, '9.9.9', false);
    expect(r.status, GateStatus.maintenance);
  });

  test('reads the NestJS envelope and honors the channel download link', () {
    final result = parseAppGateResponse(
      {
        'success': true,
        'data': {
          ...cfg,
          'updateUrl': 'https://downloads.example.com/tripmate.apk',
        },
      },
      '1.0.0',
      DistributionChannel.direct,
    );
    expect(result?.status, GateStatus.forceUpdate);
    expect(result?.storeUrl, 'https://downloads.example.com/tripmate.apk');
  });

  test(
    'does not use the Google Play link for a directly distributed build',
    () {
      final result = parseAppGateResponse(
        cfg,
        '1.2.0',
        DistributionChannel.direct,
      );
      expect(result?.status, GateStatus.softUpdate);
      expect(result?.storeUrl, isNull);
    },
  );

  test('keeps an older build usable when its channel has no download link', () {
    final result = parseAppGateResponse(
      cfg,
      '1.0.0',
      DistributionChannel.direct,
    );
    expect(result?.status, GateStatus.softUpdate);
    expect(result?.storeUrl, isNull);
  });

  testWidgets(
    'blocks routed content at startup and reapplies policy on resume',
    (tester) async {
      final initial = Completer<AppGateResult>();
      var calls = 0;
      AppGateResult next = const AppGateResult(GateStatus.maintenance);
      await tester.pumpWidget(
        localized(
          AppGateBoundary(
            load: () async => calls++ == 0 ? initial.future : next,
            child: const Text('Routed content'),
          ),
        ),
      );
      expect(find.text('Routed content'), findsNothing);
      initial.complete(AppGateResult.ok);
      await tester.pumpAndSettle();
      expect(find.text('Routed content'), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.byType(MaintenanceScreen), findsOneWidget);
      expect(find.text('Routed content'), findsNothing);

      next = AppGateResult.ok;
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Routed content'), findsOneWidget);
    },
  );
}
