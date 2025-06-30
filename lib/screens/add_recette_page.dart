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

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  void ajouterIngredient() {
    if (ingredientController.text.trim().isNotEmpty) {
      setState(() {
        ingredients.add(ingredientController.text.trim());
        ingredientController.clear();
      });
    }
  }

  void ajouterEtape() {
    if (etapeController.text.trim().isNotEmpty) {
      setState(() {
        etapes.add(etapeController.text.trim());
        etapeController.clear();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle Recette")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Titre
              TextFormField(
                controller: titreController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),

              // Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),

              const SizedBox(height: 16),

              // Ingrédients
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ingredientController,
                      decoration: const InputDecoration(
                        labelText: 'Ingrédient',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: ajouterIngredient,
                  ),
                ],
              ),
              ...ingredients.map((i) => ListTile(title: Text(i))),

              const SizedBox(height: 16),

              // Étapes
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: etapeController,
                      decoration: const InputDecoration(labelText: 'Étape'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: ajouterEtape,
                  ),
                ],
              ),
              ...etapes.map((e) => ListTile(title: Text(e))),

              const SizedBox(height: 16),

              // Image
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Ajouter une image"),
              ),
              if (imageFile != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(imageFile!, height: 150),
                ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: enregistrerRecette,
                child: const Text("Enregistrer la recette"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
