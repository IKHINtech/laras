import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/local_database.dart';
import 'song.dart';

class LocalMusicStore {
  static const _favoriteKey = 'laras.local.favorite_song_ids';
  static const _playlistKey = 'laras.local.playlists';
  static const _libraryKey = 'laras.local.library_cache';
  static const _migrationKey = 'laras.local.sqlite_migrated_v1';

  Future<Database> get _db async {
    final db = await LocalDatabase.instance.database;
    await _migrateLegacyPrefsIfNeeded(db);
    return db;
  }

  Future<void> _migrateLegacyPrefsIfNeeded(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(_migrationKey) ?? false;
    if (migrated) return;

    final existingSongs = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM local_songs'),
        ) ??
        0;
    final existingPlaylists = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM local_playlists'),
        ) ??
        0;
    final existingFavorites = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM local_favorites'),
        ) ??
        0;

    if (existingSongs > 0 || existingPlaylists > 0 || existingFavorites > 0) {
      await prefs.setBool(_migrationKey, true);
      return;
    }

    final batch = db.batch();

    final rawLibrary = prefs.getString(_libraryKey);
    if (rawLibrary != null && rawLibrary.isNotEmpty) {
      final source = jsonDecode(rawLibrary) as List<dynamic>;
      for (final item in source) {
        final song = Song.fromLocalJson(item as Map<String, dynamic>);
        batch.insert('local_songs', _songRow(song));
      }
    }

    final favoriteIds = prefs.getStringList(_favoriteKey) ?? const <String>[];
    for (final songId in favoriteIds) {
      batch.insert(
        'local_favorites',
        {'song_id': songId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final rawPlaylists = prefs.getString(_playlistKey);
    if (rawPlaylists != null && rawPlaylists.isNotEmpty) {
      final source = jsonDecode(rawPlaylists) as List<dynamic>;
      for (final item in source) {
        final playlist = LocalPlaylist.fromJson(item as Map<String, dynamic>);
        batch.insert(
          'local_playlists',
          {'id': playlist.id, 'name': playlist.name},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        for (var i = 0; i < playlist.songIds.length; i++) {
          batch.insert(
            'local_playlist_songs',
            {
              'playlist_id': playlist.id,
              'song_id': playlist.songIds[i],
              'position': i,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }

    await batch.commit(noResult: true);
    await prefs.setBool(_migrationKey, true);
  }

  Future<Set<String>> loadFavorites() async {
    final db = await _db;
    final rows = await db.query('local_favorites', orderBy: 'song_id ASC');
    return rows.map((row) => row['song_id'] as String).toSet();
  }

  Future<void> saveFavorites(Set<String> ids) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('local_favorites');
      final batch = txn.batch();
      final sorted = ids.toList()..sort();
      for (final songId in sorted) {
        batch.insert('local_favorites', {'song_id': songId});
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<LocalPlaylist>> loadPlaylists() async {
    final db = await _db;
    final playlists =
        await db.query('local_playlists', orderBy: 'name COLLATE NOCASE ASC');
    final items = await db.query(
      'local_playlist_songs',
      orderBy: 'playlist_id ASC, position ASC',
    );

    final songIdsByPlaylist = <String, List<String>>{};
    for (final item in items) {
      final playlistId = item['playlist_id'] as String;
      final songId = item['song_id'] as String;
      songIdsByPlaylist.putIfAbsent(playlistId, () => <String>[]).add(songId);
    }

    return playlists
        .map(
          (row) => LocalPlaylist(
            id: row['id'] as String,
            name: row['name'] as String,
            songIds: songIdsByPlaylist[row['id'] as String] ?? const <String>[],
          ),
        )
        .toList();
  }

  Future<void> savePlaylists(List<LocalPlaylist> playlists) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('local_playlist_songs');
      await txn.delete('local_playlists');

      final batch = txn.batch();
      for (final playlist in playlists) {
        batch.insert(
            'local_playlists', {'id': playlist.id, 'name': playlist.name});
        for (var i = 0; i < playlist.songIds.length; i++) {
          batch.insert('local_playlist_songs', {
            'playlist_id': playlist.id,
            'song_id': playlist.songIds[i],
            'position': i,
          });
        }
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> toggleFavorite(String songId) async {
    final db = await _db;
    final rows = await db.query(
      'local_favorites',
      where: 'song_id = ?',
      whereArgs: [songId],
      limit: 1,
    );
    if (rows.isEmpty) {
      await db.insert(
        'local_favorites',
        {'song_id': songId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }
    await db.delete(
      'local_favorites',
      where: 'song_id = ?',
      whereArgs: [songId],
    );
  }

  Future<void> createPlaylist(String name) async {
    final db = await _db;
    final playlist = LocalPlaylist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Untitled Playlist' : name.trim(),
      songIds: const [],
    );
    await db.insert(
      'local_playlists',
      {'id': playlist.id, 'name': playlist.name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final db = await _db;
    final existing = await db.query(
      'local_playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final nextPosition = (Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT COALESCE(MAX(position), -1) + 1 FROM local_playlist_songs WHERE playlist_id = ?',
                [playlistId],
              ),
            ) ??
            0)
        .toInt();

    await db.insert(
      'local_playlist_songs',
      {
        'playlist_id': playlistId,
        'song_id': songId,
        'position': nextPosition,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final db = await _db;
    await db.delete(
      'local_playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
    await _normalizePlaylistPositions(db, playlistId);
  }

  Future<void> deletePlaylist(String playlistId) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'local_playlist_songs',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
      );
      await txn.delete(
        'local_playlists',
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    });
  }

  Future<List<Song>> loadLibrary() async {
    final db = await _db;
    final rows =
        await db.query('local_songs', orderBy: 'title COLLATE NOCASE ASC');
    return rows.map(_songFromRow).toList();
  }

  Future<void> saveLibrary(List<Song> songs) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('local_songs');
      final batch = txn.batch();
      for (final song in songs) {
        batch.insert('local_songs', _songRow(song));
      }
      await batch.commit(noResult: true);
    });
  }

  Future<DateTime?> loadSleepTimerEnd() async {
    final db = await _db;
    final rows = await db.query(
      'local_sleep_timer',
      where: 'id = 1 AND is_active = 1',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['ends_at_epoch_ms'] as int?;
    if (raw == null || raw <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  Future<void> saveSleepTimerEnd(DateTime? endTime) async {
    final db = await _db;
    await db.insert(
      'local_sleep_timer',
      {
        'id': 1,
        'ends_at_epoch_ms': endTime?.millisecondsSinceEpoch,
        'is_active': endTime == null ? 0 : 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> loadLyricsPath(String songId) async {
    final db = await _db;
    final rows = await db.query(
      'local_lyrics_index',
      columns: ['lrc_path'],
      where: 'song_id = ?',
      whereArgs: [songId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['lrc_path'] as String;
  }

  Future<void> saveLyricsPath(String songId, String path) async {
    final db = await _db;
    await db.insert(
      'local_lyrics_index',
      {
        'song_id': songId,
        'lrc_path': path,
        'updated_at_epoch_ms': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> savePlaybackSnapshot({
    required String songId,
    required int positionMs,
    required bool incrementPlayCount,
  }) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await db.query(
      'local_playback_history',
      where: 'song_id = ?',
      whereArgs: [songId],
      limit: 1,
    );

    final previous = existing.isEmpty ? null : existing.first;
    final playCount =
        (previous?['play_count'] as int? ?? 0) + (incrementPlayCount ? 1 : 0);

    await db.insert(
      'local_playback_history',
      {
        'song_id': songId,
        'last_position_ms': positionMs,
        'played_at_epoch_ms': now,
        'play_count': playCount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PlaybackHistory?> loadPlaybackHistory(String songId) async {
    final db = await _db;
    final rows = await db.query(
      'local_playback_history',
      where: 'song_id = ?',
      whereArgs: [songId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return PlaybackHistory(
      songId: row['song_id'] as String,
      lastPositionMs: row['last_position_ms'] as int? ?? 0,
      playedAt: DateTime.fromMillisecondsSinceEpoch(
        row['played_at_epoch_ms'] as int? ?? 0,
      ),
      playCount: row['play_count'] as int? ?? 0,
    );
  }

  Future<List<PlaybackHistory>> loadRecentPlaybackHistory(
      {int limit = 20}) async {
    final db = await _db;
    final rows = await db.query(
      'local_playback_history',
      orderBy: 'played_at_epoch_ms DESC',
      limit: limit,
    );
    return rows
        .map(
          (row) => PlaybackHistory(
            songId: row['song_id'] as String,
            lastPositionMs: row['last_position_ms'] as int? ?? 0,
            playedAt: DateTime.fromMillisecondsSinceEpoch(
              row['played_at_epoch_ms'] as int? ?? 0,
            ),
            playCount: row['play_count'] as int? ?? 0,
          ),
        )
        .toList();
  }

  Future<void> reorderPlaylistSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final playlists = await loadPlaylists();
    final targetIndex = playlists.indexWhere((e) => e.id == playlistId);
    if (targetIndex < 0) return;

    final playlist = playlists[targetIndex];
    final ids = [...playlist.songIds];
    if (oldIndex < 0 || oldIndex >= ids.length) return;
    if (newIndex < 0 || newIndex > ids.length) return;

    final adjustedIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    final item = ids.removeAt(oldIndex);
    ids.insert(adjustedIndex, item);
    playlists[targetIndex] = playlist.copyWith(songIds: ids);
    await savePlaylists(playlists);
  }

  Future<void> _normalizePlaylistPositions(
      Database db, String playlistId) async {
    final rows = await db.query(
      'local_playlist_songs',
      columns: ['song_id'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'position ASC',
    );
    final batch = db.batch();
    for (var i = 0; i < rows.length; i++) {
      batch.update(
        'local_playlist_songs',
        {'position': i},
        where: 'playlist_id = ? AND song_id = ?',
        whereArgs: [playlistId, rows[i]['song_id']],
      );
    }
    await batch.commit(noResult: true);
  }

  Map<String, Object?> _songRow(Song song) => {
        'id': song.id,
        'title': song.title,
        'artist': song.artist,
        'album': song.album,
        'stream_url': song.streamUrl,
        'duration_ms': song.durationMs,
        'artwork_id': song.artworkId,
        'folder_path': song.folderPath,
        'file_path': song.filePath,
        'is_local': song.isLocal ? 1 : 0,
      };

  Song _songFromRow(Map<String, Object?> row) => Song(
        id: row['id'] as String,
        title: row['title'] as String,
        artist: row['artist'] as String,
        album: row['album'] as String,
        streamUrl: row['stream_url'] as String,
        durationMs: row['duration_ms'] as int? ?? 0,
        artworkId: row['artwork_id'] as int?,
        folderPath: row['folder_path'] as String? ?? '',
        filePath: row['file_path'] as String? ?? '',
        isLocal: (row['is_local'] as int? ?? 1) == 1,
      );
}

class LocalPlaylist {
  const LocalPlaylist({
    required this.id,
    required this.name,
    required this.songIds,
  });

  final String id;
  final String name;
  final List<String> songIds;

  LocalPlaylist copyWith({String? id, String? name, List<String>? songIds}) {
    return LocalPlaylist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
    );
  }

  factory LocalPlaylist.fromJson(Map<String, dynamic> json) => LocalPlaylist(
        id: json['id'] as String,
        name: json['name'] as String,
        songIds: (json['song_ids'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'song_ids': songIds,
      };
}

class PlaybackHistory {
  const PlaybackHistory({
    required this.songId,
    required this.lastPositionMs,
    required this.playedAt,
    required this.playCount,
  });

  final String songId;
  final int lastPositionMs;
  final DateTime playedAt;
  final int playCount;
}
