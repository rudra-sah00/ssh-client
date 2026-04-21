import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ssh_client/data/models/snippet/snippet_model.dart';
import 'package:ssh_client/data/providers/providers.dart';

class SnippetScreen extends ConsumerWidget {
  /// If provided, tapping a snippet sends it to this callback instead of just copying.
  final void Function(String command)? onSend;
  const SnippetScreen({super.key, this.onSend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snippets = ref.watch(snippetListProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Snippets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('New Snippet'),
      ),
      body: snippets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.terminal_rounded, size: 64, color: cs.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No saved snippets', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Tap below to create one',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snippets.length,
              itemBuilder: (context, i) {
                final s = snippets[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (onSend != null) {
                        onSend!(s.command);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent: ${s.name}')));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.code_rounded, color: cs.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s.name, style: Theme.of(context).textTheme.titleSmall)),
                              PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') _showEditor(context, ref, s);
                                  if (v == 'delete') {
                                    ref.read(snippetListProvider.notifier).delete(s.id);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(content: Text('Deleted "${s.name}"')));
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s.command,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (50 * i).ms).slideX(begin: 0.05);
              },
            ),
    );
  }

  void _showEditor(BuildContext context, WidgetRef ref, SnippetModel? existing) {
    final name = TextEditingController(text: existing?.name ?? '');
    final command = TextEditingController(text: existing?.command ?? '');
    final desc = TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'New Snippet' : 'Edit Snippet'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(
                controller: command,
                decoration: const InputDecoration(labelText: 'Command'),
                maxLines: 3,
                style: GoogleFonts.jetBrainsMono(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description (optional)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (name.text.isEmpty || command.text.isEmpty) return;
              final snippet = SnippetModel(
                id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: name.text.trim(),
                command: command.text.trim(),
                description: desc.text.trim(),
              );
              final notifier = ref.read(snippetListProvider.notifier);
              existing == null ? notifier.add(snippet) : notifier.update(snippet);
              Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }
}
