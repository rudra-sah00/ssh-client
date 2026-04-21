import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/providers/providers.dart';

const _accent = Color(0xFF8E8E93);

class AddEditConnectionScreen extends ConsumerStatefulWidget {
  final ConnectionModel? existing;
  final ScrollController? scrollController;
  const AddEditConnectionScreen({super.key, this.existing, this.scrollController});

  @override
  ConsumerState<AddEditConnectionScreen> createState() => _State();
}

class _State extends ConsumerState<AddEditConnectionScreen> {
  late final TextEditingController _username;
  late final TextEditingController _host;
  late final TextEditingController _port;
  late final TextEditingController _password;
  late final TextEditingController _privateKey;
  late final TextEditingController _alias;
  late final TextEditingController _group;
  late bool _useKey;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _username = TextEditingController(text: c?.username ?? '');
    _host = TextEditingController(text: c?.host ?? '');
    _port = TextEditingController(text: '${c?.port ?? 22}');
    _password = TextEditingController(text: c?.password ?? '');
    _privateKey = TextEditingController(text: c?.privateKeyPath ?? '');
    _alias = TextEditingController(text: c?.name ?? '');
    _group = TextEditingController(text: c?.group ?? '');
    _useKey = c?.useKeyAuth ?? false;
  }

  @override
  void dispose() {
    for (final c in [_username, _host, _port, _password, _privateKey, _alias, _group]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_host.text.trim().isEmpty || _username.text.trim().isEmpty) return;
    final conn = ConnectionModel(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _alias.text.trim().isEmpty ? '${_host.text.trim()}:${_port.text}' : _alias.text.trim(),
      host: _host.text.trim(),
      port: int.tryParse(_port.text) ?? 22,
      username: _username.text.trim(),
      password: _useKey ? null : _password.text,
      useKeyAuth: _useKey,
      privateKeyPath: _useKey ? _privateKey.text.trim() : null,
      group: _group.text.trim(),
    );
    final notifier = ref.read(connectionListProvider.notifier);
    _isEditing ? notifier.update(conn) : notifier.add(conn);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final bgColor = isDark ? Colors.black : const Color(0xFFF2F2F7);

    final content = ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.chevron_left, color: _accent, size: 28),
                    Text('Servers', style: TextStyle(color: _accent, fontSize: 17)),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _save,
                child: const Text('Save', style: TextStyle(color: _accent, fontSize: 17)),
              ),
            ],
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          child: Text(
            _isEditing ? 'Edit Server' : 'New Server',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),

        // SSH-Server section
        _sectionHeader('SSH-Server', Icons.dns_outlined),
        const SizedBox(height: 12),
        _label('Username'),
        _field(_username, hint: 'root'),
        const SizedBox(height: 12),
        _label('Address'),
        _field(_host, hint: 'Example: 192.168.0.3', trailing: 'Required'),
        const SizedBox(height: 12),
        _label('Port'),
        _field(_port, hint: '22', keyboardType: TextInputType.number),

        const SizedBox(height: 28),

        // Authentication section
        _sectionHeader('Authentication', Icons.lock_outline),
        const SizedBox(height: 12),
        // Password / Key toggle
        Container(
          decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              _toggleTab('Password', !_useKey, () => setState(() => _useKey = false)),
              _toggleTab('Key', _useKey, () => setState(() => _useKey = true)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _label(_useKey ? 'Private Key' : 'Password'),
        if (_useKey)
          _field(_privateKey, hint: 'Paste PEM key', maxLines: 3)
        else
          _field(_password, obscure: true),

        const SizedBox(height: 28),

        // Optional section
        _sectionHeader('Optional', Icons.tune_outlined),
        const SizedBox(height: 12),
        _label('Alias'),
        _field(_alias, hint: 'Example: MyServer'),
        const SizedBox(height: 12),
        _label('Group name'),
        _field(_group),

        const SizedBox(height: 32),

        // Cancel / Save buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Cancel', style: TextStyle(color: _accent, fontSize: 17, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: fieldColor, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Save', style: TextStyle(color: _accent, fontSize: 17, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (widget.scrollController != null) return content;
    return Scaffold(backgroundColor: bgColor, body: SafeArea(child: content));
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _accent, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: _accent, fontSize: 17, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54, fontSize: 13)),
    );
  }

  Widget _field(
    TextEditingController controller, {
    String? hint,
    String? trailing,
    bool obscure = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final d = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: d ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: d ? Colors.white : Colors.black, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: d ? Colors.white24 : Colors.black26),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixText: trailing,
          suffixStyle: TextStyle(color: d ? Colors.white30 : Colors.black38, fontSize: 13),
        ),
      ),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    final d = Theme.of(context).brightness == Brightness.dark;
    final fg = d ? Colors.white : Colors.black;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? fg.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: TextStyle(
            color: active ? fg : fg.withValues(alpha: 0.38),
            fontSize: 14,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          )),
        ),
      ),
    );
  }
}
