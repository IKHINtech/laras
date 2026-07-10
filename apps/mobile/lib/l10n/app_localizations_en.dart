// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Laras';

  @override
  String get playbackChannelName => 'Laras Playback';

  @override
  String get navLocal => 'Local';

  @override
  String get navServer => 'Server';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navSettings => 'Settings';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusServer => 'Server';

  @override
  String get welcomeTagline => 'Offline-first music player. Streaming server is only an extra feature.';

  @override
  String get continueOffline => 'Continue Offline';

  @override
  String get loginToServer => 'Login to Laras Server';

  @override
  String get register => 'Register';

  @override
  String get loginServerAccount => 'Login Server Account';

  @override
  String get registerServerAccount => 'Register Server Account';

  @override
  String get larasServer => 'Laras Server';

  @override
  String get loginDescription => 'Login is only required for upload, streaming, sync, and offline download from the server.';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get login => 'Login';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String loginFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String get modeServerActive => 'Server Mode active';

  @override
  String get modeLocalActive => 'Local Mode active';

  @override
  String get modeServerSubtitle => 'You are logged in to Laras Server. The local player is still available.';

  @override
  String get modeLocalSubtitle => 'You are using Laras without login. Songs, favorites, and local playlists are stored on the device.';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get paletteLarasDefault => 'Laras Default';

  @override
  String get paletteOceanBlue => 'Ocean Blue';

  @override
  String get paletteBurntOrange => 'Burnt Orange';

  @override
  String get paletteRosePink => 'Rose Pink';

  @override
  String get paletteEarthBrown => 'Earth Brown';

  @override
  String get paletteCustom => 'Custom';

  @override
  String get appIcon => 'App Icon';

  @override
  String get sleepTimer => 'Sleep Timer';

  @override
  String get stopPlaybackAutomatically => 'Stop playback automatically';

  @override
  String remaining(Object value) {
    return 'Remaining: $value';
  }

  @override
  String get off => 'Off';

  @override
  String minutesSeconds(Object minutes, Object seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String get lyricsLrc => 'Lyrics .lrc';

  @override
  String get lyricsLrcDescription => 'Now Playing prioritizes .lrc, then falls back to lyric metadata when available.';

  @override
  String get systemEqualizer => 'System Equalizer';

  @override
  String get systemEqualizerDescription => 'Open the built-in Android equalizer when supported by the device.';

  @override
  String get backgroundLockScreen => 'Background / Lock Screen';

  @override
  String get backgroundLockScreenDescription => 'Media service, notification control, and media buttons are already configured in the Android manifest.';

  @override
  String get account => 'Account';

  @override
  String get loginToServerDescription => 'Use your private server for upload, stream, and sync.';

  @override
  String get registerServerDescription => 'Create your personal Laras server account.';

  @override
  String get logoutFromServer => 'Logout from server';

  @override
  String get logoutFromServerDescription => 'Does not delete local library, favorites, or playlists.';

  @override
  String get offlineStillPrimary => 'Offline stays primary';

  @override
  String get offlineStillPrimaryDescription => 'Server login is only an extra feature and can be accessed any time from Settings.';

  @override
  String get equalizerOpened => 'Opened Android equalizer';

  @override
  String get equalizerUnavailable => 'Equalizer unavailable. Start playback first.';

  @override
  String launcherIconSwitched(Object label) {
    return 'Launcher icon switched to $label.';
  }

  @override
  String get launcherIconFailed => 'Failed to change launcher icon.';

  @override
  String get iconDefault => 'Default';

  @override
  String get iconDark => 'Dark';

  @override
  String get iconNeon => 'Neon';

  @override
  String get iconDefaultDescription => 'Standard Laras icon';

  @override
  String get iconDarkDescription => 'A darker and subtler version';

  @override
  String get iconNeonDescription => 'A brighter version with neon';

  @override
  String get pickThemeColor => 'Pick theme color';

  @override
  String get hue => 'Hue';

  @override
  String get saturation => 'Saturation';

  @override
  String get brightness => 'Brightness';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';
}
