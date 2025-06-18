import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteService {
  static late final Client client;
  static late final Account account;
  static late final Databases database;
  static late final Storage storage;

  static late final String databaseId;
  static late final String scheduleCollectionId;
  static late final String usersCollectionId;
  static late final String movieCollectionId;

  static void initialize() {
    if (dotenv.isInitialized) {
      client = Client()
        ..setEndpoint(dotenv.env['ENDPOINT']!)
        ..setProject(dotenv.env['APPWRITE_PROJECT_ID']!);

      account = Account(client);
      database = Databases(client);
      storage = Storage(client);

      databaseId = dotenv.env['DATABASE_ID']!;
      scheduleCollectionId = dotenv.env['SCHEDULE_COLLECTION_ID']!;
      usersCollectionId = dotenv.env['USERS_COLLECTION_ID']!; 
      movieCollectionId = dotenv.env['MOVIE_COLLECTION_ID']!;
    } else {
      throw Exception('Dotenv not loaded');
    }
  }

  static Future<void> addProgramToSchedule(String movieTitle, String movieDescription, String movieDate) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      await database.createDocument(
        databaseId: databaseId,
        collectionId: scheduleCollectionId,
        documentId: 'unique()',
        data: {
          'userId': userId,
          'movieTitle': movieTitle,
          'movieDescription': movieDescription,
          'movieDate': movieDate,
        },
      );
    } catch (e) {
      print('Erreur lors de l\'ajout du programme: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserSchedule() async {
    try {
      final user = await account.get();
      final userId = user.$id;

      final response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: scheduleCollectionId,
        queries: [
          Query.equal('userId', userId),
        ],
      );

      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print('Erreur lors de la récupération des programmes: $e');
      return [];
    }
  }

  static Future<void> removeProgramFromSchedule(String movieTitle) async {
    try {
      final user = await account.get();
      final userId = user.$id;

      final response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: scheduleCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('movieTitle', movieTitle),
        ],
      );

      if (response.documents.isNotEmpty) {
        final documentId = response.documents.first.$id;
        await database.deleteDocument(
          databaseId: databaseId,
          collectionId: scheduleCollectionId,
          documentId: documentId,
        );
      }
    } catch (e) {
      print('Erreur lors de la suppression du programme: $e');
    }
  }
}