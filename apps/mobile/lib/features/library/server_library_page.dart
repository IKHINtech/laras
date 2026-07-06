import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/auth_store.dart';
import '../../core/theme_controller.dart';
import '../auth/login_page.dart';
import '../player/player_controller.dart';
import 'song.dart';

class ServerLibraryPage extends StatefulWidget {
  const ServerLibraryPage({
    super.key,
    required this.api,
    required this.authStore,
    required this.themeController,
    required this.player,
  });
  final ApiClient api;
  final AuthStore authStore;
  final ThemeController themeController;
  final PlayerController player;

  @override
  State<ServerLibraryPage> createState() => _ServerLibraryPageState();
}

class _ServerLibraryPageState extends State<ServerLibraryPage> {
  List<Song> songs = [];
  bool loading = false;
  final search = TextEditingController();

  bool get isLoggedIn => widget.authStore.token != null;

  @override
  void initState() {
    super.initState();
    if (isLoggedIn) load();
  }

  Future<void> load() async {
    if (!isLoggedIn) return;
    setState(() => loading = true);
    try {
      songs = await widget.api.songs(q: search.text);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> upload() async {
    if (!isLoggedIn) return;
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return;
    await widget.api.uploadSong(File(result.files.single.path!));
    await load();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 56),
                  const SizedBox(height: 12),
                  const Text(
                    'Server Mode belum aktif',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Local Mode tetap bisa dipakai tanpa login. Login hanya untuk upload, streaming, sync playlist/favorite, dan offline download dari server.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Login to Laras Server'),
                    onPressed: () => Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => LoginPage(
                              api: widget.api,
                              authStore: widget.authStore,
                              themeController: widget.themeController,
                            ),
                          ),
                        )
                        .then((_) => setState(() {})),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Register'),
                    onPressed: () => Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => LoginPage(
                              api: widget.api,
                              authStore: widget.authStore,
                              themeController: widget.themeController,
                              initialRegisterMode: true,
                            ),
                          ),
                        )
                        .then((_) => setState(() {})),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search server songs',
                    ),
                    onSubmitted: (_) => load(),
                  ),
                ),
                IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
                FilledButton.icon(
                  onPressed: upload,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload'),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (_, i) {
                      final song = songs[i];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.music_note),
                        ),
                        title: Text(song.title),
                        subtitle: Text(
                          song.artist.isEmpty ? 'Unknown Artist' : song.artist,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () => widget.api.toggleFavorite(song.id),
                        ),
                        onTap: () => widget.player.playQueue(
                          songs,
                          i,
                          token: widget.authStore.token,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
