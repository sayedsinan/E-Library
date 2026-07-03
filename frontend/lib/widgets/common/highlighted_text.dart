import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Renders [text] with every occurrence of [highlight] visually highlighted.
/// Falls back to a plain Text widget when [highlight] is empty.
class HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;

    if (highlight.trim().isEmpty) {
      return Text(text, style: base, maxLines: maxLines, overflow: overflow);
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = highlight.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: base));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: base));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + lowerQuery.length),
          style: base.copyWith(
            backgroundColor: AppColors.accent.withValues(alpha: 0.35),
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = idx + lowerQuery.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
