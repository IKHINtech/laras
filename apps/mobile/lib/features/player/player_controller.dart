import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

import '../library/local_music_store.dart';
import '../library/song.dart';
import 'home_widget_sync.dart';

enum TrackPlayMode {
  normal,
  shuffle,
  repeatAll,
  repeatOne;

  String get label {
    switch (this) {
      case TrackPlayMode.normal:
        return 'Normal';
      case TrackPlayMode.shuffle:
        return 'Shuffle';
      case TrackPlayMode.repeatAll:
        return 'Repeat all';
      case TrackPlayMode.repeatOne:
        return 'Repeat one';
    }
  }
}

class PlayerController extends ChangeNotifier {
  PlayerController({required this.store}) {
    _subs.add(
      player.currentIndexStream.listen((value) {
        final next = value ?? 0;
        if (next != currentIndex) {
          currentIndex = next;
          notifyListeners();
        }
        _scheduleWidgetSync();
      }),
    );
    _subs.add(
      player.playerStateStream.listen((_) {
        notifyListeners();
        _scheduleWidgetSync();
      }),
    );
    _subs.add(player.durationStream.listen((_) => notifyListeners()));
    _subs.add(player.positionStream.listen((_) => notifyListeners()));
    _subs.add(
      player.positionStream
          .transform(_positionSampler(const Duration(seconds: 10)))
          .listen((_) => _persistCurrentPlayback()),
    );
    _subs.add(
      player.androidAudioSessionIdStream.listen((value) {
        androidAudioSessionId = value;
        notifyListeners();
      }),
    );
    _subs.add(
      player.sequenceStateStream.listen((state) {
        final nextIndex = state?.currentIndex ?? currentIndex;
        if (queue.isNotEmpty && nextIndex >= 0 && nextIndex < queue.length) {
          if (_lastTrackedSongId != queue[nextIndex].id) {
            _lastTrackedSongId = queue[nextIndex].id;
            unawaited(
              store.savePlaybackSnapshot(
                songId: queue[nextIndex].id,
                positionMs: 0,
                incrementPlayCount: true,
              ),
            );
          }
        }
      }),
    );
    _configureAudioSession();
    _restoreSleepTimer();
    _scheduleWidgetSync();
  }

  final LocalMusicStore store;
  final AudioPlayer player = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final List<StreamSubscription<dynamic>> _subs = [];
  List<Song> queue = [];
  int currentIndex = 0;
  int? androidAudioSessionId;
  DateTime? sleepTimerEndsAt;
  Timer? _sleepTimerTicker;
  Timer? _widgetSyncDebounce;
  String? _lastTrackedSongId;
  String? _lastWidgetSongId;
  bool? _lastWidgetPlaying;
  double _preDuckVolume = 1.0;

  Song? get currentSong => queue.isEmpty ? null : queue[currentIndex];
  Duration get position => player.position;
  Duration get duration => player.duration ?? Duration.zero;
  bool get isPlaying => player.playing;
  bool get hasPrevious => player.hasPrevious;
  bool get hasNext => player.hasNext;
  TrackPlayMode get trackPlayMode {
    if (player.shuffleModeEnabled) return TrackPlayMode.shuffle;
    if (player.loopMode == LoopMode.one) return TrackPlayMode.repeatOne;
    if (player.loopMode == LoopMode.all) return TrackPlayMode.repeatAll;
    return TrackPlayMode.normal;
  }
  Duration? get sleepTimerRemaining {
    final end = sleepTimerEndsAt;
    if (end == null) return null;
    final diff = end.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<void> playQueue(List<Song> songs, int index, {String? token}) async {
    queue = songs;
    currentIndex = index;
    final sources = await Future.wait(
      songs.map((song) => _createSource(song, token: token)),
    );
    await player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: index,
    );
    _lastTrackedSongId = songs[index].id;
    await store.savePlaybackSnapshot(
      songId: songs[index].id,
      positionMs: 0,
      incrementPlayCount: true,
    );
    await player.play();
    _scheduleWidgetSync();
    notifyListeners();
  }

  Future<void> cycleTrackPlayMode() async {
    switch (trackPlayMode) {
      case TrackPlayMode.normal:
        if (queue.isNotEmpty) {
          await player.shuffle();
        }
        await player.setLoopMode(LoopMode.off);
        await player.setShuffleModeEnabled(true);
        break;
      case TrackPlayMode.shuffle:
        await player.setShuffleModeEnabled(false);
        await player.setLoopMode(LoopMode.all);
        break;
      case TrackPlayMode.repeatAll:
        await player.setLoopMode(LoopMode.one);
        break;
      case TrackPlayMode.repeatOne:
        await player.setLoopMode(LoopMode.off);
        await player.setShuffleModeEnabled(false);
        break;
    }
    notifyListeners();
  }

  Future<void> playOrPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> next() => player.seekToNext();
  Future<void> previous() => player.seekToPrevious();

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> skipTo(int index) async {
    if (index < 0 || index >= queue.length) return;
    await player.seek(Duration.zero, index: index);
    currentIndex = index;
    _scheduleWidgetSync();
    notifyListeners();
  }

  Future<void> setSleepTimer(Duration duration) async {
    final end = DateTime.now().add(duration);
    sleepTimerEndsAt = end;
    await store.saveSleepTimerEnd(end);
    _startSleepTimerTicker();
    notifyListeners();
  }

  Future<void> cancelSleepTimer() async {
    sleepTimerEndsAt = null;
    _sleepTimerTicker?.cancel();
    _sleepTimerTicker = null;
    await store.saveSleepTimerEnd(null);
    notifyListeners();
  }

  String get sleepTimerLabel {
    final remaining = sleepTimerRemaining;
    if (remaining == null || remaining <= Duration.zero) return 'Off';
    if (remaining.inMinutes > 45) return '60';
    if (remaining.inMinutes > 22) return '30';
    return '15';
  }

  Future<void> cycleSleepTimerPreset() async {
    switch (sleepTimerLabel) {
      case 'Off':
        await setSleepTimer(const Duration(minutes: 15));
        break;
      case '15':
        await setSleepTimer(const Duration(minutes: 30));
        break;
      case '30':
        await setSleepTimer(const Duration(minutes: 60));
        break;
      default:
        await cancelSleepTimer();
        break;
    }
  }

  Future<void> _restoreSleepTimer() async {
    final end = await store.loadSleepTimerEnd();
    if (end == null) return;
    if (end.isBefore(DateTime.now())) {
      await store.saveSleepTimerEnd(null);
      return;
    }
    sleepTimerEndsAt = end;
    _startSleepTimerTicker();
    notifyListeners();
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _subs.add(
      session.becomingNoisyEventStream.listen((_) {
        if (player.playing) {
          unawaited(player.pause());
        }
      }),
    );

    _subs.add(
      session.interruptionEventStream.listen((event) async {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _preDuckVolume = player.volume;
              await player.setVolume(0.3);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              if (player.playing) await player.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              await player.setVolume(_preDuckVolume);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              break;
          }
        }
      }),
    );
  }

  Future<void> _persistCurrentPlayback() async {
    final song = currentSong;
    if (song == null) return;
    await store.savePlaybackSnapshot(
      songId: song.id,
      positionMs: player.position.inMilliseconds,
      incrementPlayCount: false,
    );
  }

  StreamTransformer<Duration, Duration> _positionSampler(Duration interval) {
    DateTime? last;
    return StreamTransformer.fromHandlers(
      handleData: (value, sink) {
        final now = DateTime.now();
        if (last == null || now.difference(last!) >= interval) {
          last = now;
          sink.add(value);
        }
      },
    );
  }

  void _startSleepTimerTicker() {
    _sleepTimerTicker?.cancel();
    _sleepTimerTicker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final end = sleepTimerEndsAt;
      if (end == null) {
        _sleepTimerTicker?.cancel();
        return;
      }
      if (!DateTime.now().isBefore(end)) {
        await player.pause();
        await cancelSleepTimer();
        return;
      }
      notifyListeners();
    });
  }

  void _scheduleWidgetSync() {
    _widgetSyncDebounce?.cancel();
    _widgetSyncDebounce = Timer(
      const Duration(milliseconds: 180),
      () => unawaited(_syncHomeWidget()),
    );
  }

  Future<void> _syncHomeWidget() async {
    final song = currentSong;
    final playing = isPlaying;
    if (_lastWidgetSongId == song?.id && _lastWidgetPlaying == playing) {
      return;
    }

    _lastWidgetSongId = song?.id;
    _lastWidgetPlaying = playing;

    final artworkUri = song == null ? null : await _artUri(song);
    await LarasHomeWidgetSync.sync(
      song: song,
      isPlaying: playing,
      artworkPath: artworkUri?.toFilePath(),
    );
  }

  Future<AudioSource> _createSource(Song song, {String? token}) async {
    return AudioSource.uri(
      song.streamUrl.startsWith('/')
          ? Uri.file(song.streamUrl)
          : Uri.parse(song.streamUrl),
      headers: token == null ? null : {'Authorization': 'Bearer $token'},
      tag: MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artistLabel,
        album: song.albumLabel,
        artUri: await _artUri(song),
      ),
    );
  }

  Future<Uri?> _artUri(Song song) async {
    if (!song.isLocal || song.artworkId == null) return null;

    final tempDir = await getTemporaryDirectory();
    final artworkDir = Directory('${tempDir.path}/laras_artwork');
    if (!await artworkDir.exists()) {
      await artworkDir.create(recursive: true);
    }

    final file = File('${artworkDir.path}/audio_${song.artworkId}.jpg');
    if (await file.exists()) {
      return file.uri;
    }

    try {
      final bytes = await _audioQuery.queryArtwork(
        song.artworkId!,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 512,
        quality: 80,
      );
      if (bytes == null || bytes.isEmpty) return null;
      await file.writeAsBytes(bytes, flush: true);
      return file.uri;
    } catch (_) {
      return null;
    }
  }

  Future<Uri?> resolveArtworkUri(Song song) => _artUri(song);

  Future<void> close() async {
    await _persistCurrentPlayback();
    _sleepTimerTicker?.cancel();
    _widgetSyncDebounce?.cancel();
    for (final sub in _subs) {
      await sub.cancel();
    }
    await player.dispose();
    super.dispose();
  }
}
