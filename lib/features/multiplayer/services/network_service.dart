import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum NetworkRole { host, guest }

class NetworkService {
  static const int port = 4444;

  ServerSocket? _serverSocket;
  Socket? _socket;
  StreamSubscription? _sub;
  NetworkRole? _role;

  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _ctrl.stream;

  bool get isHost => _role == NetworkRole.host;
  bool get isConnected => _socket != null;

  /// Host: 서버를 시작하고 로컬 IP 주소를 반환합니다.
  Future<String> startHost() async {
    _role = NetworkRole.host;
    _serverSocket = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    return _getLocalIp();
  }

  /// Host: 게스트 연결 1개를 기다립니다.
  Future<void> waitForGuest() async {
    final socket = await _serverSocket!.first;
    _socket = socket;
    _listen(socket);
  }

  /// Guest: 호스트 IP로 연결합니다.
  Future<void> connectToHost(String hostIp) async {
    _role = NetworkRole.guest;
    _socket = await Socket.connect(
      hostIp.trim(),
      port,
      timeout: const Duration(seconds: 10),
    );
    _listen(_socket!);
  }

  void send(Map<String, dynamic> data) {
    if (_socket == null) return;
    try {
      _socket!.write('${jsonEncode(data)}\n');
    } catch (_) {}
  }

  void _listen(Socket socket) {
    _sub = socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            try {
              _ctrl.add(jsonDecode(line) as Map<String, dynamic>);
            } catch (_) {}
          },
          onDone: () => _ctrl.add({'type': 'disconnected'}),
          onError: (_) => _ctrl.add({'type': 'disconnected'}),
          cancelOnError: false,
        );
  }

  static Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (ip.startsWith('192.168.') ||
              ip.startsWith('10.') ||
              RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(ip)) {
            return ip;
          }
        }
      }
      if (interfaces.isNotEmpty) return interfaces.first.addresses.first.address;
    } catch (_) {}
    return '?';
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _socket?.destroy();
    await _serverSocket?.close();
    if (!_ctrl.isClosed) await _ctrl.close();
  }
}
