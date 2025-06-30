import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/models/utilisateur.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final mdpController = TextEditingController();

  bool _isLoading = false;
  String _message = '';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final user = Utilisateur(
      nom: nomController.text.trim(),
      email: emailController.text.trim(),
      motDePasse: mdpController.text,
    );

    try {
      await DatabaseService.inscrire(user);
      setState(() {
        _message = "Inscription réussie. Connectez-vous.";
      });
    } catch (e) {
      setState(() {
        _message = "Erreur : Email déjà utilisé.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    mdpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nomController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
                  ),
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
                    validator: (value) => value == null || value.length < 4
                        ? 'Minimum 4 caractères'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Text("S'inscrire"),
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
