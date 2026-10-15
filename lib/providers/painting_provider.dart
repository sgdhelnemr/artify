import 'package:flutter/foundation.dart';
import '../models/comment.dart';
import '../models/painting.dart';
import '../services/local_storage.dart';
import '../services/supabase_service.dart';
import '../utils/error_helper.dart';

class PaintingProvider extends ChangeNotifier {
  PaintingProvider(this._service, this._storage)
      : _likedIds = _storage.likedIds;

  final SupabaseService _service;
  final LocalStorage _storage;

  List<Painting> _paintings = [];
  final Set<int> _likedIds;
  bool _isLoading = false;
  String? _error;
  String _query = '';
  bool _favoritesOnly = false;

  List<Painting> get paintings => List.unmodifiable(_paintings);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get favoritesOnly => _favoritesOnly;

  /// Paintings after applying search + favorites filter.
  List<Painting> get visible {
    final q = _query.trim().toLowerCase();
    return _paintings.where((p) {
      if (_favoritesOnly && !_likedIds.contains(p.id)) return false;
      if (q.isEmpty) return true;
      return p.title.toLowerCase().contains(q) ||
          p.artist.toLowerCase().contains(q);
    }).toList();
  }

  Painting? byId(int id) {
    for (final p in _paintings) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool isLiked(int id) => _likedIds.contains(id);

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setFavoritesOnly(bool v) {
    _favoritesOnly = v;
    notifyListeners();
  }

  Future<void> toggleLike(int id) async {
    if (!_likedIds.remove(id)) _likedIds.add(id);
    notifyListeners();
    await _storage.saveLikedIds(_likedIds);
  }

  // ---------- CRUD ----------
  Future<void> loadPaintings() async {
    _isLoading = _paintings.isEmpty;
    _error = null;
    notifyListeners();
    try {
      _paintings = await _service.fetchPaintings();
    } catch (e) {
      _error = friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns an error message, or null on success.
  Future<String?> addPainting(Painting p) async {
    try {
      final saved = await _service.addPainting(p);
      _paintings.add(saved);
      notifyListeners();
      return null;
    } catch (e) {
      return friendlyError(e);
    }
  }

  Future<String?> updatePainting(Painting p) async {
    try {
      final saved = await _service.updatePainting(p);
      final i = _paintings.indexWhere((x) => x.id == saved.id);
      if (i != -1) _paintings[i] = saved;
      notifyListeners();
      return null;
    } catch (e) {
      return friendlyError(e);
    }
  }

  /// Optimistic delete: removes locally first, restores if the server fails.
  Future<String?> deletePainting(Painting p) async {
    final index = _paintings.indexWhere((x) => x.id == p.id);
    if (index == -1) return null;
    _paintings.removeAt(index);
    notifyListeners();
    try {
      await _service.deletePainting(p.id);
      if (_likedIds.remove(p.id)) await _storage.saveLikedIds(_likedIds);
      return null;
    } catch (e) {
      _paintings.insert(index, p);
      notifyListeners();
      return friendlyError(e);
    }
  }

  // ---------- Comments ----------
  Future<List<Comment>> fetchComments(int paintingId) =>
      _service.fetchComments(paintingId);

  Future<String?> addComment(int paintingId, String text) async {
    try {
      await _service.addComment(paintingId, text.trim());
      return null;
    } catch (e) {
      return friendlyError(e);
    }
  }

  Future<String?> deleteComment(int id) async {
    try {
      await _service.deleteComment(id);
      return null;
    } catch (e) {
      return friendlyError(e);
    }
  }
}
