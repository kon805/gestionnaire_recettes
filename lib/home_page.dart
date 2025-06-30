import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/models/recette.dart';
import 'package:gestionnaire_recettes/routes/app_routes.dart';
import 'package:gestionnaire_recettes/services/recette_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final TextEditingController searchController = TextEditingController();

class _HomePageState extends State<HomePage> {
  late Future<List<Recette>> _recettes;

  @override
  void initState() {
    super.initState();
    _recettes = RecetteService.getToutesRecettes();
  }

  Future<void> _rafraichir() async {
    setState(() {
      _recettes = RecetteService.getToutesRecettes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes Recettes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une recette ou un ingrédient...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _rafraichir(); // recharge toutes les recettes
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) async {
                if (value.trim().isEmpty) {
                  _rafraichir();
                } else {
                  setState(() {
                    _recettes = RecetteService.rechercherRecettes(value);
                  });
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Recette>>(
              future: _recettes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final recettes = snapshot.data ?? [];

                if (recettes.isEmpty) {
                  return const Center(child: Text("Aucune recette trouvée."));
                }

                return RefreshIndicator(
                  onRefresh: _rafraichir,
                  child: ListView.builder(
                    itemCount: recettes.length,
                    itemBuilder: (context, index) {
                      final recette = recettes[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.file(
                            File(recette.imagePath),
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(recette.titre),
                          subtitle: Text(
                            recette.description.length > 50
                                ? recette.description.substring(0, 50) + '...'
                                : recette.description,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addRecette);
          _rafraichir(); // recharge après ajout
        },
        child: const Text('Ajouter'),
      ),
    );
  }
}
