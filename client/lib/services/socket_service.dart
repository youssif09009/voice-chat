import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants.dart';

/// Singleton wrapper around the Socket.IO client.
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  late io.Socket _socket;
  bool _initialized = false;

  io.Socket get socket {
    if (!_initialized) _init();
    return _socket;
  }

  void _init() {
    // Web browsers must start with polling then upgrade to websocket.
    // Native platforms can go straight to websocket.
    final transports = kIsWeb
        ? ['polling', 'websocket']
        : ['websocket'];

    _socket = io.io(
      AppConstants.serverUrl,
      io.OptionBuilder()
          .setTransports(transports)
          .disableAutoConnect()
          .build(),
    );
    _initialized = true;
  }

  void connect() => socket.connect();
  void disconnect() => socket.disconnect();

  void emit(String event, dynamic data) => socket.emit(event, data);

  void on(String event, Function(dynamic) handler) =>
      socket.on(event, handler);

  void off(String event) => socket.off(event);
}
