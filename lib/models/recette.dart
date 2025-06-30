class Recette {
  final int id;
  final String titre;
  final String description;
  final String imagePath;
  final int utilisateurId;

  Recette({
    required this.id,
    required this.titre,
    required this.description,
    required this.imagePath,
    required this.utilisateurId,
  });

  factory Recette.fromMap(Map<String, dynamic> map) {
    return Recette(
      id: map['id'],
      titre: map['titre'],
      description: map['description'],
      imagePath: map['image_path'],
      utilisateurId: map['utilisateur_id'],
    );
  }
}
