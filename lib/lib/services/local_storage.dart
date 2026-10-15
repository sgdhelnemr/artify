import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences (local storage).
class LocalStorage {
  final SharedPreferences _prefs;
  LocalStorage._(this._prefs);

  static Future<LocalStorage> init() async =>
      LocalStorage._(await SharedPreferences.getInstance());

  static const _darkKey = 'dark_mode';
  static const _likedKey = 'liked_ids';
  static const _cartKey = 'cart_ids';

  bool get isDark => _prefs.getBool(_darkKey) ?? false;
  Future<void> setDark(bool v) => _prefs.setBool(_darkKey, v);

  Set<int> get likedIds => _readIds(_likedKey);
  Future<void> saveLikedIds(Set<int> ids) => _writeIds(_likedKey, ids);

  Set<int> get cartIds => _readIds(_cartKey);
  Future<void> saveCartIds(Set<int> ids) => _writeIds(_cartKey, ids);

  Set<int> _readIds(String key) => (_prefs.getStringList(key) ?? [])
      .map(int.tryParse)
      .whereType<int>()
      .toSet();

  Future<void> _writeIds(String key, Set<int> ids) =>
      _prefs.setStringList(key, ids.map((e) => e.toString()).toList());
}
