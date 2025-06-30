import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String keyUserId = 'utilisateur_id';

  static Future<void> enregistrerSession(int utilisateurId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyUserId, utilisateurId);
  }

  static Future<int?> recupererUtilisateurConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyUserId);
  }

  static Future<void> deconnecter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUserId);
  }
}
