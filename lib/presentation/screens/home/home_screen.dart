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

  void _openAdd([ConnectionModel? existing]) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddEditConnectionScreen(existing: existing),
      transitionsBuilder: (context, anim, secondaryAnimation, child) =>
          SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)), child: child),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final connections = ref.watch(connectionListProvider);
    final mgr = ref.watch(sessionManagerProvider);
    final cs = Theme.of(context).colorScheme;

    var filtered = connections;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      filtered = filtered.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.host.toLowerCase().contains(q)).toList();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _openAdd(),
                  child: const Text('Add', style: TextStyle(color: Color(0xFF4A9EFF), fontSize: 17)),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Text('Servers', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            ),
          ),

          // Search
          if (connections.length > 3)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3)),
                    prefixIcon: Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: Theme.of(context).cardTheme.color,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  style: TextStyle(color: cs.onSurface),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
            ),

          // Content
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  connections.isEmpty ? 'No servers' : 'No results',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: 17),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < filtered.length; i++) ...[
                        _ServerRow(
                          connection: filtered[i],
                          hasActive: mgr.activeSessions.any((s) => s.connection.id == filtered[i].id),
                          onEdit: () => _openAdd(filtered[i]),
                          onDelete: () => _confirmDelete(filtered[i]),
                        ),
                        if (i < filtered.length - 1)
                          Divider(height: 1, indent: 16, endIndent: 16, color: cs.onSurface.withValues(alpha: 0.08)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(ConnectionModel conn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Connection'),
        content: Text('Delete "${conn.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(connectionListProvider.notifier).delete(conn.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ServerRow extends StatelessWidget {
  final ConnectionModel connection;
  final bool hasActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ServerRow({required this.connection, required this.hasActive, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        '${connection.host}:${connection.port}',
        style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'ssh ${connection.username}@${connection.host} -p ${connection.port}',
        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.38), fontSize: 13),
      ),
      trailing: hasActive
          ? Container(width: 8, height: 8, decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.5), shape: BoxShape.circle))
          : null,
      onTap: () => Navigator.pushNamed(context, '/terminal', arguments: connection),
      onLongPress: () => _showOptions(context),
    );
  }

  void _showOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, size: 22),
              title: const Text('Edit'),
              onTap: () { Navigator.pop(ctx); onEdit(); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, size: 22, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(ctx); onDelete(); },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
