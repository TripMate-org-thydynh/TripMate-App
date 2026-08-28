import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Loại đặt chỗ — khớp enum BE (mirror semantic type của TREK).
enum ReservationType {
  flight,
  train,
  bus,
  hotel,
  restaurant,
  car,
  event,
  attraction,
  other,
}

extension ReservationTypeX on ReservationType {
  String get api => name.toUpperCase();

  static ReservationType parse(String? v) {
    switch ((v ?? '').toUpperCase()) {
      case 'FLIGHT':
        return ReservationType.flight;
      case 'TRAIN':
        return ReservationType.train;
      case 'BUS':
        return ReservationType.bus;
      case 'HOTEL':
        return ReservationType.hotel;
      case 'RESTAURANT':
        return ReservationType.restaurant;
      case 'CAR':
        return ReservationType.car;
      case 'EVENT':
        return ReservationType.event;
      case 'ATTRACTION':
        return ReservationType.attraction;
      default:
        return ReservationType.other;
    }
  }
}

class Reservation {
  final String id;
  final ReservationType type;
  final String title;
  final String? location;
  final String? confirmationNumber;
  final String? url;
  final String? notes;
  final String status;
  final double? price;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? tripName; // chỉ có trong feed upcoming

  const Reservation({
    required this.id,
    required this.type,
    required this.title,
    this.location,
    this.confirmationNumber,
    this.url,
    this.notes,
    this.status = 'CONFIRMED',
    this.price,
    this.startTime,
    this.endTime,
    this.tripName,
  });

  factory Reservation.fromJson(Map<String, dynamic> j) {
    final trip = j['trip'];
    return Reservation(
      id: j['id'] as String,
      type: ReservationTypeX.parse(j['type'] as String?),
      title: j['title'] as String? ?? '',
      location: j['location'] as String?,
      confirmationNumber: j['confirmationNumber'] as String?,
      url: j['url'] as String?,
      notes: j['notes'] as String?,
      status: j['status'] as String? ?? 'CONFIRMED',
      price: (j['price'] as num?)?.toDouble(),
      startTime: DateTime.tryParse(j['startTime']?.toString() ?? ''),
      endTime: DateTime.tryParse(j['endTime']?.toString() ?? ''),
      tripName: trip is Map ? trip['name'] as String? : null,
    );
  }
}

class ReservationsRepository {
  final ApiClient _client;
  ReservationsRepository(this._client);

  String _base(String tripId) => '/trips/$tripId/reservations';

  Future<List<Reservation>> fetch(String tripId) async {
    final data = await _client.getData(_base(tripId));
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Reservation.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<List<Reservation>> fetchUpcoming() async {
    final data = await _client.getData('/users/me/reservations/upcoming');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Reservation.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  Future<void> add(
    String tripId, {
    required ReservationType type,
    required String title,
    String? location,
    String? confirmationNumber,
    String? url,
    String? notes,
    double? price,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    await _client.postData(_base(tripId), {
      'type': type.api,
      'title': title,
      'location': ?location,
      'confirmationNumber': ?confirmationNumber,
      'url': ?url,
      'notes': ?notes,
      'price': ?price,
      'startTime': ?startTime?.toUtc().toIso8601String(),
      'endTime': ?endTime?.toUtc().toIso8601String(),
    });
  }

  Future<void> update(
    String tripId,
    String itemId, {
    ReservationType? type,
    String? title,
    String? location,
    String? confirmationNumber,
    String? url,
    String? notes,
    String? status,
    double? price,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    await _client.patchData('${_base(tripId)}/$itemId', {
      'type': ?type?.api,
      'title': ?title,
      'location': ?location,
      'confirmationNumber': ?confirmationNumber,
      'url': ?url,
      'notes': ?notes,
      'status': ?status,
      'price': ?price,
      'startTime': ?startTime?.toUtc().toIso8601String(),
      'endTime': ?endTime?.toUtc().toIso8601String(),
    });
  }

  Future<void> remove(String tripId, String itemId) =>
      _client.deleteData('${_base(tripId)}/$itemId');

  /// Booking-import: dán text xác nhận → AI bóc tách → tạo đặt chỗ.
  /// Trả { created, expensesCreated } — 0 = AI không nhận ra gì.
  Future<Map<String, int>> importFromText(String tripId, String text) async {
    final data = await _client.postData('${_base(tripId)}/import', {
      'text': text,
    });
    if (data is Map) {
      return {
        'created': (data['created'] as num?)?.toInt() ?? 0,
        'expensesCreated': (data['expensesCreated'] as num?)?.toInt() ?? 0,
      };
    }
    return {'created': 0, 'expensesCreated': 0};
  }

  /// Booking-import từ ảnh vé (Gemini vision): gửi base64 → AI bóc tách → tạo đặt chỗ.
  /// Trả { created, expensesCreated } — tái sử dụng pattern của photo-location.
  Future<Map<String, int>> importFromImage(
    String tripId,
    String imageBase64,
    String mimeType,
  ) async {
    final data = await _client.postData('${_base(tripId)}/import-image', {
      'imageBase64': imageBase64,
      'mimeType': mimeType,
    });
    if (data is Map) {
      return {
        'created': (data['created'] as num?)?.toInt() ?? 0,
        'expensesCreated': (data['expensesCreated'] as num?)?.toInt() ?? 0,
      };
    }
    return {'created': 0, 'expensesCreated': 0};
  }
}

final reservationsRepositoryProvider = Provider<ReservationsRepository>((ref) {
  return ReservationsRepository(ref.watch(apiClientProvider));
});

final tripReservationsProvider =
    FutureProvider.family<List<Reservation>, String>((ref, tripId) {
  return ref.watch(reservationsRepositoryProvider).fetch(tripId);
});

final upcomingReservationsProvider =
    FutureProvider<List<Reservation>>((ref) {
  return ref.watch(reservationsRepositoryProvider).fetchUpcoming();
});
