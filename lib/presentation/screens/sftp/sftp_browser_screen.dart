import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/services/sftp/sftp_service.dart';

class SftpBrowserScreen extends StatefulWidget {
  final ConnectionModel connection;
  const SftpBrowserScreen({super.key, required this.connection});

  @override
  State<SftpBrowserScreen> createState() => _SftpBrowserScreenState();
}

class _SftpBrowserScreenState extends State<SftpBrowserScreen> {
  final _sftp = SftpService();
  String _currentPath = '/';
  List<SftpName> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    _sftp.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    try {
      await _sftp.connect(widget.connection);
      await _loadDir('/');
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadDir(String path) async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _sftp.listDirectory(path);
      items.sort((a, b) {
        final aDir = a.attr.isDirectory;
        final bDir = b.attr.isDirectory;
        if (aDir && !bDir) return -1;
        if (!aDir && bDir) return 1;
        return a.filename.compareTo(b.filename);
      });
      if (mounted) setState(() { _currentPath = path; _items = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _navigateTo(String name) {
    if (name == '..') {
      final parts = _currentPath.split('/')..removeLast();
      final parent = parts.isEmpty ? '/' : parts.join('/');
      _loadDir(parent.isEmpty ? '/' : parent);
    } else {
      final newPath = _currentPath == '/' ? '/$name' : '$_currentPath/$name';
      _loadDir(newPath);
    }
  }

  List<String> get _breadcrumbs {
    if (_currentPath == '/') return ['/'];
    final segments = _currentPath.split('/').where((s) => s.isNotEmpty).toList();
    return ['/', ...segments];
  }

  String _breadcrumbPath(int index) {
    if (index == 0) return '/';
    final segments = _currentPath.split('/').where((s) => s.isNotEmpty).toList();
    return '/${segments.sublist(0, index).join('/')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.connection.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'New Folder',
            onPressed: _newFolder,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadDir(_currentPath),
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb path bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  for (int i = 0; i < _breadcrumbs.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(Icons.chevron_right, size: 16, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      ),
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: i < _breadcrumbs.length - 1 ? () => _loadDir(_breadcrumbPath(i)) : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          _breadcrumbs[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            fontWeight: i == _breadcrumbs.length - 1 ? FontWeight.w600 : FontWeight.normal,
                            color: i == _breadcrumbs.length - 1 ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.folder_open_rounded, size: 48, color: colorScheme.primary.withValues(alpha: 0.5))
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Loading directory…', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ]).animate().fadeIn(duration: 300.ms),
      );
    }

    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextButton(onPressed: _connect, child: const Text('Retry')),
      ])).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
    }

    // Filter out '.' entry
    final visibleItems = _items.where((item) => item.filename != '.').toList();

    if (visibleItems.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.folder_off_rounded, size: 56, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('Empty directory', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text('No files or folders here', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
        ]),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: visibleItems.length,
      separatorBuilder: (_, _) => Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      itemBuilder: (context, i) {
        final item = visibleItems[i];
        final isDir = item.attr.isDirectory;
        final isBack = item.filename == '..';
        final iconData = isDir ? (isBack ? Icons.drive_file_move_rtl_rounded : Icons.folder_rounded) : _fileIcon(item.filename);
        final iconColor = isDir ? Colors.amber.shade700 : _fileIconColor(item.filename, colorScheme);

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          title: Text(
            isBack ? '..' : item.filename,
            style: TextStyle(fontWeight: isDir ? FontWeight.w500 : FontWeight.normal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isBack
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isDir)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          _formatSize(item.attr.size ?? 0),
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()]),
                        ),
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20, color: colorScheme.onSurfaceVariant),
                      onSelected: (v) => _onItemAction(v, item),
                      itemBuilder: (_) => [
                        if (!isDir) const PopupMenuItem(value: 'view', child: Text('View')),
                        const PopupMenuItem(value: 'rename', child: Text('Rename')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
          onTap: isDir ? () => _navigateTo(item.filename) : null,
        ).animate().fadeIn(duration: 200.ms, delay: (30 * i).ms).slideX(begin: 0.03);
      },
    );
  }

  void _onItemAction(String action, SftpName item) {
    final fullPath = _currentPath == '/'
        ? '/${item.filename}' : '$_currentPath/${item.filename}';
    switch (action) {
      case 'view':
        _viewFile(fullPath, item.filename);
      case 'rename':
        _renameItem(fullPath, item.filename);
      case 'delete':
        _deleteItem(fullPath, item.filename);
    }
  }

  Future<void> _viewFile(String path, String name) async {
    try {
      final data = await _sftp.readFile(path);
      if (!mounted) return;
      final text = utf8.decode(data, allowMalformed: true);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(name, style: const TextStyle(fontSize: 14)),
          content: SingleChildScrollView(
            child: SelectableText(text, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
        ),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteItem(String path, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _sftp.delete(path);
      _loadDir(_currentPath);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "$name"')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _renameItem(String path, String oldName) async {
    final controller = TextEditingController(text: oldName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Rename')),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == oldName) return;
    try {
      final dir = _currentPath == '/' ? '/' : '$_currentPath/';
      await _sftp.rename(path, '$dir$newName');
      _loadDir(_currentPath);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _newFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Folder name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Create')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      final path = _currentPath == '/' ? '/$name' : '$_currentPath/$name';
      await _sftp.mkdir(path);
      _loadDir(_currentPath);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'txt' || 'md' || 'log' => Icons.description,
      'json' || 'yaml' || 'yml' || 'xml' => Icons.data_object,
      'dart' || 'py' || 'js' || 'ts' || 'sh' || 'bash' => Icons.code,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'svg' => Icons.image,
      'zip' || 'tar' || 'gz' => Icons.archive,
      'conf' || 'cfg' || 'ini' || 'env' => Icons.settings,
      _ => Icons.insert_drive_file,
    };
  }

  Color _fileIconColor(String name, ColorScheme colorScheme) {
    final ext = name.split('.').last.toLowerCase();
    return switch (ext) {
      'txt' || 'md' || 'log' => Colors.blue.shade600,
      'json' || 'yaml' || 'yml' || 'xml' => Colors.orange.shade700,
      'dart' || 'py' || 'js' || 'ts' || 'sh' || 'bash' => Colors.teal.shade600,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'svg' => Colors.pink.shade400,
      'zip' || 'tar' || 'gz' => Colors.brown.shade400,
      'conf' || 'cfg' || 'ini' || 'env' => Colors.deepPurple.shade400,
      _ => colorScheme.onSurfaceVariant,
    };
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
