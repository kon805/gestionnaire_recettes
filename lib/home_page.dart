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
import 'package:gestionnaire_recettes/screens/top_recettes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final TextEditingController _searchController = TextEditingController();

  final List<String> _banniereImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  late Future<List<Recette>> _recettes;
  Timer? _bannerTimer;
  bool _isSearching = false;

  final Color primaryColor = const Color(0xFFEF6C00);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final double borderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    RecetteService.synchroniserLikes().then((_) {
      setState(() {
        _recettes = RecetteService.getToutesRecettes();
      });
    });
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % _banniereImages.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _rafraichir() async {
    setState(() {
      _recettes = _searchController.text.isEmpty
          ? RecetteService.getToutesRecettes()
          : RecetteService.rechercherRecettes(_searchController.text);
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => _rafraichir(),
            )
          : const Text(
              "Mes Recettes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _rafraichir();
              }
            });
          },
        ),
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.person, size: 26),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilPage()),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Image.asset(_banniereImages[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banniereImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index ? primaryColor : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRecetteCard(Recette recette, bool estFavori) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecetteDetailPage(recette: recette),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                  ),
                  child: Image.file(
                    File(recette.imagePath),
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: FutureBuilder<int?>(
                    future: SessionService.recupererUtilisateurConnecte(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) return const SizedBox();
                      return IconButton(
                        icon: Icon(
                          estFavori ? Icons.favorite : Icons.favorite_border,
                          color: estFavori ? Colors.red : Colors.white,
                          size: 24,
                        ),
                        onPressed: () async {
                          await FavorisService.toggleFavori(
                            snapshot.data!,
                            recette.id,
                          );
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    recette.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      Text(
                        recette.likes.toString(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        recette.note.toStringAsFixed(1),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecetteList() {
    return FutureBuilder<List<Recette>>(
      future: _recettes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recettes = snapshot.data ?? [];

        if (recettes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? "Aucune recette disponible"
                      : "Aucun résultat trouvé",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (_searchController.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _rafraichir();
                    },
                    child: const Text("Réinitialiser la recherche"),
                  ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _rafraichir,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recettes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final recette = recettes[index];
              return FutureBuilder<bool>(
                future: SessionService.recupererUtilisateurConnecte().then(
                  (userId) => userId == null
                      ? Future.value(false)
                      : FavorisService.estFavori(userId, recette.id),
                ),
                builder: (context, snapshot) {
                  return _buildRecetteCard(recette, snapshot.data ?? false);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (!_isSearching) _buildBanner(),
          if (!_isSearching)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Découvrez nos recettes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          Expanded(child: _buildRecetteList()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Top'),
        ],
        onTap: (index) {
          if (index == 1) {
            // Naviguer vers les favoris
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TopRecettesPage()),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addRecette);
          _rafraichir();
        },
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
