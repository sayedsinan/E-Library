import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ebook_provider.dart';
import 'screens/library_screen.dart';

void main() {
  runApp(const EbookLibraryApp());
}

class EbookLibraryApp extends StatelessWidget {
  const EbookLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EbookProvider(),
      child: MaterialApp(
        title: 'Ebook Library',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF5D4037),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        ),
        home: const LibraryScreen(),
      ),
    );
  }
}
