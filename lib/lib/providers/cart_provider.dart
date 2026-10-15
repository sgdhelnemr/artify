import 'package:flutter/foundation.dart';
import '../models/painting.dart';
import '../services/local_storage.dart';

/// Cart stores only painting ids (persisted locally); details are resolved
/// against the list loaded from Supabase.
class CartProvider extends ChangeNotifier {
  CartProvider(this._storage) : _ids = _storage.cartIds;

  final LocalStorage _storage;
  final Set<int> _ids;

  int get count => _ids.length;
  bool contains(int id) => _ids.contains(id);

  Future<void> add(int id) async {
    if (_ids.add(id)) {
      notifyListeners();
      await _storage.saveCartIds(_ids);
    }
  }

  Future<void> remove(int id) async {
    if (_ids.remove(id)) {
      notifyListeners();
      await _storage.saveCartIds(_ids);
    }
  }

  Future<void> clear() async {
    _ids.clear();
    notifyListeners();
    await _storage.saveCartIds(_ids);
  }

  /// Drops ids of paintings that no longer exist.
  Future<void> prune(Set<int> validIds) async {
    final before = _ids.length;
    _ids.removeWhere((id) => !validIds.contains(id));
    if (_ids.length != before) {
      notifyListeners();
      await _storage.saveCartIds(_ids);
    }
  }

  List<Painting> itemsFrom(List<Painting> all) =>
      all.where((p) => _ids.contains(p.id)).toList();

  double totalFrom(List<Painting> all) =>
      itemsFrom(all).fold(0.0, (sum, p) => sum + p.price);
}
