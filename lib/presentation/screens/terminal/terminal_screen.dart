import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xterm/xterm.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/models/settings/settings_model.dart';
import 'package:ssh_client/data/providers/providers.dart';
import 'package:ssh_client/data/services/ssh/session_manager.dart';
import 'package:ssh_client/presentation/widgets/terminal/terminal_control_bar.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  final ConnectionModel connection;
  const TerminalScreen({super.key, required this.connection});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  SshSession? _session;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final mgr = ref.read(sessionManagerProvider);
      final settings = ref.read(settingsProvider);
      final session = await mgr.createSession(
        widget.connection,
        keepAlive: settings.keepAlive,
        keepAliveInterval: settings.keepAliveInterval,
        fontSize: settings.terminalFontSize,
      );
      if (mounted) {
        setState(() { _session = session; _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Connected to ${widget.connection.name}'),
          ])),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDisconnect(BuildContext context, SessionManager mgr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.red, size: 32),
        title: const Text('Disconnect'),
        content: Text('Disconnect from ${_session?.connection.name ?? "session"}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final name = _session?.connection.name ?? '';
              if (_session != null) await mgr.closeSession(_session!.id);
              if (mgr.activeSessions.isNotEmpty) {
                setState(() => _session = mgr.activeSessions.last);
              } else {
                if (context.mounted) Navigator.pop(context);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Disconnected from $name')));
              }
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mgr = ref.watch(sessionManagerProvider);
    final allSessions = mgr.activeSessions;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _session?.isConnected == true ? Colors.green.shade400 : Colors.grey,
              ),
            ),
            const SizedBox(width: 10),
            Text(_session?.connection.name ?? 'Connecting...'),
          ],
        ),
        titleTextStyle: GoogleFonts.jetBrainsMono(fontSize: 15, color: cs.onSurface),
        actions: [
          // Session switcher
          if (allSessions.length > 1)
            PopupMenuButton<String>(
              icon: Badge(
                label: Text('${allSessions.length}', style: const TextStyle(fontSize: 10)),
                child: Icon(Icons.tab_rounded, color: cs.primary),
              ),
              onSelected: (id) {
                final s = mgr.getSession(id);
                if (s != null) setState(() => _session = s);
              },
              itemBuilder: (_) => allSessions.map((s) => PopupMenuItem(
                value: s.id,
                child: Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.isConnected ? Colors.green.shade400 : Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(s.connection.name),
                  if (s.id == _session?.id) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check_rounded, size: 16, color: cs.primary),
                  ],
                ]),
              )).toList(),
            ),
          IconButton(icon: Icon(Icons.code_rounded, color: cs.primary), tooltip: 'Snippets',
            onPressed: () => Navigator.pushNamed(context, '/snippets',
              arguments: _session != null
                  ? (String cmd) => _session!.service.write(Uint8List.fromList('$cmd\n'.codeUnits))
                  : null)),
          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red), tooltip: 'Disconnect',
            onPressed: () => _confirmDisconnect(context, mgr)),
        ],
      ),
      body: _buildBody(settings),
    );
  }

  Widget _buildBody(SettingsModel settings) {
    if (_loading) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 48, height: 48,
              child: CircularProgressIndicator(strokeWidth: 3, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text('Connecting to ${widget.connection.host}...',
                style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 6),
            Text('${widget.connection.username}@${widget.connection.host}:${widget.connection.port}',
                style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12)),
          ]).animate().fadeIn(duration: 400.ms),
        ),
      );
    }

    if (_error != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.error_outline_rounded, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 20),
              Text('Connection Failed', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: () { setState(() { _loading = true; _error = null; }); _connect(); },
                label: const Text('Retry'),
              ),
            ]).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          ),
        ),
      );
    }

    return Column(children: [
      // Connection info bar
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        color: Colors.white.withValues(alpha: 0.05),
        child: Text(
          '${_session!.connection.username}@${_session!.connection.host}:${_session!.connection.port}',
          style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 11),
        ),
      ),
      Expanded(
        child: TerminalView(
          _session!.terminal,
          textStyle: TerminalStyle(
            fontSize: settings.terminalFontSize,
            fontFamily: GoogleFonts.jetBrainsMono().fontFamily!,
          ),
          autofocus: true,
        ),
      ),
      TerminalControlBar(
        onKeyTap: (key) => _session?.service.write(Uint8List.fromList(key.codeUnits)),
      ),
    ]);
  }
}
