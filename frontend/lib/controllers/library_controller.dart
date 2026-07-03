import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/debouncer.dart';
import '../models/ebook.dart';
import '../providers/ebook_provider.dart';
import '../services/ebook_actions_service.dart';

/// Handles library screen business logic — search, delete, download.
class LibraryController extends ChangeNotifier {
  LibraryController({
    required EbookProvider ebookProvider,
    EbookActionsService? actionsService,
  })  : _ebookProvider = ebookProvider,
        _actions = actionsService ?? EbookActionsService();

  final EbookProvider _ebookProvider;
  final EbookActionsService _actions;
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: AppConstants.searchDebounceMs),
  );

  EbookProvider get provider => _ebookProvider;

  void init() => _ebookProvider.loadEbooks();

  void onSearchChanged(String value) {
    _debouncer.run(() => _ebookProvider.search(value));
  }

  void clearSearch() {
    _debouncer.dispose();
    _ebookProvider.loadEbooks();
  }

  Future<DeleteResult> deleteEbook(Ebook ebook) async {
    final ok = await _ebookProvider.delete(ebook.id);
    return ok
        ? DeleteResult.success('"${ebook.title}" deleted.')
        : DeleteResult.failure('Delete failed. Try again.');
  }

  Future<DownloadResult> downloadEbook(Ebook ebook) async {
    final ok = await _actions.download(ebook);
    return ok
        ? DownloadResult.success()
        : DownloadResult.failure('Could not start download.');
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}

class DeleteResult {
  final bool success;
  final String message;

  const DeleteResult._(this.success, this.message);

  factory DeleteResult.success(String message) => DeleteResult._(true, message);
  factory DeleteResult.failure(String message) => DeleteResult._(false, message);
}

class DownloadResult {
  final bool success;
  final String? message;

  const DownloadResult._(this.success, this.message);

  factory DownloadResult.success() => const DownloadResult._(true, null);
  factory DownloadResult.failure(String message) => DownloadResult._(false, message);
}
