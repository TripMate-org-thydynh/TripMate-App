import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'api_service.dart';
import 'distribution_channel.dart';
import 'network/envelope.dart';

/// Kết quả kiểm tra lúc mở app (đọc `GET /app-config`).
enum GateStatus { ok, softUpdate, forceUpdate, maintenance }

class AppGateResult {
  final GateStatus status;
  final String? message;
  final String? storeUrl;
  final String currentVersion;
  final String? latestVersion;

  const AppGateResult(
    this.status, {
    this.message,
    this.storeUrl,
    this.currentVersion = '',
    this.latestVersion,
  });

  static const ok = AppGateResult(GateStatus.ok);
}

/// So sánh "1.2.10" với "1.2.9" theo từng số (không theo chuỗi).
@visibleForTesting
int compareVersions(String a, String b) {
  List<int> parse(String v) => v
      .split('+')
      .first
      .split('.')
      .map((s) => int.tryParse(s.trim()) ?? 0)
      .toList();
  final x = parse(a), y = parse(b);
  for (var i = 0; i < 3; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d.sign;
  }
  return 0;
}

/// Quyết định trạng thái từ cấu hình server + phiên bản đang chạy.
@visibleForTesting
AppGateResult decideGate(
  Map<String, dynamic> cfg,
  String version,
  bool ios, {
  bool legacyStoreFallback = true,
}) {
  final legacyUrl = (cfg['storeUrl'] as Map?)?[ios ? 'ios' : 'android'];
  final candidate =
      cfg['updateUrl'] ?? (legacyStoreFallback ? legacyUrl : null);
  final uri = candidate is String ? Uri.tryParse(candidate) : null;
  final store = uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
      ? uri.toString()
      : null;
  if (cfg['maintenance'] == true) {
    return AppGateResult(
      GateStatus.maintenance,
      message: cfg['maintenanceMessage'] as String?,
      currentVersion: version,
    );
  }
  final min = cfg['minVersion']?.toString() ?? '0.0.0';
  final latest = cfg['latestVersion']?.toString() ?? min;
  if (compareVersions(version, min) < 0) {
    return AppGateResult(
      store == null ? GateStatus.softUpdate : GateStatus.forceUpdate,
      storeUrl: store,
      currentVersion: version,
      latestVersion: latest,
    );
  }
  if (compareVersions(version, latest) < 0) {
    return AppGateResult(
      GateStatus.softUpdate,
      storeUrl: store,
      currentVersion: version,
      latestVersion: latest,
    );
  }
  return AppGateResult(GateStatus.ok, currentVersion: version);
}

/// Đọc cấu hình. "Fail-open": server chậm/lỗi/mất mạng thì cho vào app bình
/// thường (đã có màn mất kết nối riêng) — không bao giờ khoá người dùng chỉ vì
/// không đọc được cấu hình.
AppGateResult? parseAppGateResponse(
  Object? response,
  String version,
  DistributionChannel channel,
) {
  final data = unwrapEnvelope(response);
  if (data is! Map<String, dynamic>) return null;
  return decideGate(
    data,
    version,
    channel == DistributionChannel.appstore,
    legacyStoreFallback:
        !data.containsKey('updateUrl') &&
        (channel == DistributionChannel.play ||
            channel == DistributionChannel.appstore),
  );
}

Future<AppGateResult?> checkAppGate() async {
  try {
    final info = await PackageInfo.fromPlatform();
    final res = await Dio(
      BaseOptions(
        baseUrl: ApiService.baseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        headers: {'X-Client-Channel': kDistributionChannel.wire},
      ),
    ).get<Map<String, dynamic>>('/app-config');
    return parseAppGateResponse(res.data, info.version, kDistributionChannel);
  } on DioException catch (e) {
    // Server trả 503 = đang bảo trì / deploy.
    if (e.response?.statusCode == 503) {
      return const AppGateResult(GateStatus.maintenance);
    }
    return null;
  } catch (_) {
    return null;
  }
}
