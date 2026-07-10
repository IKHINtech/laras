import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../../l10n/app_localizations.dart';
import '../player/player_controller.dart';
import 'song.dart';

class ServerLibraryPage extends StatefulWidget {
  const ServerLibraryPage({
    super.key,
    required this.api,
    required this.authStore,
    required this.player,
  });

  final ApiClient api;
  final AuthStore authStore;
  final PlayerController player;

  @override
  State<ServerLibraryPage> createState() => _ServerLibraryPageState();
}

class _ServerLibraryPageState extends State<ServerLibraryPage> {
  List<Song> songs = [];
  bool loading = false;
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      songs = await widget.api.songs(q: search.text.trim());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> upload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return;
    await widget.api.uploadSong(File(result.files.single.path!));
    await load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.searchServerSongs,
                  ),
                  onSubmitted: (_) => load(),
                ),
              ),
              IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
              FilledButton.icon(
                onPressed: upload,
                icon: const Icon(Icons.upload),
                label: Text(l10n.upload),
              ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : songs.isEmpty
                  ? Center(
                      child: Text(
                        search.text.trim().isEmpty
                            ? l10n.noSongsOnServer
                            : l10n.noMatchingSongs,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: songs.length,
                      itemBuilder: (_, index) {
                        final song = songs[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.music_note),
                          ),
                          title: Text(song.title),
                          subtitle: Text(
                            song.artist.isEmpty
                                ? l10n.unknownArtist
                                : song.artist,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () => widget.api.toggleFavorite(song.id),
                          ),
                          onTap: () => widget.player.playQueue(
                            songs,
                            index,
                            token: widget.authStore.token,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
