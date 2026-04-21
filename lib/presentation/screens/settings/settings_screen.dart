import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/providers/providers.dart';

const _grey = Color(0xFF8E8E93);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final labelColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: const Text('Settings'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(delegate: SliverChildListDelegate([
          // ── Theme ──
          _Card(
            color: cardColor,
            children: [
              _CardHeader(icon: Icons.brightness_6_outlined, title: 'Theme'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(settings.themeMode == 'dark' ? 'Dark Mode' : 'Light Mode', style: const TextStyle(fontSize: 16)),
                  Switch.adaptive(
                    value: settings.themeMode == 'dark',
                    activeColor: _grey,
                    onChanged: (v) => notifier.update(settings.copyWith(themeMode: v ? 'dark' : 'light')),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Terminal ──
          _Card(
            color: cardColor,
            children: [
              _CardHeader(icon: Icons.terminal_outlined, title: 'Terminal'),
              Text('Font size: ${settings.terminalFontSize.round()}', style: TextStyle(color: labelColor, fontSize: 13)),
              Slider(
                min: 8, max: 24, divisions: 16,
                value: settings.terminalFontSize,
                activeColor: _grey,
                onChanged: (v) => notifier.update(settings.copyWith(terminalFontSize: v)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Connection ──
          _Card(
            color: cardColor,
            children: [
              _CardHeader(icon: Icons.wifi_outlined, title: 'Connection'),
              Text('Keep connections alive in background', style: TextStyle(color: labelColor, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Keep Alive'),
                  Switch.adaptive(
                    value: settings.keepAlive,
                    activeColor: _grey,
                    onChanged: (v) => notifier.update(settings.copyWith(keepAlive: v)),
                  ),
                ],
              ),
              if (settings.keepAlive) ...[
                Text('Interval: ${settings.keepAliveInterval}s', style: TextStyle(color: labelColor, fontSize: 13)),
                Slider(
                  min: 5, max: 120, divisions: 23,
                  value: settings.keepAliveInterval.toDouble(),
                  activeColor: _grey,
                  onChanged: (v) => notifier.update(settings.copyWith(keepAliveInterval: v.round())),
                ),
              ],
              Text('Timeout: ${settings.connectionTimeout}s', style: TextStyle(color: labelColor, fontSize: 13)),
              Slider(
                min: 5, max: 60, divisions: 11,
                value: settings.connectionTimeout.toDouble(),
                activeColor: _grey,
                onChanged: (v) => notifier.update(settings.copyWith(connectionTimeout: v.round())),
              ),
              const Divider(height: 16),
              Text(
                settings.maxSessionMinutes == 0
                    ? 'Max session: Forever'
                    : 'Max session: ${settings.maxSessionMinutes} min',
                style: TextStyle(color: labelColor, fontSize: 13),
              ),
              Slider(
                min: 0, max: 480, divisions: 16,
                value: settings.maxSessionMinutes.toDouble(),
                activeColor: _grey,
                onChanged: (v) => notifier.update(settings.copyWith(maxSessionMinutes: v.round())),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Snippets ──
          _Card(
            color: cardColor,
            children: [
              _CardHeader(icon: Icons.code_outlined, title: 'Snippets'),
              Text('Saved commands for quick access', style: TextStyle(color: labelColor, fontSize: 13)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/snippets'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Manage Snippets', style: TextStyle(color: _grey, fontSize: 16)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Data ──
          _Card(
            color: cardColor,
            children: [
              _CardHeader(icon: Icons.swap_vert_outlined, title: 'Data'),
              Text('Backup and restore your connections', style: TextStyle(color: labelColor, fontSize: 13)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  final json = ref.read(connectionListProvider.notifier).exportAll();
                  Clipboard.setData(ClipboardData(text: json));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Export Connections', style: TextStyle(color: _grey, fontSize: 16)),
                ),
              ),
              GestureDetector(
                onTap: () => _showImportDialog(context, ref),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Import Connections', style: TextStyle(color: _grey, fontSize: 16)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── About ──
          _Card(
            color: cardColor,
            children: [
              _CardHeader(icon: Icons.info_outline, title: 'About'),
              Text('SSH Client v1.0.0', style: TextStyle(color: labelColor, fontSize: 13)),
              const SizedBox(height: 4),
              Text('A pure client-side SSH terminal with no backend required.', style: TextStyle(color: labelColor, fontSize: 13)),
            ],
          ),

          const SizedBox(height: 32),
        ])),
            ),
          ],
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported $count connection(s)')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
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

class _Card extends StatelessWidget {
  final Color color;
  final List<Widget> children;
  const _Card({required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
