import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gestionnaire_recettes/models/recette.dart';
import 'package:gestionnaire_recettes/services/favoris_service.dart';
import 'package:gestionnaire_recettes/services/recette_service.dart';
import 'package:gestionnaire_recettes/services/session_service.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';
import 'package:gestionnaire_recettes/screens/edit_recette_page.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> exporterRecetteEnPDF({
  required String titre,
  required String description,
  required List<String> ingredients,
  required List<String> etapes,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            titre,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(description, style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 20),
          pw.Text(
            "Ingrédients :",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Bullet(
            text: ingredients.join('\n'),
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Étapes :",
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: etapes.asMap().entries.map((entry) {
              final i = entry.key + 1;
              final e = entry.value;
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  "$i. $e",
                  style: const pw.TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

class RecetteDetailPage extends StatefulWidget {
  final Recette recette;
  const RecetteDetailPage({super.key, required this.recette});

  @override
  State<RecetteDetailPage> createState() => _RecetteDetailPageState();
}

class _RecetteDetailPageState extends State<RecetteDetailPage> {
  List<String> ingredients = [];
  List<String> etapes = [];
  bool _isLoading = true;

  final Future<int?> _userIdF = SessionService.recupererUtilisateurConnecte();
  late Future<bool> _isFavF;
  late Future<double> _noteMoyenneF;

  final Color primaryColor = const Color(0xFFEF6C00);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final double borderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await chargerDetails();
    _refreshFavAndNote();
    setState(() => _isLoading = false);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer cette recette ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await RecetteService.supprimerRecette(widget.recette.id);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Recette supprimée avec succès"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.green[400],
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.recette.titre,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Modifier',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditRecettePage(recette: widget.recette),
              ),
            );
            if (result == true) await _loadData();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Supprimer',
          onPressed: _supprimer,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          File(widget.recette.imagePath),
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.recette.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return FutureBuilder<int?>(
      future: _userIdF,
      builder: (context, snapUser) {
        if (!snapUser.hasData || snapUser.data == null) {
          return const SizedBox();
        }
        final uid = snapUser.data!;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<bool>(
                      future: _isFavF,
                      builder: (context, snapFav) {
                        final fav = snapFav.data ?? false;
                        return IconButton(
                          icon: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                            color: fav ? Colors.red : Colors.grey[700],
                            size: 32,
                          ),
                          onPressed: () => _toggleFavori(uid),
                          tooltip: fav
                              ? 'Retirer des favoris'
                              : 'Ajouter aux favoris',
                        );
                      },
                    ),
                    FutureBuilder<double>(
                      future: _noteMoyenneF,
                      builder: (context, snapNote) {
                        final note = snapNote.data ?? 0.0;
                        return Column(
                          children: [
                            RatingBar.builder(
                              initialRating: note,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemSize: 28,
                              itemCount: 5,
                              itemBuilder: (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (val) => _updateNote(uid, val),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Note moyenne: ${note.toStringAsFixed(1)}/5",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Exporter en PDF"),
                  onPressed: () => exporterRecetteEnPDF(
                    titre: widget.recette.titre,
                    description: widget.recette.description,
                    ingredients: ingredients,
                    etapes: etapes,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ingrédients",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...ingredients.map(
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 8, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(i, style: const TextStyle(fontSize: 16)),
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

  Widget _buildStepsSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Étapes de préparation",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...etapes.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          "${e.key + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 16, height: 1.4),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageSection(),
            _buildDescriptionSection(),
            _buildRatingSection(),
            _buildIngredientsSection(),
            _buildStepsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
