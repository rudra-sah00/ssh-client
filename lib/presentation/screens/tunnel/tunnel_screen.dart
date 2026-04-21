import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/services/tunnel/tunnel_service.dart';

final tunnelServiceProvider = Provider((_) => TunnelService());

class TunnelScreen extends ConsumerStatefulWidget {
  final ConnectionModel connection;
  const TunnelScreen({super.key, required this.connection});

  @override
  ConsumerState<TunnelScreen> createState() => _TunnelScreenState();
}

class _TunnelScreenState extends ConsumerState<TunnelScreen> {
  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(tunnelServiceProvider);
    final tunnels = svc.activeTunnels;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Tunnels — ${widget.connection.name}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, svc),
        icon: const Icon(Icons.add),
        label: const Text('New Tunnel'),
      ),
      body: tunnels.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_calls_rounded, size: 64, color: cs.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No active tunnels', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('Tap below to create a port forward', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline)),
                ],
              ).animate().fadeIn(duration: 400.ms).moveY(begin: 12, end: 0),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: tunnels.length,
              itemBuilder: (context, i) {
                final t = tunnels[i];
                final srcLabel = t.isLocal ? 'localhost:${t.localPort}' : '${t.remoteHost}:${t.remotePort}';
                final dstLabel = t.isLocal ? '${t.remoteHost}:${t.remotePort}' : 'localhost:${t.localPort}';

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Status dot
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.isActive ? Colors.white70 : Colors.grey,
                            boxShadow: t.isActive
                                ? [BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 6, spreadRadius: 1)]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Tunnel info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(t.isLocal ? Icons.upload_rounded : Icons.download_rounded, size: 16, color: cs.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.isLocal ? 'Local Forward' : 'Remote Forward',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(srcLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: cs.outline),
                                  ),
                                  Text(dstLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Stop button
                        IconButton(
                          icon: const Icon(Icons.stop_circle_rounded),
                          color: cs.error,
                          tooltip: 'Stop tunnel',
                          onPressed: () async {
                            await svc.stopTunnel(t.id);
                            setState(() {});
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tunnel stopped')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (50 * i).ms).slideX(begin: 0.05, end: 0);
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, TunnelService svc) {
    final localPort = TextEditingController();
    final remoteHost = TextEditingController(text: '127.0.0.1');
    final remotePort = TextEditingController();
    bool isLocal = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Tunnel'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Local')),
                  ButtonSegment(value: false, label: Text('Remote')),
                ],
                selected: {isLocal},
                onSelectionChanged: (v) => setDialogState(() => isLocal = v.first),
              ),
              const SizedBox(height: 12),
              TextField(controller: localPort, decoration: const InputDecoration(labelText: 'Local Port'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: remoteHost, decoration: const InputDecoration(labelText: 'Remote Host')),
              const SizedBox(height: 8),
              TextField(controller: remotePort, decoration: const InputDecoration(labelText: 'Remote Port'), keyboardType: TextInputType.number),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  if (isLocal) {
                    await svc.startLocalForward(
                      connection: widget.connection,
                      localPort: int.parse(localPort.text),
                      remoteHost: remoteHost.text.trim(),
                      remotePort: int.parse(remotePort.text),
                    );
                  } else {
                    await svc.startRemoteForward(
                      connection: widget.connection,
                      remotePort: int.parse(remotePort.text),
                      localHost: remoteHost.text.trim(),
                      localPort: int.parse(localPort.text),
                    );
                  }
                  setState(() {});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tunnel started')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
