import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_library/models/ebook.dart';
import 'package:ebook_library/providers/ebook_provider.dart';
import 'package:ebook_library/services/api_service.dart';

class FakeApiService implements ApiService {
  List<Ebook> books;
  bool failNext = false;

  FakeApiService(this.books);

  @override
  Future<List<Ebook>> fetchEbooks() async {
    if (failNext) throw ApiException('Cannot reach server.');
    return books;
  }

  @override
  Future<List<Ebook>> search(String query) async {
    if (failNext) throw ApiException('Search failed.');
    return books.where((b) => b.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<Ebook> uploadEbook({
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    required String title,
    String? author,
    required String fileType,
  }) async {
    if (failNext) throw ApiException('Upload failed.');
    final ebook = Ebook(
      id: books.length + 1,
      title: title,
      author: author,
      fileType: fileType,
      fileSize: 1000,
      filename: 'file.$fileType',
      uploadDate: DateTime.now(),
      downloadUrl: 'http://x/download',
    );
    books = [ebook, ...books];
    return ebook;
  }

  @override
  Future<void> deleteEbook(int id) async {
    if (failNext) throw ApiException('Delete failed.');
    books = books.where((b) => b.id != id).toList();
  }

  @override
  String downloadUrlFor(Ebook ebook) => ebook.downloadUrl;
}

Ebook _book(int id, String title) => Ebook(
      id: id,
      title: title,
      author: 'Author $id',
      fileType: 'pdf',
      fileSize: 1000,
      filename: '$title.pdf',
      uploadDate: DateTime(2026, 1, 1),
      downloadUrl: 'http://x/$id/download',
    );

void main() {
  group('EbookProvider', () {
    test('loadEbooks populates list and sets status loaded', () async {
      final fake = FakeApiService([_book(1, 'Rails Guide')]);
      final provider = EbookProvider(api: fake);

      await provider.loadEbooks();

      expect(provider.status, LoadStatus.loaded);
      expect(provider.ebooks.length, 1);
    });

    test('loadEbooks sets status error on failure', () async {
      final fake = FakeApiService([])..failNext = true;
      final provider = EbookProvider(api: fake);

      await provider.loadEbooks();

      expect(provider.status, LoadStatus.error);
      expect(provider.errorMessage, isNotNull);
    });

    test('search filters results by query', () async {
      final fake = FakeApiService([_book(1, 'Rails Guide'), _book(2, 'Flutter Basics')]);
      final provider = EbookProvider(api: fake);

      await provider.search('rails');

      expect(provider.ebooks.length, 1);
      expect(provider.ebooks.first.title, 'Rails Guide');
    });

    test('search with empty query reloads full list', () async {
      final fake = FakeApiService([_book(1, 'A'), _book(2, 'B')]);
      final provider = EbookProvider(api: fake);

      await provider.search('');

      expect(provider.ebooks.length, 2);
    });

    test('delete removes ebook optimistically and stays removed on success', () async {
      final fake = FakeApiService([_book(1, 'A'), _book(2, 'B')]);
      final provider = EbookProvider(api: fake);
      await provider.loadEbooks();

      final ok = await provider.delete(1);

      expect(ok, isTrue);
      expect(provider.ebooks.any((b) => b.id == 1), isFalse);
    });

    test('delete rolls back list when the API call fails', () async {
      final fake = FakeApiService([_book(1, 'A'), _book(2, 'B')]);
      final provider = EbookProvider(api: fake);
      await provider.loadEbooks();

      fake.failNext = true;
      final ok = await provider.delete(1);

      expect(ok, isFalse);
      expect(provider.ebooks.any((b) => b.id == 1), isTrue); // rolled back
    });

    test('upload prepends new ebook on success', () async {
      final fake = FakeApiService([_book(1, 'Existing')]);
      final provider = EbookProvider(api: fake);
      await provider.loadEbooks();

      final ok = await provider.upload(
        file: File('dummy.pdf'),
        title: 'New Book',
        fileType: 'pdf',
      );

      expect(ok, isTrue);
      expect(provider.ebooks.first.title, 'New Book');
      expect(provider.uploading, isFalse);
    });
  });
}
