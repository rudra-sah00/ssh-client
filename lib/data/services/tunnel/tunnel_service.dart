import 'dart:async';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:ssh_client/core/errors/app_exceptions.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';

class PortForward {
  final String id;
  final int localPort;
  final String remoteHost;
  final int remotePort;
  final bool isLocal;
  ServerSocket? _server;
  SSHClient? _client;
  SSHRemoteForward? _remoteForward;
  bool _active = false;

  bool get isActive => _active;

  PortForward({
    required this.id,
    required this.localPort,
    required this.remoteHost,
    required this.remotePort,
    this.isLocal = true,
  });
}

class TunnelService {
  final Map<String, PortForward> _tunnels = {};

  List<PortForward> get activeTunnels => _tunnels.values.toList();

  Future<PortForward> startLocalForward({
    required ConnectionModel connection,
    required int localPort,
    required String remoteHost,
    required int remotePort,
  }) async {
    final id = '${localPort}_${remoteHost}_$remotePort';
    if (_tunnels.containsKey(id)) throw const SessionException('Tunnel already exists');

    final socket = await SSHSocket.connect(
      connection.host, connection.port,
      timeout: const Duration(seconds: 30),
    );
    final client = SSHClient(
      socket,
      username: connection.username,
      onPasswordRequest: connection.useKeyAuth ? null : () => connection.password ?? '',
      identities: connection.useKeyAuth && connection.privateKeyPath != null
          ? [...SSHKeyPair.fromPem(connection.privateKeyPath!, connection.passphrase)]
          : null,
    );

    final server = await ServerSocket.bind('127.0.0.1', localPort);
    final forward = PortForward(
      id: id,
      localPort: server.port,
      remoteHost: remoteHost,
      remotePort: remotePort,
    )
      .._server = server
      .._client = client
      .._active = true;

    server.listen((sock) async {
      try {
        final channel = await client.forwardLocal(remoteHost, remotePort);
        channel.stream.cast<List<int>>().pipe(sock);
        sock.cast<List<int>>().pipe(channel.sink);
      } catch (_) {
        sock.destroy();
      }
    });

    _tunnels[id] = forward;
    return forward;
  }

  Future<PortForward> startRemoteForward({
    required ConnectionModel connection,
    required int remotePort,
    required String localHost,
    required int localPort,
  }) async {
    final id = 'r_${remotePort}_${localHost}_$localPort';
    if (_tunnels.containsKey(id)) throw const SessionException('Tunnel already exists');

    final socket = await SSHSocket.connect(
      connection.host, connection.port,
      timeout: const Duration(seconds: 30),
    );
    final client = SSHClient(
      socket,
      username: connection.username,
      onPasswordRequest: connection.useKeyAuth ? null : () => connection.password ?? '',
      identities: connection.useKeyAuth && connection.privateKeyPath != null
          ? [...SSHKeyPair.fromPem(connection.privateKeyPath!, connection.passphrase)]
          : null,
    );

    final remoteForward = await client.forwardRemote(port: remotePort);

    final forward = PortForward(
      id: id,
      localPort: localPort,
      remoteHost: localHost,
      remotePort: remotePort,
      isLocal: false,
    )
      .._client = client
      .._remoteForward = remoteForward
      .._active = true;

    remoteForward!.connections.listen((channel) async {
      try {
        final sock = await Socket.connect(localHost, localPort);
        channel.stream.cast<List<int>>().pipe(sock);
        sock.cast<List<int>>().pipe(channel.sink);
      } catch (_) {
        channel.close();
      }
    });

    _tunnels[id] = forward;
    return forward;
  }

  Future<void> stopTunnel(String id) async {
    final tunnel = _tunnels.remove(id);
    if (tunnel == null) return;
    tunnel._active = false;
    await tunnel._server?.close();
    if (tunnel._remoteForward != null) {
      await tunnel._client?.cancelForwardRemote(tunnel._remoteForward!);
    }
    tunnel._client?.close();
  }

  Future<void> stopAll() async {
    for (final id in _tunnels.keys.toList()) {
      await stopTunnel(id);
    }
  }
}
