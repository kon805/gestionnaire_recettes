import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/utilisateur.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'recettes.db');
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE utilisateurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            email TEXT UNIQUE,
            mot_de_passe TEXT
          )
        ''');
        // Table recettes
        await db.execute('''
    CREATE TABLE recettes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      titre TEXT,
      description TEXT,
      image_path TEXT,
      utilisateur_id INTEGER,
      FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
    )
  ''');

        // Table ingrédients
        await db.execute('''
    CREATE TABLE ingredients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recette_id INTEGER,
      nom TEXT,
      FOREIGN KEY (recette_id) REFERENCES recettes(id)
    )
  ''');
        // Table étapes
        await db.execute('''
    CREATE TABLE etapes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recette_id INTEGER,
      description TEXT,
      numero INTEGER,
      FOREIGN KEY (recette_id) REFERENCES recettes(id)
    )
  ''');
      },
    );
    return _database!;
  }

  static Future<int> inscrire(Utilisateur user) async {
    final db = await getDatabase();
    return await db.insert('utilisateurs', user.toMap());
  }

  static Future<Utilisateur?> connecter(String email, String motDePasse) async {
    final db = await getDatabase();
    final result = await db.query(
      'utilisateurs',
      where: 'email = ? AND mot_de_passe = ?',
      whereArgs: [email, motDePasse],
    );
    if (result.isNotEmpty) {
      return Utilisateur.fromMap(result.first);
    }
    return null;
  }
}
