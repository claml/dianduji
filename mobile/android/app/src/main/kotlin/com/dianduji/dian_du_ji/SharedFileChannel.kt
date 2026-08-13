package com.dianduji.dian_du_ji

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Receives ACTION_SEND / ACTION_VIEW intents that deliver a supported
 * document through a content URI, copies the bytes into the application
 * cache, and emits `{path, name, mime}` events on the
 * `com.dianduji/dian_du_ji/shared_files/events` channel.
 *
 * Every event is buffered until the first Dart listener attaches and then
 * flushed exactly once, so cold-start intents are replayed to the app without
 * being delivered twice. Failure events carry `{error, name}` instead of a
 * path, e.g. `permission_revoked` when the sharing app revoked read access.
 */
class SharedFileChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) {
    private val eventsChannel = EventChannel(messenger, EVENTS_NAME)
    private val pending = ArrayDeque<Map<String, Any?>>()
    private val deduplicator = SharedFileDeduplicator()
    private var eventSink: EventChannel.EventSink? = null

    init {
        eventsChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                while (pending.isNotEmpty()) events?.success(pending.removeFirst())
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    fun handleIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        if (action != Intent.ACTION_SEND && action != Intent.ACTION_VIEW) return
        val uri = if (action == Intent.ACTION_SEND) {
            intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        } else {
            intent.data
        }
        if (uri == null || uri.scheme != "content") return
        val mime = intent.type
        if (mime == null || mime !in SharedFileDeduplicator.SUPPORTED_MIMES) {
            emit(mapOf("error" to "unsupported_mime", "name" to displayName(uri)))
            return
        }
        val fingerprint = fingerprintOf(action, uri, mime)
        if (!deduplicator.accept(fingerprint)) return

        val destination = try {
            copyToCache(uri)
        } catch (security: SecurityException) {
            emit(mapOf("error" to "permission_revoked", "name" to displayName(uri)))
            return
        }
        emit(
            mapOf(
                "path" to destination.absolutePath,
                "name" to displayName(uri),
                "mime" to mime,
            ),
        )
    }

    private fun emit(event: Map<String, Any?>) {
        val sink = eventSink
        if (sink != null) sink.success(event) else pending.addLast(event)
    }

    private fun copyToCache(uri: Uri): File {
        val input = activity.contentResolver.openInputStream(uri)
            ?: throw SecurityException("shared_uri_unavailable")
        input.use { source ->
            val destination = File(
                activity.cacheDir,
                "shared-${System.currentTimeMillis()}-${Math.abs(uri.hashCode())}.bin",
            )
            FileOutputStream(destination).use { output -> source.copyTo(output) }
            return destination
        }
    }

    private fun fingerprintOf(action: String, uri: Uri, mime: String): String {
        var size = -1L
        var modified = -1L
        activity.contentResolver.query(
            uri,
            arrayOf(OpenableColumns.SIZE, "last_modified"),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
                if (sizeIndex >= 0 && !cursor.isNull(sizeIndex)) size = cursor.getLong(sizeIndex)
                val modifiedIndex = cursor.getColumnIndex("last_modified")
                if (modifiedIndex >= 0 && !cursor.isNull(modifiedIndex)) {
                    modified = cursor.getLong(modifiedIndex)
                }
            }
        }
        return "$action|$uri|$mime|$size|$modified"
    }

    private fun displayName(uri: Uri): String {
        activity.contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) {
                    val name = cursor.getString(index)
                    if (!name.isNullOrBlank()) return name
                }
            }
        }
        val segment = uri.lastPathSegment?.substringAfterLast('/').orEmpty()
        return segment.ifBlank { "分享文件" }
    }

    fun dispose() {
        eventsChannel.setStreamHandler(null)
        eventSink = null
        pending.clear()
    }

    companion object {
        const val EVENTS_NAME = "com.dianduji/dian_du_ji/shared_files/events"
    }
}
