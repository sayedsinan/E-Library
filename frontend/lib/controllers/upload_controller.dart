import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/ebook_utils.dart';
import '../providers/ebook_provider.dart';

/// Manages upload form state and validation — no UI code.
class UploadController extends ChangeNotifier {
  // Native path (non-web)
  String? _filePath;
  // Web bytes + filename
  List<int>? _fileBytes;
  String? _webFileName;

  String? fileType;
  String? pickError;

  final titleController = TextEditingController();
  final authorController = TextEditingController();

  String? get fileName {
    if (kIsWeb) return _webFileName;
    return _filePath != null ? EbookUtils.fileNameFromPath(_filePath!) : null;
  }

  bool get hasFile => kIsWeb ? _fileBytes != null : _filePath != null;

  Future<void> pickFile() async {
    pickError = null;
    notifyListeners();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.allowedExtensions,
      withData: kIsWeb, // web needs bytes; native uses path
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    final name = picked.name;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';

    if (!AppConstants.allowedExtensions.contains(ext)) {
      pickError = 'Only PDF and EPUB files are supported.';
      notifyListeners();
      return;
    }

    if (kIsWeb) {
      final bytes = picked.bytes;
      if (bytes == null) {
        pickError = 'Could not read the selected file.';
        notifyListeners();
        return;
      }
      if (bytes.length > AppConstants.maxUploadBytes) {
        pickError = 'File is too large (max 100MB).';
        notifyListeners();
        return;
      }
      _fileBytes = bytes;
      _webFileName = name;
      _filePath = null;
    } else {
      final path = picked.path;
      if (path == null) {
        pickError = 'Could not access the selected file.';
        notifyListeners();
        return;
      }
      // Size check for native via path
      final sizeCheck = picked.size;
      if (sizeCheck > AppConstants.maxUploadBytes) {
        pickError = 'File is too large (max 100MB).';
        notifyListeners();
        return;
      }
      _filePath = path;
      _fileBytes = null;
      _webFileName = null;
    }

    fileType = ext;
    if (titleController.text.isEmpty) {
      final rawName = kIsWeb ? _webFileName! : EbookUtils.fileNameFromPath(_filePath!);
      titleController.text = EbookUtils.titleFromFileName(rawName);
    }
    notifyListeners();
  }

  String? validateTitle(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Title is required' : null;

  Future<UploadResult> submit(EbookProvider provider) async {
    if (!hasFile) {
      pickError = 'Please choose a PDF or EPUB file.';
      notifyListeners();
      return UploadResult.failure('Please choose a PDF or EPUB file.');
    }

    final ok = await provider.upload(
      filePath: kIsWeb ? null : _filePath,
      fileBytes: kIsWeb ? _fileBytes : null,
      fileName: kIsWeb ? _webFileName : null,
      title: titleController.text.trim(),
      author: authorController.text.trim().isEmpty ? null : authorController.text.trim(),
      fileType: fileType!,
    );

    if (ok) return UploadResult.success();
    return UploadResult.failure(provider.errorMessage ?? 'Upload failed.');
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    super.dispose();
  }
}

class UploadResult {
  final bool success;
  final String? message;

  const UploadResult._(this.success, this.message);

  factory UploadResult.success() => const UploadResult._(true, null);
  factory UploadResult.failure(String message) => UploadResult._(false, message);
}
