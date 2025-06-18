import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un QR Code'),
      ),
      body: MobileScanner(
        //allowDuplicates: false,
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;
          final Barcode? barcode = barcodes.isNotEmpty ? barcodes.first : null;

          if (barcode?.rawValue != null) {
            String code = barcode!.rawValue!;
            debugPrint('QR Code détecté : $code');

            // Complète l'URL si nécessaire
            if (!code.startsWith('http://') && !code.startsWith('https://')) {
              code = 'https://$code';
            }

            final Uri url = Uri.parse(code);
            await launchUrlString(code, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('Aucun QR Code détecté.');
          }
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
