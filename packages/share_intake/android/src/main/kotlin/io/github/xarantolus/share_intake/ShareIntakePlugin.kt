package io.github.xarantolus.share_intake

import android.content.ClipData
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import androidx.core.content.IntentCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Takes what other apps share: each content:// stream is copied into
 * <cacheDir>/share/<uuid>/ under a cleaned-up basename, so no path an app chooses
 * reaches the file system.
 */
class ShareIntakePlugin :
    FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler, PluginRegistry.NewIntentListener {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private val main = Handler(Looper.getMainLooper())
    private val worker = Executors.newSingleThreadExecutor()
    private var binding: ActivityPluginBinding? = null
    private var pending: Intent? = null
    private var cacheDir: File? = null
    private var cancel = AtomicBoolean(false)

    override fun onAttachedToEngine(flutter: FlutterPlugin.FlutterPluginBinding) {
        context = flutter.applicationContext
        channel = MethodChannel(flutter.binaryMessenger, "matterleast/share_intake")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutter: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addOnNewIntentListener(this)
        take(binding.activity.intent)
    }

    override fun onDetachedFromActivity() {
        binding?.removeOnNewIntentListener(this)
        binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onNewIntent(intent: Intent): Boolean {
        take(intent)
        return false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                cacheDir = File(call.argument<String>("cacheDir")!!)
                result.success(pending != null)
                pending?.let { copy(it) }
                pending = null
            }
            "cancel" -> {
                cancel.set(true)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Keeps a share for the copy, once: the intent loses its share so a re-attach doesn't take it again. */
    private fun take(intent: Intent?) {
        intent ?: return
        if (intent.action != Intent.ACTION_SEND && intent.action != Intent.ACTION_SEND_MULTIPLE) return
        val share = Intent(intent)
        intent.action = null
        intent.replaceExtras(null as Bundle?)
        intent.clipData = null
        if (cacheDir != null) copy(share) else pending = share
    }

    private fun copy(intent: Intent) {
        cancel = AtomicBoolean(false)
        val cancelled = cancel
        val folder = File(cacheDir, "share/${UUID.randomUUID()}")
        worker.execute {
            try {
                val result = copyShare(intent, folder, cancelled)
                main.post { channel.invokeMethod(if (result == null) "cancelled" else "shared", result) }
            } catch (e: IOException) {
                folder.deleteRecursively()
                main.post { channel.invokeMethod("failed", mapOf("message" to (e.message ?: e.toString()))) }
            }
        }
    }

    /** The share as Dart reads it, null when cancelled; throws when the disk is full. */
    private fun copyShare(intent: Intent, folder: File, cancelled: AtomicBoolean): Map<String, Any?>? {
        val resolver = context.contentResolver
        val streams = streamsOf(intent)
        val names = streams.map { nameAndSize(resolver, it) }
        val total = if (names.any { it.second == null }) -1L else names.sumOf { it.second ?: 0L }
        val files = mutableListOf<Map<String, String>>()
        val refused = mutableListOf<String>()
        val taken = mutableSetOf<String>()
        var done = 0L
        val begun = SystemClock.elapsedRealtime()
        var reported = 0L
        for ((index, uri) in streams.withIndex()) {
            val display = names[index].first
            if (uri.scheme != ContentResolver.SCHEME_CONTENT) {
                refused.add(display ?: uri.lastPathSegment ?: "file")
                continue
            }
            val mime = resolver.getType(uri) ?: intent.type?.takeIf { !it.contains('*') }
            val name = unique(cleanName(display, mime), taken)
            folder.mkdirs()
            val target = File(folder, name)
            try {
                val input = resolver.openInputStream(uri) ?: throw IOException("No stream")
                input.use { from ->
                    target.outputStream().use { to ->
                        val buffer = ByteArray(64 * 1024)
                        while (true) {
                            if (cancelled.get()) {
                                folder.deleteRecursively()
                                return null
                            }
                            val read = from.read(buffer)
                            if (read < 0) break
                            to.write(buffer, 0, read)
                            done += read
                            val now = SystemClock.elapsedRealtime()
                            // Only a copy that takes a moment shows progress.
                            if (now - begun > PROGRESS_AFTER_MS && now - reported > PROGRESS_EVERY_MS) {
                                reported = now
                                val progress = mapOf("done" to done, "total" to total)
                                main.post { channel.invokeMethod("progress", progress) }
                            }
                        }
                    }
                }
                files.add(mapOf("path" to target.path, "name" to name, "mime" to (mime ?: "")))
            } catch (e: IOException) {
                target.delete()
                if (outOfSpace(e)) throw e
                refused.add(display ?: name)
            } catch (e: SecurityException) {
                target.delete()
                refused.add(display ?: name)
            }
        }
        if (files.isEmpty()) folder.deleteRecursively()
        return mapOf(
            "text" to intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString(),
            "files" to files,
            "refused" to refused,
            "target" to intent.getStringExtra(Intent.EXTRA_SHORTCUT_ID),
        )
    }

    private fun streamsOf(intent: Intent): List<Uri> {
        val uris = LinkedHashSet<Uri>()
        if (intent.action == Intent.ACTION_SEND_MULTIPLE) {
            IntentCompat.getParcelableArrayListExtra(intent, Intent.EXTRA_STREAM, Uri::class.java)?.let { uris.addAll(it) }
        } else {
            IntentCompat.getParcelableExtra(intent, Intent.EXTRA_STREAM, Uri::class.java)?.let { uris.add(it) }
        }
        val clip: ClipData? = intent.clipData
        if (uris.isEmpty() && clip != null) {
            for (i in 0 until clip.itemCount) clip.getItemAt(i).uri?.let { uris.add(it) }
        }
        return uris.toList()
    }

    private fun nameAndSize(resolver: ContentResolver, uri: Uri): Pair<String?, Long?> {
        if (uri.scheme != ContentResolver.SCHEME_CONTENT) return Pair(uri.lastPathSegment, 0L)
        return try {
            resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE), null, null, null)
                ?.use { cursor ->
                    if (!cursor.moveToFirst()) return Pair(null, null)
                    val name = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    val size = cursor.getColumnIndex(OpenableColumns.SIZE)
                    Pair(
                        if (name >= 0 && !cursor.isNull(name)) cursor.getString(name) else null,
                        if (size >= 0 && !cursor.isNull(size)) cursor.getLong(size) else null,
                    )
                } ?: Pair(null, null)
        } catch (e: RuntimeException) {
            Pair(null, null)
        }
    }

    private fun outOfSpace(e: IOException): Boolean =
        generateSequence<Throwable>(e) { it.cause }.any { it.message?.contains("ENOSPC") == true || it.message?.contains("No space left") == true }

    private fun unique(name: String, taken: MutableSet<String>): String {
        var candidate = name
        var n = 2
        val dot = name.lastIndexOf('.').takeIf { it > 0 } ?: name.length
        while (!taken.add(candidate.lowercase())) {
            candidate = "${name.substring(0, dot)} ($n)${name.substring(dot)}"
            n++
        }
        return candidate
    }

    companion object {
        private const val PROGRESS_AFTER_MS = 300L
        private const val PROGRESS_EVERY_MS = 100L
        private const val MAX_NAME_BYTES = 200

        /** A file name of our own from what the sender calls the file: its last path segment, without control characters or leading dots. */
        fun cleanName(display: String?, mime: String?): String {
            val base = (display ?: "").substringAfterLast('/').substringAfterLast('\\')
                .filter { it >= ' ' && it != '\u007f' }
                .trimStart('.', ' ')
                .trimEnd('.', ' ')
            val name = base.ifEmpty {
                val extension = mime?.let { MimeTypeMap.getSingleton().getExtensionFromMimeType(it) }
                if (extension == null) "file" else "file.$extension"
            }
            if (name.toByteArray().size <= MAX_NAME_BYTES) return name
            val dot = name.lastIndexOf('.')
            val extension = if (dot > 0 && name.length - dot <= 16) name.substring(dot) else ""
            var stem = name.substring(0, name.length - extension.length)
            while ((stem + extension).toByteArray().size > MAX_NAME_BYTES) stem = stem.dropLast(1)
            return stem + extension
        }
    }
}
