import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';
import 'package:gestionnaire_recettes/models/utilisateur.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestionnaire_recettes/routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final mdpController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final email = emailController.text.trim();
    final motDePasse = mdpController.text;

    Utilisateur? utilisateur = await DatabaseService.connecter(
      email,
      motDePasse,
    );

    if (utilisateur != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('utilisateur_id', utilisateur.id!);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      setState(() {
        _message = "Connexion réussie.";
      });
    } else {
      setState(() {
        _message = "Email ou mot de passe incorrect.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    mdpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Email invalide'
                        : null,
                  ),
                  TextFormField(
                    controller: mdpController,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text("Se connecter"),
                        ),
                  const SizedBox(height: 10),
                  if (_message.isNotEmpty)
                    Text(_message, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
