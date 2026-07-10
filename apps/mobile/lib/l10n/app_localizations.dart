import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('ja')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Laras'**
  String get appTitle;

  /// No description provided for @playbackChannelName.
  ///
  /// In en, this message translates to:
  /// **'Laras Playback'**
  String get playbackChannelName;

  /// No description provided for @navLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get navLocal;

  /// No description provided for @navServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get navServer;

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @statusServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get statusServer;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Offline-first music player. Streaming server is only an extra feature.'**
  String get welcomeTagline;

  /// No description provided for @continueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue Offline'**
  String get continueOffline;

  /// No description provided for @loginToServer.
  ///
  /// In en, this message translates to:
  /// **'Login to Laras Server'**
  String get loginToServer;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @loginServerAccount.
  ///
  /// In en, this message translates to:
  /// **'Login Server Account'**
  String get loginServerAccount;

  /// No description provided for @registerServerAccount.
  ///
  /// In en, this message translates to:
  /// **'Register Server Account'**
  String get registerServerAccount;

  /// No description provided for @larasServer.
  ///
  /// In en, this message translates to:
  /// **'Laras Server'**
  String get larasServer;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Login is only required for upload, streaming, sync, and offline download from the server.'**
  String get loginDescription;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String loginFailed(Object error);

  /// No description provided for @modeServerActive.
  ///
  /// In en, this message translates to:
  /// **'Server Mode active'**
  String get modeServerActive;

  /// No description provided for @modeLocalActive.
  ///
  /// In en, this message translates to:
  /// **'Local Mode active'**
  String get modeLocalActive;

  /// No description provided for @modeServerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are logged in to Laras Server. The local player is still available.'**
  String get modeServerSubtitle;

  /// No description provided for @modeLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are using Laras without login. Songs, favorites, and local playlists are stored on the device.'**
  String get modeLocalSubtitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get languageIndonesian;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown Artist'**
  String get unknownArtist;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown Album'**
  String get unknownAlbum;

  /// No description provided for @unknownFolder.
  ///
  /// In en, this message translates to:
  /// **'Unknown Folder'**
  String get unknownFolder;

  /// No description provided for @unknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Title'**
  String get unknownTitle;

  /// No description provided for @unknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownLabel;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @serverDashboard.
  ///
  /// In en, this message translates to:
  /// **'Server Dashboard'**
  String get serverDashboard;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @serverDashboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No server playback yet. Start playing server songs first.'**
  String get serverDashboardEmpty;

  /// No description provided for @serverRecentlyPlayedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Server songs you played recently'**
  String get serverRecentlyPlayedSubtitle;

  /// No description provided for @serverMostPlayedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Server songs you played most often'**
  String get serverMostPlayedSubtitle;

  /// No description provided for @totalSongsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Songs'**
  String get totalSongsLabel;

  /// No description provided for @storageLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageLabel;

  /// No description provided for @recentLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentLabel;

  /// No description provided for @searchServerSongs.
  ///
  /// In en, this message translates to:
  /// **'Search server songs'**
  String get searchServerSongs;

  /// No description provided for @noSongsOnServer.
  ///
  /// In en, this message translates to:
  /// **'No songs on the server yet.'**
  String get noSongsOnServer;

  /// No description provided for @noMatchingSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs match.'**
  String get noMatchingSongs;

  /// No description provided for @localPlaylistsIntro.
  ///
  /// In en, this message translates to:
  /// **'Local favorites and playlists are stored on this device without login.'**
  String get localPlaylistsIntro;

  /// No description provided for @playlistButton.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistButton;

  /// No description provided for @createLocalPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create local playlist'**
  String get createLocalPlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @cancelText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelText;

  /// No description provided for @createText.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createText;

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist?'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistMessage.
  ///
  /// In en, this message translates to:
  /// **'Playlist \"{name}\" will be deleted from this device.'**
  String deletePlaylistMessage(Object name);

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteText;

  /// No description provided for @noPlayHistory.
  ///
  /// In en, this message translates to:
  /// **'No play history yet'**
  String get noPlayHistory;

  /// No description provided for @recentSongsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recent songs'**
  String recentSongsCount(Object count);

  /// No description provided for @noPlayStats.
  ///
  /// In en, this message translates to:
  /// **'No play stats yet'**
  String get noPlayStats;

  /// No description provided for @topSongsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} top songs'**
  String topSongsCount(Object count);

  /// No description provided for @favoriteSongs.
  ///
  /// In en, this message translates to:
  /// **'Favorite Songs'**
  String get favoriteSongs;

  /// No description provided for @songsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} songs'**
  String songsCount(Object count);

  /// No description provided for @noLocalPlaylistYet.
  ///
  /// In en, this message translates to:
  /// **'No local playlists yet. Create one or add songs from the Local tab.'**
  String get noLocalPlaylistYet;

  /// No description provided for @clearRecentPlayedTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Recently Played?'**
  String get clearRecentPlayedTitle;

  /// No description provided for @clearMostPlayedTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Most Played?'**
  String get clearMostPlayedTitle;

  /// No description provided for @clearLocalPlaybackWarning.
  ///
  /// In en, this message translates to:
  /// **'Local playback history will be removed from this device.'**
  String get clearLocalPlaybackWarning;

  /// No description provided for @noRecentPlayedDetail.
  ///
  /// In en, this message translates to:
  /// **'No play history yet. Start playing local songs first.'**
  String get noRecentPlayedDetail;

  /// No description provided for @noMostPlayedDetail.
  ///
  /// In en, this message translates to:
  /// **'No most-played song data yet.'**
  String get noMostPlayedDetail;

  /// No description provided for @noServerRecentDetail.
  ///
  /// In en, this message translates to:
  /// **'No server play history yet. Start playing server songs first.'**
  String get noServerRecentDetail;

  /// No description provided for @noServerMostPlayedDetail.
  ///
  /// In en, this message translates to:
  /// **'No most-played server song data yet.'**
  String get noServerMostPlayedDetail;

  /// No description provided for @playsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} plays'**
  String playsCount(Object count);

  /// No description provided for @recentPlaybackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{artist} • {playedAt} • {playCount}'**
  String recentPlaybackSubtitle(Object artist, Object playedAt, Object playCount);

  /// No description provided for @mostPlayedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{artist} • {playCount} • last {playedAt}'**
  String mostPlayedSubtitle(Object artist, Object playCount, Object playedAt);

  /// No description provided for @rankLabel.
  ///
  /// In en, this message translates to:
  /// **'#{index}'**
  String rankLabel(Object index);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{value} minutes ago'**
  String minutesAgo(Object value);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{value} hours ago'**
  String hoursAgo(Object value);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{value} days ago'**
  String daysAgo(Object value);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{value} weeks ago'**
  String weeksAgo(Object value);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{value} months ago'**
  String monthsAgo(Object value);

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{value} years ago'**
  String yearsAgo(Object value);

  /// No description provided for @removeSongFromPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove song from playlist?'**
  String get removeSongFromPlaylistTitle;

  /// No description provided for @removeSongFromPlaylistMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed from this playlist.'**
  String removeSongFromPlaylistMessage(Object title);

  /// No description provided for @searchPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Search playlist'**
  String get searchPlaylist;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @searchText.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchText;

  /// No description provided for @playlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Playlist empty'**
  String get playlistEmpty;

  /// No description provided for @noSongsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No songs match search.'**
  String get noSongsMatchSearch;

  /// No description provided for @playText.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playText;

  /// No description provided for @scannedLocalSongs.
  ///
  /// In en, this message translates to:
  /// **'Scanned {count} local songs'**
  String scannedLocalSongs(Object count);

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToPlaylist(Object name);

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavorite;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get addFavorite;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @noLocalLibraryCache.
  ///
  /// In en, this message translates to:
  /// **'No local library cache yet. Tap Scan.'**
  String get noLocalLibraryCache;

  /// No description provided for @localRecentlyPlayedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Songs you played recently on this device'**
  String get localRecentlyPlayedSubtitle;

  /// No description provided for @localMostPlayedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Songs you play most often'**
  String get localMostPlayedSubtitle;

  /// No description provided for @bucketSongsCached.
  ///
  /// In en, this message translates to:
  /// **'{count} songs cached for offline access.'**
  String bucketSongsCached(Object count);

  /// No description provided for @localLibraryEmptyHero.
  ///
  /// In en, this message translates to:
  /// **'Offline library is empty. Scan device music first.'**
  String get localLibraryEmptyHero;

  /// No description provided for @localCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get localCollection;

  /// No description provided for @rescanSongs.
  ///
  /// In en, this message translates to:
  /// **'Rescan songs'**
  String get rescanSongs;

  /// No description provided for @shuffleAll.
  ///
  /// In en, this message translates to:
  /// **'Shuffle All'**
  String get shuffleAll;

  /// No description provided for @scanText.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanText;

  /// No description provided for @searchLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Search songs, artist, album, folder'**
  String get searchLibraryHint;

  /// No description provided for @songsTab.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songsTab;

  /// No description provided for @artistsTab.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artistsTab;

  /// No description provided for @albumsTab.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albumsTab;

  /// No description provided for @foldersTab.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get foldersTab;

  /// No description provided for @noArtistsFound.
  ///
  /// In en, this message translates to:
  /// **'No artists found.'**
  String get noArtistsFound;

  /// No description provided for @noAlbumsFound.
  ///
  /// In en, this message translates to:
  /// **'No albums found.'**
  String get noAlbumsFound;

  /// No description provided for @noFoldersFound.
  ///
  /// In en, this message translates to:
  /// **'No folders found.'**
  String get noFoldersFound;

  /// No description provided for @noSongPlaying.
  ///
  /// In en, this message translates to:
  /// **'No song playing'**
  String get noSongPlaying;

  /// No description provided for @firstPlay.
  ///
  /// In en, this message translates to:
  /// **'First play'**
  String get firstPlay;

  /// No description provided for @normalMode.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normalMode;

  /// No description provided for @shuffleMode.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffleMode;

  /// No description provided for @loopMode.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get loopMode;

  /// No description provided for @loopOneMode.
  ///
  /// In en, this message translates to:
  /// **'Loop 1'**
  String get loopOneMode;

  /// No description provided for @queuePosition.
  ///
  /// In en, this message translates to:
  /// **'{index} / {total} in queue'**
  String queuePosition(Object index, Object total);

  /// No description provided for @lyricsPreview.
  ///
  /// In en, this message translates to:
  /// **'Lyrics preview'**
  String get lyricsPreview;

  /// No description provided for @noLyricsFound.
  ///
  /// In en, this message translates to:
  /// **'No lyrics were found from .lrc or metadata.'**
  String get noLyricsFound;

  /// No description provided for @sourceText.
  ///
  /// In en, this message translates to:
  /// **'Source: {label}'**
  String sourceText(Object label);

  /// No description provided for @viewLyrics.
  ///
  /// In en, this message translates to:
  /// **'View lyrics'**
  String get viewLyrics;

  /// No description provided for @lyricsDetail.
  ///
  /// In en, this message translates to:
  /// **'Lyrics detail'**
  String get lyricsDetail;

  /// No description provided for @shareSheetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open share sheet.'**
  String get shareSheetFailed;

  /// No description provided for @prepareShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to prepare lyric image for sharing.'**
  String get prepareShareFailed;

  /// No description provided for @lyricsSharePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Lyrics share preview'**
  String get lyricsSharePreviewTitle;

  /// No description provided for @lyricsSharePreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the card theme and export format before sharing.'**
  String get lyricsSharePreviewSubtitle;

  /// No description provided for @quickPreset.
  ///
  /// In en, this message translates to:
  /// **'Quick presets'**
  String get quickPreset;

  /// No description provided for @cardTheme.
  ///
  /// In en, this message translates to:
  /// **'Card theme'**
  String get cardTheme;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export format'**
  String get exportFormat;

  /// No description provided for @textLayout.
  ///
  /// In en, this message translates to:
  /// **'Text layout'**
  String get textLayout;

  /// No description provided for @fontSizeText.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSizeText;

  /// No description provided for @fontWeightText.
  ///
  /// In en, this message translates to:
  /// **'Font weight'**
  String get fontWeightText;

  /// No description provided for @lineSpacingText.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get lineSpacingText;

  /// No description provided for @cardOptions.
  ///
  /// In en, this message translates to:
  /// **'Card options'**
  String get cardOptions;

  /// No description provided for @artworkBackground.
  ///
  /// In en, this message translates to:
  /// **'Artwork background'**
  String get artworkBackground;

  /// No description provided for @footerSongInfo.
  ///
  /// In en, this message translates to:
  /// **'Song info footer'**
  String get footerSongInfo;

  /// No description provided for @shareStory.
  ///
  /// In en, this message translates to:
  /// **'Share 9:16 Story'**
  String get shareStory;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share Image'**
  String get shareImage;

  /// No description provided for @shareSelectedLyrics.
  ///
  /// In en, this message translates to:
  /// **'Share selected lyrics'**
  String get shareSelectedLyrics;

  /// No description provided for @linesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} lines selected'**
  String linesSelected(Object count);

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get cancelSelection;

  /// No description provided for @sharedFromLaras.
  ///
  /// In en, this message translates to:
  /// **'Shared from Laras'**
  String get sharedFromLaras;

  /// No description provided for @instagramStoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Instagram Story • {ratio}'**
  String instagramStoryLabel(Object ratio);

  /// No description provided for @mostPlayedLabel.
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get mostPlayedLabel;

  /// No description provided for @shareThemeLarasNight.
  ///
  /// In en, this message translates to:
  /// **'Laras Night'**
  String get shareThemeLarasNight;

  /// No description provided for @shareThemeAuroraGlow.
  ///
  /// In en, this message translates to:
  /// **'Aurora Glow'**
  String get shareThemeAuroraGlow;

  /// No description provided for @shareThemeDaylightPaper.
  ///
  /// In en, this message translates to:
  /// **'Daylight Paper'**
  String get shareThemeDaylightPaper;

  /// No description provided for @shareFormatSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get shareFormatSquare;

  /// No description provided for @shareFormatStory.
  ///
  /// In en, this message translates to:
  /// **'Instagram Story'**
  String get shareFormatStory;

  /// No description provided for @shareFontWeightMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get shareFontWeightMedium;

  /// No description provided for @shareFontWeightSemibold.
  ///
  /// In en, this message translates to:
  /// **'Semibold'**
  String get shareFontWeightSemibold;

  /// No description provided for @shareFontWeightBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get shareFontWeightBold;

  /// No description provided for @shareFontWeightHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get shareFontWeightHeavy;

  /// No description provided for @sharePresetQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get sharePresetQuote;

  /// No description provided for @sharePresetPoster.
  ///
  /// In en, this message translates to:
  /// **'Poster'**
  String get sharePresetPoster;

  /// No description provided for @sharePresetStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get sharePresetStory;

  /// No description provided for @sharePresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get sharePresetCustom;

  /// No description provided for @shareTextAlignLeft.
  ///
  /// In en, this message translates to:
  /// **'Align left'**
  String get shareTextAlignLeft;

  /// No description provided for @shareTextAlignCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get shareTextAlignCenter;

  /// No description provided for @shareTextAlignRight.
  ///
  /// In en, this message translates to:
  /// **'Align right'**
  String get shareTextAlignRight;

  /// No description provided for @paletteLarasDefault.
  ///
  /// In en, this message translates to:
  /// **'Laras Default'**
  String get paletteLarasDefault;

  /// No description provided for @paletteOceanBlue.
  ///
  /// In en, this message translates to:
  /// **'Ocean Blue'**
  String get paletteOceanBlue;

  /// No description provided for @paletteBurntOrange.
  ///
  /// In en, this message translates to:
  /// **'Burnt Orange'**
  String get paletteBurntOrange;

  /// No description provided for @paletteRosePink.
  ///
  /// In en, this message translates to:
  /// **'Rose Pink'**
  String get paletteRosePink;

  /// No description provided for @paletteEarthBrown.
  ///
  /// In en, this message translates to:
  /// **'Earth Brown'**
  String get paletteEarthBrown;

  /// No description provided for @paletteCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get paletteCustom;

  /// No description provided for @appIcon.
  ///
  /// In en, this message translates to:
  /// **'App Icon'**
  String get appIcon;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get sleepTimer;

  /// No description provided for @stopPlaybackAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Stop playback automatically'**
  String get stopPlaybackAutomatically;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {value}'**
  String remaining(Object value);

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @minutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String minutesSeconds(Object minutes, Object seconds);

  /// No description provided for @lyricsLrc.
  ///
  /// In en, this message translates to:
  /// **'Lyrics .lrc'**
  String get lyricsLrc;

  /// No description provided for @lyricsLrcDescription.
  ///
  /// In en, this message translates to:
  /// **'Now Playing prioritizes .lrc, then falls back to lyric metadata when available.'**
  String get lyricsLrcDescription;

  /// No description provided for @systemEqualizer.
  ///
  /// In en, this message translates to:
  /// **'System Equalizer'**
  String get systemEqualizer;

  /// No description provided for @systemEqualizerDescription.
  ///
  /// In en, this message translates to:
  /// **'Open the built-in Android equalizer when supported by the device.'**
  String get systemEqualizerDescription;

  /// No description provided for @backgroundLockScreen.
  ///
  /// In en, this message translates to:
  /// **'Background / Lock Screen'**
  String get backgroundLockScreen;

  /// No description provided for @backgroundLockScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Media service, notification control, and media buttons are already configured in the Android manifest.'**
  String get backgroundLockScreenDescription;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @loginToServerDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your private server for upload, stream, and sync.'**
  String get loginToServerDescription;

  /// No description provided for @registerServerDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your personal Laras server account.'**
  String get registerServerDescription;

  /// No description provided for @logoutFromServer.
  ///
  /// In en, this message translates to:
  /// **'Logout from server'**
  String get logoutFromServer;

  /// No description provided for @logoutFromServerDescription.
  ///
  /// In en, this message translates to:
  /// **'Does not delete local library, favorites, or playlists.'**
  String get logoutFromServerDescription;

  /// No description provided for @offlineStillPrimary.
  ///
  /// In en, this message translates to:
  /// **'Offline stays primary'**
  String get offlineStillPrimary;

  /// No description provided for @offlineStillPrimaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Server login is only an extra feature and can be accessed any time from Settings.'**
  String get offlineStillPrimaryDescription;

  /// No description provided for @equalizerOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened Android equalizer'**
  String get equalizerOpened;

  /// No description provided for @equalizerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Equalizer unavailable. Start playback first.'**
  String get equalizerUnavailable;

  /// No description provided for @launcherIconSwitched.
  ///
  /// In en, this message translates to:
  /// **'Launcher icon switched to {label}.'**
  String launcherIconSwitched(Object label);

  /// No description provided for @launcherIconFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change launcher icon.'**
  String get launcherIconFailed;

  /// No description provided for @iconDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get iconDefault;

  /// No description provided for @iconDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get iconDark;

  /// No description provided for @iconNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get iconNeon;

  /// No description provided for @iconDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Standard Laras icon'**
  String get iconDefaultDescription;

  /// No description provided for @iconDarkDescription.
  ///
  /// In en, this message translates to:
  /// **'A darker and subtler version'**
  String get iconDarkDescription;

  /// No description provided for @iconNeonDescription.
  ///
  /// In en, this message translates to:
  /// **'A brighter version with neon'**
  String get iconNeonDescription;

  /// No description provided for @pickThemeColor.
  ///
  /// In en, this message translates to:
  /// **'Pick theme color'**
  String get pickThemeColor;

  /// No description provided for @hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hue;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
    case 'ja': return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
