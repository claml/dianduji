package com.dianduji.dian_du_ji

import android.content.Context
import android.speech.tts.TextToSpeech
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class PronunciationChannel(context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler, TextToSpeech.OnInitListener {
    private val channel = MethodChannel(messenger, "com.dianduji.dian_du_ji/pronunciation")
    private val speaker = TextToSpeech(context, this)
    private var ready = false

    init { channel.setMethodCallHandler(this) }

    override fun onInit(status: Int) {
        if (status != TextToSpeech.SUCCESS) return
        val english = listOf(Locale.US) + speaker.availableLanguages.orEmpty().filter { it.language == Locale.ENGLISH.language }
        val locale = english.firstOrNull { speaker.isLanguageAvailable(it) >= TextToSpeech.LANG_AVAILABLE } ?: return
        ready = speaker.setLanguage(locale) >= TextToSpeech.LANG_AVAILABLE
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "speak" -> speak(call.argument<String>("text").orEmpty(), result)
            "stop" -> { speaker.stop(); result.success(null) }
            else -> result.notImplemented()
        }
    }

    private fun speak(text: String, result: MethodChannel.Result) {
        if (!ready || text.isBlank()) { result.success("unavailable"); return }
        val code = speaker.speak(text, TextToSpeech.QUEUE_FLUSH, null, "dianduji-pronunciation")
        result.success(if (code == TextToSpeech.SUCCESS) "spoken" else "unavailable")
    }

    fun dispose() { channel.setMethodCallHandler(null); speaker.stop(); speaker.shutdown() }
}
