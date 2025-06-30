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

  static final Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomePage(),
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    home: (context) => const HomePage(),
    main: (context) => const RecetteApp(),
    splash: (context) => const SplashPage(),
    addRecette: (context) => const AddRecettePage(),
  };
}
