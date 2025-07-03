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
  String? _emailUtilisateur;
  final Color primaryColor = const Color(0xFFEF6C00);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final double cardElevation = 2.0;
  final double borderRadius = 16.0;

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
      // Afficher un feedback à l'utilisateur
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Photo de profil mise à jour"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.green[400],
        ),
      );
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
        _emailUtilisateur = res.first['email'] as String?;
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

  Widget _buildInfoCard(String title, String? value, IconData icon) {
    return Card(
      elevation: cardElevation,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? "Non disponible",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Section Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _changerAvatar,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!))
                        : null,
                    child: _imagePath == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20),
                      color: Colors.white,
                      onPressed: _changerAvatar,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nom utilisateur
            Text(
              _nomUtilisateur ?? "Chargement...",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Membre depuis",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),

            // Informations utilisateur
            _buildInfoCard("Nom d'utilisateur", _nomUtilisateur, Icons.person),
            _buildInfoCard("Email", _emailUtilisateur, Icons.email),
            _buildInfoCard("Statut", "Membre Premium", Icons.star),

            const SizedBox(height: 40),

            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  "SE DÉCONNECTER",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: _deconnexion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  elevation: 2,
                  shadowColor: Colors.red.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
