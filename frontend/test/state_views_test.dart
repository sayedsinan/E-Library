import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_library/widgets/state_views.dart';

void main() {
  testWidgets('EmptyShelfView shows default message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EmptyShelfView()));
    expect(find.textContaining('Your shelf is empty'), findsOneWidget);
  });

  testWidgets('EmptyShelfView shows custom search-empty message', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: EmptyShelfView(message: 'No ebooks match your search.'),
    ));
    expect(find.text('No ebooks match your search.'), findsOneWidget);
  });

  testWidgets('LoadingView shows a spinner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoadingView()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ErrorView shows message and retry button, retry fires callback', (tester) async {
    var retried = false;
    await tester.pumpWidget(MaterialApp(
      home: ErrorView(message: 'Network error', onRetry: () => retried = true),
    ));

    expect(find.text('Network error'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
