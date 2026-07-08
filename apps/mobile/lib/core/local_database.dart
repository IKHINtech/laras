import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  static Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      '$dbPath/laras_local.db',
      version: 4,
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS local_app_settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            ALTER TABLE local_lyrics_index
            ADD COLUMN source TEXT NOT NULL DEFAULT 'lrc'
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS local_playback_events (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              song_id TEXT NOT NULL,
              event_type TEXT NOT NULL DEFAULT 'play_start',
              position_ms INTEGER NOT NULL DEFAULT 0,
              played_at_epoch_ms INTEGER NOT NULL DEFAULT 0,
              play_weight INTEGER NOT NULL DEFAULT 1
            )
          ''');
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_playback_events_song_time
            ON local_playback_events(song_id, played_at_epoch_ms DESC)
          ''');
          await db.execute('''
            INSERT INTO local_playback_events (
              song_id,
              event_type,
              position_ms,
              played_at_epoch_ms,
              play_weight
            )
            SELECT
              song_id,
              'legacy_import',
              last_position_ms,
              played_at_epoch_ms,
              CASE
                WHEN play_count <= 0 THEN 1
                ELSE play_count
              END
            FROM local_playback_history
            WHERE played_at_epoch_ms > 0
          ''');
        }
      },
    );
    return _db!;
  }

  static Future<void> _createSchema(Database db) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE local_songs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        stream_url TEXT NOT NULL,
        duration_ms INTEGER NOT NULL DEFAULT 0,
        artwork_id INTEGER,
        folder_path TEXT NOT NULL DEFAULT '',
        file_path TEXT NOT NULL DEFAULT '',
        is_local INTEGER NOT NULL DEFAULT 1
      )
    ''');

    batch.execute('''
      CREATE TABLE local_favorites (
        song_id TEXT PRIMARY KEY
      )
    ''');

    batch.execute('''
      CREATE TABLE local_playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE local_playlist_songs (
        playlist_id TEXT NOT NULL,
        song_id TEXT NOT NULL,
        position INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (playlist_id, song_id)
      )
    ''');

    batch.execute('''
      CREATE TABLE local_sleep_timer (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        ends_at_epoch_ms INTEGER,
        is_active INTEGER NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE local_lyrics_index (
        song_id TEXT PRIMARY KEY,
        lrc_path TEXT NOT NULL DEFAULT '',
        source TEXT NOT NULL DEFAULT 'lrc',
        updated_at_epoch_ms INTEGER NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE local_playback_history (
        song_id TEXT PRIMARY KEY,
        last_position_ms INTEGER NOT NULL DEFAULT 0,
        played_at_epoch_ms INTEGER NOT NULL DEFAULT 0,
        play_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE local_playback_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id TEXT NOT NULL,
        event_type TEXT NOT NULL DEFAULT 'play_start',
        position_ms INTEGER NOT NULL DEFAULT 0,
        played_at_epoch_ms INTEGER NOT NULL DEFAULT 0,
        play_weight INTEGER NOT NULL DEFAULT 1
      )
    ''');

    batch.execute('''
      CREATE INDEX idx_playback_events_song_time
      ON local_playback_events(song_id, played_at_epoch_ms DESC)
    ''');

    batch.execute('''
      CREATE TABLE local_app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }
}
