import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/routes/app_routes.dart';

void main() {
  runApp(const RecetteApp());
}

class RecetteApp extends StatelessWidget {
  const RecetteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestionnaire de Recettes',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      initialRoute: AppRoutes.splash,

      routes: AppRoutes.routes,
    );
  }
}
