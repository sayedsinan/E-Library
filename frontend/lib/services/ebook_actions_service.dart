import 'package:url_launcher/url_launcher.dart';
import '../models/ebook.dart';
import 'api_service.dart';

class EbookActionsService {
  final ApiService _api;

  EbookActionsService({ApiService? api}) : _api = api ?? ApiService();

  Future<bool> download(Ebook ebook) async {
    final url = Uri.parse(_api.downloadUrlFor(ebook));
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
