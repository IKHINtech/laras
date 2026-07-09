import 'dart:io';
import 'package:dio/dio.dart';
import 'auth_store.dart';
import '../features/library/local_music_store.dart';
import '../features/library/song.dart';

class ApiClient {
  ApiClient({required this.baseUrl, required this.authStore}) {
    dio = Dio(BaseOptions(baseUrl: '$baseUrl/api/v1'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = authStore.token;
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final String baseUrl;
  final AuthStore authStore;
  late final Dio dio;

  Future<String> login(String email, String password) async {
    final res = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return res.data['token'] as String;
  }

  Future<String> register(String name, String email, String password) async {
    final res = await dio.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return res.data['token'] as String;
  }

  Future<List<Song>> songs({String? q}) async {
    final res = await dio.get(
      '/songs',
      queryParameters: q == null || q.isEmpty ? null : {'q': q},
    );
    return (res.data['data'] as List)
        .map((e) => Song.fromJson(e as Map<String, dynamic>, baseUrl))
        .toList();
  }

  Future<List<RecentPlaybackEntry>> recentPlayedSongs({int limit = 20}) async {
    final res = await dio.get(
      '/songs/recent-played',
      queryParameters: {'limit': limit},
    );
    return _playbackEntriesFromResponse(res.data as Map<String, dynamic>);
  }

  Future<List<RecentPlaybackEntry>> mostPlayedSongs({int limit = 20}) async {
    final res = await dio.get(
      '/songs/most-played',
      queryParameters: {'limit': limit},
    );
    return _playbackEntriesFromResponse(res.data as Map<String, dynamic>);
  }

  Future<Song> uploadSong(
    File file, {
    String? title,
    String? artist,
    String? album,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
    });
    final res = await dio.post('/songs/upload', data: form);
    return Song.fromJson(res.data as Map<String, dynamic>, baseUrl);
  }

  Future<void> toggleFavorite(String songId) =>
      dio.post('/favorites/$songId/toggle');
  Future<Map<String, dynamic>> stats() async =>
      (await dio.get('/stats')).data as Map<String, dynamic>;

  List<RecentPlaybackEntry> _playbackEntriesFromResponse(
    Map<String, dynamic> data,
  ) {
    final rows = (data['data'] as List<dynamic>? ?? const []);
    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      final songJson = row['song'] as Map<String, dynamic>? ?? const {};
      final song = Song.fromJson(songJson, baseUrl);
      final playedAtRaw = row['played_at'] as String? ?? '';
      final playedAt = DateTime.tryParse(playedAtRaw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final playCount = (row['play_count'] as num?)?.toInt() ?? 0;
      return RecentPlaybackEntry(
        song: song,
        history: PlaybackHistory(
          songId: song.id,
          lastPositionMs: 0,
          playedAt: playedAt,
          playCount: playCount,
        ),
      );
    }).toList();
  }
}
