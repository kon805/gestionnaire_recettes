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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE utilisateurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            email TEXT UNIQUE,
            mot_de_passe TEXT
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
