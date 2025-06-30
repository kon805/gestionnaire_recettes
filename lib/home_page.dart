import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/routes/app_routes.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Bienvenue Sur l'application"),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.welcome),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Se connecter"),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("S'inscrire"),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
            ),
          ],
        ),
      ),
    );
  }
}
