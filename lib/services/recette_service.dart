import 'package:sqflite/sqflite.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';
import 'package:gestionnaire_recettes/models/recette.dart';

class RecetteService {
  static Future<int> ajouterRecette({
    required String titre,
    required String description,
    required String imagePath,
    required int utilisateurId,
    required List<String> ingredients,
    required List<String> etapes,
  }) async {
    final db = await DatabaseService.getDatabase();

    // 1. Insérer la recette
    final recetteId = await db.insert('recettes', {
      'titre': titre,
      'description': description,
      'image_path': imagePath,
      'utilisateur_id': utilisateurId,
    });

    // 2. Insérer les ingrédients
    for (final ingredient in ingredients) {
      await db.insert('ingredients', {
        'recette_id': recetteId,
        'nom': ingredient,
      });
    }

    // 3. Insérer les étapes
    for (int i = 0; i < etapes.length; i++) {
      await db.insert('etapes', {
        'recette_id': recetteId,
        'description': etapes[i],
        'numero': i + 1,
      });
    }

    return recetteId;
  }

  static Future<List<Recette>> getToutesRecettes() async {
    final db = await DatabaseService.getDatabase();
    final result = await db.query('recettes', orderBy: 'id DESC');
    return result.map((map) => Recette.fromMap(map)).toList();
  }

  static Future<List<Recette>> rechercherRecettes(String motCle) async {
    final db = await DatabaseService.getDatabase();

    // Rechercher dans les titres ou les ingrédients
    final result = await db.rawQuery(
      '''
    SELECT DISTINCT r.* FROM recettes r
    LEFT JOIN ingredients i ON i.recette_id = r.id
    WHERE r.titre LIKE ? OR i.nom LIKE ?
    ORDER BY r.id DESC
  ''',
      ['%$motCle%', '%$motCle%'],
    );

    return result.map((map) => Recette.fromMap(map)).toList();
  }
}
