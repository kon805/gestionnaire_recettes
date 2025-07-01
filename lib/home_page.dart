import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/models/recette.dart';
import 'package:gestionnaire_recettes/routes/app_routes.dart';
import 'package:gestionnaire_recettes/services/recette_service.dart';
import 'package:gestionnaire_recettes/services/favoris_service.dart';
import 'package:gestionnaire_recettes/services/session_service.dart';
import 'package:gestionnaire_recettes/screens/recette_detail_page.dart';
import 'package:gestionnaire_recettes/screens/profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final TextEditingController searchController = TextEditingController();

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final List<String> _banniereImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  late Future<List<Recette>> _recettes;

  @override
  void initState() {
    super.initState();
    _recettes = RecetteService.getToutesRecettes();
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController.hasClients) {
          _currentIndex = (_currentIndex + 1) % _banniereImages.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  Future<void> _rafraichir() async {
    setState(() {
      _recettes = RecetteService.getToutesRecettes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB),
      appBar: AppBar(
        title: const Text("Mes Recettes"),
        backgroundColor: const Color(0xFFEF6C00),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilPage()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),

            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Rechercher une recette ou un ingrédient...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _rafraichir();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
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
          // BANNIÈRE DÉROULANTE
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banniereImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      _banniereImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // PETITS POINTS INDICATEURS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banniereImages.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 12 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),
          //bienvue sur notre application
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Bienvenue sur notre application !",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: recettes.length,
                    itemBuilder: (context, index) {
                      final recette = recettes[index];
                      return FutureBuilder<int?>(
                        future: SessionService.recupererUtilisateurConnecte(),
                        builder: (context, userSnapshot) {
                          final userId = userSnapshot.data;
                          return FutureBuilder<bool>(
                            future: userId == null
                                ? Future.value(false)
                                : FavorisService.estFavori(userId, recette.id),
                            builder: (context, favoriSnap) {
                              final estFavori = favoriSnap.data ?? false;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RecetteDetailPage(recette: recette),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: Image.file(
                                          File(recette.imagePath),
                                          width: double.infinity,
                                          height: 110,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              recette.titre,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              recette.description.length > 60
                                                  ? '${recette.description.substring(0, 60)}...'
                                                  : recette.description,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: IconButton(
                                                icon: Icon(
                                                  estFavori
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: estFavori
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                                onPressed: userId == null
                                                    ? null
                                                    : () async {
                                                        await FavorisService.toggleFavori(
                                                          userId,
                                                          recette.id,
                                                        );
                                                        setState(() {});
                                                      },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
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
        backgroundColor: const Color(0xFFEF6C00),
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addRecette);
          _rafraichir();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
