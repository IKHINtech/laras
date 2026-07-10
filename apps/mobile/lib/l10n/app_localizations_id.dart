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
