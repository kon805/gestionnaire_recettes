import 'package:flutter/material.dart';
import 'package:gestionnaire_recettes/models/recette.dart';
import 'package:gestionnaire_recettes/services/database_service.dart';
import 'package:gestionnaire_recettes/screens/recette_detail_page.dart';
import 'dart:io';

class TopRecettesPage extends StatefulWidget {
  const TopRecettesPage({super.key});

  @override
  State<TopRecettesPage> createState() => _TopRecettesPageState();
}

class _TopRecettesPageState extends State<TopRecettesPage> {
  List<Recette> plusLiker = [];
  List<Recette> mieuxNote = [];
  bool _isLoading = true;

  final Color primaryColor = const Color(0xFFEF6C00);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final double borderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _chargerClassement();
  }

  Future<void> _chargerClassement() async {
    setState(() => _isLoading = true);

    final db = await DatabaseService.getDatabase();

    // Afficher uniquement les recettes qui ont au moins 1 like pour le classement des plus likées
    final likerRes = await db.query(
      'recettes',
      where: 'likes > 0',
      orderBy: 'likes DESC',
      limit: 5,
    );

    // Afficher uniquement les recettes qui ont au moins 1 like ou une note > 0 pour le classement des mieux notées
    final noterRes = await db.query(
      'recettes',
      where: 'likes > 0 OR note > 0',
      orderBy: 'note DESC',
      limit: 5,
    );

    setState(() {
      plusLiker = likerRes.map((r) => Recette.fromMap(r)).toList();
      mieuxNote = noterRes.map((r) => Recette.fromMap(r)).toList();
      _isLoading = false;
    });
  }

  Widget _buildRecetteCard(Recette recette, int rank) {
    // Ajout d'un effet visuel pour le top 1 (ex: cercle doré et couronne)
    final bool isTop1 = rank == 0;
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isTop1
                          ? Colors.amber.withOpacity(0.7)
                          : primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: isTop1
                          ? Border.all(color: Colors.amber, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        "#${rank + 1}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isTop1 ? Colors.brown[800] : primaryColor,
                        ),
                      ),
                    ),
                  ),
                  if (isTop1)
                    Positioned(
                      top: -8,
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber[700],
                        size: 24,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(recette.imagePath),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text(
                          recette.likes.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          recette.note.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Recette> recettes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        if (recettes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                "Aucune recette disponible",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...recettes.asMap().entries.map(
            (e) => _buildRecetteCard(e.value, e.key),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Top Recettes"),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection("❤️ Les plus populaires", plusLiker),
                  const SizedBox(height: 24),
                  _buildSection("⭐ Les mieux notées", mieuxNote),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Actualiser"),
                    onPressed: _chargerClassement,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
