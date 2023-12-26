import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/ticket/ImageViewerPage.dart';
import 'package:internet_praktikum/ui/views/ticket/PDFViewerPage.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';

class TicketContainer extends StatefulWidget {
  const TicketContainer({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<TicketContainer> createState() => _TicketContainerState();
}

class _TicketContainerState extends State<TicketContainer> {
  Image? image;
  bool isImageLoading = false; // TODO: loading animation npoh einbauen
  bool isPDF = false;
  String? imageUrlNew;

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  Future<void> fetchImage() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
      final String tripId = userDoc.data()!['selectedtrip'].toString();

      final imageUrl = await FirebaseStorage.instance
          .ref()
          .child('files/$tripId/${widget.title}')
          .list()
          .then((value) => value.items.first.fullPath);

      imageUrlNew = imageUrl;

      imageUrl.contains('.pdf') ? isPDF = true : isPDF = false;

      var getDownloadUrlLink =
          await FirebaseStorage.instance.ref(imageUrl).getDownloadURL();
      print("LIST:  $getDownloadUrlLink");
      setState(() {
        image = Image.network(
          getDownloadUrlLink,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      });
    } catch (error) {
      image = null;
      if (kDebugMode) {
        print('Error fetching image: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 20, right: 20, top: 10.0, bottom: 10.0),
      child: GestureDetector(
        onTap: () async {
          setState(() =>
              CustomBottomSheet.show(context, title: widget.title, content: [
                Builder(
                  builder: (context) {
                    fetchImage();
                    return Column(
                        // hier Modal für Preview des Belegs
                        children: [
                          const SizedBox(height: 30.0),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                              ),
                            ),
                            height: 350,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: image != null
                                ? GestureDetector(
                                    onTap: () {
                                      (isPDF == true
                                          ? openPDF(
                                              context,
                                              File(image!.toString()),
                                              widget
                                                  .title) // Das funktioniert nicht
                                          : openImage(
                                              context,
                                              image!,
                                              widget
                                                  .title)); // Das funktioniert
                                    },
                                    child: image,
                                  )
                                : const Center(
                                    child: Text(
                                      "No Image Selected",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                          ),
                        ]);
                  },
                ),
              ]));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 66.0,
          decoration: BoxDecoration(
            color: const Color(0xE51E1E1E),
            border: Border.all(color: const Color(0xE51E1E1E)),
            borderRadius: BorderRadius.circular(34.5),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 18.0, left: 25, right: 25, bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const ImageIcon(
                            AssetImage('assets/docs.png'),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openPDF(BuildContext context, File file, String title) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PDFViewerPage(file: file, title: title)));

  void openImage(BuildContext context, Image image, String title) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ImageViewerPage(image: image, title: title)));
}
