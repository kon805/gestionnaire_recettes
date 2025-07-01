import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';
import 'package:gestionnaire_recettes/services/session_service.dart';
import 'package:gestionnaire_recettes/screens/login_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? _imagePath;
  String? _nomUtilisateur;
  final Color primaryColor = const Color(0xFFEF6C00);

  @override
  void initState() {
    super.initState();
    _chargerUtilisateur();
  }

  Future<void> _changerAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await SessionService.enregistrerAvatar(image.path);
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _chargerUtilisateur() async {
    final avatar = await SessionService.recupererAvatar();
    setState(() {
      _imagePath = avatar;
    });

    final userId = await SessionService.recupererUtilisateurConnecte();
    if (userId == null) return;

    final db = await DatabaseService.getDatabase();
    final res = await db.query(
      'utilisateurs',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (res.isNotEmpty) {
      setState(() {
        _nomUtilisateur = res.first['nom'] as String;
      });
    }
  }

  Future<void> _deconnexion() async {
    await SessionService.deconnecter();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _changerAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : null,
                      child: _imagePath == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: primaryColor,
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Bienvenue",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _nomUtilisateur ?? "Chargement...",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Se déconnecter",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 254, 252), //
                    fontSize: 20, // (optionnel) Taille du texte
                    fontWeight: FontWeight.bold, // (optionnel) Gras
                  ),
                ),

                onPressed: _deconnexion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
