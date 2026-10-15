import 'package:flutter/widgets.dart';

class Validators {
  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email address';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? Function(String?) confirmPassword(
    TextEditingController passwordController,
  ) {
    return (String? v) {
      if (v == null || v.isEmpty) return 'Please confirm your password';
      if (v != passwordController.text) return 'Passwords do not match';
      return null;
    };
  }

  static String? year(String? v) {
    if (v == null || v.trim().isEmpty) return 'Year is required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Enter a valid year';
    final now = DateTime.now().year;
    if (n < 1 || n > now) return 'Year must be between 1 and $now';
    return null;
  }

  static String? price(String? v) {
    if (v == null || v.trim().isEmpty) return 'Price is required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Price must be greater than 0';
    return null;
  }

  /// Optional field: empty is fine, otherwise an http(s) URL or an asset path.
  static String? imagePath(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final s = v.trim();
    if (s.startsWith('assets/')) return null;
    final uri = Uri.tryParse(s);
    if (uri != null &&
        uri.isAbsolute &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      return null;
    }
    return 'Use an https:// link or an assets/ path';
  }

  static String? comment(String? v) {
    if (v == null || v.trim().isEmpty) return 'Write something first';
    if (v.trim().length < 2) return 'Comment is too short';
    if (v.trim().length > 500) return 'Comment is too long (max 500)';
    return null;
  }
}
