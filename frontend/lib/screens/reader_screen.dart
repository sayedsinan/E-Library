import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../core/theme/app_colors.dart';
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
      appBar: AppBar(
        title: Text(widget.ebook.title, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: !isPdf
          ? _UnsupportedFormatView(fileType: widget.ebook.fileType)
          : _failed
              ? _ReaderErrorView(onRetry: () => setState(() => _failed = false))
              : SfPdfViewer.network(
                  widget.ebook.downloadUrl,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  onDocumentLoadFailed: (_) => setState(() => _failed = true),
                ),
    );
  }
}

class _UnsupportedFormatView extends StatelessWidget {
  final String fileType;

  const _UnsupportedFormatView({required this.fileType});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accentLight.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded, size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              '.$fileType reading coming soon',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Download the file to read it in another app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ReaderErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            const Text(
              'This ebook could not be opened.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
