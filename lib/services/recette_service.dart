import 'package:sqflite/sqflite.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';
import 'package:gestionnaire_recettes/models/recette.dart';

class RecetteService {
  /// Synchronise les likes pour toutes les recettes (utile après migration ou bug)
  static Future<void> synchroniserLikes() async {
    final db = await DatabaseService.getDatabase();
    final recettes = await db.query('recettes');
    for (final recette in recettes) {
      final recetteId = recette['id'];
      final count =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM favoris WHERE recette_id = ?',
              [recetteId],
            ),
          ) ??
          0;
      await db.update(
        'recettes',
        {'likes': count},
        where: 'id = ?',
        whereArgs: [recetteId],
      );
    }
  }

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

  static Future<void> supprimerRecette(int recetteId) async {
    final db = await DatabaseService.getDatabase();
    // Supprime dans tables enfants
    await db.delete(
      'ingredients',
      where: 'recette_id = ?',
      whereArgs: [recetteId],
    );
    await db.delete('etapes', where: 'recette_id = ?', whereArgs: [recetteId]);
    await db.delete('favoris', where: 'recette_id = ?', whereArgs: [recetteId]);
    // Supprime la recette
    await db.delete('recettes', where: 'id = ?', whereArgs: [recetteId]);
  }

  static Future<void> mettreAJourRecette(
    int recetteId, {
    required String titre,
    required String description,
  }) async {
    final db = await DatabaseService.getDatabase();
    await db.update(
      'recettes',
      {'titre': titre, 'description': description},
      where: 'id = ?',
      whereArgs: [recetteId],
    );
  }
}
