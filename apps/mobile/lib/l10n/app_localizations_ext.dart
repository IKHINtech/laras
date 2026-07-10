import 'app_localizations.dart';

extension AppLocalizationsExt on AppLocalizations {
  bool get isIndonesian => localeName.startsWith('id');

  String get unknownArtist =>
      isIndonesian ? 'Artis Tidak Diketahui' : 'Unknown Artist';
  String get unknownAlbum =>
      isIndonesian ? 'Album Tidak Diketahui' : 'Unknown Album';
  String get unknownFolder =>
      isIndonesian ? 'Folder Tidak Diketahui' : 'Unknown Folder';
  String get unknownTitle =>
      isIndonesian ? 'Judul Tidak Diketahui' : 'Unknown Title';
  String get unknownLabel => isIndonesian ? 'Tidak Diketahui' : 'Unknown';
  String get viewAll => isIndonesian ? 'Lihat semua' : 'View all';
  String get recentlyPlayed =>
      isIndonesian ? 'Recently Played' : 'Recently Played';
  String get serverDashboard =>
      isIndonesian ? 'Dashboard Server' : 'Server Dashboard';
  String get upload => isIndonesian ? 'Upload' : 'Upload';
  String get serverDashboardEmpty => isIndonesian
      ? 'Belum ada playback server. Mulai putar lagu server dulu.'
      : 'No server playback yet. Start playing server songs first.';
  String get serverRecentlyPlayedSubtitle => isIndonesian
      ? 'Lagu server yang baru kamu putar'
      : 'Server songs you played recently';
  String get serverMostPlayedSubtitle => isIndonesian
      ? 'Lagu server yang paling sering kamu putar'
      : 'Server songs you played most often';
  String get totalSongsLabel => isIndonesian ? 'Total Lagu' : 'Total Songs';
  String get storageLabel => isIndonesian ? 'Penyimpanan' : 'Storage';
  String get recentLabel => isIndonesian ? 'Terbaru' : 'Recent';
  String get searchServerSongs =>
      isIndonesian ? 'Cari lagu server' : 'Search server songs';
  String get noSongsOnServer => isIndonesian
      ? 'Belum ada lagu di server.'
      : 'No songs on the server yet.';
  String get noMatchingSongs =>
      isIndonesian ? 'Tidak ada lagu yang cocok.' : 'No songs match.';
  String get localPlaylistsIntro => isIndonesian
      ? 'Favorite lokal dan playlist tersimpan di device, tanpa login.'
      : 'Local favorites and playlists are stored on this device without login.';
  String get playlistButton => isIndonesian ? 'Playlist' : 'Playlist';
  String get createLocalPlaylist =>
      isIndonesian ? 'Buat playlist lokal' : 'Create local playlist';
  String get playlistName => isIndonesian ? 'Nama playlist' : 'Playlist name';
  String get cancelText => isIndonesian ? 'Batal' : 'Cancel';
  String get createText => isIndonesian ? 'Buat' : 'Create';
  String get deletePlaylistTitle =>
      isIndonesian ? 'Hapus playlist?' : 'Delete playlist?';
  String deletePlaylistMessage(String name) => isIndonesian
      ? 'Playlist "$name" akan dihapus dari device ini.'
      : 'Playlist "$name" will be deleted from this device.';
  String get deleteText => isIndonesian ? 'Hapus' : 'Delete';
  String get noPlayHistory =>
      isIndonesian ? 'Belum ada riwayat putar' : 'No play history yet';
  String recentSongsCount(int count) =>
      isIndonesian ? '$count lagu terakhir' : '$count recent songs';
  String get noPlayStats =>
      isIndonesian ? 'Belum ada statistik putar' : 'No play stats yet';
  String topSongsCount(int count) =>
      isIndonesian ? '$count lagu teratas' : '$count top songs';
  String get favoriteSongs => isIndonesian ? 'Lagu Favorit' : 'Favorite Songs';
  String songsCount(int count) => isIndonesian ? '$count lagu' : '$count songs';
  String get noLocalPlaylistYet => isIndonesian
      ? 'Belum ada playlist lokal. Buat playlist atau tambahkan lagu dari tab Local.'
      : 'No local playlists yet. Create one or add songs from the Local tab.';
  String get clearRecentPlayedTitle =>
      isIndonesian ? 'Hapus Recently Played?' : 'Clear Recently Played?';
  String get clearMostPlayedTitle =>
      isIndonesian ? 'Reset Most Played?' : 'Reset Most Played?';
  String get clearLocalPlaybackWarning => isIndonesian
      ? 'Riwayat pemutaran lokal akan dihapus dari device ini.'
      : 'Local playback history will be removed from this device.';
  String get noRecentPlayedDetail => isIndonesian
      ? 'Belum ada riwayat putar. Mulai putar lagu lokal dulu.'
      : 'No play history yet. Start playing local songs first.';
  String get noMostPlayedDetail => isIndonesian
      ? 'Belum ada data lagu yang paling sering diputar.'
      : 'No most-played song data yet.';
  String get noServerRecentDetail => isIndonesian
      ? 'Belum ada riwayat putar server. Mulai putar lagu server dulu.'
      : 'No server play history yet. Start playing server songs first.';
  String get noServerMostPlayedDetail => isIndonesian
      ? 'Belum ada data lagu server yang paling sering diputar.'
      : 'No most-played server song data yet.';
  String playsCount(int count) =>
      isIndonesian ? '${count}x diputar' : '$count plays';
  String playedCountWithLast(String last) =>
      isIndonesian ? 'terakhir $last' : 'last $last';
  String recentPlaybackSubtitle(
          String artist, String playedAt, int playCount) =>
      isIndonesian
          ? '$artist • $playedAt • ${playsCount(playCount)}'
          : '$artist • $playedAt • ${playsCount(playCount)}';
  String mostPlayedSubtitle(String artist, int playCount, String playedAt) =>
      isIndonesian
          ? '$artist • ${playsCount(playCount)} • terakhir $playedAt'
          : '$artist • ${playsCount(playCount)} • last $playedAt';
  String rankLabel(int index) => '#$index';
  String get justNow => isIndonesian ? 'Baru saja' : 'Just now';
  String minutesAgo(int value) =>
      isIndonesian ? '$value menit lalu' : '$value minutes ago';
  String hoursAgo(int value) =>
      isIndonesian ? '$value jam lalu' : '$value hours ago';
  String daysAgo(int value) =>
      isIndonesian ? '$value hari lalu' : '$value days ago';
  String weeksAgo(int value) =>
      isIndonesian ? '$value minggu lalu' : '$value weeks ago';
  String monthsAgo(int value) =>
      isIndonesian ? '$value bulan lalu' : '$value months ago';
  String yearsAgo(int value) =>
      isIndonesian ? '$value tahun lalu' : '$value years ago';
  String get removeSongFromPlaylistTitle =>
      isIndonesian ? 'Hapus lagu dari playlist?' : 'Remove song from playlist?';
  String removeSongFromPlaylistMessage(String title) => isIndonesian
      ? '"$title" akan dihapus dari playlist ini.'
      : '"$title" will be removed from this playlist.';
  String get searchPlaylist =>
      isIndonesian ? 'Cari playlist' : 'Search playlist';
  String get closeSearch => isIndonesian ? 'Tutup pencarian' : 'Close search';
  String get searchText => isIndonesian ? 'Cari' : 'Search';
  String get playlistEmpty =>
      isIndonesian ? 'Playlist kosong' : 'Playlist empty';
  String get noSongsMatchSearch =>
      isIndonesian ? 'Tidak ada lagu yang cocok.' : 'No songs match search.';
  String get playText => isIndonesian ? 'Putar' : 'Play';
  String scannedLocalSongs(int count) => isIndonesian
      ? 'Memindai $count lagu lokal'
      : 'Scanned $count local songs';
  String addedToPlaylist(String name) =>
      isIndonesian ? 'Ditambahkan ke $name' : 'Added to $name';
  String get removeFavorite =>
      isIndonesian ? 'Hapus favorit' : 'Remove favorite';
  String get addFavorite => isIndonesian ? 'Tambah favorit' : 'Add favorite';
  String get addToPlaylist =>
      isIndonesian ? 'Tambah ke playlist' : 'Add to playlist';
  String get noLocalLibraryCache => isIndonesian
      ? 'Belum ada cache library lokal. Tekan Scan.'
      : 'No local library cache yet. Tap Scan.';
  String get localRecentlyPlayedSubtitle => isIndonesian
      ? 'Lagu yang baru kamu putar di device ini'
      : 'Songs you played recently on this device';
  String get localMostPlayedSubtitle => isIndonesian
      ? 'Lagu yang paling sering kamu putar'
      : 'Songs you play most often';
  String bucketSongsCached(int count) => isIndonesian
      ? '$count lagu tersimpan untuk akses offline.'
      : '$count songs cached for offline access.';
  String get localLibraryEmptyHero => isIndonesian
      ? 'Library offline kosong. Pindai musik di device terlebih dulu.'
      : 'Offline library is empty. Scan device music first.';
  String get localCollection => isIndonesian ? 'Koleksi' : 'Collection';
  String get rescanSongs => isIndonesian ? 'Scan ulang lagu' : 'Rescan songs';
  String get shuffleAll => isIndonesian ? 'Acak Semua' : 'Shuffle All';
  String get scanText => isIndonesian ? 'Scan' : 'Scan';
  String get searchLibraryHint => isIndonesian
      ? 'Cari lagu, artis, album, folder'
      : 'Search songs, artist, album, folder';
  String get songsTab => isIndonesian ? 'Lagu' : 'Songs';
  String get artistsTab => isIndonesian ? 'Artis' : 'Artists';
  String get albumsTab => isIndonesian ? 'Album' : 'Albums';
  String get foldersTab => isIndonesian ? 'Folder' : 'Folders';
  String get noArtistsFound =>
      isIndonesian ? 'Tidak ada artis.' : 'No artists found.';
  String get noAlbumsFound =>
      isIndonesian ? 'Tidak ada album.' : 'No albums found.';
  String get noFoldersFound =>
      isIndonesian ? 'Tidak ada folder.' : 'No folders found.';
  String get noSongPlaying =>
      isIndonesian ? 'Tidak ada lagu yang diputar' : 'No song playing';
  String get firstPlay => isIndonesian ? 'Pemutaran pertama' : 'First play';
  String get normalMode => isIndonesian ? 'Normal' : 'Normal';
  String get shuffleMode => isIndonesian ? 'Acak' : 'Shuffle';
  String get loopMode => isIndonesian ? 'Loop' : 'Loop';
  String get loopOneMode => isIndonesian ? 'Loop 1' : 'Loop 1';
  String queuePosition(int index, int total) =>
      isIndonesian ? '$index / $total di antrean' : '$index / $total in queue';
  String get lyricsPreview =>
      isIndonesian ? 'Pratinjau lirik' : 'Lyrics preview';
  String get noLyricsFound => isIndonesian
      ? 'Belum ada lirik yang ditemukan dari .lrc atau metadata.'
      : 'No lyrics were found from .lrc or metadata.';
  String sourceText(String label) =>
      isIndonesian ? 'Sumber: $label' : 'Source: $label';
  String get viewLyrics => isIndonesian ? 'Lihat lirik' : 'View lyrics';
  String get lyricsDetail => isIndonesian ? 'Detail lirik' : 'Lyrics detail';
  String get shareSheetFailed => isIndonesian
      ? 'Gagal membuka share sheet.'
      : 'Failed to open share sheet.';
  String get prepareShareFailed => isIndonesian
      ? 'Gagal menyiapkan gambar lirik untuk dibagikan.'
      : 'Failed to prepare lyric image for sharing.';
  String get lyricsSharePreviewTitle =>
      isIndonesian ? 'Preview share lirik' : 'Lyrics share preview';
  String get lyricsSharePreviewSubtitle => isIndonesian
      ? 'Pilih tema card dan format export sebelum dibagikan.'
      : 'Choose the card theme and export format before sharing.';
  String get quickPreset => isIndonesian ? 'Preset cepat' : 'Quick presets';
  String get cardTheme => isIndonesian ? 'Tema card' : 'Card theme';
  String get exportFormat => isIndonesian ? 'Format export' : 'Export format';
  String get textLayout => isIndonesian ? 'Tata teks' : 'Text layout';
  String get fontSizeText => isIndonesian ? 'Ukuran font' : 'Font size';
  String get fontWeightText => isIndonesian ? 'Ketebalan font' : 'Font weight';
  String get lineSpacingText => isIndonesian ? 'Line spacing' : 'Line spacing';
  String get cardOptions => isIndonesian ? 'Opsi card' : 'Card options';
  String get artworkBackground =>
      isIndonesian ? 'Latar artwork' : 'Artwork background';
  String get footerSongInfo =>
      isIndonesian ? 'Footer info lagu' : 'Song info footer';
  String get shareStory =>
      isIndonesian ? 'Bagikan Story 9:16' : 'Share 9:16 Story';
  String get shareImage => isIndonesian ? 'Bagikan Gambar' : 'Share Image';
  String get shareSelectedLyrics =>
      isIndonesian ? 'Bagikan lirik terpilih' : 'Share selected lyrics';
  String linesSelected(int count) =>
      isIndonesian ? '$count baris dipilih' : '$count lines selected';
  String get cancelSelection =>
      isIndonesian ? 'Batal pilih' : 'Cancel selection';
  String get sharedFromLaras =>
      isIndonesian ? 'Dibagikan dari Laras' : 'Shared from Laras';
  String instagramStoryLabel(String ratio) =>
      isIndonesian ? 'Instagram Story • $ratio' : 'Instagram Story • $ratio';
  String get mostPlayedLabel => isIndonesian ? 'Paling Sering' : 'Most Played';
}
