package id.my.sarikhin.laras_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.os.Build
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File

class LarasHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.laras_home_widget)
            val title = widgetData.getString(KEY_TITLE, "Tidak ada lagu") ?: "Tidak ada lagu"
            val artist = widgetData.getString(KEY_ARTIST, "Putar lagu dari Laras") ?: "Putar lagu dari Laras"
            val album = widgetData.getString(KEY_ALBUM, "Offline player") ?: "Offline player"
            val isPlaying = widgetData.getBoolean(KEY_IS_PLAYING, false)
            val artworkPath = widgetData.getString(KEY_ARTWORK_PATH, null)

            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_artist, artist)
            views.setTextViewText(R.id.widget_album, album)
            views.setTextViewText(
                R.id.widget_state,
                if (isPlaying) "Sedang diputar" else "Jeda",
            )

            val artworkBitmap =
                artworkPath
                    ?.takeIf { it.isNotBlank() }
                    ?.let(::File)
                    ?.takeIf { it.exists() }
                    ?.let { BitmapFactory.decodeFile(it.absolutePath) }

            if (artworkBitmap != null) {
                views.setImageViewBitmap(R.id.widget_artwork, artworkBitmap)
            } else {
                views.setImageViewResource(R.id.widget_artwork, R.drawable.ic_stat_laras)
            }

            views.setOnClickPendingIntent(
                R.id.widget_root,
                launchIntent(context, "laras://now-playing"),
            )
            views.setOnClickPendingIntent(
                R.id.widget_artwork,
                launchIntent(context, "laras://now-playing"),
            )
            views.setOnClickPendingIntent(
                R.id.widget_previous,
                launchIntent(context, "laras://player?action=previous"),
            )
            views.setOnClickPendingIntent(
                R.id.widget_play_pause,
                launchIntent(context, "laras://player?action=play-pause"),
            )
            views.setOnClickPendingIntent(
                R.id.widget_next,
                launchIntent(context, "laras://player?action=next"),
            )
            views.setImageViewResource(
                R.id.widget_play_pause,
                if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play,
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun launchIntent(context: Context, uri: String): PendingIntent {
        return HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse(uri),
        )
    }

    companion object {
        private const val KEY_TITLE = "laras_widget_title"
        private const val KEY_ARTIST = "laras_widget_artist"
        private const val KEY_ALBUM = "laras_widget_album"
        private const val KEY_IS_PLAYING = "laras_widget_is_playing"
        private const val KEY_ARTWORK_PATH = "laras_widget_artwork_path"
    }
}
