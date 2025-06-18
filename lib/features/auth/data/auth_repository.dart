import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:feffs/core/services/appwrite_services.dart';
import 'package:feffs/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final Account _account = AppwriteService.account;
  final Databases _database = AppwriteService.database;
  final String _databaseId = AppwriteService.databaseId;
  final String _usersCollectionId = AppwriteService.usersCollectionId;

  Future<User?> register(String email, String password, String firstName, String lastName) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: '$firstName $lastName',
      );

      _database.createDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': user.$id,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      return user;
    } catch (e) {
      print('Erreur lors de l’inscription : $e');
      return null;
    }
  }

  Future<Session?> login(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final fcmToken = await FirebaseMessaging.instance.getToken();
      _account.createPushTarget(
        targetId: ID.unique(),
        identifier: fcmToken!,
        providerId: dotenv.env['MESSAGING_PROVIDER_ID'],
      );

      return session;
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserWithDetails() async {
    try {
      final user = await _account.get();

      final userDocs = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        queries: [
          Query.equal('userId', user.$id),
        ],
      );

      if (userDocs.documents.isNotEmpty) {
        final userData = userDocs.documents.first.data;
        return {
          'userId': user.$id,
          'email': user.email,
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur : $e');
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = await _account.get();
      return user;
    } catch (e) {
      print('Aucun utilisateur connecté : $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
    }
  }
}
