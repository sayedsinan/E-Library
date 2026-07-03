import 'package:flutter/material.dart';
import '../models/ebook.dart';
import 'ebook_card.dart';

/// Lays ebooks out in rows of a fixed count, each row sitting on a
/// wooden-shelf strip — classic iOS-ebook-library look.
class EbookShelf extends StatelessWidget {
  final List<Ebook> ebooks;
  final void Function(Ebook) onOpen;
  final void Function(Ebook) onDelete;
  final void Function(Ebook) onDownload;

  const EbookShelf({
    super.key,
    required this.ebooks,
    required this.onOpen,
    required this.onDelete,
    required this.onDownload,
  });

  static const int _perRow = 3;

  @override
  Widget build(BuildContext context) {
    final rows = <List<Ebook>>[];
    for (var i = 0; i < ebooks.length; i += _perRow) {
      rows.add(ebooks.sublist(i, (i + _perRow).clamp(0, ebooks.length)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 170,
                child: Row(
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
                          ),
                        ),
                      ),
                    // fill any incomplete row so shelf width stays consistent
                    for (var i = row.length; i < _perRow; i++) const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              // the wooden shelf strip
              Container(
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 3)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
