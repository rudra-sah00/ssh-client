import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/providers/providers.dart';
import 'package:ssh_client/presentation/screens/connection/add_edit_connection_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _search = '';

  void _openAddSheet([ConnectionModel? existing]) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => AddEditConnectionScreen(existing: existing),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(connectionListProvider);
    final mgr = ref.watch(sessionManagerProvider);

    var filtered = connections;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      filtered = filtered.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.host.toLowerCase().contains(q)).toList();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar: "Add" text right-aligned
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _openAddSheet(),
                    child: const Text('Add', style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 17)),
                  ),
                ],
              ),
            ),

            // Big title
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text('Servers', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
            ),

            // Search (only when many connections)
            if (connections.length > 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(Icons.search, color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),

            // Server list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Connection cards
                  if (filtered.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < filtered.length; i++) ...[
                            _ServerRow(
                              connection: filtered[i],
                              hasActive: mgr.activeSessions.any((s) => s.connection.id == filtered[i].id),
                              onEdit: () => _openAddSheet(filtered[i]),
                            ),
                            if (i < filtered.length - 1)
                              const Divider(height: 1, indent: 16, endIndent: 16, color: Colors.white10),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // + Add Server row
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.add, color: Color(0xFF4A9EFF), size: 20),
                      title: const Text('Add Server', style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 16)),
                      onTap: () => _openAddSheet(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerRow extends ConsumerWidget {
  final ConnectionModel connection;
  final bool hasActive;
  final VoidCallback onEdit;
  const _ServerRow({required this.connection, required this.hasActive, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        '${connection.host}:${connection.port}',
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'ssh ${connection.username}@${connection.host} -p ${connection.port}',
        style: const TextStyle(color: Colors.white38, fontSize: 13),
      ),
      trailing: hasActive
          ? Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
            )
          : null,
      onTap: () => Navigator.pushNamed(context, '/terminal', arguments: connection),
      onLongPress: () => _showActions(context, ref),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            Text(connection.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 4),
            Text('${connection.username}@${connection.host}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 16),
            _actionTile(ctx, 'Connect', Icons.terminal_rounded, () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/terminal', arguments: connection);
            }),
            _actionTile(ctx, 'SFTP Browser', Icons.folder_open_rounded, () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/sftp', arguments: connection);
            }),
            _actionTile(ctx, 'Tunnels', Icons.swap_horiz_rounded, () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/tunnel', arguments: connection);
            }),
            _actionTile(ctx, 'Duplicate', Icons.copy_rounded, () {
              Navigator.pop(ctx);
              final dup = connection.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString(), name: '${connection.name} (copy)');
              ref.read(connectionListProvider.notifier).add(dup);
            }),
            _actionTile(ctx, 'Edit', Icons.edit_rounded, () {
              Navigator.pop(ctx);
              onEdit();
            }),
            _actionTile(ctx, 'Delete', Icons.delete_outline_rounded, () {
              Navigator.pop(ctx);
              _confirmDelete(context, ref);
            }, isDestructive: true),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext ctx, String label, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white70, size: 22),
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : Colors.white)),
      onTap: onTap,
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Connection'),
        content: Text('Delete "${connection.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(connectionListProvider.notifier).delete(connection.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
