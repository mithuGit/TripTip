// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerPage extends StatefulWidget {
  final File file;
  final String title;

  const PDFViewerPage({
    super.key,
    required this.file,
    required this.title,
  });

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PDFViewController controller;
  int pages = 0;
  int indexpage = 0;

  @override
  Widget build(BuildContext context) {
    final text = '${indexpage + 1} of $pages';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: pages >= 2
            ? [
                Center(child: Text(text)),
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      size: 30, color: Colors.black),
                  onPressed: () {
                    final page = indexpage == 0 ? pages : indexpage - 1;
                    controller.setPage(page);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 30),
                  onPressed: () {
                    final page = indexpage == pages - 1 ? 0 : indexpage + 1;
                    controller.setPage(page);
                  },
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: double.infinity,
          panEnabled: true,
          scaleEnabled: true,
          trackpadScrollCausesScale: false,
          child: PDFView(
            filePath: widget.file.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
            onRender: (pages) => setState(() => this.pages = pages!),
            onViewCreated: (controller) =>
                setState(() => this.controller = controller),
            onPageChanged: (indexpage, _) =>
                setState(() => this.indexpage = indexpage!),
          ),
        ),
      ),
    );
  }
}
