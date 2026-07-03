import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_library/app.dart';

void main() {
  testWidgets('App loads library screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EbookLibraryApp());
    await tester.pump();

    expect(find.text('My Library'), findsOneWidget);
    expect(find.text('Add Book'), findsOneWidget);
  });
}
