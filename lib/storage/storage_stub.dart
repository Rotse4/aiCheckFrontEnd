abstract class KeyValueStore {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
}

// This will be provided by platform-specific implementations via conditional import.
KeyValueStore getStore() => throw UnimplementedError('No storage implementation found');
