import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/providers/providers.dart';

class AddEditConnectionScreen extends ConsumerStatefulWidget {
  final ConnectionModel? existing;
  final ScrollController? scrollController;
  const AddEditConnectionScreen({super.key, this.existing, this.scrollController});

  @override
  ConsumerState<AddEditConnectionScreen> createState() => _State();
}

class _State extends ConsumerState<AddEditConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _host;
  late final TextEditingController _port;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late bool _useKey;
  late final TextEditingController _privateKey;
  late final TextEditingController _group;
  late final TextEditingController _tagsInput;
  late List<String> _tags;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _host = TextEditingController(text: c?.host ?? '');
    _port = TextEditingController(text: '${c?.port ?? 22}');
    _username = TextEditingController(text: c?.username ?? '');
    _password = TextEditingController(text: c?.password ?? '');
    _useKey = c?.useKeyAuth ?? false;
    _privateKey = TextEditingController(text: c?.privateKeyPath ?? '');
    _group = TextEditingController(text: c?.group ?? '');
    _tags = List<String>.from(c?.tags ?? []);
    _tagsInput = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [_name, _host, _port, _username, _password, _privateKey, _group, _tagsInput]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final conn = ConnectionModel(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      host: _host.text.trim(),
      port: int.tryParse(_port.text) ?? 22,
      username: _username.text.trim(),
      password: _useKey ? null : _password.text,
      useKeyAuth: _useKey,
      privateKeyPath: _useKey ? _privateKey.text.trim() : null,
      group: _group.text.trim(),
      tags: _tags,
    );
    final notifier = ref.read(connectionListProvider.notifier);
    _isEditing ? notifier.update(conn) : notifier.add(conn);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSheet = widget.scrollController != null;

    final content = SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSheet) ...[
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: colors.onSurfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(children: [
                Icon(_isEditing ? Icons.edit_rounded : Icons.add_link_rounded, size: 22, color: colors.primary),
                const SizedBox(width: 10),
                Text(_isEditing ? 'Edit Connection' : 'New Connection', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 20),
            ],
              // ── Server Section ──
              _SectionHeader(icon: Icons.dns_rounded, label: 'Server', color: colors.primary)
                  .animate().fadeIn(duration: 300.ms).slideY(begin: 0.15),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: colors.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.label_outline)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _host,
                      decoration: const InputDecoration(labelText: 'Host', prefixIcon: Icon(Icons.language_rounded)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _port,
                      decoration: const InputDecoration(labelText: 'Port', prefixIcon: Icon(Icons.numbers_rounded)),
                      keyboardType: TextInputType.number,
                    ),
                  ]),
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 300.ms).slideY(begin: 0.15),

              const SizedBox(height: 28),

              // ── Authentication Section ──
              _SectionHeader(icon: Icons.shield_rounded, label: 'Authentication', color: colors.tertiary)
                  .animate().fadeIn(delay: 160.ms, duration: 300.ms).slideY(begin: 0.15),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: colors.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline_rounded)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile.adaptive(
                      title: const Text('Use Private Key'),
                      secondary: Icon(_useKey ? Icons.key_rounded : Icons.lock_outline_rounded, color: colors.tertiary),
                      value: _useKey,
                      onChanged: (v) => setState(() => _useKey = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    if (_useKey)
                      TextFormField(controller: _privateKey, decoration: const InputDecoration(labelText: 'Private Key (PEM)', prefixIcon: Icon(Icons.key_rounded)), maxLines: 3)
                    else
                      TextFormField(controller: _password, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)), obscureText: true),
                  ]),
                ),
              ).animate().fadeIn(delay: 240.ms, duration: 300.ms).slideY(begin: 0.15),

              const SizedBox(height: 28),

              // ── Organization Section ──
              _SectionHeader(icon: Icons.folder_open_rounded, label: 'Organization', color: colors.secondary)
                  .animate().fadeIn(delay: 320.ms, duration: 300.ms).slideY(begin: 0.15),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: colors.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _group,
                        decoration: const InputDecoration(labelText: 'Group (optional)', prefixIcon: Icon(Icons.folder_outlined)),
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _tagsInput,
                            decoration: const InputDecoration(labelText: 'Add tag', prefixIcon: Icon(Icons.tag_rounded), isDense: true),
                            onSubmitted: _addTag,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(icon: const Icon(Icons.add_rounded), onPressed: () => _addTag(_tagsInput.text)),
                      ]),
                      if (_tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _tags.map((t) => Chip(
                              label: Text(t),
                              onDeleted: () => setState(() => _tags.remove(t)),
                            )).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.15),

              const SizedBox(height: 32),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEditing ? Icons.check_rounded : Icons.save_rounded),
                  label: Text(_isEditing ? 'Update' : 'Save', style: textTheme.titleMedium?.copyWith(color: colors.onPrimary)),
                ),
              ).animate().fadeIn(delay: 480.ms, duration: 300.ms).slideY(begin: 0.15),

              const SizedBox(height: 16),
            ],
          ),
        ),
      );

    if (isSheet) return content;
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_isEditing ? Icons.edit_rounded : Icons.add_link_rounded, size: 22),
          const SizedBox(width: 10),
          Text(_isEditing ? 'Edit Connection' : 'New Connection'),
        ]),
      ),
      body: content,
    );
  }

  void _addTag(String tag) {
    final t = tag.trim();
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() => _tags.add(t));
      _tagsInput.clear();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
