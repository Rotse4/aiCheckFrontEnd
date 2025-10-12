export 'storage_stub.dart';
import 'dart:html' as html;
import 'storage_stub.dart';

class WebLocalStorageStore implements KeyValueStore {
  @override
  Future<void> setString(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return html.window.localStorage[key];
  }

  @override
  Future<void> remove(String key) async {
    html.window.localStorage.remove(key);
  }
}

KeyValueStore getStore() => WebLocalStorageStore();
