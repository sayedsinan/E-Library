import 'package:flutter/foundation.dart';
import '../models/ebook.dart';
import '../services/api_service.dart';

enum LoadStatus { initial, loading, loaded, error }

enum SortOrder { newest, oldest, titleAZ, authorAZ }

enum FileTypeFilter { all, pdf, epub }

class EbookProvider extends ChangeNotifier {
  final ApiService _api;
  EbookProvider({ApiService? api}) : _api = api ?? ApiService();

  List<Ebook> _ebooks = [];
  List<Ebook> get ebooks => _applyFilters(_ebooks);

  LoadStatus _status = LoadStatus.initial;
  LoadStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _uploading = false;
  bool get uploading => _uploading;

  String _query = '';
  String get query => _query;

  SortOrder _sortOrder = SortOrder.newest;
  SortOrder get sortOrder => _sortOrder;

  FileTypeFilter _fileTypeFilter = FileTypeFilter.all;
  FileTypeFilter get fileTypeFilter => _fileTypeFilter;

  // Recently read — ordered most-recent first, max 5
  final List<Ebook> _recentlyRead = [];
  List<Ebook> get recentlyRead => List.unmodifiable(_recentlyRead);

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void setFileTypeFilter(FileTypeFilter filter) {
    _fileTypeFilter = filter;
    notifyListeners();
  }

  void markAsRead(Ebook ebook) {
    _recentlyRead.removeWhere((e) => e.id == ebook.id);
    _recentlyRead.insert(0, ebook);
    if (_recentlyRead.length > 5) _recentlyRead.removeLast();
    notifyListeners();
  }

  List<Ebook> _applyFilters(List<Ebook> source) {
    var result = List<Ebook>.from(source);

    // File type filter
    if (_fileTypeFilter != FileTypeFilter.all) {
      final ext = _fileTypeFilter == FileTypeFilter.pdf ? 'pdf' : 'epub';
      result = result.where((e) => e.fileType.toLowerCase() == ext).toList();
    }

    // Sort
    switch (_sortOrder) {
      case SortOrder.newest:
        result.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        break;
      case SortOrder.oldest:
        result.sort((a, b) => a.uploadDate.compareTo(b.uploadDate));
        break;
      case SortOrder.titleAZ:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOrder.authorAZ:
        result.sort((a, b) {
          final aAuthor = a.author?.toLowerCase() ?? '';
          final bAuthor = b.author?.toLowerCase() ?? '';
          return aAuthor.compareTo(bAuthor);
        });
        break;
    }

    return result;
  }

  Future<void> loadEbooks() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _ebooks = await _api.fetchEbooks();
      _status = LoadStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    _query = query;
    if (query.trim().isEmpty) {
      return loadEbooks();
    }
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _ebooks = await _api.search(query);
      _status = LoadStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> upload({
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    required String title,
    String? author,
    required String fileType,
  }) async {
    _uploading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final ebook = await _api.uploadEbook(
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
        title: title,
        author: author,
        fileType: fileType,
      );
      _ebooks = [ebook, ..._ebooks];
      _uploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _uploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    final backup = List<Ebook>.from(_ebooks);
    _ebooks = _ebooks.where((e) => e.id != id).toList();
    notifyListeners();
    try {
      await _api.deleteEbook(id);
      return true;
    } catch (e) {
      _ebooks = backup; // roll back on failure
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
