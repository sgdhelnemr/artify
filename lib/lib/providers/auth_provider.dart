import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../utils/error_helper.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final SupabaseService _service;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get email => _service.currentUser?.email;
  String? get userId => _service.currentUser?.id;

  Future<bool> signIn(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<bool> signUp(String email, String password) =>
      _run(() => _service.signUp(email, password));

  Future<void> signOut() async {
    try {
      await _service.signOut();
    } catch (e) {
      _error = friendlyError(e);
      notifyListeners();
    }
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _error = friendlyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
