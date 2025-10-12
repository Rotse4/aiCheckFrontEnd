// import 'package:shared_preferences/shared_preferences.dart';
// import 'storage_stub.dart';

// class SharedPrefsStore implements KeyValueStore {
//   @override
//   Future<void> setString(String key, String value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(key, value);
//   }

//   @override
//   Future<String?> getString(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(key);
//   }

//   @override
//   Future<void> remove(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(key);
//   }
// }

// KeyValueStore getStore() => SharedPrefsStore();
