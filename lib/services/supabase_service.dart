import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment.dart';
import '../models/painting.dart';

/// All communication with Supabase (Auth + Postgres) lives here.
class SupabaseService {
  SupabaseClient get _c => Supabase.instance.client;

  // ---------- Auth ----------
  User? get currentUser => _c.auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _c.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _c.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _c.auth.signOut();
  }

  // ---------- Paintings (CRUD) ----------
  Future<List<Painting>> fetchPaintings() async {
    final data = await _c.from('paintings').select().order('id');
    return (data as List)
        .map((e) => Painting.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Painting> addPainting(Painting p) async {
    final data = await _c.from('paintings').insert(p.toMap()).select().single();
    return Painting.fromMap(data);
  }

  Future<Painting> updatePainting(Painting p) async {
    final data = await _c
        .from('paintings')
        .update(p.toMap())
        .eq('id', p.id)
        .select()
        .single();
    return Painting.fromMap(data);
  }

  Future<void> deletePainting(int id) async {
    await _c.from('paintings').delete().eq('id', id);
  }

  // ---------- Comments ----------
  Future<List<Comment>> fetchComments(int paintingId) async {
    final data = await _c
        .from('comments')
        .select()
        .eq('painting_id', paintingId)
        .order('created_at');
    return (data as List)
        .map((e) => Comment.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addComment(int paintingId, String text) async {
    await _c.from('comments').insert({
      'painting_id': paintingId,
      'text': text,
      'user_email': currentUser?.email,
    });
  }

  Future<void> deleteComment(int id) async {
    await _c.from('comments').delete().eq('id', id);
  }
}
