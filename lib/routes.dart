import 'package:flutter/material.dart';
import 'models/painting.dart';
import 'screens/auth_gate.dart';
import 'screens/cart_screen.dart';
import 'screens/details_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/painting_form_screen.dart';
import 'screens/register_screen.dart';

class AppRoutes {
  static const home = '/';
  static const register = '/register';
  static const details = '/details'; // arguments: int (painting id)
  static const cart = '/cart';
  static const form = '/form'; // arguments: Painting? (null = add)
  static const discover = '/discover';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        return _page(const RegisterScreen(), settings);
      case details:
        return _page(DetailsScreen(paintingId: settings.arguments as int), settings);
      case cart:
        return _page(const CartScreen(), settings);
      case form:
        return _page(
          PaintingFormScreen(painting: settings.arguments as Painting?),
          settings,
        );
      case discover:
        return _page(const DiscoverScreen(), settings);
      case home:
      default:
        return _page(const AuthGate(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => child, settings: s);
}
