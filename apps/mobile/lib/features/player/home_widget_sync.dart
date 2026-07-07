import 'package:home_widget/home_widget.dart';

import '../library/song.dart';

class LarasHomeWidgetSync {
  static const providerName = 'LarasHomeWidgetProvider';

  static Future<void> sync({
    required Song? song,
    required bool isPlaying,
    String? artworkPath,
  }) async {
    await HomeWidget.saveWidgetData<String>(
      'laras_widget_title',
      song?.title ?? 'Tidak ada lagu',
    );
    await HomeWidget.saveWidgetData<String>(
      'laras_widget_artist',
      song?.artistLabel ?? 'Putar lagu dari Laras',
    );
    await HomeWidget.saveWidgetData<String>(
      'laras_widget_album',
      song?.albumLabel ?? 'Offline player',
    );
    await HomeWidget.saveWidgetData<bool>(
      'laras_widget_is_playing',
      song != null && isPlaying,
    );
    await HomeWidget.saveWidgetData<String>(
      'laras_widget_artwork_path',
      artworkPath ?? '',
    );
    await HomeWidget.updateWidget(name: providerName);
  }
}
