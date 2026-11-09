package io.github.xarantolus.matterleast

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/**
 * Keeps the microphone and the call's connection alive while the app is in
 * the background during a call. Android stops a process that holds the
 * microphone without a foreground service of the microphone type, and one
 * that plays audio without a media playback one.
 */
class CallService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_HANG_UP) {
            onHangUp?.invoke()
            return START_NOT_STICKY
        }
        val manager = getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(CHANNEL) == null) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL, "Calls", NotificationManager.IMPORTANCE_LOW),
            )
        }
        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE,
        )
        val hangUp = PendingIntent.getService(
            this,
            1,
            Intent(this, CallService::class.java).setAction(ACTION_HANG_UP),
            PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = Notification.Builder(this, CHANNEL)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(intent?.getStringExtra(EXTRA_TITLE) ?: "Call in progress")
            .setContentText(intent?.getStringExtra(EXTRA_TEXT))
            .setContentIntent(open)
            .setOngoing(true)
            .setShowWhen(true)
            .setCategory(Notification.CATEGORY_CALL)
            .addAction(Notification.Action.Builder(null, "Hang up", hangUp).build())
            .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // The microphone type needs the permission; a call that only
            // listens runs as media playback.
            val type = if (checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
            } else {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
            }
            startForeground(NOTIFICATION_ID, notification, type)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        return START_NOT_STICKY
    }

    companion object {
        private const val ACTION_HANG_UP = "io.github.xarantolus.matterleast.HANG_UP_CALL"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_TEXT = "text"
        private const val CHANNEL = "calls"
        private const val NOTIFICATION_ID = 0x5d

        /** Set by the activity while it can pass the Hang up action to Dart. */
        @Volatile
        var onHangUp: (() -> Unit)? = null

        fun start(context: Context, title: String?, text: String?) {
            context.startForegroundService(
                Intent(context, CallService::class.java)
                    .putExtra(EXTRA_TITLE, title)
                    .putExtra(EXTRA_TEXT, text),
            )
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CallService::class.java))
        }
    }
}
