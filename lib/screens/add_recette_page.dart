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
        const SnackBar(content: Text("Tous les champs sont obligatoires.")),
      );
      return;
    }

    final utilisateurId = await SessionService.recupererUtilisateurConnecte();
    if (utilisateurId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Utilisateur non connecté")));
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Recette enregistrée 🎉")));
    Navigator.pop(context);
  }

  Widget _buildChipsList(List<String> items, void Function(int) onDelete) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(items.length, (index) {
        return Chip(
          label: Text(items[index]),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () => onDelete(index),
          backgroundColor: primaryColor.withOpacity(0.15),
          labelStyle: TextStyle(color: primaryColor.darken()),
          deleteIconColor: primaryColor,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle Recette"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              TextFormField(
                controller: titreController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),

              // Ingrédients
              Text(
                'Ingrédients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ingredientController,
                      decoration: InputDecoration(
                        hintText: 'Ajouter un ingrédient',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: ajouterIngredient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildChipsList(ingredients, supprimerIngredient),
              const SizedBox(height: 24),

              // Étapes
              Text(
                'Étapes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: etapeController,
                      decoration: InputDecoration(
                        hintText: 'Ajouter une étape',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: ajouterEtape,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildChipsList(etapes, supprimerEtape),
              const SizedBox(height: 24),

              // Image
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(
                  Icons.image,
                  color: Color(0xFFFFFFFF),
                ), // 🎨 Couleur de l'icône
                label: const Text(
                  "Ajouter une image",
                  style: TextStyle(
                    color: Colors.white, // 🎨 Couleur du texte
                    fontSize: 20, // (optionnel) Taille du texte
                    fontWeight: FontWeight.bold, // (optionnel) Gras
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,

                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Bouton enregistrer
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: enregistrerRecette,
                  child: const Text(
                    "Enregistrer la recette",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Couleur du texte
                      fontWeight: FontWeight.bold, // Gras
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
  /// Récupérer une couleur plus foncée
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
