import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_library/models/ebook.dart';
import 'package:ebook_library/widgets/ebook_card.dart';

Ebook _sampleEbook({String title = 'Clean Code', String? author = 'Robert Martin'}) {
  return Ebook(
    id: 1,
    title: title,
    author: author,
    fileType: 'pdf',
    fileSize: 204800,
    filename: 'clean_code.pdf',
    uploadDate: DateTime(2026, 1, 1),
    coverImageUrl: null,
    downloadUrl: 'http://localhost:3000/api/ebooks/1/download',
  );
}

void main() {
  testWidgets('EbookCard renders title and author', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 220,
          child: EbookCard(
            ebook: _sampleEbook(),
            onTap: () {},
            onDelete: () {},
            onDownload: () {},
          ),
        ),
      ),
    ));

    expect(find.text('Clean Code'), findsWidgets);
    expect(find.text('Robert Martin'), findsOneWidget);
  });

  testWidgets('EbookCard omits author when author is null', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 220,
          child: EbookCard(
            ebook: _sampleEbook(author: null),
            onTap: () {},
            onDelete: () {},
            onDownload: () {},
          ),
        ),
      ),
    ));

    expect(find.text('Clean Code'), findsWidgets);
    expect(find.text('Robert Martin'), findsNothing);
  });

  testWidgets('tapping the card triggers onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 220,
          child: EbookCard(
            ebook: _sampleEbook(),
            onTap: () => tapped = true,
            onDelete: () {},
            onDownload: () {},
          ),
        ),
      ),
    ));

    await tester.tap(find.byType(EbookCard));
    expect(tapped, isTrue);
  });

  testWidgets('long-press shows Read/Download/Delete actions', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 220,
          child: EbookCard(
            ebook: _sampleEbook(),
            onTap: () {},
            onDelete: () {},
            onDownload: () {},
          ),
        ),
      ),
    ));

    await tester.longPress(find.byType(EbookCard));
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
