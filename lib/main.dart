import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/routes/app_routes.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La suppression de la base est retirée pour conserver les données !
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
