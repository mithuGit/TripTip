import 'package:flutter/material.dart';

class ImageViewerPage extends StatefulWidget {
  final Image image;
  final String title;
  const ImageViewerPage({super.key, required this.image, required this.title});

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          //für zoom in und zoom raus
          child: InteractiveViewer(
              maxScale: double.infinity,
              minScale: 0.5,
              panEnabled: true,
              scaleEnabled: true,
              trackpadScrollCausesScale: false,
              child: widget.image),
        ));
  }
}
