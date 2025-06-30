class Utilisateur {
  final int? id;
  final String nom;
  final String email;
  final String motDePasse;

  Utilisateur({
    this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'email': email, 'mot_de_passe': motDePasse};
  }

  static Utilisateur fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      email: map['email'],
      motDePasse: map['mot_de_passe'],
    );
  }
}
