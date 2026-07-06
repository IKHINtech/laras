class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.streamUrl,
    this.durationMs = 0,
    this.artworkId,
    this.folderPath = '',
    this.filePath = '',
    this.isLocal = false,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String streamUrl;
  final int durationMs;
  final int? artworkId;
  final String folderPath;
  final String filePath;
  final bool isLocal;

  String get artistLabel => artist.isEmpty ? 'Unknown Artist' : artist;
  String get albumLabel => album.isEmpty ? 'Unknown Album' : album;

  String get folderLabel {
    if (folderPath.isEmpty) return 'Unknown Folder';
    final normalized = folderPath.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isEmpty ? folderPath : parts.last;
  }

  factory Song.fromJson(Map<String, dynamic> json, String baseUrl) {
    final id = json['id'] as String;
    return Song(
      id: id,
      title: (json['title'] ?? 'Unknown Title') as String,
      artist: (json['artist'] ?? 'Unknown Artist') as String,
      album: (json['album'] ?? '') as String,
      durationMs: (json['duration_ms'] ?? 0) as int,
      streamUrl: '$baseUrl/api/v1/songs/$id/stream',
    );
  }

  factory Song.fromLocalJson(Map<String, dynamic> json) => Song(
        id: json['id'] as String,
        title: (json['title'] ?? 'Unknown Title') as String,
        artist: (json['artist'] ?? '') as String,
        album: (json['album'] ?? '') as String,
        streamUrl: (json['stream_url'] ?? '') as String,
        durationMs: (json['duration_ms'] ?? 0) as int,
        artworkId: json['artwork_id'] as int?,
        folderPath: (json['folder_path'] ?? '') as String,
        filePath: (json['file_path'] ?? '') as String,
        isLocal: (json['is_local'] ?? true) as bool,
      );

  Map<String, dynamic> toLocalJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'stream_url': streamUrl,
        'duration_ms': durationMs,
        'artwork_id': artworkId,
        'folder_path': folderPath,
        'file_path': filePath,
        'is_local': isLocal,
      };
}
