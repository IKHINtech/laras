import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
    Locale('id')
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
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
