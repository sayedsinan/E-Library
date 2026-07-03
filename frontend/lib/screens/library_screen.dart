import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ebook.dart';
import '../providers/ebook_provider.dart';
import '../widgets/ebook_shelf.dart';
import '../widgets/state_views.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'upload_screen.dart';
import 'reader_screen.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EbookProvider>().loadEbooks();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<EbookProvider>().search(value);
    });
  }

  Future<void> _handleDelete(Ebook ebook) async {
    final confirmed = await confirmDelete(context, ebook.title);
    if (!confirmed) return;

    final ok = await context.read<EbookProvider>().delete(ebook.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? '"${ebook.title}" deleted.' : 'Delete failed. Try again.')),
    );
  }

  Future<void> _handleDownload(Ebook ebook) async {
    final url = Uri.parse(ApiService().downloadUrlFor(ebook));
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start download.')),
      );
    }
  }

  void _openReader(Ebook ebook) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderScreen(ebook: ebook)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookshelf'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by title, author, or file name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<EbookProvider>().loadEbooks();
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: Consumer<EbookProvider>(
              builder: (context, provider, _) {
                switch (provider.status) {
                  case LoadStatus.initial:
                  case LoadStatus.loading:
                    return const LoadingView();
                  case LoadStatus.error:
                    return ErrorView(
                      message: provider.errorMessage ?? 'Something went wrong.',
                      onRetry: () => provider.loadEbooks(),
                    );
                  case LoadStatus.loaded:
                    if (provider.ebooks.isEmpty) {
                      return provider.query.isEmpty
                          ? const EmptyShelfView()
                          : const EmptyShelfView(message: 'No ebooks match your search.');
                    }
                    return EbookShelf(
                      ebooks: provider.ebooks,
                      onOpen: _openReader,
                      onDelete: _handleDelete,
                      onDownload: _handleDownload,
                    );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final uploaded = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const UploadScreen()),
          );
          if (uploaded == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ebook uploaded.')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
      ),
    );
  }
}
