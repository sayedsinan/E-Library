import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/ebook_utils.dart';
import '../models/ebook.dart';
import 'common/highlighted_text.dart';
import 'ebook/ebook_actions_sheet.dart';

/// A single book cover on the bookshelf. Tap to open, long-press for actions.
class EbookCard extends StatelessWidget {
  final Ebook ebook;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDownload;
  /// When non-empty, title and author text will highlight matching substrings.
  final String searchQuery;

  const EbookCard({
    super.key,
    required this.ebook,
    required this.onTap,
    required this.onDelete,
    required this.onDownload,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final spineColor = EbookUtils.spineColorFor(ebook.title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => EbookActionsSheet.show(
          context,
          title: ebook.title,
          onRead: onTap,
          onDownload: onDownload,
          onDelete: onDelete,
        ),
        borderRadius: BorderRadius.circular(10),
        child: Semantics(
          label: 'Ebook: ${ebook.title}${ebook.author != null ? " by ${ebook.author}" : ""}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: spineColor.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _CoverImage(ebook: ebook, spineColor: spineColor),
                        const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.cardGradient)),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _FileTypeBadge(type: ebook.fileType),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 4,
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HighlightedText(
                                text: ebook.title,
                                highlight: searchQuery,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 1.2,
                                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                                ),
                              ),
                              if (ebook.author != null) ...[
                                const SizedBox(height: 2),
                                HighlightedText(
                                  text: ebook.author!,
                                  highlight: searchQuery,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 10,
                                    shadows: const [Shadow(color: Colors.black45, blurRadius: 3)],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ebook.readableFileSize,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final Ebook ebook;
  final Color spineColor;

  const _CoverImage({required this.ebook, required this.spineColor});

  @override
  Widget build(BuildContext context) {
    if (ebook.coverImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: ebook.coverImageUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _PlaceholderCover(ebook: ebook, color: spineColor),
      );
    }
    return _PlaceholderCover(ebook: ebook, color: spineColor);
  }
}

class _PlaceholderCover extends StatelessWidget {
  final Ebook ebook;
  final Color color;

  const _PlaceholderCover({required this.ebook, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ebook.fileType.toLowerCase() == 'pdf'
                    ? Icons.picture_as_pdf_rounded
                    : Icons.menu_book_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                ebook.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileTypeBadge extends StatelessWidget {
  final String type;

  const _FileTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
