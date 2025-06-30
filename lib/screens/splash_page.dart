import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/routes/app_routes.dart';
import 'package:gestionnaire_recettes/services/session_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _verifierSession();
  }

  Future<void> _verifierSession() async {
    final utilisateurId = await SessionService.recupererUtilisateurConnecte();

    if (!mounted) return;
    if (utilisateurId != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
