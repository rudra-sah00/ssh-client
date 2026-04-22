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

class _TerminalScreenState extends ConsumerState<TerminalScreen> with WidgetsBindingObserver {
  SshSession? _session;
  bool _loading = true;
  String? _error;
  bool _reconnecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connect();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _session != null && !_session!.isConnected) {
      _autoReconnect();
    }
  }

  Future<void> _autoReconnect() async {
    if (_reconnecting) return;
    _reconnecting = true;

    final terminal = _session!.terminal;
    final mgr = ref.read(sessionManagerProvider);
    final settings = ref.read(settingsProvider);

    // Write reconnect message to existing terminal
    terminal.write('\r\n\x1b[33m[Connection lost — reconnecting...]\x1b[0m\r\n');

    // Close dead session
    await mgr.closeSession(_session!.id);

    try {
      // Create new session but reuse the same terminal
      final session = await mgr.reconnectSession(
        widget.connection,
        terminal: terminal,
        keepAlive: settings.keepAlive,
        keepAliveInterval: settings.keepAliveInterval,
      );

      if (mounted) {
        setState(() { _session = session; });
        terminal.write('\x1b[32m[Reconnected]\x1b[0m\r\n');
      }
    } catch (e) {
      if (mounted) {
        terminal.write('\x1b[31m[Reconnect failed: $e]\x1b[0m\r\n');
      }
    }
    _reconnecting = false;
  }

  Future<void> _connect() async {
    try {
      final mgr = ref.read(sessionManagerProvider);
      final settings = ref.read(settingsProvider);

      // Check for existing session for this connection
      final existing = mgr.activeSessions.where(
        (s) => s.connection.id == widget.connection.id && s.isConnected,
      );
      if (existing.isNotEmpty) {
        if (mounted) setState(() { _session = existing.first; _loading = false; });
        return;
      }

      final session = await mgr.createSession(
        widget.connection,
        keepAlive: settings.keepAlive,
        keepAliveInterval: settings.keepAliveInterval,
        fontSize: settings.terminalFontSize,
      );
      if (mounted) {
        setState(() { _session = session; _loading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _loading = false; });
      }
    }
  }

  void _confirmDisconnect(BuildContext context, SessionManager mgr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect'),
        content: Text('Disconnect from ${_session?.connection.name ?? "session"}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              if (_session != null) await mgr.closeSession(_session!.id);
              if (mgr.activeSessions.isNotEmpty) {
                setState(() => _session = mgr.activeSessions.last);
              } else {
                if (context.mounted) Navigator.pop(context);
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
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _session?.isConnected == true ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(width: 10),
            Text(_session?.connection.name ?? 'Connecting...'),
          ],
        ),
        titleTextStyle: GoogleFonts.jetBrainsMono(fontSize: 15, color: cs.onSurface),
        actions: [
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
                      color: s.isConnected ? Colors.white70 : Colors.red.shade400,
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
              const Icon(Icons.error_outline_rounded, size: 40, color: Colors.red),
              const SizedBox(height: 20),
              Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () { setState(() { _loading = true; _error = null; }); _connect(); },
                child: const Text('Retry'),
              ),
            ]),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        child: Text(
          '${_session!.connection.username}@${_session!.connection.host}:${_session!.connection.port}',
          style: GoogleFonts.jetBrainsMono(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 11,
          ),
        ),
      ),
      Expanded(
        child: TerminalView(
          _session!.terminal,
          textStyle: TerminalStyle(
            fontSize: settings.terminalFontSize,
            fontFamily: GoogleFonts.jetBrainsMono().fontFamily!,
          ),
          theme: isDark
              ? const TerminalTheme(
                  cursor: Color(0xFFE0E0E0),
                  selection: Color(0x80FFFFFF),
                  foreground: Color(0xFFE0E0E0),
                  background: Color(0xFF000000),
                  black: Color(0xFF000000),
                  white: Color(0xFFE0E0E0),
                  red: Color(0xFFFF6B6B),
                  green: Color(0xFF69DB7C),
                  yellow: Color(0xFFFCC419),
                  blue: Color(0xFF74C0FC),
                  magenta: Color(0xFFDA77F2),
                  cyan: Color(0xFF66D9E8),
                  brightBlack: Color(0xFF868E96),
                  brightRed: Color(0xFFFF8787),
                  brightGreen: Color(0xFF8CE99A),
                  brightYellow: Color(0xFFFFD43B),
                  brightBlue: Color(0xFFA5D8FF),
                  brightMagenta: Color(0xFFE599F7),
                  brightCyan: Color(0xFF99E9F2),
                  brightWhite: Color(0xFFFFFFFF),
                  searchHitBackground: Color(0xFFFFD43B),
                  searchHitBackgroundCurrent: Color(0xFFFFA94D),
                  searchHitForeground: Color(0xFF000000),
                )
              : const TerminalTheme(
                  cursor: Color(0xFF333333),
                  selection: Color(0x40000000),
                  foreground: Color(0xFF1E1E1E),
                  background: Color(0xFFF2F2F7),
                  black: Color(0xFF1E1E1E),
                  white: Color(0xFFF2F2F7),
                  red: Color(0xFFC92A2A),
                  green: Color(0xFF2B8A3E),
                  yellow: Color(0xFFE67700),
                  blue: Color(0xFF1864AB),
                  magenta: Color(0xFF862E9C),
                  cyan: Color(0xFF0B7285),
                  brightBlack: Color(0xFF868E96),
                  brightRed: Color(0xFFE03131),
                  brightGreen: Color(0xFF37B24D),
                  brightYellow: Color(0xFFF59F00),
                  brightBlue: Color(0xFF1C7ED6),
                  brightMagenta: Color(0xFF9C36B5),
                  brightCyan: Color(0xFF1098AD),
                  brightWhite: Color(0xFF000000),
                  searchHitBackground: Color(0xFFFFD43B),
                  searchHitBackgroundCurrent: Color(0xFFFFA94D),
                  searchHitForeground: Color(0xFF000000),
                ),
          autofocus: true,
          deleteDetection: true,
        ),
      ),
      TerminalControlBar(
        onKeyTap: (key) => _session?.service.write(Uint8List.fromList(key.codeUnits)),
      ),
    ]);
  }
}
