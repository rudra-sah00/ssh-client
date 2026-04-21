import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/providers/providers.dart';
import 'package:ssh_client/data/services/ssh/session_manager.dart';
import 'package:ssh_client/presentation/screens/connection/add_edit_connection_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _search = '';
  String _selectedGroup = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final connections = ref.watch(connectionListProvider);
    final mgr = ref.watch(sessionManagerProvider);
    final groups = connections.map((c) => c.group).where((g) => g.isNotEmpty).toSet().toList()..sort();

    var filtered = connections;
    if (_selectedGroup.isNotEmpty) {
      filtered = filtered.where((c) => c.group == _selectedGroup).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      filtered = filtered.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.host.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: null,
        toolbarHeight: 48,
        actions: [
          IconButton(icon: Icon(Icons.flash_on_rounded, color: cs.tertiary), tooltip: 'Quick Connect', onPressed: () => _showQuickConnect(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddConnection(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New'),
      ).animate().scale(delay: 300.ms, duration: 300.ms, curve: Curves.easeOutBack),
      body: Column(
        children: [
          // Active sessions banner
          if (mgr.activeSessions.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(Icons.circle, size: 8, color: cs.primary),
                const SizedBox(width: 8),
                Text('${mgr.activeSessions.length} active session${mgr.activeSessions.length > 1 ? 's' : ''}',
                    style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
              ]),
            ).animate().fadeIn().slideY(begin: -0.3, duration: 300.ms),

          // Search
          if (connections.length > 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search connections or tags...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => setState(() => _search = ''))
                      : null,
                  filled: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ).animate().fadeIn(delay: 100.ms),

          // Group chips
          if (groups.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(label: const Text('All'), selected: _selectedGroup.isEmpty, onSelected: (_) => setState(() => _selectedGroup = '')),
                    const SizedBox(width: 6),
                    ...groups.map((g) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(label: Text(g), selected: _selectedGroup == g, onSelected: (_) => setState(() => _selectedGroup = _selectedGroup == g ? '' : g)),
                    )),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 4),

          // Content
          Expanded(
            child: filtered.isEmpty ? _buildEmptyState(context) : _buildList(filtered, mgr),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer.withValues(alpha: 0.3),
            ),
            child: Icon(Icons.terminal_rounded, size: 56, color: cs.primary),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(delay: 1.seconds, duration: 2.seconds, color: cs.primary.withValues(alpha: 0.15)),
          const SizedBox(height: 24),
          Text(
            _search.isEmpty ? 'No saved connections' : 'No matches found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (_search.isEmpty)
            Text('Tap + New to add or Quick Connect to get started',
                style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildList(List<ConnectionModel> filtered, SessionManager mgr) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _ConnectionTile(
        connection: filtered[i],
        activeSessions: mgr.activeSessions.where((s) => s.connection.id == filtered[i].id).toList(),
      ).animate().fadeIn(delay: Duration(milliseconds: 40 * i), duration: 300.ms).slideX(begin: 0.05),
    );
  }

  void _showAddConnection(BuildContext context, [ConnectionModel? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => AddEditConnectionScreen(
          existing: existing,
          scrollController: controller,
        ),
      ),
    );
  }

  void _showQuickConnect(BuildContext context) {
    final host = TextEditingController();
    final user = TextEditingController();
    final pass = TextEditingController();
    final port = TextEditingController(text: '22');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Icon(Icons.flash_on_rounded, color: Theme.of(context).colorScheme.tertiary),
            const SizedBox(width: 10),
            Text('Quick Connect', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 20),
          TextField(controller: host, decoration: const InputDecoration(labelText: 'Host', prefixIcon: Icon(Icons.dns_rounded))),
          const SizedBox(height: 12),
          TextField(controller: port, decoration: const InputDecoration(labelText: 'Port', prefixIcon: Icon(Icons.numbers_rounded)), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: user, decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_rounded))),
          const SizedBox(height: 12),
          TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_rounded)), obscureText: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              onPressed: () {
                if (host.text.isEmpty || user.text.isEmpty) return;
                Navigator.pop(ctx);
                final conn = ConnectionModel(
                  id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
                  name: '${user.text}@${host.text}',
                  host: host.text.trim(),
                  port: int.tryParse(port.text) ?? 22,
                  username: user.text.trim(),
                  password: pass.text,
                );
                Navigator.pushNamed(context, '/terminal', arguments: conn);
              },
              label: const Text('Connect'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ConnectionTile extends ConsumerWidget {
  final ConnectionModel connection;
  final List<SshSession> activeSessions;
  const _ConnectionTile({required this.connection, required this.activeSessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final hasActive = activeSessions.isNotEmpty;

    return Card(
      elevation: hasActive ? 2 : 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/terminal', arguments: connection),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Leading icon with active indicator
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: hasActive ? cs.primaryContainer : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.dns_rounded, color: hasActive ? cs.primary : cs.onSurfaceVariant, size: 22),
                    if (hasActive)
                      Positioned(
                        top: 2, right: 2,
                        child: Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(connection.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      if (hasActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${activeSessions.length} active',
                              style: TextStyle(color: Colors.green.shade400, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                    ]),
                    const SizedBox(height: 3),
                    Text('${connection.username}@${connection.host}:${connection.port}',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, fontFamily: 'monospace')),
                    if (connection.group.isNotEmpty || connection.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(spacing: 4, runSpacing: 4, children: [
                          if (connection.group.isNotEmpty)
                            _MiniChip(label: connection.group, color: cs.tertiary),
                          ...connection.tags.map((t) => _MiniChip(label: t, color: cs.secondary)),
                        ]),
                      ),
                  ],
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
                onSelected: (v) => _onAction(v, context, ref),
                itemBuilder: (_) => [
                  if (hasActive) _menuItem('resume', Icons.play_arrow_rounded, 'Resume Session'),
                  _menuItem('connect', Icons.add_circle_outline_rounded, 'New Session'),
                  _menuItem('sftp', Icons.folder_open_rounded, 'SFTP Browser'),
                  _menuItem('tunnel', Icons.swap_horiz_rounded, 'Tunnels'),
                  const PopupMenuDivider(),
                  _menuItem('duplicate', Icons.copy_rounded, 'Duplicate'),
                  _menuItem('edit', Icons.edit_rounded, 'Edit'),
                  _menuItem('delete', Icons.delete_outline_rounded, 'Delete', isDestructive: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 20, color: isDestructive ? Colors.red : null),
        const SizedBox(width: 12),
        Text(label, style: isDestructive ? const TextStyle(color: Colors.red) : null),
      ]),
    );
  }

  void _onAction(String action, BuildContext context, WidgetRef ref) {
    switch (action) {
      case 'resume' || 'connect':
        Navigator.pushNamed(context, '/terminal', arguments: connection);
      case 'sftp':
        Navigator.pushNamed(context, '/sftp', arguments: connection);
      case 'tunnel':
        Navigator.pushNamed(context, '/tunnel', arguments: connection);
      case 'duplicate':
        final dup = connection.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString(), name: '${connection.name} (copy)');
        ref.read(connectionListProvider.notifier).add(dup);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duplicated "${connection.name}"')));
      case 'edit':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, controller) => AddEditConnectionScreen(
              existing: connection,
              scrollController: controller,
            ),
          ),
        );
      case 'delete':
        _confirmDelete(context, ref);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32),
        title: const Text('Delete Connection'),
        content: Text('Delete "${connection.name}"?\nThis cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(connectionListProvider.notifier).delete(connection.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${connection.name}"')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
