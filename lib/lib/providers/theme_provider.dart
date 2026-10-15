import 'package:flutter/material.dart';
import '../services/local_storage.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage) : _isDark = _storage.isDark;

  final LocalStorage _storage;
  bool _isDark;

  bool get isDark => _isDark;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    await _storage.setDark(_isDark);
  }
}
