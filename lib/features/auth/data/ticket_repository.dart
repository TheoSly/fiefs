import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:feffs/core/services/appwrite_services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TicketRepository {
  final Databases _databases = AppwriteService.database;

  static  String databaseId = dotenv.env['DATABASE_ID']!;
  static  String collectionId = dotenv.env['TICKETS_COLLECTION_ID']!;

  Future<Document?> saveTicket({
    required String userId,
    required String firstName,
    required String lastName,
    required String qrCodeData,
    required String? imageUrl,
  }) async {
    try {
      final response = await _databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'firstName': firstName,
          'lastName': lastName,
          'qrCodeData': qrCodeData,
          'imageUrl': imageUrl,
        },
      );
      return response;
    } catch (e) {
      print('Erreur lors de l’enregistrement du ticket : $e');
      return null;
    }
  }

  Future<Document?> fetchUserTicket(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [Query.equal('userId', userId)],
      );

      if (response.documents.isNotEmpty) {
        return response.documents.first;
      }
    } catch (e) {
      print('Erreur lors de la récupération du ticket : $e');
    }
    return null;
  }
}
