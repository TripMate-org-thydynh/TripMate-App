import 'package:socket_io_client/socket_io_client.dart' as io;

import 'api_client.dart';

/// Kết nối realtime tới ChatGateway của BE (namespace `/chat`).
///
/// Dùng:
///   final sock = ChatSocket(token);
///   sock.connect();
///   sock.join(tripId);
///   sock.onMessage((data) => ...);
///   sock.send(tripId, 'hello');
///   sock.dispose();
class ChatSocket {
  final String token;
  io.Socket? _socket;

  ChatSocket(this.token);

  /// URL socket = host gốc (bỏ `/api/v1`) + namespace `/chat`.
  static String get _baseHost {
    final base = ApiClient.baseUrl; // vd http://10.0.2.2:3000/api/v1
    final idx = base.indexOf('/api/');
    return idx > 0 ? base.substring(0, idx) : base;
  }

  String? _joinedTrip;

  void connect() {
    _socket = io.io(
      '$_baseHost/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setAuth({'token': token})
          .build(),
    );

    // Tự join lại room sau khi reconnect (mạng mobile chập chờn).
    _socket!.onConnect((_) {
      _onConnectionChanged?.call(true);
      if (_joinedTrip != null) {
        _socket?.emit('join', {'tripId': _joinedTrip});
      }
    });
    _socket!.onDisconnect((_) => _onConnectionChanged?.call(false));
    _socket!.onReconnect((_) => _onConnectionChanged?.call(true));

    _socket!.connect();
  }

  void Function(bool connected)? _onConnectionChanged;
  void onConnectionChanged(void Function(bool connected) handler) =>
      _onConnectionChanged = handler;

  void join(String tripId) {
    _joinedTrip = tripId;
    _socket?.emit('join', {'tripId': tripId});
  }

  void leave(String tripId) {
    if (_joinedTrip == tripId) _joinedTrip = null;
    _socket?.emit('leave', {'tripId': tripId});
  }

  void send(String tripId, String content) =>
      _socket?.emit('message', {'tripId': tripId, 'content': content});

  void setTyping(String tripId, bool isTyping) =>
      _socket?.emit('typing', {'tripId': tripId, 'isTyping': isTyping});

  void onMessage(void Function(dynamic data) handler) =>
      _socket?.on('message', handler);

  void onTyping(void Function(dynamic data) handler) =>
      _socket?.on('typing', handler);

  bool get connected => _socket?.connected ?? false;

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
