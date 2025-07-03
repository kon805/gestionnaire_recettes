class Recette {
  final int id;
  final String titre;
  final String description;
  final String imagePath;
  final int utilisateurId;
  final int likes;
  final double note;

  Recette({
    required this.id,
    required this.titre,
    required this.description,
    required this.imagePath,
    required this.utilisateurId,
    required this.likes,
    required this.note,
  });

  factory Recette.fromMap(Map<String, dynamic> map) {
    return Recette(
      id: map['id'],
      titre: map['titre'],
      description: map['description'],
      imagePath: map['image_path'],
      utilisateurId: map['utilisateur_id'],
      likes: map['likes'] ?? 0,
      note: (map['note'] is int)
          ? (map['note'] as int).toDouble()
          : (map['note'] ?? 0.0) as double,
    );
  }
}
