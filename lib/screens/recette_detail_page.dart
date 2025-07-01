import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gestionnaire_recettes/models/recette.dart';
import 'package:gestionnaire_recettes/services/favoris_service.dart';
import 'package:gestionnaire_recettes/services/recette_service.dart';
import 'package:gestionnaire_recettes/services/session_service.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';
import 'package:gestionnaire_recettes/screens/edit_recette_page.dart';

class RecetteDetailPage extends StatefulWidget {
  final Recette recette;
  const RecetteDetailPage({super.key, required this.recette});

  @override
  State<RecetteDetailPage> createState() => _RecetteDetailPageState();
}

class _RecetteDetailPageState extends State<RecetteDetailPage> {
  List<String> ingredients = [];
  List<String> etapes = [];

  final Future<int?> _userIdF = SessionService.recupererUtilisateurConnecte();
  late Future<bool> _isFavF;
  late Future<double> _noteMoyenneF;

  final Color primaryColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    chargerDetails();
    _refreshFavAndNote();
  }

  void _refreshFavAndNote() {
    _isFavF = _userIdF.then(
      (uid) => uid == null
          ? false
          : FavorisService.estFavori(uid, widget.recette.id),
    );
    _noteMoyenneF = FavorisService.getNoteMoyenne(widget.recette.id);
  }

  Future<void> chargerDetails() async {
    final db = await DatabaseService.getDatabase();
    final ingr = await db.query(
      'ingredients',
      where: 'recette_id = ?',
      whereArgs: [widget.recette.id],
    );
    final etap = await db.query(
      'etapes',
      where: 'recette_id = ?',
      whereArgs: [widget.recette.id],
      orderBy: 'numero ASC',
    );

    setState(() {
      ingredients = ingr.map((i) => i['nom'] as String).toList();
      etapes = etap.map((e) => e['description'] as String).toList();
    });
  }

  Future<void> _toggleFavori(int uid) async {
    await FavorisService.toggleFavori(uid, widget.recette.id);
    setState(_refreshFavAndNote);
  }

  Future<void> _updateNote(int uid, double value) async {
    await FavorisService.noter(uid, widget.recette.id, value.toInt());
    setState(_refreshFavAndNote);
  }

  Future<void> _supprimer() async {
    await RecetteService.supprimerRecette(widget.recette.id);
    if (!mounted) return;
    Navigator.pop(context); // Retour à la liste
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Recette supprimée")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recette.titre),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditRecettePage(recette: widget.recette),
                ),
              );
              if (result == true) {
                setState(() {
                  chargerDetails();
                  _refreshFavAndNote();
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Supprimer"),
                  content: const Text(
                    "Confirmer la suppression de cette recette ?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Supprimer",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (ok == true) _supprimer();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec ombre et arrondis
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.file(
                  File(widget.recette.imagePath),
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description justifiée
            Text(
              widget.recette.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 30),

            // Favoris + Note
            FutureBuilder<int?>(
              future: _userIdF,
              builder: (context, snapUser) {
                if (!snapUser.hasData || snapUser.data == null)
                  return const SizedBox.shrink();
                final uid = snapUser.data!;
                return Row(
                  children: [
                    FutureBuilder<bool>(
                      future: _isFavF,
                      builder: (context, snapFav) {
                        final fav = snapFav.data ?? false;
                        return IconButton(
                          iconSize: 32,
                          icon: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                            color: fav ? Colors.red : Colors.grey[700],
                          ),
                          onPressed: () => _toggleFavori(uid),
                          tooltip: fav
                              ? 'Retirer des favoris'
                              : 'Ajouter aux favoris',
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    FutureBuilder<double>(
                      future: _noteMoyenneF,
                      builder: (context, snapNote) {
                        final note = snapNote.data ?? 0.0;
                        return Row(
                          children: [
                            RatingBar.builder(
                              initialRating: note,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemSize: 28,
                              itemCount: 5,
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (val) => _updateNote(uid, val),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              note.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // Section ingrédients
            Text(
              "🧂 Ingrédients",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            ...ingredients.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(i, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Section étapes
            Text(
              "🪜 Étapes",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            ...etapes.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${e.key + 1}.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 16, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
