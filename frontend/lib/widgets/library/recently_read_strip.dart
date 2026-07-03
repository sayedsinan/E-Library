import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/ebook_utils.dart';
import '../../models/ebook.dart';

/// A horizontal strip showing the last few opened books.
class RecentlyReadStrip extends StatelessWidget {
  final List<Ebook> ebooks;
  final void Function(Ebook) onOpen;

  const RecentlyReadStrip({
    super.key,
    required this.ebooks,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (ebooks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              const Text(
                'Recently Read',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ebooks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final ebook = ebooks[index];
                return _RecentBookTile(ebook: ebook, onTap: () => onOpen(ebook));
              },
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.accentLight.withValues(alpha: 0.6), height: 1),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RecentBookTile extends StatelessWidget {
  final Ebook ebook;
  final VoidCallback onTap;

  const _RecentBookTile({required this.ebook, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final spineColor = EbookUtils.spineColorFor(ebook.title);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: ebook.coverImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: ebook.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _MiniPlaceholder(color: spineColor, title: ebook.title),
                      )
                    : _MiniPlaceholder(color: spineColor, title: ebook.title),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ebook.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlaceholder extends StatelessWidget {
  final Color color;
  final String title;

  const _MiniPlaceholder({required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: 18,
        ),
      ),
    );
  }
}
