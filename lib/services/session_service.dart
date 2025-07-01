import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String keyUserId = 'utilisateur_id';
  static const String keyAvatar = 'avatar_path';

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
    await prefs.remove(keyAvatar);
  }

  static Future<void> enregistrerAvatar(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAvatar, path);
  }

  static Future<String?> recupererAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAvatar);
  }
}
