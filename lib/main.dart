import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import 'config/env.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/painting_provider.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'services/local_storage.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );
  final storage = await LocalStorage.init();
  final service = SupabaseService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => AuthProvider(service)),
        ChangeNotifierProvider(
            create: (_) => PaintingProvider(service, storage)),
        ChangeNotifierProvider(create: (_) => CartProvider(storage)),
      ],
      child: const ArtifyApp(),
    ),
  );
}

class ArtifyApp extends StatelessWidget {
  const ArtifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Artify',
      debugShowCheckedModeBanner: false,
      themeMode: theme.mode,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
