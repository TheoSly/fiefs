import 'package:feffs/features/auth/domain/ticket_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late TicketViewModel viewModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<TicketViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.refreshTicket();
    });
  }

  void _showImageSourceSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await viewModel.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await viewModel.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Acheter un Billet')),
      body: Consumer<TicketViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.hasFetchedTicket) {
            return const Center(child: CircularProgressIndicator());
          }

          final ticket = viewModel.ticket;

          if (ticket != null) {
            final qrData =
                'Nom: ${ticket.data['lastName']}\nPrénom: ${ticket.data['firstName']}';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        const Text(
                          'Détails de votre Ticket',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nom :',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${ticket.data['lastName']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prénom :',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${ticket.data['firstName']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Image
                        if (ticket.data['imageUrl'] != null)
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(ticket.data['imageUrl']),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // QR Code
                        const Text(
                          'Votre QR Code :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        QrImageView(
                          data: qrData,
                          size: 150,
                          backgroundColor: Colors.transparent,
                          eyeStyle: QrEyeStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Generate PDF button
                        ElevatedButton.icon(
                          onPressed: () async {
                            final pdfPath = await viewModel.generatePDF();
                            if (pdfPath != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'PDF généré et enregistré dans Téléchargements!',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Générer le PDF'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Form to create ticket
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      onChanged: (value) => viewModel.firstName = value,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prénom est obligatoire.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      onChanged: (value) => viewModel.lastName = value,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est obligatoire.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            _showImageSourceSelector(context);
                          },
                          child: const Text('Ajouter une photo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (viewModel.selectedImage != null)
                      Center(
                        child: Image.file(
                          viewModel.selectedImage!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (viewModel.selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez sélectionner une image.'),
                              ),
                            );
                            return;
                          }

                          await viewModel.createTicket();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ticket acheté!'),
                            ),
                          );
                          viewModel.refreshTicket();
                        }
                      },
                      child: const Text('Acheter le Billet'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
