abstract class SecureStorageService {
  Future<void> saveConnection(String id, String jsonData);
  Future<String?> getConnection(String id);
  Future<List<String>> getAllConnectionIds();
  Future<void> deleteConnection(String id);
  Future<void> saveCredential(String key, String value);
  Future<String?> getCredential(String key);
}
