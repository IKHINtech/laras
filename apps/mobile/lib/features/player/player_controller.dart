import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../library/local_music_store.dart';
import '../library/song.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({required this.store}) {
    _subs.add(
      player.currentIndexStream.listen((value) {
        final next = value ?? 0;
        if (next != currentIndex) {
          currentIndex = next;
          notifyListeners();
        }
      }),
    );
    _subs.add(player.playerStateStream.listen((_) => notifyListeners()));
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
  }

  final LocalMusicStore store;
  final AudioPlayer player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subs = [];
  List<Song> queue = [];
  int currentIndex = 0;
  int? androidAudioSessionId;
  DateTime? sleepTimerEndsAt;
  Timer? _sleepTimerTicker;
  String? _lastTrackedSongId;
  double _preDuckVolume = 1.0;

  Song? get currentSong => queue.isEmpty ? null : queue[currentIndex];
  Duration get position => player.position;
  Duration get duration => player.duration ?? Duration.zero;
  bool get isPlaying => player.playing;
  bool get hasPrevious => player.hasPrevious;
  bool get hasNext => player.hasNext;
  Duration? get sleepTimerRemaining {
    final end = sleepTimerEndsAt;
    if (end == null) return null;
    final diff = end.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<void> playQueue(List<Song> songs, int index, {String? token}) async {
    queue = songs;
    currentIndex = index;
    final sources = songs.map((song) {
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
          artUri: _artUri(song),
        ),
      );
    }).toList();
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

  Uri? _artUri(Song song) {
    if (!song.isLocal || !song.streamUrl.startsWith('/')) return null;
    if (!File(song.streamUrl).existsSync()) return null;
    return Uri.file(song.streamUrl);
  }

  Future<void> close() async {
    await _persistCurrentPlayback();
    _sleepTimerTicker?.cancel();
    for (final sub in _subs) {
      await sub.cancel();
    }
    await player.dispose();
    super.dispose();
  }
}
