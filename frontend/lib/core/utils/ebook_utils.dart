import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

abstract final class EbookUtils {
  static Color spineColorFor(String title) =>
      AppColors.spineColors[title.hashCode.abs() % AppColors.spineColors.length];

  static String fileNameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  static String titleFromFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }
}
