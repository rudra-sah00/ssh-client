import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:ssh_client/core/errors/app_exceptions.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';

class SftpService {
  SSHClient? _client;
  SftpClient? _sftp;

  bool get isConnected => _sftp != null;

  Future<void> connect(ConnectionModel connection) async {
    try {
      final socket = await SSHSocket.connect(
        connection.host, connection.port,
        timeout: const Duration(seconds: 30),
      );
      _client = SSHClient(
        socket,
        username: connection.username,
        onPasswordRequest: connection.useKeyAuth
            ? null : () => connection.password ?? '',
        identities: connection.useKeyAuth && connection.privateKeyPath != null
            ? [...SSHKeyPair.fromPem(connection.privateKeyPath!, connection.passphrase)]
            : null,
      );
      _sftp = await _client!.sftp();
    } catch (e) {
      throw ConnectionException('SFTP connect failed: $e');
    }
  }

  Future<List<SftpName>> listDirectory(String path) async {
    if (_sftp == null) throw const SessionException('No SFTP session');
    return _sftp!.listdir(path);
  }

  Future<Uint8List> readFile(String path) async {
    if (_sftp == null) throw const SessionException('No SFTP session');
    final file = await _sftp!.open(path);
    final data = await file.readBytes();
    await file.close();
    return data;
  }

  Future<void> writeFile(String path, Uint8List data) async {
    if (_sftp == null) throw const SessionException('No SFTP session');
    final file = await _sftp!.open(path, mode: SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate);
    await file.writeBytes(data);
    await file.close();
  }

  Future<void> delete(String path) async {
    if (_sftp == null) throw const SessionException('No SFTP session');
    await _sftp!.remove(path);
  }

  Future<void> mkdir(String path) async {
    if (_sftp == null) throw const SessionException('No SFTP session');
    await _sftp!.mkdir(path);
  }

  Future<void> rename(String oldPath, String newPath) async {
    if (_sftp == null) throw const SessionException('No SFTP session');
    await _sftp!.rename(oldPath, newPath);
  }

  Future<SftpFileAttrs> stat(String path) async {
    if (_sftp == null) throw const SessionException('No SFTP session');
    return _sftp!.stat(path);
  }

  void dispose() {
    _sftp?.close();
    _client?.close();
  }
}
