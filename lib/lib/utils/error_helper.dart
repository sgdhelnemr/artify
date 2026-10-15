import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Converts any exception into a short, user-friendly message.
String friendlyError(Object e) {
  if (e is AuthException) return e.message;
  if (e is PostgrestException) return e.message;
  if (e is TimeoutException) return 'The request timed out. Please try again.';
  final s = e.toString();
  if (s.contains('SocketException') ||
      s.contains('ClientException') ||
      s.contains('Failed host lookup')) {
    return 'No internet connection. Please check your network.';
  }
  return 'Something went wrong. Please try again.';
}
