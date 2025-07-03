import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class FavorisService {
  static Future<void> toggleFavori(int userId, int recetteId) async {
    final db = await DatabaseService.getDatabase();

    final exist = await db.query(
      'favoris',
      where: 'utilisateur_id = ? AND recette_id = ?',
      whereArgs: [userId, recetteId],
    );

    if (exist.isNotEmpty) {
      await db.delete(
        'favoris',
        where: 'utilisateur_id = ? AND recette_id = ?',
        whereArgs: [userId, recetteId],
      );
    } else {
      await db.insert('favoris', {
        'utilisateur_id': userId,
        'recette_id': recetteId,
        'note': 0,
      });
    }

    // Met à jour le nombre de likes dans la table recettes
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

  static Future<bool> estFavori(int userId, int recetteId) async {
    final db = await DatabaseService.getDatabase();
    final result = await db.query(
      'favoris',
      where: 'utilisateur_id = ? AND recette_id = ?',
      whereArgs: [userId, recetteId],
    );
    return result.isNotEmpty;
  }

  static Future<void> noter(int userId, int recetteId, int note) async {
    final db = await DatabaseService.getDatabase();
    await db.update(
      'favoris',
      {'note': note},
      where: 'utilisateur_id = ? AND recette_id = ?',
      whereArgs: [userId, recetteId],
    );

    // Met à jour la note moyenne dans la table recettes
    final rows = await db.rawQuery(
      'SELECT AVG(note) AS moyenne FROM favoris WHERE recette_id = ? AND note > 0',
      [recetteId],
    );
    final moyenne = (rows.first['moyenne'] as num?)?.toDouble() ?? 0.0;
    await db.update(
      'recettes',
      {'note': moyenne},
      where: 'id = ?',
      whereArgs: [recetteId],
    );
  }

  static Future<int> getNote(int userId, int recetteId) async {
    final db = await DatabaseService.getDatabase();
    final result = await db.query(
      'favoris',
      columns: ['note'],
      where: 'utilisateur_id = ? AND recette_id = ?',
      whereArgs: [userId, recetteId],
    );
    if (result.isNotEmpty) return result.first['note'] as int;
    return 0;
  }

  static Future<double> getNoteMoyenne(int recetteId) async {
    final db = await DatabaseService.getDatabase();
    final rows = await db.rawQuery(
      'SELECT AVG(note) AS moyenne FROM favoris WHERE recette_id = ? AND note > 0',
      [recetteId],
    );
    return (rows.first['moyenne'] as num?)?.toDouble() ?? 0.0;
  }
}
