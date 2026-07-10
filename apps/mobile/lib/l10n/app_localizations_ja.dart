// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Laras';

  @override
  String get playbackChannelName => 'Laras Playback';

  @override
  String get navLocal => 'ローカル';

  @override
  String get navServer => 'サーバー';

  @override
  String get navPlaylists => 'プレイリスト';

  @override
  String get navSettings => '設定';

  @override
  String get statusOffline => 'オフライン';

  @override
  String get statusServer => 'サーバー';

  @override
  String get welcomeTagline => 'オフライン優先の音楽プレーヤー。ストリーミングサーバーは追加機能です。';

  @override
  String get continueOffline => 'オフラインで続ける';

  @override
  String get loginToServer => 'Laras Server にログイン';

  @override
  String get register => '登録';

  @override
  String get loginServerAccount => 'サーバーアカウントにログイン';

  @override
  String get registerServerAccount => 'サーバーアカウントを登録';

  @override
  String get larasServer => 'Laras Server';

  @override
  String get loginDescription => 'ログインはアップロード、ストリーミング、同期、サーバーからのオフラインダウンロードにのみ必要です。';

  @override
  String get fieldName => '名前';

  @override
  String get fieldEmail => 'メール';

  @override
  String get fieldPassword => 'パスワード';

  @override
  String get login => 'ログイン';

  @override
  String get alreadyHaveAccount => 'すでにアカウントがありますか？ ログイン';

  @override
  String get dontHaveAccount => 'アカウントがありませんか？ 登録';

  @override
  String loginFailed(Object error) {
    return '失敗: $error';
  }

  @override
  String get modeServerActive => 'サーバーモードが有効';

  @override
  String get modeLocalActive => 'ローカルモードが有効';

  @override
  String get modeServerSubtitle => 'Laras Server にログインしています。ローカルプレーヤーも引き続き使えます。';

  @override
  String get modeLocalSubtitle => 'ログインせずに Laras を利用しています。曲、お気に入り、ローカルプレイリストは端末に保存されます。';

  @override
  String get theme => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageIndonesian => 'インドネシア語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get unknownArtist => '不明なアーティスト';

  @override
  String get unknownAlbum => '不明なアルバム';

  @override
  String get unknownFolder => '不明なフォルダ';

  @override
  String get unknownTitle => '不明なタイトル';

  @override
  String get unknownLabel => '不明';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get recentlyPlayed => '最近再生';

  @override
  String get serverDashboard => 'サーバーダッシュボード';

  @override
  String get upload => 'アップロード';

  @override
  String get serverDashboardEmpty => 'サーバー再生履歴はまだありません。まずサーバーの曲を再生してください。';

  @override
  String get serverRecentlyPlayedSubtitle => '最近再生したサーバーの曲';

  @override
  String get serverMostPlayedSubtitle => 'よく再生するサーバーの曲';

  @override
  String get totalSongsLabel => '総曲数';

  @override
  String get storageLabel => 'ストレージ';

  @override
  String get recentLabel => '最近';

  @override
  String get searchServerSongs => 'サーバーの曲を検索';

  @override
  String get noSongsOnServer => 'サーバーに曲がありません。';

  @override
  String get noMatchingSongs => '一致する曲がありません。';

  @override
  String get localPlaylistsIntro => 'ローカルのお気に入りとプレイリストはログイン不要で端末に保存されます。';

  @override
  String get playlistButton => 'プレイリスト';

  @override
  String get createLocalPlaylist => 'ローカルプレイリストを作成';

  @override
  String get playlistName => 'プレイリスト名';

  @override
  String get cancelText => 'キャンセル';

  @override
  String get createText => '作成';

  @override
  String get deletePlaylistTitle => 'プレイリストを削除しますか？';

  @override
  String deletePlaylistMessage(Object name) {
    return 'プレイリスト「$name」はこの端末から削除されます。';
  }

  @override
  String get deleteText => '削除';

  @override
  String get noPlayHistory => '再生履歴はまだありません';

  @override
  String recentSongsCount(Object count) {
    return '最近の $count 曲';
  }

  @override
  String get noPlayStats => '再生統計はまだありません';

  @override
  String topSongsCount(Object count) {
    return '上位 $count 曲';
  }

  @override
  String get favoriteSongs => 'お気に入りの曲';

  @override
  String songsCount(Object count) {
    return '$count 曲';
  }

  @override
  String get noLocalPlaylistYet => 'ローカルプレイリストはまだありません。作成するか、ローカルタブから曲を追加してください。';

  @override
  String get clearRecentPlayedTitle => '最近再生を消去しますか？';

  @override
  String get clearMostPlayedTitle => '最も再生をリセットしますか？';

  @override
  String get clearLocalPlaybackWarning => 'ローカル再生履歴はこの端末から削除されます。';

  @override
  String get noRecentPlayedDetail => '再生履歴はまだありません。まずローカルの曲を再生してください。';

  @override
  String get noMostPlayedDetail => '最も再生された曲のデータはまだありません。';

  @override
  String get noServerRecentDetail => 'サーバー再生履歴はまだありません。まずサーバーの曲を再生してください。';

  @override
  String get noServerMostPlayedDetail => '最も再生されたサーバー曲のデータはまだありません。';

  @override
  String playsCount(Object count) {
    return '$count 回再生';
  }

  @override
  String recentPlaybackSubtitle(Object artist, Object playedAt, Object playCount) {
    return '$artist • $playedAt • $playCount';
  }

  @override
  String mostPlayedSubtitle(Object artist, Object playCount, Object playedAt) {
    return '$artist • $playCount • 最後は $playedAt';
  }

  @override
  String rankLabel(Object index) {
    return '#$index';
  }

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(Object value) {
    return '$value 分前';
  }

  @override
  String hoursAgo(Object value) {
    return '$value 時間前';
  }

  @override
  String daysAgo(Object value) {
    return '$value 日前';
  }

  @override
  String weeksAgo(Object value) {
    return '$value 週間前';
  }

  @override
  String monthsAgo(Object value) {
    return '$value か月前';
  }

  @override
  String yearsAgo(Object value) {
    return '$value 年前';
  }

  @override
  String get removeSongFromPlaylistTitle => 'プレイリストから曲を削除しますか？';

  @override
  String removeSongFromPlaylistMessage(Object title) {
    return '「$title」はこのプレイリストから削除されます。';
  }

  @override
  String get searchPlaylist => 'プレイリストを検索';

  @override
  String get closeSearch => '検索を閉じる';

  @override
  String get searchText => '検索';

  @override
  String get playlistEmpty => 'プレイリストは空です';

  @override
  String get noSongsMatchSearch => '検索に一致する曲がありません。';

  @override
  String get playText => '再生';

  @override
  String scannedLocalSongs(Object count) {
    return '$count 曲のローカル曲をスキャンしました';
  }

  @override
  String addedToPlaylist(Object name) {
    return '$name に追加しました';
  }

  @override
  String get removeFavorite => 'お気に入りを削除';

  @override
  String get addFavorite => 'お気に入りに追加';

  @override
  String get addToPlaylist => 'プレイリストに追加';

  @override
  String get noLocalLibraryCache => 'ローカルライブラリのキャッシュはまだありません。Scan を押してください。';

  @override
  String get localRecentlyPlayedSubtitle => 'この端末で最近再生した曲';

  @override
  String get localMostPlayedSubtitle => 'この端末でよく再生する曲';

  @override
  String bucketSongsCached(Object count) {
    return '$count 曲をオフライン閲覧用に保存しました。';
  }

  @override
  String get localLibraryEmptyHero => 'オフラインライブラリは空です。まず端末の音楽をスキャンしてください。';

  @override
  String get localCollection => 'コレクション';

  @override
  String get rescanSongs => '曲を再スキャン';

  @override
  String get shuffleAll => 'すべてシャッフル';

  @override
  String get scanText => 'スキャン';

  @override
  String get searchLibraryHint => '曲、アーティスト、アルバム、フォルダを検索';

  @override
  String get songsTab => '曲';

  @override
  String get artistsTab => 'アーティスト';

  @override
  String get albumsTab => 'アルバム';

  @override
  String get foldersTab => 'フォルダ';

  @override
  String get noArtistsFound => 'アーティストがありません。';

  @override
  String get noAlbumsFound => 'アルバムがありません。';

  @override
  String get noFoldersFound => 'フォルダがありません。';

  @override
  String get noSongPlaying => '再生中の曲はありません';

  @override
  String get firstPlay => '初回再生';

  @override
  String get normalMode => '通常';

  @override
  String get shuffleMode => 'シャッフル';

  @override
  String get loopMode => 'ループ';

  @override
  String get loopOneMode => '1曲ループ';

  @override
  String queuePosition(Object index, Object total) {
    return '$index / $total キュー内';
  }

  @override
  String get lyricsPreview => '歌詞プレビュー';

  @override
  String get noLyricsFound => '.lrc またはメタデータから歌詞が見つかりませんでした。';

  @override
  String sourceText(Object label) {
    return 'ソース: $label';
  }

  @override
  String get viewLyrics => '歌詞を見る';

  @override
  String get lyricsDetail => '歌詞の詳細';

  @override
  String get shareSheetFailed => '共有シートを開けませんでした。';

  @override
  String get prepareShareFailed => '共有用の歌詞画像を準備できませんでした。';

  @override
  String get lyricsSharePreviewTitle => '歌詞共有プレビュー';

  @override
  String get lyricsSharePreviewSubtitle => '共有前にカードテーマと書き出し形式を選択してください。';

  @override
  String get quickPreset => 'クイックプリセット';

  @override
  String get cardTheme => 'カードテーマ';

  @override
  String get exportFormat => '書き出し形式';

  @override
  String get textLayout => 'テキスト配置';

  @override
  String get fontSizeText => 'フォントサイズ';

  @override
  String get fontWeightText => 'フォントの太さ';

  @override
  String get lineSpacingText => '行間';

  @override
  String get cardOptions => 'カードオプション';

  @override
  String get artworkBackground => 'アートワーク背景';

  @override
  String get footerSongInfo => '曲情報フッター';

  @override
  String get shareStory => '9:16 ストーリーで共有';

  @override
  String get shareImage => '画像を共有';

  @override
  String get shareSelectedLyrics => '選択した歌詞を共有';

  @override
  String linesSelected(Object count) {
    return '$count 行を選択中';
  }

  @override
  String get cancelSelection => '選択を解除';

  @override
  String get sharedFromLaras => 'Laras から共有';

  @override
  String instagramStoryLabel(Object ratio) {
    return 'Instagram Story • $ratio';
  }

  @override
  String get mostPlayedLabel => 'よく再生';

  @override
  String get shareThemeLarasNight => 'Laras Night';

  @override
  String get shareThemeAuroraGlow => 'Aurora Glow';

  @override
  String get shareThemeDaylightPaper => 'Daylight Paper';

  @override
  String get shareFormatSquare => 'スクエア';

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
  String get sharePresetCustom => 'カスタム';

  @override
  String get shareTextAlignLeft => '左寄せ';

  @override
  String get shareTextAlignCenter => '中央揃え';

  @override
  String get shareTextAlignRight => '右寄せ';

  @override
  String get paletteLarasDefault => 'Laras Default';

  @override
  String get paletteOceanBlue => 'オーシャンブルー';

  @override
  String get paletteBurntOrange => 'バーントオレンジ';

  @override
  String get paletteRosePink => 'ローズピンク';

  @override
  String get paletteEarthBrown => 'アースブラウン';

  @override
  String get paletteCustom => 'カスタム';

  @override
  String get appIcon => 'アプリアイコン';

  @override
  String get sleepTimer => 'スリープタイマー';

  @override
  String get stopPlaybackAutomatically => '再生を自動停止';

  @override
  String remaining(Object value) {
    return '残り: $value';
  }

  @override
  String get off => 'オフ';

  @override
  String minutesSeconds(Object minutes, Object seconds) {
    return '$minutes分 $seconds秒';
  }

  @override
  String get lyricsLrc => '歌詞 .lrc';

  @override
  String get lyricsLrcDescription => 'Now Playing は .lrc を優先し、利用可能なら歌詞メタデータにフォールバックします。';

  @override
  String get systemEqualizer => 'システムイコライザー';

  @override
  String get systemEqualizerDescription => '端末が対応している場合、Android 標準のイコライザーを開きます。';

  @override
  String get backgroundLockScreen => 'バックグラウンド / ロック画面';

  @override
  String get backgroundLockScreenDescription => 'メディアサービス、通知コントロール、メディアボタンは Android マニフェストで設定済みです。';

  @override
  String get account => 'アカウント';

  @override
  String get loginToServerDescription => '個人サーバーをアップロード、ストリーム、同期に使用します。';

  @override
  String get registerServerDescription => '個人用 Laras サーバーアカウントを作成します。';

  @override
  String get logoutFromServer => 'サーバーからログアウト';

  @override
  String get logoutFromServerDescription => 'ローカルライブラリ、お気に入り、プレイリストは削除されません。';

  @override
  String get offlineStillPrimary => 'オフラインが主役';

  @override
  String get offlineStillPrimaryDescription => 'サーバーログインは追加機能で、設定からいつでも使えます。';

  @override
  String get equalizerOpened => 'Android イコライザーを開きました';

  @override
  String get equalizerUnavailable => 'イコライザーは利用できません。まず再生を開始してください。';

  @override
  String launcherIconSwitched(Object label) {
    return 'ランチャーアイコンを $label に切り替えました。';
  }

  @override
  String get launcherIconFailed => 'ランチャーアイコンの切り替えに失敗しました。';

  @override
  String get iconDefault => 'デフォルト';

  @override
  String get iconDark => 'ダーク';

  @override
  String get iconNeon => 'ネオン';

  @override
  String get iconDefaultDescription => '標準の Laras アイコン';

  @override
  String get iconDarkDescription => '落ち着いたダークバージョン';

  @override
  String get iconNeonDescription => 'ネオン調の明るいバージョン';

  @override
  String get pickThemeColor => 'テーマカラーを選択';

  @override
  String get hue => '色相';

  @override
  String get saturation => '彩度';

  @override
  String get brightness => '明るさ';

  @override
  String get cancel => 'キャンセル';

  @override
  String get apply => '適用';
}
