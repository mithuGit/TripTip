// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ImageViewerPage extends StatefulWidget {
  final Image image;
  final String title;
  const ImageViewerPage({super.key, required this.image, required this.title});

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

// class for viewing an image and zooming in and out
class _ImageViewerPageState extends State<ImageViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Center(
            //für zoom in und zoom raus
            child: InteractiveViewer(
                maxScale: double.infinity,
                minScale: 0.5,
                panEnabled: true,
                scaleEnabled: true,
                trackpadScrollCausesScale: false,
                child: widget.image),
          ),
        ));
  }
}
