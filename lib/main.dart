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
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // ← ici on démarre par le splash
    );
  }
}
