import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/upload_controller.dart';
import '../core/theme/app_colors.dart';
import '../providers/ebook_provider.dart';
import '../widgets/common/app_snackbar.dart';
import '../widgets/upload/file_picker_zone.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late final UploadController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = UploadController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EbookProvider>();
    final result = await _controller.submit(provider);

    if (!mounted) return;
    if (result.success) {
      Navigator.pop(context, true);
    } else {
      showAppSnackBar(context, result.message!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploading = context.watch<EbookProvider>().uploading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Book'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: uploading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Upload an ebook',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add a PDF or EPUB to your personal library.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    FilePickerZone(
                      fileName: _controller.fileName,
                      error: _controller.pickError,
                      onPick: _controller.pickFile,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _controller.titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: _controller.validateTitle,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controller.authorController,
                      decoration: const InputDecoration(
                        labelText: 'Author (optional)',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: uploading ? null : _submit,
                      child: uploading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('Upload to Library'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (uploading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Uploading your book…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
