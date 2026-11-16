package io.github.xarantolus.matterleast

import android.app.Notification
import android.app.NotificationChannel
import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.SystemClock
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

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
            cancelCheck()
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }
        if (engine == null) {
            running = true
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
        scheduleCheck()
        if (intent?.action == ACTION_CHECK) {
            checkSocket()
        }
        if (intent?.action == ACTION_UI_GONE) {
            engine?.let {
                MethodChannel(it.dartExecutor.binaryMessenger, ENGINE_CHANNEL)
                    .invokeMethod("uiGone", null)
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        cancelCheck()
        engine?.destroy()
        engine = null
        running = false
        super.onDestroy()
    }

    private fun checkIntent(): PendingIntent = PendingIntent.getForegroundService(
        this,
        2,
        Intent(this, StayConnectedService::class.java).setAction(ACTION_CHECK),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

    /**
     * While the device dozes, Dart's timers sleep with the CPU, so a socket
     * that a router dropped goes unnoticed. This inexact alarm (no
     * permission, allowed while idle, which the system limits to about one
     * per nine minutes) wakes the engine to ping the sockets.
     */
    private fun scheduleCheck() {
        getSystemService(AlarmManager::class.java).setAndAllowWhileIdle(
            AlarmManager.ELAPSED_REALTIME_WAKEUP,
            SystemClock.elapsedRealtime() + CHECK_INTERVAL_MS,
            checkIntent(),
        )
    }

    private fun cancelCheck() {
        getSystemService(AlarmManager::class.java).cancel(checkIntent())
    }

    /** Keeps the CPU awake only until Dart has pinged, reconnected and answered. */
    private fun checkSocket() {
        val wakeLock = getSystemService(PowerManager::class.java)
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "matterleast:socket-check")
        wakeLock.acquire(WAKE_LOCK_MS)
        val release = {
            if (wakeLock.isHeld) wakeLock.release()
        }
        val messenger = engine?.dartExecutor?.binaryMessenger
        if (messenger == null) {
            release()
            return
        }
        MethodChannel(messenger, ENGINE_CHANNEL).invokeMethod(
            "check",
            null,
            object : MethodChannel.Result {
                override fun success(result: Any?) = release()
                override fun error(code: String, message: String?, details: Any?) = release()
                override fun notImplemented() = release()
            },
        )
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
        private const val ACTION_UI_GONE = "io.github.xarantolus.matterleast.UI_GONE"
        private const val ENGINE_CHANNEL = "matterleast/stay_connected_engine"
        const val SYNC_CHANNEL = "sync"
        private const val ACTION_CHECK = "io.github.xarantolus.matterleast.CHECK_SOCKET"
        private const val CHECK_INTERVAL_MS = 5 * 60 * 1000L
        private const val WAKE_LOCK_MS = 30 * 1000L
        private const val NOTIFICATION_ID = 0x5c
        private const val PREFS = "stay_connected"
        private const val KEY_ENABLED = "enabled"

        @Volatile
        private var running = false

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

        /**
         * Tells the engine the UI is gone. Swiping the app away from the recent
         * apps destroys the UI without it saying so itself.
         */
        fun uiGone(context: Context) {
            // A plain start: the running service is in the foreground already.
            if (running) {
                context.startService(
                    Intent(context, StayConnectedService::class.java).setAction(ACTION_UI_GONE),
                )
            }
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
