import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/library_controller.dart';
import '../core/theme/app_colors.dart';
import '../models/ebook.dart';
import '../providers/ebook_provider.dart';
import '../widgets/common/app_search_field.dart';
import '../widgets/common/app_snackbar.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/ebook_shelf.dart';
import '../widgets/library/library_header.dart';
import '../widgets/library/recently_read_strip.dart';
import '../widgets/library/sort_filter_bar.dart';
import '../widgets/state_views.dart';
import 'reader_screen.dart';
import 'upload_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final LibraryController _controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = LibraryController(ebookProvider: context.read<EbookProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.init());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(Ebook ebook) async {
    final confirmed = await confirmDelete(context, ebook.title);
    if (!confirmed || !mounted) return;

    final result = await _controller.deleteEbook(ebook);
    if (!mounted) return;
    showAppSnackBar(context, result.message, isError: !result.success);
  }

  Future<void> _handleDownload(Ebook ebook) async {
    final result = await _controller.downloadEbook(ebook);
    if (!mounted || result.success) return;
    showAppSnackBar(context, result.message!, isError: true);
  }

  void _openReader(Ebook ebook) {
    context.read<EbookProvider>().markAsRead(ebook);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(ebook: ebook)),
    );
  }

  Future<void> _openUpload() async {
    final uploaded = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const UploadScreen()),
    );
    if (uploaded == true && mounted) {
      showAppSnackBar(context, 'Ebook uploaded successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Consumer<EbookProvider>(
            builder: (context, provider, _) => LibraryHeader(
              bookCount: provider.status == LoadStatus.loaded ? provider.ebooks.length : 0,
              isSearching: provider.query.isNotEmpty,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchField(
                controller: _searchController,
                onChanged: _controller.onSearchChanged,
                onClear: _controller.clearSearch,
              ),
            ),
          ),
          Consumer<EbookProvider>(
            builder: (context, provider, _) => SortFilterBar(
              sortOrder: provider.sortOrder,
              fileTypeFilter: provider.fileTypeFilter,
              onSortChanged: provider.setSortOrder,
              onFilterChanged: provider.setFileTypeFilter,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<EbookProvider>(
              builder: (context, provider, _) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: provider.loadEbooks,
                  child: _LibraryContent(
                    provider: provider,
                    onOpen: _openReader,
                    onDelete: _handleDelete,
                    onDownload: _handleDownload,
                    onUpload: _openUpload,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUpload,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book'),
        elevation: 6,
      ),
    );
  }
}

class _LibraryContent extends StatelessWidget {
  final EbookProvider provider;
  final void Function(Ebook) onOpen;
  final void Function(Ebook) onDelete;
  final void Function(Ebook) onDownload;
  final VoidCallback onUpload;

  const _LibraryContent({
    required this.provider,
    required this.onOpen,
    required this.onDelete,
    required this.onDownload,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    switch (provider.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return _scrollable(const LoadingView());
      case LoadStatus.error:
        return _scrollable(ErrorView(
          message: provider.errorMessage ?? 'Something went wrong.',
          onRetry: provider.loadEbooks,
        ));
      case LoadStatus.loaded:
        if (provider.ebooks.isEmpty) {
          return _scrollable(
            provider.query.isEmpty
                ? EmptyShelfView(actionLabel: 'Upload your first ebook', onAction: onUpload)
                : const EmptyShelfView(message: 'No ebooks match your search.'),
          );
        }
        return Column(
          children: [
            RecentlyReadStrip(
              ebooks: provider.recentlyRead,
              onOpen: onOpen,
            ),
            Expanded(
              child: EbookShelf(
                ebooks: provider.ebooks,
                onOpen: onOpen,
                onDelete: onDelete,
                onDownload: onDownload,
                searchQuery: provider.query,
              ),
            ),
          ],
        );
    }
  }

  Widget _scrollable(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}
