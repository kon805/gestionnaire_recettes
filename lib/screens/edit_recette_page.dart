import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gestionnaire_recettes/models/recette.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';

class EditRecettePage extends StatefulWidget {
  final Recette recette;

  const EditRecettePage({super.key, required this.recette});

  @override
  State<EditRecettePage> createState() => _EditRecettePageState();
}

class _EditRecettePageState extends State<EditRecettePage> {
  final titreController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<TextEditingController> ingredientControllers = [];
  final List<TextEditingController> etapeControllers = [];

  File? _image;

  final Color primaryColor = const Color(0xFFEF6C00);

  @override
  void initState() {
    super.initState();
    titreController.text = widget.recette.titre;
    descriptionController.text = widget.recette.description;
    _image = File(widget.recette.imagePath);
    _chargerDetails();
  }

  Future<void> _chargerDetails() async {
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
      ingredientControllers.clear();
      etapeControllers.clear();

      ingredientControllers.addAll(
        ingr.map((i) => TextEditingController(text: i['nom'] as String)),
      );
      etapeControllers.addAll(
        etap.map(
          (e) => TextEditingController(text: e['description'] as String),
        ),
      );
    });
  }

  Future<void> _modifierImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _enregistrerModifs() async {
    final db = await DatabaseService.getDatabase();

    // MAJ recette
    await db.update(
      'recettes',
      {
        'titre': titreController.text,
        'description': descriptionController.text,
        'image_path': _image?.path,
      },
      where: 'id = ?',
      whereArgs: [widget.recette.id],
    );

    // Supprime anciens ingrédients/étapes
    await db.delete(
      'ingredients',
      where: 'recette_id = ?',
      whereArgs: [widget.recette.id],
    );
    await db.delete(
      'etapes',
      where: 'recette_id = ?',
      whereArgs: [widget.recette.id],
    );

    // Réinsère les ingrédients
    for (var controller in ingredientControllers) {
      final nom = controller.text.trim();
      if (nom.isNotEmpty) {
        await db.insert('ingredients', {
          'recette_id': widget.recette.id,
          'nom': nom,
        });
      }
    }

    // Réinsère les étapes
    for (int i = 0; i < etapeControllers.length; i++) {
      final description = etapeControllers[i].text.trim();
      if (description.isNotEmpty) {
        await db.insert('etapes', {
          'recette_id': widget.recette.id,
          'numero': i + 1,
          'description': description,
        });
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recette modifiée avec succès")),
    );
  }

  Widget _buildTextFieldList({
    required String title,
    required List<TextEditingController> controllers,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      hintText: "$hint ${index + 1}",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      controllers.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Ajouter"),
            onPressed: () {
              setState(() {
                controllers.add(TextEditingController());
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    for (var c in ingredientControllers) {
      c.dispose();
    }
    for (var c in etapeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier Recette"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _modifierImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _image != null
                      ? Image.file(
                          _image!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titreController,
              decoration: InputDecoration(
                labelText: "Titre",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            _buildTextFieldList(
              title: "🧂 Ingrédients",
              controllers: ingredientControllers,
              hint: "Ingrédient",
            ),
            const SizedBox(height: 24),
            _buildTextFieldList(
              title: "🪜 Étapes",
              controllers: etapeControllers,
              hint: "Étape",
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  "Enregistrer",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _enregistrerModifs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
