import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Shows Home when a Supabase session exists, otherwise Login.
/// Listens to auth changes, so login/logout switch screens automatically
/// and the session survives app restarts.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        return auth.currentSession != null
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}
