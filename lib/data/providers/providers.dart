import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/data/models/settings/settings_model.dart';
import 'package:ssh_client/data/models/snippet/snippet_model.dart';
import 'package:ssh_client/data/services/ssh/session_manager.dart';
import 'package:ssh_client/data/services/storage/secure_storage_service_impl.dart';

// Storage
final storageProvider = Provider((_) => SecureStorageServiceImpl());

// Session Manager (global, survives navigation)
final sessionManagerProvider = ChangeNotifierProvider<SessionManager>((_) => SessionManager());

// Settings
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(ref.read(storageProvider)),
);

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final SecureStorageServiceImpl _storage;

  SettingsNotifier(this._storage) : super(const SettingsModel()) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _storage.getSettings();
    if (raw != null) state = SettingsModel.fromJson(jsonDecode(raw));
  }

  Future<void> update(SettingsModel settings) async {
    state = settings;
    await _storage.saveSettings(jsonEncode(settings.toJson()));
  }
}

// Connections
final connectionListProvider =
    StateNotifierProvider<ConnectionListNotifier, List<ConnectionModel>>(
  (ref) => ConnectionListNotifier(ref.read(storageProvider)),
);

class ConnectionListNotifier extends StateNotifier<List<ConnectionModel>> {
  final SecureStorageServiceImpl _storage;

  ConnectionListNotifier(this._storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final ids = await _storage.getAllConnectionIds();
    final list = <ConnectionModel>[];
    for (final id in ids) {
      final raw = await _storage.getConnection(id);
      if (raw != null) list.add(ConnectionModel.fromJson(jsonDecode(raw)));
    }
    state = list;
  }

  Future<void> add(ConnectionModel conn) async {
    await _storage.saveConnection(conn.id, jsonEncode(conn.toJson()));
    state = [...state, conn];
  }

  Future<void> update(ConnectionModel conn) async {
    await _storage.saveConnection(conn.id, jsonEncode(conn.toJson()));
    state = [for (final c in state) c.id == conn.id ? conn : c];
  }

  Future<void> delete(String id) async {
    await _storage.deleteConnection(id);
    state = state.where((c) => c.id != id).toList();
  }

  /// Export all connections as JSON string
  String exportAll() {
    return jsonEncode(state.map((c) => c.toJson()).toList());
  }

  /// Import connections from JSON string, returns count imported
  Future<int> importAll(String jsonStr) async {
    final list = (jsonDecode(jsonStr) as List)
        .map((e) => ConnectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    int count = 0;
    for (final conn in list) {
      final existing = state.any((c) => c.id == conn.id);
      if (!existing) {
        await _storage.saveConnection(conn.id, jsonEncode(conn.toJson()));
        count++;
      }
    }
    if (count > 0) await _load();
    return count;
  }
}

// Snippets
final snippetListProvider =
    StateNotifierProvider<SnippetListNotifier, List<SnippetModel>>(
  (ref) => SnippetListNotifier(ref.read(storageProvider)),
);

class SnippetListNotifier extends StateNotifier<List<SnippetModel>> {
  final SecureStorageServiceImpl _storage;
  static const _key = 'snippets';

  SnippetListNotifier(this._storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _storage.getCredential(_key);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).map((e) => SnippetModel.fromJson(e as Map<String, dynamic>)).toList();
      state = list;
    }
  }

  Future<void> _save() async {
    await _storage.saveCredential(_key, jsonEncode(state.map((s) => s.toJson()).toList()));
  }

  Future<void> add(SnippetModel snippet) async {
    state = [...state, snippet];
    await _save();
  }

  Future<void> update(SnippetModel snippet) async {
    state = [for (final s in state) s.id == snippet.id ? snippet : s];
    await _save();
  }

  Future<void> delete(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _save();
  }
}
