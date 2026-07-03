class Ebook {
  final int id;
  final String title;
  final String? author;
  final String fileType;
  final int fileSize;
  final String? filename;
  final DateTime uploadDate;
  final String? coverImageUrl;
  final String downloadUrl;

  Ebook({
    required this.id,
    required this.title,
    this.author,
    required this.fileType,
    required this.fileSize,
    this.filename,
    required this.uploadDate,
    this.coverImageUrl,
    required this.downloadUrl,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String?,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      filename: json['filename'] as String?,
      uploadDate: DateTime.parse(json['upload_date'] as String),
      coverImageUrl: json['cover_image_url'] as String?,
      downloadUrl: json['download_url'] as String,
    );
  }

  String get readableFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
