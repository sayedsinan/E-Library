import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/ebook.dart';
import 'ebook_card.dart';

/// Lays ebooks in rows on wooden shelf strips — classic library look.
class EbookShelf extends StatelessWidget {
  final List<Ebook> ebooks;
  final void Function(Ebook) onOpen;
  final void Function(Ebook) onDelete;
  final void Function(Ebook) onDownload;
  final String searchQuery;

  const EbookShelf({
    super.key,
    required this.ebooks,
    required this.onOpen,
    required this.onDelete,
    required this.onDownload,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<Ebook>>[];
    for (var i = 0; i < ebooks.length; i += AppConstants.booksPerShelfRow) {
      rows.add(ebooks.sublist(i, (i + AppConstants.booksPerShelfRow).clamp(0, ebooks.length)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              SizedBox(
                height: AppConstants.bookCoverHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final ebook in row)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: EbookCard(
                            ebook: ebook,
                            onTap: () => onOpen(ebook),
                            onDelete: () => onDelete(ebook),
                            onDownload: () => onDownload(ebook),
                            searchQuery: searchQuery,
                          ),
                        ),
                      ),
                    for (var i = row.length; i < AppConstants.booksPerShelfRow; i++)
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              _ShelfPlank(),
            ],
          ),
        );
      },
    );
  }
}

class _ShelfPlank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.shelfWoodTop, AppColors.shelfWoodBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: AppColors.shelfWoodBottom.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1),
          ),
        ),
      ),
    );
  }
}
