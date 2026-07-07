package id.my.sarikhin.laras_mobile

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.media.audiofx.AudioEffect
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val equalizerChannelName = "laras/equalizer"
    private val appIconChannelName = "laras/app_icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, equalizerChannelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "openEqualizer") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val sessionId = call.argument<Int>("sessionId")
                if (sessionId == null) {
                    result.success(false)
                    return@setMethodCallHandler
                }

                val intent = Intent(AudioEffect.ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL).apply {
                    putExtra(AudioEffect.EXTRA_AUDIO_SESSION, sessionId)
                    putExtra(AudioEffect.EXTRA_CONTENT_TYPE, AudioEffect.CONTENT_TYPE_MUSIC)
                    putExtra(AudioEffect.EXTRA_PACKAGE_NAME, packageName)
                }

                if (intent.resolveActivity(packageManager) != null) {
                    startActivity(intent)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appIconChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setIcon" -> {
                        val variant = call.argument<String>("variant")
                        if (variant == null) {
                            result.error("missing_variant", "Launcher icon variant is required.", null)
                            return@setMethodCallHandler
                        }
                        result.success(setLauncherIcon(variant))
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun setLauncherIcon(variant: String): Boolean {
        val targetAlias =
            when (variant) {
                "default" -> "id.my.sarikhin.laras_mobile.DefaultLauncherAlias"
                "dark" -> "id.my.sarikhin.laras_mobile.DarkLauncherAlias"
                "neon" -> "id.my.sarikhin.laras_mobile.NeonLauncherAlias"
                else -> return false
            }

        val aliases =
            listOf(
                "id.my.sarikhin.laras_mobile.DefaultLauncherAlias",
                "id.my.sarikhin.laras_mobile.DarkLauncherAlias",
                "id.my.sarikhin.laras_mobile.NeonLauncherAlias",
            )

        aliases.forEach { aliasName ->
            val state =
                if (aliasName == targetAlias) {
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                } else {
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                }
            packageManager.setComponentEnabledSetting(
                ComponentName(this, aliasName),
                state,
                PackageManager.DONT_KILL_APP,
            )
        }

        return true
    }
}
