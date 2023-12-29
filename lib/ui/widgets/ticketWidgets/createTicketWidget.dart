import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/styles/Styles.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/my_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class CreateTicketsWidget extends StatefulWidget {
  const CreateTicketsWidget({super.key});

  @override
  State<CreateTicketsWidget> createState() => _CreateTicketsWidgetState();
}

class _CreateTicketsWidgetState extends State<CreateTicketsWidget> {
  final titleOfTicket = TextEditingController();
  File? selectedImage;
  UploadTask? uploadTask;
  PlatformFile? pickedFile;
  bool isPdf = false;

  //TODO: Die Methode in ein Try-Catch-Block reinpacken
  Future uploadFile() async {
    if (selectedImage == null && pickedFile == null) {
      return;
    }

    File file;

    if (selectedImage != null) {
      file = File(selectedImage!.path);
    } else {
      file = File(pickedFile!.path!);
    }

    final auth = FirebaseAuth.instance.currentUser!;
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .get();
    final String tripId = userDoc.data()!['selectedtrip'].toString();

    // TODO: Pfad anpassen; Temporär in FirebaseStorage mit TripID und titleOfTicket
    String titleOfTicketText = titleOfTicket.text;
    String fileName = file.path.split('/').last;
    final path = "files/$tripId/$titleOfTicketText/$fileName";

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  // TODO: Die Methode in ein Try-Catch-Block reinpacken
  Future selectedFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      //type: FileType.custom,
      //allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
    );
    if (result == null) return;

    setState(() {
      isPdf = result.files.first.extension == 'pdf';
      pickedFile = result.files.first;
    });
  }

  // TODO: Die Methode in ein Try-Catch-Block reinpacken
  void takePicture() async {
    final imagePicker = ImagePicker();
    //ImageSource.galery auch möglich
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      selectedImage = File(pickedImage.path);
    });
  }

  void showAlertDialog(BuildContext context,
      {String? title = "Select an Option",
      String? button1 = "Take a Picture",
      bool? button2 = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Text(title!),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
          actionsOverflowButtonSpacing: 20,
          actions: [
            ElevatedButton(
              onPressed: () {
                button2! ? takePicture() : null;
                Navigator.of(context).pop();
              },
              child: Text(button1!),
            ),
            button2!
                ? ElevatedButton(
                    onPressed: () {
                      // Funktion File hin
                      selectedFile();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Upload a File"))
                : Container(
                    width: 0,
                  ), // hier muss width = 0, damit actionsAlignment: MainAxisAlignment.center,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //TODO: checken ob Title schon existiert, um KOnflikte zu vermeiden
        //TODO: checken ob Title schon existiert, um KOnflikte zu vermeiden
        InputField(
            controller: titleOfTicket,
            borderColor: Colors.grey.shade400,
            focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
            hintText: "Title of Ticket or Receipt",
            obscureText: false),
        const SizedBox(height: 20),

        //Ticket or Receip Upload
        Container(
          decoration: BoxDecoration(
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
              : pickedFile != null
                  ? GestureDetector(
                      // Nochmal neues File erstellen, wenn man drauf klickt
                      // TODO: Gerade funktioniert nur Bilder und keine PDF
                      onTap: () => selectedFile(),
                      child: isPdf
                          ?
                          FutureBuilder<PdfDocument>(
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
                    )
                  : GestureDetector(
                      onTap: () => showAlertDialog(context),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 50,
                              ),
                              SizedBox(width: 10),
                              Text("Or"),
                              SizedBox(width: 10),
                              Icon(
                                Icons.upload_file_outlined,
                                size: 50,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Upload Ticket or Receipt",
                            style: TextStyle(
                              color: Color.fromARGB(255, 84, 113, 255),
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),

        const SizedBox(height: 10),
        MyButton(
          borderColor: Colors.black,
          textStyle: Styles.buttonFontStyleModal,
          onTap: () {
            // TODO: Widget soll dann erstellt werden und dieser soll in Ticket direkt zu sehen sein.
            if (titleOfTicket.text.isNotEmpty &&
                (selectedImage != null || pickedFile != null)) {
              uploadFile();
              Navigator.of(context).pop();
              setState(() {
                uploadTask = null;
              });
            } else {
              if (selectedImage == null && pickedFile == null) {
                showAlertDialog(context);
              } else {
                showAlertDialog(context,
                    title: "Please enter a title for your Ticket or Receipt",
                    button1: "Ok",
                    button2: false);
              }
            }
          },
          text: "Upload Ticket or Receipt",
        ),
      ],
    );
  }




//TODO BuildProgress mit if uploadtask != null dann wirds aufgerufen ? eventuell nach upload und dann wird der upload button weiß wenns ready ist 
  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask!.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          final progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 80,
            child: Stack(fit: StackFit.expand, children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black,
                color: Colors.green,
              ),
              Center(
                  child: Text(
                '${(100 * progress).roundToDouble()}%',
                style: const TextStyle(color: Colors.black),
              ))
            ]),
          );
        } else {
          return Container();
        }
      });
}
