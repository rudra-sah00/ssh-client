import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // — Terminal —
          _SectionHeader(icon: Icons.terminal_outlined, title: 'Terminal'),
          _SectionCard(
            children: [
              ListTile(
                leading: Icon(Icons.text_fields, color: colors.primary),
                title: const Text('Terminal Font Size'),
                subtitle: Text('${settings.terminalFontSize.round()}'),
              ),
              Slider(
                min: 8, max: 24, divisions: 16,
                value: settings.terminalFontSize,
                label: '${settings.terminalFontSize.round()}',
                onChanged: (v) => notifier.update(settings.copyWith(terminalFontSize: v)),
              ),
            ],
          ),

          // — Connection —
          _SectionHeader(icon: Icons.lan_outlined, title: 'Connection'),
          _SectionCard(
            children: [
              SwitchListTile(
                title: const Text('Keep Alive'),
                subtitle: const Text('Prevent idle disconnect'),
                secondary: Icon(Icons.timer, color: colors.primary),
                value: settings.keepAlive,
                onChanged: (v) => notifier.update(settings.copyWith(keepAlive: v)),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.schedule, color: colors.primary),
                title: const Text('Keep Alive Interval'),
                subtitle: Text('${settings.keepAliveInterval} seconds'),
              ),
              Slider(
                min: 5, max: 120, divisions: 23,
                value: settings.keepAliveInterval.toDouble(),
                label: '${settings.keepAliveInterval}s',
                onChanged: settings.keepAlive
                    ? (v) => notifier.update(settings.copyWith(keepAliveInterval: v.round()))
                    : null,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.access_time, color: colors.primary),
                title: const Text('Connection Timeout'),
                subtitle: Text('${settings.connectionTimeout} seconds'),
              ),
              Slider(
                min: 5, max: 60, divisions: 11,
                value: settings.connectionTimeout.toDouble(),
                label: '${settings.connectionTimeout}s',
                onChanged: (v) => notifier.update(settings.copyWith(connectionTimeout: v.round())),
              ),
            ],
          ),

          // — Data —
          _SectionHeader(icon: Icons.folder_outlined, title: 'Data'),
          _SectionCard(
            children: [
              ListTile(
                leading: Icon(Icons.upload, color: colors.primary),
                title: const Text('Export Connections'),
                subtitle: const Text('Copy all connections as JSON'),
                onTap: () {
                  final json = ref.read(connectionListProvider.notifier).exportAll();
                  Clipboard.setData(ClipboardData(text: json));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Connections copied to clipboard')),
                  );
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.download, color: colors.primary),
                title: const Text('Import Connections'),
                subtitle: const Text('Paste JSON to import'),
                onTap: () => _showImportDialog(context, ref),
              ),
            ],
          ),

          // — About —
          _SectionHeader(icon: Icons.info_outline, title: 'About'),
          _SectionCard(
            children: [
              ListTile(
                leading: Icon(Icons.info_outline, color: colors.primary),
                title: const Text('SSH Client'),
                subtitle: const Text('v1.0.0'),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ].animate(interval: 80.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 300.ms),
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Connections'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(hintText: 'Paste exported JSON here...', border: OutlineInputBorder()),
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final count = await ref.read(connectionListProvider.notifier).importAll(controller.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Imported $count connection(s)')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Import failed: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(children: children),
    );
  }
}
