import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/routes/app_routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenue')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("S'inscrire"),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Se connecter"),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}
