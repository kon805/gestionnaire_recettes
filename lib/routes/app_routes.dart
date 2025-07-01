import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/screens/login_page.dart';
import 'package:gestionnaire_recettes/screens/register_page.dart';
import 'package:gestionnaire_recettes/home_page.dart';
import 'package:gestionnaire_recettes/screens/welcome_page.dart';
import 'package:gestionnaire_recettes/main.dart';
import 'package:gestionnaire_recettes/screens/splash_page.dart';
import 'package:gestionnaire_recettes/screens/add_recette_page.dart';

// on va le créer ci-dessous

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String main = '/main';
  static const String splash = '/splash';
  static const String addRecette = '/ajouter-recette';
  static const String recetteDetail = '/recette-detail';

  // Route avec animation personnalisée
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeTransition(const SplashPage());
      case welcome:
        return _slideFromRight(const WelcomePage());
      case register:
        return _slideFromBottom(const RegisterPage());
      case login:
        return _scaleTransition(const LoginPage());
      case addRecette:
        return _slideFromRight(const AddRecettePage());

      case home:
        return _fadeTransition(const HomePage());
      default:
        return _fadeTransition(const WelcomePage());
    }
  }

  /// Fondu (fade)
  static PageRouteBuilder _fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Slide depuis la droite
  static PageRouteBuilder _slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// Slide depuis le bas
  static PageRouteBuilder _slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// Zoom (scale)
  static PageRouteBuilder _scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
