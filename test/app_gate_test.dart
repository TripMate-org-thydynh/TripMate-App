import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/core/app_gate.dart';

void main() {
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
}
