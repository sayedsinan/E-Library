import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FilePickerZone extends StatelessWidget {
  final String? fileName;
  final String? error;
  final VoidCallback onPick;

  const FilePickerZone({
    super.key,
    this.fileName,
    this.error,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: hasFile
              ? AppColors.success.withValues(alpha: 0.08)
              : AppColors.accentLight.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasFile ? AppColors.success.withValues(alpha: 0.4) : AppColors.accent,
                  width: hasFile ? 1.5 : 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    hasFile ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                    size: 48,
                    color: hasFile ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasFile ? fileName! : 'Tap to choose a file',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: hasFile ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasFile ? 'Tap to change file' : 'PDF or EPUB · max 100MB',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 4),
            child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
      ],
    );
  }
}
