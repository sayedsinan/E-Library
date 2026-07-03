import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ebook.dart';
import '../services/api_service.dart';

enum LoadStatus { initial, loading, loaded, error }

class EbookProvider extends ChangeNotifier {
  final ApiService _api;
  EbookProvider({ApiService? api}) : _api = api ?? ApiService();

  List<Ebook> _ebooks = [];
  List<Ebook> get ebooks => _ebooks;

  LoadStatus _status = LoadStatus.initial;
  LoadStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _uploading = false;
  bool get uploading => _uploading;

  String _query = '';
  String get query => _query;

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
    required File file,
    required String title,
    String? author,
    required String fileType,
  }) async {
    _uploading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final ebook = await _api.uploadEbook(
        file: file,
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
