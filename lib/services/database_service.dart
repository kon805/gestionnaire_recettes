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
      version: 4,
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
      likes INTEGER DEFAULT 0,
      note REAL DEFAULT 0,
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

        // Table favoris
        await db.execute('''
  CREATE TABLE favoris (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER,
    recette_id INTEGER,
    note INTEGER DEFAULT 0,
    UNIQUE(utilisateur_id, recette_id),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id),
    FOREIGN KEY (recette_id) REFERENCES recettes(id)
  )
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Ici, on ne supprime rien, on peut ajouter des migrations si besoin
        // Par défaut, ne rien faire pour préserver les données existantes
        // Exemples de migrations :
        // if (oldVersion < 4) {
        //   await db.execute("ALTER TABLE recettes ADD COLUMN nouvelle_colonne TEXT;");
        // }
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        // Ne rien faire pour préserver les données existantes lors d'une rétrogradation
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
