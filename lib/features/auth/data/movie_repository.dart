import 'package:appwrite/appwrite.dart';
import 'package:feffs/core/services/appwrite_services.dart';
import 'package:feffs/features/auth/entity/movie.dart';

class MovieRepository {
  final Databases _database = AppwriteService.database;

  final String _databaseId = AppwriteService.databaseId;
  final String _movieCollectionId = AppwriteService.movieCollectionId; 

  Future<List<Movie>> getMovies() async {
    try {
      final movieDocs = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: _movieCollectionId,
      );

      return movieDocs.documents.map((doc) => Movie.fromDocument(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des données des films : $e');
      return [];
    }
  }
}
