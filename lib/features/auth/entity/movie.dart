import 'package:appwrite/models.dart';

class Movie {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String date;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl, 
    required this.date,
  });

  factory Movie.fromDocument(Document doc) {
    return Movie(
      id: doc.$id,
      title: doc.data['title'] ?? 'Titre inconnu',
      description: doc.data['description'] ?? 'Description non disponible',
      imageUrl: doc.data['imageUrl'] ?? 'assets/img/default.png',
      date: doc.data['date'] ?? '01jan', 
    );
  }
}
