import 'dart:async';
import 'dart:typed_data';

import 'package:xterm/xterm.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/services/ssh/ssh_service_impl.dart';

class SshSession {
  final String id;
  final ConnectionModel connection;
  final SshServiceImpl service;
  final Terminal terminal;
  Timer? _keepAliveTimer;

  SshSession({
    required this.id,
    required this.connection,
    required this.service,
    required this.terminal,
  });

  bool get isConnected => service.isConnected;

  void startKeepAlive(int intervalSeconds) {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) {
        if (service.isConnected) {
          // Send SSH keep-alive (null byte ignored by most shells)
          service.sendCommand('');
        }
      },
    );
  }

  void stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  void dispose() {
    stopKeepAlive();
    service.dispose();
  }
}

class SessionManager {
  final Map<String, SshSession> _sessions = {};

  Map<String, SshSession> get sessions => Map.unmodifiable(_sessions);
  List<SshSession> get activeSessions => _sessions.values.toList();
  int get count => _sessions.length;

  Future<SshSession> createSession(
    ConnectionModel connection, {
    int keepAliveInterval = 30,
    bool keepAlive = true,
    double fontSize = 14.0,
  }) async {
    final id = '${connection.id}_${DateTime.now().millisecondsSinceEpoch}';
    final sshService = SshServiceImpl();
    final terminal = Terminal(maxLines: 10000);

    await sshService.connect(connection);

    // Bind SSH output → terminal
    sshService.output.listen((data) {
      terminal.write(String.fromCharCodes(data));
    });

    // Bind terminal input → SSH
    terminal.onOutput = (data) {
      sshService.write(Uint8List.fromList(data.codeUnits));
    };

    // Bind terminal resize → SSH
    terminal.onResize = (w, h, pw, ph) {
      sshService.resizeTerminal(w, h);
    };

    final session = SshSession(
      id: id,
      connection: connection,
      service: sshService,
      terminal: terminal,
    );

    if (keepAlive) session.startKeepAlive(keepAliveInterval);
    _sessions[id] = session;
    return session;
  }

  SshSession? getSession(String id) => _sessions[id];

  Future<void> closeSession(String id) async {
    final session = _sessions.remove(id);
    session?.dispose();
  }

  Future<void> closeAll() async {
    for (final session in _sessions.values) {
      session.dispose();
    }
    _sessions.clear();
  }
}
