import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF7F2EA);
  static const surface = Color(0xFFFFFCF7);
  static const primary = Color(0xFF6B4F3A);
  static const primaryDark = Color(0xFF4A3426);
  static const accent = Color(0xFFC8956C);
  static const accentLight = Color(0xFFE8C4A8);

  static const shelfWoodTop = Color(0xFF9A7B6A);
  static const shelfWoodBottom = Color(0xFF5D4037);

  static const textPrimary = Color(0xFF2C2419);
  static const textSecondary = Color(0xFF6B5D52);
  static const textMuted = Color(0xFF9E8F82);

  static const error = Color(0xFFC62828);
  static const success = Color(0xFF2E7D32);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5D4037), Color(0xFF8D6E63), Color(0xFF6B4F3A)],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00FFFFFF), Color(0xCC000000)],
  );

  static const spineColors = [
    Color(0xFF6D4C41),
    Color(0xFF37474F),
    Color(0xFF4E342E),
    Color(0xFF33691E),
    Color(0xFF4A148C),
    Color(0xFF01579B),
    Color(0xFFBF360C),
    Color(0xFF00695C),
  ];
}
