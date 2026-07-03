import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/ebook.dart';

class ReaderScreen extends StatefulWidget {
  final Ebook ebook;
  const ReaderScreen({super.key, required this.ebook});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final isPdf = widget.ebook.fileType.toLowerCase() == 'pdf';

    return Scaffold(
      appBar: AppBar(title: Text(widget.ebook.title, overflow: TextOverflow.ellipsis)),
      body: !isPdf
          ? _unsupportedFormat()
          : _failed
              ? _errorState()
              : SfPdfViewer.network(
                  widget.ebook.downloadUrl,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  onDocumentLoadFailed: (details) => setState(() => _failed = true),
                ),
    );
  }

  Widget _unsupportedFormat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'In-app reading for .${widget.ebook.fileType} files isn\'t supported yet.\n'
              'Download the file to read it in another app.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            const Text('This ebook could not be opened.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _failed = false),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
