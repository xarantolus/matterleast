package io.github.xarantolus.conversation_shortcuts

import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import androidx.core.app.Person
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/** Long-lived conversation shortcuts: what Android needs for the Conversations section and Direct Share. */
class ConversationShortcutsPlugin :
    FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler, PluginRegistry.NewIntentListener {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var binding: ActivityPluginBinding? = null
    private var launchId: String? = null

    override fun onAttachedToEngine(flutter: FlutterPlugin.FlutterPluginBinding) {
        context = flutter.applicationContext
        channel = MethodChannel(flutter.binaryMessenger, "matterleast/conversation_shortcuts")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(flutter: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addOnNewIntentListener(this)
        record(binding.activity.intent)
    }

    override fun onDetachedFromActivity() {
        binding?.removeOnNewIntentListener(this)
        binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onNewIntent(intent: Intent): Boolean {
        if (record(intent)) channel.invokeMethod("opened", null)
        return false
    }

    /** Remembers what a shortcut asked for; true when it opens a conversation. */
    private fun record(intent: Intent?): Boolean {
        intent ?: return false
        if (intent.action != ACTION_OPEN) return false
        launchId = intent.getStringExtra(EXTRA_ID)
        intent.removeExtra(EXTRA_ID)
        return launchId != null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "maxCount" -> result.success(ShortcutManagerCompat.getMaxShortcutCountPerActivity(context))
                "published" -> result.success(ShortcutManagerCompat.getDynamicShortcuts(context).map { it.id })
                "push" -> {
                    push(call)
                    result.success(null)
                }
                "remove" -> {
                    val ids = call.argument<List<String>>("ids") ?: emptyList()
                    ShortcutManagerCompat.removeLongLivedShortcuts(context, ids)
                    ShortcutManagerCompat.removeDynamicShortcuts(context, ids)
                    result.success(null)
                }
                "reportUsed" -> {
                    ShortcutManagerCompat.reportShortcutUsed(context, call.argument<String>("id")!!)
                    result.success(null)
                }
                "takeLaunch" -> result.success(launchId.also { launchId = null })
                else -> result.notImplemented()
            }
        } catch (e: RuntimeException) {
            result.error("shortcuts", e.message, null)
        }
    }

    private fun push(call: MethodCall) {
        val id = call.argument<String>("id")!!
        val label = call.argument<String>("label")!!
        val icon = call.argument<ByteArray>("icon")?.let { bytes ->
            BitmapFactory.decodeByteArray(bytes, 0, bytes.size)?.let { IconCompat.createWithBitmap(it) }
        }
        val open = (context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return)
            .setAction(ACTION_OPEN)
            .putExtra(EXTRA_ID, id)
        val builder = ShortcutInfoCompat.Builder(context, id)
            .setShortLabel(label)
            .setLongLived(true)
            .setIntent(open)
            .setRank(call.argument<Int>("rank") ?: 0)
            .setCategories(setOf(CATEGORY))
        if (icon != null) builder.setIcon(icon)
        if (call.argument<Boolean>("group") != true) {
            builder.setPerson(Person.Builder().setName(label).setKey(id).setIcon(icon).setImportant(true).build())
        }
        ShortcutManagerCompat.pushDynamicShortcut(context, builder.build())
    }

    private companion object {
        const val ACTION_OPEN = "io.github.xarantolus.matterleast.OPEN_CONVERSATION"
        const val EXTRA_ID = "conversation"
        const val CATEGORY = "io.github.xarantolus.matterleast.directshare.CONVERSATION"
    }
}
