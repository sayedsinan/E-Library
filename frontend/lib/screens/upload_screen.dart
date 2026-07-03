import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ebook_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();

  File? _pickedFile;
  String? _fileType; // 'pdf' | 'epub'
  String? _pickError;

  static const _maxBytes = 100 * 1024 * 1024; // matches backend limit

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _pickError = null);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final file = File(path);
    final size = await file.length();
    final ext = path.split('.').last.toLowerCase();

    if (size > _maxBytes) {
      setState(() => _pickError = 'File is too large (max 100MB).');
      return;
    }
    if (ext != 'pdf' && ext != 'epub') {
      setState(() => _pickError = 'Only PDF and EPUB files are supported.');
      return;
    }

    setState(() {
      _pickedFile = file;
      _fileType = ext;
      if (_titleController.text.isEmpty) {
        final name = path.split('/').last.replaceAll('.$ext', '');
        _titleController.text = name;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      setState(() => _pickError = 'Please choose a PDF or EPUB file.');
      return;
    }

    final provider = context.read<EbookProvider>();
    final ok = await provider.upload(
      file: _pickedFile!,
      title: _titleController.text.trim(),
      author: _authorController.text.trim().isEmpty ? null : _authorController.text.trim(),
      fileType: _fileType!,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Upload failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploading = context.watch<EbookProvider>().uploading;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Ebook')),
      body: AbsorbPointer(
        absorbing: uploading,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_pickedFile == null
                      ? 'Choose PDF or EPUB'
                      : _pickedFile!.path.split('/').last),
                ),
                if (_pickError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_pickError!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Author (optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: uploading ? null : _submit,
                  child: uploading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Upload'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
