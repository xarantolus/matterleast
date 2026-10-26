package io.github.xarantolus.matterleast

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Keeps the process alive with a low-priority notification and runs the
 * Dart entry point `stayConnectedMain` in its own engine, which holds the
 * servers' WebSockets and raises message notifications. Whether it should
 * run is stored here, so the notification's Stop action and the settings
 * switch share one source of truth.
 */
class StayConnectedService : Service() {
    private var engine: FlutterEngine? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // startForegroundService must always be answered with startForeground.
        startInForeground()
        if (intent?.action == ACTION_STOP || !isEnabled(this)) {
            setEnabled(this, false)
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }
        if (engine == null) {
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(applicationContext)
            loader.ensureInitializationComplete(applicationContext, null)
            engine = FlutterEngine(applicationContext).also {
                it.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint(
                        loader.findAppBundlePath(),
                        "package:matterleast/notifications/stay_connected.dart",
                        "stayConnectedMain",
                    ),
                )
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        engine?.destroy()
        engine = null
        super.onDestroy()
    }

    private fun startInForeground() {
        val manager = getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(SYNC_CHANNEL) == null) {
            manager.createNotificationChannel(
                NotificationChannel(SYNC_CHANNEL, "Sync", NotificationManager.IMPORTANCE_MIN),
            )
        }
        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE,
        )
        val stop = PendingIntent.getService(
            this,
            1,
            Intent(this, StayConnectedService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = Notification.Builder(this, SYNC_CHANNEL)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("Staying connected")
            .setContentText("New messages arrive right away")
            .setContentIntent(open)
            .setOngoing(true)
            .setShowWhen(false)
            .addAction(Notification.Action.Builder(null, "Stop", stop).build())
            .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    companion object {
        const val ACTION_STOP = "io.github.xarantolus.matterleast.STOP_STAY_CONNECTED"
        const val SYNC_CHANNEL = "sync"
        private const val NOTIFICATION_ID = 0x5c
        private const val PREFS = "stay_connected"
        private const val KEY_ENABLED = "enabled"

        fun isEnabled(context: Context): Boolean =
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getBoolean(KEY_ENABLED, false)

        private fun setEnabled(context: Context, enabled: Boolean) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putBoolean(KEY_ENABLED, enabled).apply()
        }

        fun enable(context: Context) {
            setEnabled(context, true)
            context.startForegroundService(Intent(context, StayConnectedService::class.java))
        }

        fun disable(context: Context) {
            setEnabled(context, false)
            context.stopService(Intent(context, StayConnectedService::class.java))
        }

        /** Starts the service when it is switched on; a running one stays as is. */
        fun resume(context: Context) {
            if (isEnabled(context)) {
                context.startForegroundService(Intent(context, StayConnectedService::class.java))
            }
        }
    }
}

/** Starts the service again after a reboot or an app update. */
class StayConnectedBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED ->
                StayConnectedService.resume(context)
        }
    }
}
