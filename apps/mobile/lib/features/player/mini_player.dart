import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../library/local_music_store.dart';
import 'player_controller.dart';
import 'now_playing_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.controller, required this.store});
  final PlayerController controller;
  final LocalMusicStore store;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: controller.player.playerStateStream,
      builder: (context, snapshot) {
        final song = controller.currentSong;
        if (song == null) return const SizedBox.shrink();
        final playing = snapshot.data?.playing ?? false;
        return Material(
          elevation: 10,
          child: ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    NowPlayingPage(controller: controller, store: store),
              ),
            ),
            leading: song.artworkId == null
                ? const CircleAvatar(child: Icon(Icons.music_note))
                : QueryArtworkWidget(
                    id: song.artworkId!,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: const CircleAvatar(
                      child: Icon(Icons.music_note),
                    ),
                  ),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artistLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed:
                      controller.hasPrevious ? controller.previous : null,
                ),
                IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  onPressed: controller.playOrPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: controller.hasNext ? controller.next : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
