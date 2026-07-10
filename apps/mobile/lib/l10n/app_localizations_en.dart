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
  String get languageJapanese => 'Japanese';

  @override
  String get unknownArtist => 'Unknown Artist';

  @override
  String get unknownAlbum => 'Unknown Album';

  @override
  String get unknownFolder => 'Unknown Folder';

  @override
  String get unknownTitle => 'Unknown Title';

  @override
  String get unknownLabel => 'Unknown';

  @override
  String get viewAll => 'View all';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get serverDashboard => 'Server Dashboard';

  @override
  String get upload => 'Upload';

  @override
  String get serverDashboardEmpty => 'No server playback yet. Start playing server songs first.';

  @override
  String get serverRecentlyPlayedSubtitle => 'Server songs you played recently';

  @override
  String get serverMostPlayedSubtitle => 'Server songs you played most often';

  @override
  String get totalSongsLabel => 'Total Songs';

  @override
  String get storageLabel => 'Storage';

  @override
  String get recentLabel => 'Recent';

  @override
  String get searchServerSongs => 'Search server songs';

  @override
  String get noSongsOnServer => 'No songs on the server yet.';

  @override
  String get noMatchingSongs => 'No songs match.';

  @override
  String get localPlaylistsIntro => 'Local favorites and playlists are stored on this device without login.';

  @override
  String get playlistButton => 'Playlist';

  @override
  String get createLocalPlaylist => 'Create local playlist';

  @override
  String get playlistName => 'Playlist name';

  @override
  String get cancelText => 'Cancel';

  @override
  String get createText => 'Create';

  @override
  String get deletePlaylistTitle => 'Delete playlist?';

  @override
  String deletePlaylistMessage(Object name) {
    return 'Playlist \"$name\" will be deleted from this device.';
  }

  @override
  String get deleteText => 'Delete';

  @override
  String get noPlayHistory => 'No play history yet';

  @override
  String recentSongsCount(Object count) {
    return '$count recent songs';
  }

  @override
  String get noPlayStats => 'No play stats yet';

  @override
  String topSongsCount(Object count) {
    return '$count top songs';
  }

  @override
  String get favoriteSongs => 'Favorite Songs';

  @override
  String songsCount(Object count) {
    return '$count songs';
  }

  @override
  String get noLocalPlaylistYet => 'No local playlists yet. Create one or add songs from the Local tab.';

  @override
  String get clearRecentPlayedTitle => 'Clear Recently Played?';

  @override
  String get clearMostPlayedTitle => 'Reset Most Played?';

  @override
  String get clearLocalPlaybackWarning => 'Local playback history will be removed from this device.';

  @override
  String get noRecentPlayedDetail => 'No play history yet. Start playing local songs first.';

  @override
  String get noMostPlayedDetail => 'No most-played song data yet.';

  @override
  String get noServerRecentDetail => 'No server play history yet. Start playing server songs first.';

  @override
  String get noServerMostPlayedDetail => 'No most-played server song data yet.';

  @override
  String playsCount(Object count) {
    return '$count plays';
  }

  @override
  String recentPlaybackSubtitle(Object artist, Object playedAt, Object playCount) {
    return '$artist • $playedAt • $playCount';
  }

  @override
  String mostPlayedSubtitle(Object artist, Object playCount, Object playedAt) {
    return '$artist • $playCount • last $playedAt';
  }

  @override
  String rankLabel(Object index) {
    return '#$index';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object value) {
    return '$value minutes ago';
  }

  @override
  String hoursAgo(Object value) {
    return '$value hours ago';
  }

  @override
  String daysAgo(Object value) {
    return '$value days ago';
  }

  @override
  String weeksAgo(Object value) {
    return '$value weeks ago';
  }

  @override
  String monthsAgo(Object value) {
    return '$value months ago';
  }

  @override
  String yearsAgo(Object value) {
    return '$value years ago';
  }

  @override
  String get removeSongFromPlaylistTitle => 'Remove song from playlist?';

  @override
  String removeSongFromPlaylistMessage(Object title) {
    return '\"$title\" will be removed from this playlist.';
  }

  @override
  String get searchPlaylist => 'Search playlist';

  @override
  String get closeSearch => 'Close search';

  @override
  String get searchText => 'Search';

  @override
  String get playlistEmpty => 'Playlist empty';

  @override
  String get noSongsMatchSearch => 'No songs match search.';

  @override
  String get playText => 'Play';

  @override
  String scannedLocalSongs(Object count) {
    return 'Scanned $count local songs';
  }

  @override
  String addedToPlaylist(Object name) {
    return 'Added to $name';
  }

  @override
  String get removeFavorite => 'Remove favorite';

  @override
  String get addFavorite => 'Add favorite';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get noLocalLibraryCache => 'No local library cache yet. Tap Scan.';

  @override
  String get localRecentlyPlayedSubtitle => 'Songs you played recently on this device';

  @override
  String get localMostPlayedSubtitle => 'Songs you play most often';

  @override
  String bucketSongsCached(Object count) {
    return '$count songs cached for offline access.';
  }

  @override
  String get localLibraryEmptyHero => 'Offline library is empty. Scan device music first.';

  @override
  String get localCollection => 'Collection';

  @override
  String get rescanSongs => 'Rescan songs';

  @override
  String get shuffleAll => 'Shuffle All';

  @override
  String get scanText => 'Scan';

  @override
  String get searchLibraryHint => 'Search songs, artist, album, folder';

  @override
  String get songsTab => 'Songs';

  @override
  String get artistsTab => 'Artists';

  @override
  String get albumsTab => 'Albums';

  @override
  String get foldersTab => 'Folders';

  @override
  String get noArtistsFound => 'No artists found.';

  @override
  String get noAlbumsFound => 'No albums found.';

  @override
  String get noFoldersFound => 'No folders found.';

  @override
  String get noSongPlaying => 'No song playing';

  @override
  String get firstPlay => 'First play';

  @override
  String get normalMode => 'Normal';

  @override
  String get shuffleMode => 'Shuffle';

  @override
  String get loopMode => 'Loop';

  @override
  String get loopOneMode => 'Loop 1';

  @override
  String queuePosition(Object index, Object total) {
    return '$index / $total in queue';
  }

  @override
  String get lyricsPreview => 'Lyrics preview';

  @override
  String get noLyricsFound => 'No lyrics were found from .lrc or metadata.';

  @override
  String sourceText(Object label) {
    return 'Source: $label';
  }

  @override
  String get viewLyrics => 'View lyrics';

  @override
  String get lyricsDetail => 'Lyrics detail';

  @override
  String get shareSheetFailed => 'Failed to open share sheet.';

  @override
  String get prepareShareFailed => 'Failed to prepare lyric image for sharing.';

  @override
  String get lyricsSharePreviewTitle => 'Lyrics share preview';

  @override
  String get lyricsSharePreviewSubtitle => 'Choose the card theme and export format before sharing.';

  @override
  String get quickPreset => 'Quick presets';

  @override
  String get cardTheme => 'Card theme';

  @override
  String get exportFormat => 'Export format';

  @override
  String get textLayout => 'Text layout';

  @override
  String get fontSizeText => 'Font size';

  @override
  String get fontWeightText => 'Font weight';

  @override
  String get lineSpacingText => 'Line spacing';

  @override
  String get cardOptions => 'Card options';

  @override
  String get artworkBackground => 'Artwork background';

  @override
  String get footerSongInfo => 'Song info footer';

  @override
  String get shareStory => 'Share 9:16 Story';

  @override
  String get shareImage => 'Share Image';

  @override
  String get shareSelectedLyrics => 'Share selected lyrics';

  @override
  String linesSelected(Object count) {
    return '$count lines selected';
  }

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String get sharedFromLaras => 'Shared from Laras';

  @override
  String instagramStoryLabel(Object ratio) {
    return 'Instagram Story • $ratio';
  }

  @override
  String get mostPlayedLabel => 'Most Played';

  @override
  String get shareThemeLarasNight => 'Laras Night';

  @override
  String get shareThemeAuroraGlow => 'Aurora Glow';

  @override
  String get shareThemeDaylightPaper => 'Daylight Paper';

  @override
  String get shareFormatSquare => 'Square';

  @override
  String get shareFormatStory => 'Instagram Story';

  @override
  String get shareFontWeightMedium => 'Medium';

  @override
  String get shareFontWeightSemibold => 'Semibold';

  @override
  String get shareFontWeightBold => 'Bold';

  @override
  String get shareFontWeightHeavy => 'Heavy';

  @override
  String get sharePresetQuote => 'Quote';

  @override
  String get sharePresetPoster => 'Poster';

  @override
  String get sharePresetStory => 'Story';

  @override
  String get sharePresetCustom => 'Custom';

  @override
  String get shareTextAlignLeft => 'Align left';

  @override
  String get shareTextAlignCenter => 'Center';

  @override
  String get shareTextAlignRight => 'Align right';

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
