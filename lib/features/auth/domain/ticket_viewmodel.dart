import 'dart:io';
import 'package:feffs/features/auth/data/auth_repository.dart';
import 'package:feffs/features/auth/data/ticket_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:appwrite/appwrite.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final TicketRepository _ticketRepository = TicketRepository();
  String firstName = '';
  String lastName = '';
  File? selectedImage;
  dynamic ticket; 
  bool hasFetchedTicket = false; 
  final ImagePicker _picker = ImagePicker();
  final Databases _database; 
  final Storage _storage;
  final String _collectionId = dotenv.env['TICKETS_COLLECTION_ID']!; 

  TicketViewModel(this._database, this._storage);

Future<void> pickImage(ImageSource source) async {
  final XFile? image = await _picker.pickImage(source: source);
  if (image != null) {
    selectedImage = File(image.path);
    notifyListeners();
  }
}

Future<void> createTicket() async {
  final currentUser = await _authRepository.getCurrentUser();
  final qrData = 'Ticket de $firstName $lastName';
  print(qrData);

  final uploadedFile = await _storage.createFile(
    bucketId: dotenv.env['BUCKET_ID']!,
    fileId: 'unique()',
    file: InputFile.fromPath(path: selectedImage!.path),
  );

  final fileMetadata = await _storage.getFile(
    bucketId: dotenv.env['BUCKET_ID']!,
    fileId: uploadedFile.$id,
  );

  final String imageUrl = '${dotenv.env['ENDPOINT']}/storage/buckets/${dotenv.env['BUCKET_ID']!}/files/${fileMetadata.$id}/view?project=${dotenv.env['APPWRITE_PROJECT_ID']}';

  await _ticketRepository.saveTicket(
    userId: currentUser!.$id,
    firstName: firstName,
    lastName: lastName,
    qrCodeData: qrData,
    imageUrl: imageUrl, 
  );

  await refreshTicket();
  notifyListeners();
}


 Future<void> getUserTicket() async {
    if (hasFetchedTicket) return;

    hasFetchedTicket = true; 
    final currentUser = await _authRepository.getCurrentUser();

    if (currentUser != null) {
      try {
        final fetchedTicket = await _ticketRepository.fetchUserTicket(currentUser.$id);
        if (fetchedTicket != null) {
          ticket = fetchedTicket; 
          print('Ticket récupéré: ${ticket.data['firstName']}');
        } else {
          ticket = null; 
        }
      } catch (e) {
        print('Erreur lors de la récupération du ticket : $e');
        ticket = null;
      }
    } else {
      ticket = null; 
    }

    notifyListeners(); 
  }

  Future<void> refreshTicket() async {
    ticket = null; 
    hasFetchedTicket = false; 
    await getUserTicket(); 
  }

Future<String?> generatePDF() async {
  if (ticket == null) {
    throw Exception('Aucun ticket disponible pour générer le PDF.');
  }

  final pdf = pw.Document();

  final qrData = 'Nom: ${ticket.data['lastName']}\nPrénom: ${ticket.data['firstName']}';
  final String ticketUserId = ticket.data['userId'];
  final String ticketLastName = ticket.data['lastName'];
  final String ticketFirstName = ticket.data['firstName'];
  final String? imageUrl = ticket.data['imageUrl']; 

  final qrPainter = QrPainter(
    data: qrData,
    version: QrVersions.auto,
    gapless: false,
  );

  final qrImageData = await qrPainter.toImageData(200);
  if (qrImageData == null) {
    throw Exception('Erreur lors de la génération du QR Code');
  }
  final qrImageBytes = qrImageData.buffer.asUint8List();

  Uint8List? imageBytes;
  if (imageUrl != null) {
    try {
      final response = await HttpClient().getUrl(Uri.parse(imageUrl));
      final imageResponse = await response.close();
      imageBytes = await consolidateHttpClientResponseBytes(imageResponse);
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      imageBytes = null;
    }
  }

  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Ticket Information',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Numéro de ticket: $ticketUserId'),
          pw.Text('Nom: $ticketLastName'),
          pw.Text('Prénom: $ticketFirstName'),
          pw.SizedBox(height: 20),
          pw.Text('QR Code :'),
          pw.Container(
            width: 150,
            height: 150,
            child: pw.Image(pw.MemoryImage(qrImageBytes)),
          ),
          pw.SizedBox(height: 20),
          if (imageBytes != null)
            pw.Column(
              children: [
                pw.Text('Image :'),
                pw.SizedBox(height: 10),
                pw.Image(pw.MemoryImage(imageBytes)),
              ],
            ),
        ],
      );
    },
  ));

  late String filePath;

  if (Platform.isAndroid) {
    final directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    filePath = '${directory.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.pdf';
  } else if (Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    filePath = '${directory.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.pdf';
  } else {
    throw UnsupportedError('Plateforme non supportée');
  }

  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  return filePath;
}

}