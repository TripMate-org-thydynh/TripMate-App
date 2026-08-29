import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class TripInvite {
  final String id;
  final String tripId;
  final String code;
  final bool isActive;
  final DateTime? expiresAt;
  final int? maxUses;
  final int useCount;
  final String creatorName;
  final DateTime createdAt;

  const TripInvite({
    required this.id,
    required this.tripId,
    required this.code,
    required this.isActive,
    this.expiresAt,
    this.maxUses,
    required this.useCount,
    required this.creatorName,
    required this.createdAt,
  });

  factory TripInvite.fromJson(Map<String, dynamic> j) => TripInvite(
    id: j['id'] as String,
    tripId: j['tripId'] as String? ?? '',
    code: j['code'] as String? ?? '',
    isActive: j['isActive'] as bool? ?? true,
    expiresAt: j['expiresAt'] != null
        ? DateTime.tryParse(j['expiresAt'] as String)
        : null,
    maxUses: (j['maxUses'] as num?)?.toInt(),
    useCount: (j['useCount'] as num?)?.toInt() ?? 0,
    creatorName:
        (j['creator'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    createdAt:
        DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isExhausted => maxUses != null && useCount >= maxUses!;

  String get statusLabel {
    if (!isActive) return 'invites.status_disabled'.tr();
    if (isExpired) return 'Hết hạn';
    if (isExhausted) return 'invites.status_exhausted'.tr();
    return 'Còn hiệu lực';
  }
}

class InvitesRepository {
  final ApiClient _client;
  InvitesRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/invites';

  Future<List<TripInvite>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => TripInvite.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  Future<TripInvite> create(
    String tripId, {
    String? expiresAt,
    int? maxUses,
  }) async {
    final data = await _client.postData(_base(tripId), {
      'expiresAt': ?expiresAt,
      'maxUses': ?maxUses,
    });
    return TripInvite.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> deactivate(String tripId, String inviteId) =>
      _client.deleteData('${_base(tripId)}/$inviteId');

  Future<dynamic> joinByCode(String code) =>
      _client.postData('/trips/join-link/$code');
}

final invitesRepositoryProvider = Provider<InvitesRepository>((ref) {
  return InvitesRepository(ref.watch(apiClientProvider));
});
