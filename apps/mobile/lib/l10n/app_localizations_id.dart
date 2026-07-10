// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Laras';

  @override
  String get playbackChannelName => 'Laras Playback';

  @override
  String get navLocal => 'Lokal';

  @override
  String get navServer => 'Server';

  @override
  String get navPlaylists => 'Playlist';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusServer => 'Server';

  @override
  String get welcomeTagline => 'Pemutar musik offline-first. Server streaming hanya fitur tambahan.';

  @override
  String get continueOffline => 'Lanjut Offline';

  @override
  String get loginToServer => 'Login ke Laras Server';

  @override
  String get register => 'Daftar';

  @override
  String get loginServerAccount => 'Login Akun Server';

  @override
  String get registerServerAccount => 'Daftar Akun Server';

  @override
  String get larasServer => 'Laras Server';

  @override
  String get loginDescription => 'Login hanya diperlukan untuk upload, streaming, sinkronisasi, dan unduhan offline dari server.';

  @override
  String get fieldName => 'Nama';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Kata Sandi';

  @override
  String get login => 'Login';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun? Login';

  @override
  String get dontHaveAccount => 'Belum punya akun? Daftar';

  @override
  String loginFailed(Object error) {
    return 'Gagal: $error';
  }

  @override
  String get modeServerActive => 'Mode Server aktif';

  @override
  String get modeLocalActive => 'Mode Lokal aktif';

  @override
  String get modeServerSubtitle => 'Kamu login ke Laras Server. Pemutar lokal tetap bisa dipakai.';

  @override
  String get modeLocalSubtitle => 'Kamu memakai Laras tanpa login. Lagu, favorit, dan playlist lokal tersimpan di perangkat.';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get languageJapanese => 'Jepang';

  @override
  String get unknownArtist => 'Artis Tidak Diketahui';

  @override
  String get unknownAlbum => 'Album Tidak Diketahui';

  @override
  String get unknownFolder => 'Folder Tidak Diketahui';

  @override
  String get unknownTitle => 'Judul Tidak Diketahui';

  @override
  String get unknownLabel => 'Tidak Diketahui';

  @override
  String get viewAll => 'Lihat semua';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get serverDashboard => 'Dashboard Server';

  @override
  String get upload => 'Upload';

  @override
  String get serverDashboardEmpty => 'Belum ada playback server. Mulai putar lagu server dulu.';

  @override
  String get serverRecentlyPlayedSubtitle => 'Lagu server yang baru kamu putar';

  @override
  String get serverMostPlayedSubtitle => 'Lagu server yang paling sering kamu putar';

  @override
  String get totalSongsLabel => 'Total Lagu';

  @override
  String get storageLabel => 'Penyimpanan';

  @override
  String get recentLabel => 'Terbaru';

  @override
  String get searchServerSongs => 'Cari lagu server';

  @override
  String get noSongsOnServer => 'Belum ada lagu di server.';

  @override
  String get noMatchingSongs => 'Tidak ada lagu yang cocok.';

  @override
  String get localPlaylistsIntro => 'Favorite lokal dan playlist tersimpan di device, tanpa login.';

  @override
  String get playlistButton => 'Playlist';

  @override
  String get createLocalPlaylist => 'Buat playlist lokal';

  @override
  String get playlistName => 'Nama playlist';

  @override
  String get cancelText => 'Batal';

  @override
  String get createText => 'Buat';

  @override
  String get deletePlaylistTitle => 'Hapus playlist?';

  @override
  String deletePlaylistMessage(Object name) {
    return 'Playlist \"$name\" akan dihapus dari device ini.';
  }

  @override
  String get deleteText => 'Hapus';

  @override
  String get noPlayHistory => 'Belum ada riwayat putar';

  @override
  String recentSongsCount(Object count) {
    return '$count lagu terakhir';
  }

  @override
  String get noPlayStats => 'Belum ada statistik putar';

  @override
  String topSongsCount(Object count) {
    return '$count lagu teratas';
  }

  @override
  String get favoriteSongs => 'Lagu Favorit';

  @override
  String songsCount(Object count) {
    return '$count lagu';
  }

  @override
  String get noLocalPlaylistYet => 'Belum ada playlist lokal. Buat playlist atau tambahkan lagu dari tab Local.';

  @override
  String get clearRecentPlayedTitle => 'Hapus Recently Played?';

  @override
  String get clearMostPlayedTitle => 'Reset Most Played?';

  @override
  String get clearLocalPlaybackWarning => 'Riwayat pemutaran lokal akan dihapus dari device ini.';

  @override
  String get noRecentPlayedDetail => 'Belum ada riwayat putar. Mulai putar lagu lokal dulu.';

  @override
  String get noMostPlayedDetail => 'Belum ada data lagu yang paling sering diputar.';

  @override
  String get noServerRecentDetail => 'Belum ada riwayat putar server. Mulai putar lagu server dulu.';

  @override
  String get noServerMostPlayedDetail => 'Belum ada data lagu server yang paling sering diputar.';

  @override
  String playsCount(Object count) {
    return '${count}x diputar';
  }

  @override
  String recentPlaybackSubtitle(Object artist, Object playedAt, Object playCount) {
    return '$artist • $playedAt • $playCount';
  }

  @override
  String mostPlayedSubtitle(Object artist, Object playCount, Object playedAt) {
    return '$artist • $playCount • terakhir $playedAt';
  }

  @override
  String rankLabel(Object index) {
    return '#$index';
  }

  @override
  String get justNow => 'Baru saja';

  @override
  String minutesAgo(Object value) {
    return '$value menit lalu';
  }

  @override
  String hoursAgo(Object value) {
    return '$value jam lalu';
  }

  @override
  String daysAgo(Object value) {
    return '$value hari lalu';
  }

  @override
  String weeksAgo(Object value) {
    return '$value minggu lalu';
  }

  @override
  String monthsAgo(Object value) {
    return '$value bulan lalu';
  }

  @override
  String yearsAgo(Object value) {
    return '$value tahun lalu';
  }

  @override
  String get removeSongFromPlaylistTitle => 'Hapus lagu dari playlist?';

  @override
  String removeSongFromPlaylistMessage(Object title) {
    return '\"$title\" akan dihapus dari playlist ini.';
  }

  @override
  String get searchPlaylist => 'Cari playlist';

  @override
  String get closeSearch => 'Tutup pencarian';

  @override
  String get searchText => 'Cari';

  @override
  String get playlistEmpty => 'Playlist kosong';

  @override
  String get noSongsMatchSearch => 'Tidak ada lagu yang cocok.';

  @override
  String get playText => 'Putar';

  @override
  String scannedLocalSongs(Object count) {
    return 'Memindai $count lagu lokal';
  }

  @override
  String addedToPlaylist(Object name) {
    return 'Ditambahkan ke $name';
  }

  @override
  String get removeFavorite => 'Hapus favorit';

  @override
  String get addFavorite => 'Tambah favorit';

  @override
  String get addToPlaylist => 'Tambah ke playlist';

  @override
  String get noLocalLibraryCache => 'Belum ada cache library lokal. Tekan Scan.';

  @override
  String get localRecentlyPlayedSubtitle => 'Lagu yang baru kamu putar di device ini';

  @override
  String get localMostPlayedSubtitle => 'Lagu yang paling sering kamu putar';

  @override
  String bucketSongsCached(Object count) {
    return '$count lagu tersimpan untuk akses offline.';
  }

  @override
  String get localLibraryEmptyHero => 'Library offline kosong. Pindai musik di device terlebih dulu.';

  @override
  String get localCollection => 'Koleksi';

  @override
  String get rescanSongs => 'Scan ulang lagu';

  @override
  String get shuffleAll => 'Acak Semua';

  @override
  String get scanText => 'Scan';

  @override
  String get searchLibraryHint => 'Cari lagu, artis, album, folder';

  @override
  String get songsTab => 'Lagu';

  @override
  String get artistsTab => 'Artis';

  @override
  String get albumsTab => 'Album';

  @override
  String get foldersTab => 'Folder';

  @override
  String get noArtistsFound => 'Tidak ada artis.';

  @override
  String get noAlbumsFound => 'Tidak ada album.';

  @override
  String get noFoldersFound => 'Tidak ada folder.';

  @override
  String get noSongPlaying => 'Tidak ada lagu yang diputar';

  @override
  String get firstPlay => 'Pemutaran pertama';

  @override
  String get normalMode => 'Normal';

  @override
  String get shuffleMode => 'Acak';

  @override
  String get loopMode => 'Loop';

  @override
  String get loopOneMode => 'Loop 1';

  @override
  String queuePosition(Object index, Object total) {
    return '$index / $total di antrean';
  }

  @override
  String get lyricsPreview => 'Pratinjau lirik';

  @override
  String get noLyricsFound => 'Belum ada lirik yang ditemukan dari .lrc atau metadata.';

  @override
  String sourceText(Object label) {
    return 'Sumber: $label';
  }

  @override
  String get viewLyrics => 'Lihat lirik';

  @override
  String get lyricsDetail => 'Detail lirik';

  @override
  String get shareSheetFailed => 'Gagal membuka share sheet.';

  @override
  String get prepareShareFailed => 'Gagal menyiapkan gambar lirik untuk dibagikan.';

  @override
  String get lyricsSharePreviewTitle => 'Preview share lirik';

  @override
  String get lyricsSharePreviewSubtitle => 'Pilih tema card dan format export sebelum dibagikan.';

  @override
  String get quickPreset => 'Preset cepat';

  @override
  String get cardTheme => 'Tema card';

  @override
  String get exportFormat => 'Format export';

  @override
  String get textLayout => 'Tata teks';

  @override
  String get fontSizeText => 'Ukuran font';

  @override
  String get fontWeightText => 'Ketebalan font';

  @override
  String get lineSpacingText => 'Line spacing';

  @override
  String get cardOptions => 'Opsi card';

  @override
  String get artworkBackground => 'Latar artwork';

  @override
  String get footerSongInfo => 'Footer info lagu';

  @override
  String get shareStory => 'Bagikan Story 9:16';

  @override
  String get shareImage => 'Bagikan Gambar';

  @override
  String get shareSelectedLyrics => 'Bagikan lirik terpilih';

  @override
  String linesSelected(Object count) {
    return '$count baris dipilih';
  }

  @override
  String get cancelSelection => 'Batal pilih';

  @override
  String get sharedFromLaras => 'Dibagikan dari Laras';

  @override
  String instagramStoryLabel(Object ratio) {
    return 'Instagram Story • $ratio';
  }

  @override
  String get mostPlayedLabel => 'Paling Sering';

  @override
  String get shareThemeLarasNight => 'Laras Night';

  @override
  String get shareThemeAuroraGlow => 'Aurora Glow';

  @override
  String get shareThemeDaylightPaper => 'Daylight Paper';

  @override
  String get shareFormatSquare => 'Persegi';

  @override
  String get shareFormatStory => 'Instagram Story';

  @override
  String get shareFontWeightMedium => 'Medium';

  @override
  String get shareFontWeightSemibold => 'Semi Bold';

  @override
  String get shareFontWeightBold => 'Bold';

  @override
  String get shareFontWeightHeavy => 'Tebal';

  @override
  String get sharePresetQuote => 'Quote';

  @override
  String get sharePresetPoster => 'Poster';

  @override
  String get sharePresetStory => 'Story';

  @override
  String get sharePresetCustom => 'Kustom';

  @override
  String get shareTextAlignLeft => 'Rata kiri';

  @override
  String get shareTextAlignCenter => 'Rata tengah';

  @override
  String get shareTextAlignRight => 'Rata kanan';

  @override
  String get paletteLarasDefault => 'Laras Default';

  @override
  String get paletteOceanBlue => 'Biru Laut';

  @override
  String get paletteBurntOrange => 'Oranye Tua';

  @override
  String get paletteRosePink => 'Merah Muda';

  @override
  String get paletteEarthBrown => 'Cokelat Bumi';

  @override
  String get paletteCustom => 'Kustom';

  @override
  String get appIcon => 'Ikon Aplikasi';

  @override
  String get sleepTimer => 'Timer Tidur';

  @override
  String get stopPlaybackAutomatically => 'Hentikan pemutaran otomatis';

  @override
  String remaining(Object value) {
    return 'Sisa: $value';
  }

  @override
  String get off => 'Mati';

  @override
  String minutesSeconds(Object minutes, Object seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String get lyricsLrc => 'Lirik .lrc';

  @override
  String get lyricsLrcDescription => 'Now Playing memprioritaskan .lrc, lalu fallback ke metadata lirik bila tersedia.';

  @override
  String get systemEqualizer => 'Equalizer Sistem';

  @override
  String get systemEqualizerDescription => 'Buka equalizer Android bawaan bila perangkat mendukung.';

  @override
  String get backgroundLockScreen => 'Latar / Lock Screen';

  @override
  String get backgroundLockScreenDescription => 'Media service, kontrol notifikasi, dan tombol media sudah disiapkan di Android manifest.';

  @override
  String get account => 'Akun';

  @override
  String get loginToServerDescription => 'Gunakan server pribadi untuk upload, stream, dan sinkronisasi.';

  @override
  String get registerServerDescription => 'Buat akun server pribadi Laras.';

  @override
  String get logoutFromServer => 'Logout dari server';

  @override
  String get logoutFromServerDescription => 'Tidak menghapus library, favorit, atau playlist lokal.';

  @override
  String get offlineStillPrimary => 'Offline tetap utama';

  @override
  String get offlineStillPrimaryDescription => 'Login server hanya fitur tambahan dan bisa diakses kapan saja dari Pengaturan.';

  @override
  String get equalizerOpened => 'Equalizer Android dibuka';

  @override
  String get equalizerUnavailable => 'Equalizer tidak tersedia. Mulai playback dulu.';

  @override
  String launcherIconSwitched(Object label) {
    return 'Ikon launcher diganti ke $label.';
  }

  @override
  String get launcherIconFailed => 'Gagal mengganti ikon launcher.';

  @override
  String get iconDefault => 'Default';

  @override
  String get iconDark => 'Gelap';

  @override
  String get iconNeon => 'Neon';

  @override
  String get iconDefaultDescription => 'Ikon standar Laras';

  @override
  String get iconDarkDescription => 'Versi gelap dan subtle';

  @override
  String get iconNeonDescription => 'Versi terang dengan neon';

  @override
  String get pickThemeColor => 'Pilih warna tema';

  @override
  String get hue => 'Hue';

  @override
  String get saturation => 'Saturasi';

  @override
  String get brightness => 'Kecerahan';

  @override
  String get cancel => 'Batal';

  @override
  String get apply => 'Pakai';
}
