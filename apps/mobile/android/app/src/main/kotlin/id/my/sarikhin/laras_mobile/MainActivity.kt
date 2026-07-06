package id.my.sarikhin.laras_mobile

import android.content.Intent
import android.media.audiofx.AudioEffect
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val channelName = "laras/equalizer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
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
    }
}
