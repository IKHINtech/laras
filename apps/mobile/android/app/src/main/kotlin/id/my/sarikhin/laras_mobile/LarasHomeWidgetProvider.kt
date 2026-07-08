package id.my.sarikhin.laras_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
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
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
            val compact = minWidth < 250 || minHeight < 110
            val title = widgetData.getString(KEY_TITLE, "Tidak ada lagu") ?: "Tidak ada lagu"
            val artist = widgetData.getString(KEY_ARTIST, "Putar lagu dari Laras") ?: "Putar lagu dari Laras"
            val album = widgetData.getString(KEY_ALBUM, "Offline player") ?: "Offline player"
            val isPlaying = widgetData.getBoolean(KEY_IS_PLAYING, false)
            val artworkPath = widgetData.getString(KEY_ARTWORK_PATH, null)
            val hasSong = title != "Tidak ada lagu"

            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_artist, artist)
            views.setTextViewText(R.id.widget_album, album)
            views.setTextViewText(
                R.id.widget_hint,
                if (hasSong) album else "Offline-first library",
            )
            views.setTextViewText(
                R.id.widget_state,
                if (isPlaying) "Memutar" else if (hasSong) "Jeda" else "Siap",
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

            applySizing(context, views, compact, hasSong)

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
        val intent =
            Intent(context, MainActivity::class.java).apply {
                action = HOME_WIDGET_LAUNCH_ACTION
                data = Uri.parse(uri)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }

        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= 23) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }

        return PendingIntent.getActivity(
            context,
            uri.hashCode() and 0x7fffffff.toInt(),
            intent,
            flags,
        )
    }

    private fun applySizing(
        context: Context,
        views: RemoteViews,
        compact: Boolean,
        hasSong: Boolean,
    ) {
        views.setViewVisibility(R.id.widget_album, if (compact) View.GONE else View.VISIBLE)
        views.setViewVisibility(R.id.widget_hint, if (compact) View.GONE else View.VISIBLE)
        views.setViewVisibility(
            R.id.widget_previous,
            if (compact || !hasSong) View.GONE else View.VISIBLE,
        )
        views.setViewVisibility(
            R.id.widget_next,
            if (compact || !hasSong) View.GONE else View.VISIBLE,
        )
        views.setViewVisibility(
            R.id.widget_brand,
            if (compact) View.GONE else View.VISIBLE,
        )
        val artworkSize = if (compact) 60 else 72
        val titleSize = if (compact) 15f else 17f
        val artistSize = if (compact) 12f else 13f
        val hintTextSize = if (compact) 10f else 11f
        views.setInt(R.id.widget_artwork, "setMaxWidth", dp(context, artworkSize))
        views.setInt(R.id.widget_artwork, "setMaxHeight", dp(context, artworkSize))
        views.setTextViewTextSize(R.id.widget_title, TypedValue.COMPLEX_UNIT_SP, titleSize)
        views.setTextViewTextSize(R.id.widget_artist, TypedValue.COMPLEX_UNIT_SP, artistSize)
        views.setTextViewTextSize(R.id.widget_hint, TypedValue.COMPLEX_UNIT_SP, hintTextSize)
    }

    private fun dp(context: Context, value: Int): Int =
        TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            context.resources.displayMetrics,
        ).toInt()

    companion object {
        private const val KEY_TITLE = "laras_widget_title"
        private const val KEY_ARTIST = "laras_widget_artist"
        private const val KEY_ALBUM = "laras_widget_album"
        private const val KEY_IS_PLAYING = "laras_widget_is_playing"
        private const val KEY_ARTWORK_PATH = "laras_widget_artwork_path"
        private const val HOME_WIDGET_LAUNCH_ACTION = "es.antonborri.home_widget.action.LAUNCH"
    }
}
