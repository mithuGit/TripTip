import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_praktikum/ui/views/ticket/ImageViewerPage.dart';
import 'package:internet_praktikum/ui/views/ticket/PDFViewerPage.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class TicketContainer extends StatefulWidget {
  DocumentSnapshot ticket;

  TicketContainer({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  State<TicketContainer> createState() => _TicketContainerState();
}

class _TicketContainerState extends State<TicketContainer> {
  Image? image;
  bool isPDF = false;
  PdfDocumentLoader? pdfDocumentLoader;
  File? pdfFile;
  var height = 350.0;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    data = widget.ticket.data() as Map<String, dynamic>;
  }

  Future<void> fetchImage() async {
    try {
      var getDownloadUrlLink =
          await FirebaseStorage.instance.ref(data!["url"]).getDownloadURL();
      getDownloadUrlLink.contains('.pdf') ? isPDF = true : isPDF = false;

      isPDF
          ? setState(() async {
              final Directory tempDir = await getTemporaryDirectory();
              pdfFile = File('${tempDir.path}/${data!["title"]}');
              await FirebaseStorage.instance
                  .ref(data!["url"])
                  .writeToFile(pdfFile!);

              pdfDocumentLoader = PdfDocumentLoader.openFile(
                pdfFile!.path,
                pageNumber: 1,
              );
              image = null;
              height = 480.0;
            })
          : setState(() {
              image = Image.network(
                getDownloadUrlLink,
                fit: BoxFit.cover,
                width: double.infinity,
              );
              pdfFile = null;
              height = 350.0;
            });
    } catch (error) {
      // image = null;
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
          CustomBottomSheet.show(context, title: data!["title"], content: [
            FutureBuilder(
              future: fetchImage(),
              builder: (context, futuredata) {
                return Column(
                    // hier Modal für Preview des Belegs
                    children: [
                      const SizedBox(height: 20.0),
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
                        height: height,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: image != null || pdfFile != null
                            ? GestureDetector(
                                onTap: () {
                                  isPDF
                                      ? (openPDF(
                                          context, pdfFile!, data!["title"]))
                                      : (openImage(
                                          context, image!, data!["title"]));
                                },
                                child: isPDF ? pdfDocumentLoader : image,
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
          ]);
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
                            data!["title"],
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
