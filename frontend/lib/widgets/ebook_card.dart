import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/ebook.dart';

/// A single spine/cover on the bookshelf. Tap to open, long-press to see actions.
class EbookCard extends StatelessWidget {
  final Ebook ebook;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDownload;

  const EbookCard({
    super.key,
    required this.ebook,
    required this.onTap,
    required this.onDelete,
    required this.onDownload,
  });

  static const _spineColors = [
    Color(0xFF6D4C41),
    Color(0xFF37474F),
    Color(0xFF4E342E),
    Color(0xFF33691E),
    Color(0xFF4A148C),
    Color(0xFF01579B),
  ];

  Color _colorFor(String title) => _spineColors[title.hashCode.abs() % _spineColors.length];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showActions(context),
      child: Semantics(
        label: 'Ebook: ${ebook.title}${ebook.author != null ? " by ${ebook.author}" : ""}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _colorFor(ebook.title),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 3)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: ebook.coverImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: ebook.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholderCover(),
                      )
                    : _placeholderCover(),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ebook.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            if (ebook.author != null)
              Text(
                ebook.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderCover() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          ebook.title,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Read'),
              onTap: () {
                Navigator.pop(ctx);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(ctx);
                onDownload();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
