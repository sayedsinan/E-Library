import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ebook.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  // Android emulator -> host machine is 10.0.2.2. iOS simulator / desktop -> localhost.
  // Override at run time with --dart-define=API_BASE_URL=http://your-host:3000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  Future<List<Ebook>> fetchEbooks() async {
    final res = await _get('$baseUrl/ebooks');
    final List data = jsonDecode(res.body);
    return data.map((e) => Ebook.fromJson(e)).toList();
  }

  Future<List<Ebook>> search(String query) async {
    final uri = Uri.parse('$baseUrl/ebooks/search').replace(queryParameters: {'q': query});
    final res = await _getUri(uri);
    final List data = jsonDecode(res.body);
    return data.map((e) => Ebook.fromJson(e)).toList();
  }

  Future<Ebook> uploadEbook({
    required File file,
    required String title,
    String? author,
    required String fileType,
  }) async {
    final uri = Uri.parse('$baseUrl/ebooks');
    final request = http.MultipartRequest('POST', uri)
      ..fields['ebook[title]'] = title
      ..fields['ebook[file_type]'] = fileType;

    if (author != null && author.isNotEmpty) {
      request.fields['ebook[author]'] = author;
    }
    request.files.add(await http.MultipartFile.fromPath('ebook[file]', file.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 201) {
      return Ebook.fromJson(jsonDecode(res.body));
    }
    throw ApiException(_extractError(res));
  }

  Future<void> deleteEbook(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/ebooks/$id'));
    if (res.statusCode != 204) {
      throw ApiException(_extractError(res));
    }
  }

  String downloadUrlFor(Ebook ebook) => ebook.downloadUrl;

  Future<http.Response> _get(String url) => _getUri(Uri.parse(url));

  Future<http.Response> _getUri(Uri uri) async {
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode >= 200 && res.statusCode < 300) return res;
      throw ApiException(_extractError(res));
    } on SocketException {
      throw ApiException('Cannot reach server. Check your connection and try again.');
    } on http.ClientException {
      throw ApiException('Network error. Please try again.');
    }
  }

  String _extractError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['errors'] != null) {
        return (body['errors'] as List).join(', ');
      }
      if (body is Map && body['error'] != null) {
        return body['error'].toString();
      }
    } catch (_) {
      // fall through
    }
    return 'Request failed (${res.statusCode})';
  }
}
