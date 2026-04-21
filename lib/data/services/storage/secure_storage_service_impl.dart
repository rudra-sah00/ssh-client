import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ssh_client/data/services/storage/secure_storage_service.dart';

class SecureStorageServiceImpl implements SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _connPrefix = 'conn_';
  static const _connIdsKey = 'connection_ids';

  @override
  Future<void> saveConnection(String id, String jsonData) async {
    await _storage.write(key: '$_connPrefix$id', value: jsonData);
    final ids = await getAllConnectionIds();
    if (!ids.contains(id)) {
      ids.add(id);
      await _storage.write(key: _connIdsKey, value: jsonEncode(ids));
    }
  }

  @override
  Future<String?> getConnection(String id) async {
    return _storage.read(key: '$_connPrefix$id');
  }

  @override
  Future<List<String>> getAllConnectionIds() async {
    final raw = await _storage.read(key: _connIdsKey);
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw));
  }

  @override
  Future<void> deleteConnection(String id) async {
    await _storage.delete(key: '$_connPrefix$id');
    final ids = await getAllConnectionIds();
    ids.remove(id);
    await _storage.write(key: _connIdsKey, value: jsonEncode(ids));
  }

  @override
  Future<void> saveCredential(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> getCredential(String key) async {
    return _storage.read(key: key);
  }

  Future<void> saveSettings(String jsonData) async {
    await _storage.write(key: 'app_settings', value: jsonData);
  }

  Future<String?> getSettings() async {
    return _storage.read(key: 'app_settings');
  }
}
