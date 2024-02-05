// ignore_for_file: file_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/modalButton.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:uuid/uuid.dart';

// class for creating a ticket
class CreateTicketsWidget extends StatefulWidget {
  final DocumentReference? selectedTrip;
  const CreateTicketsWidget({super.key, required this.selectedTrip});

  @override
  State<CreateTicketsWidget> createState() => _CreateTicketsWidgetState();
}

class _CreateTicketsWidgetState extends State<CreateTicketsWidget> {
  final titleOfTicket = TextEditingController();
  File? selectedImage;
  UploadTask? uploadTask;
  PlatformFile? pickedFile;
  bool isPdf = false;

  bool isUploading = false;

// Function to upload a file to firebase storage
  Future<void> uploadFile() async {
    if (titleOfTicket.text.isEmpty) {
      throw "Please enter a title for the ticket";
    }
    if (selectedImage == null && pickedFile == null) {
      throw "No File selected";
    }
    File file;
    if (selectedImage != null) {
      file = File(selectedImage!.path);
    } else {
      file = File(pickedFile!.path!);
    }
    final tripId = widget.selectedTrip!.id;

    String titleOfTicketText = titleOfTicket.text;

    // Check if the title already exists in the specified path
    String fileName;
    String path;

    fileName = file.path.split('/').last;
    String uuid = const Uuid().v4();
    path = "files/$tripId/$uuid/$fileName";

    bool fileExists = await doesFileExist(tripId, titleOfTicketText);

    if (fileExists) {
      // ignore: use_build_context_synchronously
      ErrorSnackbar.showErrorSnackbar(
          context, "File with title $titleOfTicketText already exists ");
    } else {
      final ref = FirebaseStorage.instance.ref().child(path);

      uploadTask = ref.putFile(file);
      setState(() {
        isUploading = true;
      });
      uploadTask!.whenComplete(() async {
        await FirebaseFirestore.instance
            .collection("trips")
            .doc(tripId)
            .collection("tickets")
            .add({
          "title": titleOfTicketText,
          "url": ref.fullPath,
          "createdBy": FirebaseAuth.instance.currentUser!.uid,
          "createdAt": DateTime.now(),
        });
        setState(() {
          isUploading = false;
        });
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

// Function to select a file from the device
  Future selectedFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      );
      if (result == null) return;

      setState(() {
        isPdf = result.files.first.extension == 'pdf';
        pickedFile = result.files.first;
      });
    } on Exception catch (e) {
      if (context.mounted) {
        ErrorSnackbar.showErrorSnackbar(context, e.toString());
      }
    }
  }

// Function to take a picture with the camera
  void takePicture() async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
          source: ImageSource.camera, maxWidth: 600);

      if (pickedImage == null) {
        return;
      }

      setState(() {
        selectedImage = File(pickedImage.path);
      });
    } catch (e) {
      if (context.mounted) {
        ErrorSnackbar.showErrorSnackbar(context, e.toString());
      }
    }
  }

// Build the Custom Bottom Sheet with the InputField, the Buttons to take a picture or upload a file and the Upload Button
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
            controller: titleOfTicket,
            borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
            hintText: "Title of Ticket",
            obscureText: false),
        const SizedBox(height: 20),
        if (pickedFile == null && selectedImage == null) ...[
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.all(10),
            children: [
              ModalButton(
                  onTap: takePicture,
                  icon: Icons.photo_camera,
                  text: "Take a Picture"),
              ModalButton(
                  onTap: selectedFile,
                  icon: Icons.picture_as_pdf,
                  text: "Upload a PDF"),
            ],
          ),
        ] else
          //Ticket or Receip Upload
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              height: 250,
              width: double.infinity,
              alignment: Alignment.center,
              child: selectedImage != null
                  ? GestureDetector(
                      // Nochmal neues Bild erstellen, wenn man drauf klickt
                      onTap: () => takePicture(),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : GestureDetector(
                      // Nochmal neues File erstellen, wenn man drauf klickt
                      onTap: () => selectedFile(),
                      child: isPdf
                          ? FutureBuilder<PdfDocument>(
                              future: PdfDocument.openFile(pickedFile!.path!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  final pdfDocument = snapshot.data;
                                  return pdfDocument != null
                                      ? PdfDocumentLoader(
                                          doc: pdfDocument,
                                          pageNumber: 1,
                                        )
                                      : Container(); // Handle null document
                                } else if (snapshot.hasError) {
                                  // Handle error
                                  return Container();
                                } else {
                                  // Display a loading indicator if needed
                                  return const CircularProgressIndicator();
                                }
                              },
                            )
                          : Image.file(
                              File(pickedFile!.path!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    )),
        const SizedBox(height: 10),
        if (isUploading)
          const Center(
              child: CircularProgressIndicator(
            color: Colors.black,
          ))
        else
          MyButton(
            borderColor: Colors.black,
            textStyle: Styles.buttonFontStyleModal,
            onTap: () {
              uploadFile().onError((error, stackTrace) => {
                    debugPrint(error.toString()),
                    debugPrint(stackTrace.toString()),
                    debugPrint("error"),
                    ErrorSnackbar.showErrorSnackbar(context, error.toString())
                  });
            },
            text: "Upload Ticket",
          ),
      ],
    );
  }

  // Function to check if a file already exists in the specified path
  Future<bool> doesFileExist(String tripId, String titleOfTicketText) async {
    QuerySnapshot ticket = await FirebaseFirestore.instance
        .collection("trips")
        .doc(tripId)
        .collection("tickets")
        .where("title", isEqualTo: titleOfTicketText)
        .get();
    return ticket.docs.isNotEmpty;
  }
}
