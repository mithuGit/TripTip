import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_praktikum/ui/widgets/inputfield.dart';
import 'package:internet_praktikum/ui/widgets/profileWidgets/profileButton.dart';
import 'package:file_picker/file_picker.dart';

class CreateTicketsWidget extends StatefulWidget {
  const CreateTicketsWidget({super.key});

  @override
  State<CreateTicketsWidget> createState() => _CreateTicketsWidgetState();
}

class _CreateTicketsWidgetState extends State<CreateTicketsWidget> {
  final titleofTicket = TextEditingController();
  File? selectedImage;
  UploadTask? uploadTask;
  PlatformFile? pickedFile;

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

    final path = 'files/${file}';

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download-Link: $urlDownload');
    setState(() {
      uploadTask = null;
    });
  }

  Future selectedFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select an Option"),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
          actionsOverflowButtonSpacing: 20,
          actions: [
            ElevatedButton(
              onPressed: () {
                _takePicture();
                Navigator.of(context).pop();
              },
              child: const Text("Take a Picture "),
            ),
            ElevatedButton(
                onPressed: () {
                  // Funktion File hin
                  selectedFile();
                  Navigator.of(context).pop();
                },
                child: const Text("Upload a File")),
          ],
        );
      },
    );
  }

  void _takePicture() async {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
            controller: titleofTicket,
            borderColor: Colors.grey.shade400,
            focusedBorderColor: const Color.fromARGB(255, 84, 113, 255),
            hintText: "Title of Ticket or Receipt",
            obscureText: false),
        const SizedBox(height: 10),

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
                  //nochmal neues bild erstellen wenn man drauf klickt
                  onTap: () => _takePicture(),
                  child: Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : pickedFile != null
                  ? GestureDetector(
                      //nochmal neues file erstellen wenn man drauf klickt
                      onTap: () => selectedFile(),
                      child: Image.file(
                        File(pickedFile!.path!),
                        fit: BoxFit.cover,
                        width: double.infinity,
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
        ProfileButton(
          onTap: () =>
              uploadFile(), // TODO: Widget soll dann erstellt werden und dieser soll in Ticket direkt zu sehen sein.
          title: "Upload Ticket or Receipt",
          textcolor: Colors.white,
          backgroundColor: Colors.blue,
        ),
      ],
    );
  }

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
