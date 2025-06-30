import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gestionnaire_recettes/models/recette.dart';
import 'package:gestionnaire_recettes/services/favoris_service.dart';
import 'package:gestionnaire_recettes/services/recette_service.dart';
import 'package:gestionnaire_recettes/services/session_service.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO : naviguer vers une page d’édition (si tu la crées)
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
                      child: const Text("Supprimer"),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              File(widget.recette.imagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              widget.recette.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            /// ---- Favori + Note -------------------------------------------------
            FutureBuilder<int?>(
              future: _userIdF,
              builder: (context, snapUser) {
                if (!snapUser.hasData || snapUser.data == null)
                  return const SizedBox.shrink();
                final uid = snapUser.data!;
                return Row(
                  children: [
                    // Favori
                    FutureBuilder<bool>(
                      future: _isFavF,
                      builder: (context, snapFav) {
                        final fav = snapFav.data ?? false;
                        return IconButton(
                          icon: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                            color: fav ? Colors.red : null,
                          ),
                          onPressed: () => _toggleFavori(uid),
                        );
                      },
                    ),
                    // Notation
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
                              itemSize: 24,
                              itemCount: 5,
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (val) => _updateNote(uid, val),
                            ),
                            const SizedBox(width: 8),
                            Text(note.toStringAsFixed(1)),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            const Text(
              "🧂 Ingrédients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...ingredients.map((i) => Text("- $i")),

            const SizedBox(height: 24),
            const Text(
              "🪜 Étapes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...etapes.asMap().entries.map(
              (e) => Text("${e.key + 1}. ${e.value}"),
            ),
          ],
        ),
      ),
    );
  }
}
