import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gestionnaire_recettes/services/recette_service.dart';
import 'package:gestionnaire_recettes/services/session_service.dart';

class AddRecettePage extends StatefulWidget {
  const AddRecettePage({super.key});

  @override
  State<AddRecettePage> createState() => _AddRecettePageState();
}

class _AddRecettePageState extends State<AddRecettePage> {
  final _formKey = GlobalKey<FormState>();
  final titreController = TextEditingController();
  final descriptionController = TextEditingController();
  final ingredientController = TextEditingController();
  final etapeController = TextEditingController();

  List<String> ingredients = [];
  List<String> etapes = [];
  File? imageFile;

  final Color primaryColor = const Color(0xFFEF6C00);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color cardColor = Colors.white;
  final double cardElevation = 2.0;
  final double borderRadius = 16.0;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  void ajouterIngredient() {
    final text = ingredientController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        ingredients.add(text);
        ingredientController.clear();
      });
    }
  }

  void supprimerIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void ajouterEtape() {
    final text = etapeController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        etapes.add(text);
        etapeController.clear();
      });
    }
  }

  void supprimerEtape(int index) {
    setState(() {
      etapes.removeAt(index);
    });
  }

  void enregistrerRecette() async {
    if (!_formKey.currentState!.validate()) return;

    if (ingredients.isEmpty || etapes.isEmpty || imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Tous les champs sont obligatoires."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    final utilisateurId = await SessionService.recupererUtilisateurConnecte();
    if (utilisateurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Utilisateur non connecté"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    await RecetteService.ajouterRecette(
      titre: titreController.text.trim(),
      description: descriptionController.text.trim(),
      imagePath: imageFile!.path,
      utilisateurId: utilisateurId,
      ingredients: ingredients,
      etapes: etapes,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Recette enregistrée avec succès! 🎉"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: Colors.green[400],
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildChipsList(List<String> items, void Function(int) onDelete) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(items.length, (index) {
        return Chip(
          label: Text(items[index]),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => onDelete(index),
          backgroundColor: primaryColor.withOpacity(0.1),
          labelStyle: TextStyle(color: primaryColor.darken(), fontSize: 14),
          deleteIconColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          side: BorderSide(color: primaryColor.withOpacity(0.3)),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInputCard(Widget child) {
    return Card(
      elevation: cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: cardColor,
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Nouvelle Recette"),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section Image
              _buildInputCard(
                Column(
                  children: [
                    _buildSectionTitle("Image de la recette"),
                    const SizedBox(height: 8),
                    if (imageFile != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: Image.file(
                            imageFile!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            imageFile == null
                                ? "Ajouter une image"
                                : "Changer l'image",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Titre et Description
              _buildInputCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Informations de base"),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titreController,
                      decoration: InputDecoration(
                        labelText: 'Titre de la recette',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        prefixIcon: const Icon(Icons.restaurant_menu),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Ingrédients
              _buildInputCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Ingrédients"),
                    const SizedBox(height: 8),
                    if (ingredients.isNotEmpty) ...[
                      _buildChipsList(ingredients, supprimerIngredient),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ingredientController,
                            decoration: InputDecoration(
                              hintText: 'Ex: 2 tomates',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  borderRadius,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: ajouterIngredient,
                          backgroundColor: primaryColor,
                          mini: true,
                          elevation: 0,
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Étapes
              _buildInputCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Étapes de préparation"),
                    const SizedBox(height: 8),
                    if (etapes.isNotEmpty) ...[
                      _buildChipsList(etapes, supprimerEtape),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: etapeController,
                            decoration: InputDecoration(
                              hintText: 'Ex: Faire revenir les oignons',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  borderRadius,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: ajouterEtape,
                          backgroundColor: primaryColor,
                          mini: true,
                          elevation: 0,
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton Enregistrer
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: enregistrerRecette,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    elevation: 2,
                    shadowColor: primaryColor.withOpacity(0.3),
                  ),
                  child: const Text(
                    "ENREGISTRER LA RECETTE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
