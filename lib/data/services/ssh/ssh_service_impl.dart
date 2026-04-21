import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:ssh_client/core/errors/app_exceptions.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/services/ssh/ssh_service.dart';

class SshServiceImpl implements SshService {
  SSHClient? _client;
  SSHSession? _session;
  final _outputController = StreamController<Uint8List>.broadcast();
  bool _connected = false;

  Stream<Uint8List> get output => _outputController.stream;

  @override
  Stream<String> get outputStream =>
      _outputController.stream.map((d) => utf8.decode(d, allowMalformed: true));

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect(ConnectionModel connection) async {
    try {
      final socket = await SSHSocket.connect(
        connection.host,
        connection.port,
        timeout: const Duration(seconds: 30),
      );

      _client = SSHClient(
        socket,
        username: connection.username,
        onPasswordRequest: connection.useKeyAuth
            ? null
            : () => connection.password ?? '',
        identities: connection.useKeyAuth && connection.privateKeyPath != null
            ? [
                ...SSHKeyPair.fromPem(
                  connection.privateKeyPath!,
                  connection.passphrase,
                ),
              ]
            : null,
      );

      _session = await _client!.shell(
        pty: const SSHPtyConfig(type: 'xterm-256color'),
      );

      _session!.stdout.listen(
        _outputController.add,
        onError: (e) => _outputController.addError(e),
      );
      _session!.stderr.listen(
        _outputController.add,
        onError: (e) => _outputController.addError(e),
      );

      _connected = true;

      _session!.done.then((_) {
        _connected = false;
      });
    } catch (e) {
      _connected = false;
      throw ConnectionException('Failed to connect: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    _session?.close();
    _client?.close();
    _connected = false;
    await _outputController.close();
  }

  @override
  Future<void> sendCommand(String command) async {
    if (_session == null) throw const SessionException('No active session');
    _session!.stdin.add(utf8.encode(command));
  }

  void write(Uint8List data) {
    if (_session == null) return;
    _session!.stdin.add(data);
  }

  @override
  Future<void> resizeTerminal(int width, int height) async {
    _session?.resizeTerminal(width, height);
  }

  void dispose() {
    _session?.close();
    _client?.close();
    _outputController.close();
  }
}
