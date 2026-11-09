package io.github.xarantolus.matterleast

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterShellArgs
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Profile builds keep the whole timeline instead of the last few seconds.
    override fun getFlutterShellArgs(): FlutterShellArgs {
        val args = super.getFlutterShellArgs()
        if (resources.getBoolean(R.bool.profiling)) args.add("--endless-trace-buffer")
        return args
    }

    private var dataSaver: MethodChannel? = null

    private val dataSaverChanged = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) = reportDataSaver()
    }

    private fun dataSaverOn(): Boolean {
        val manager = getSystemService(ConnectivityManager::class.java)
        return manager.restrictBackgroundStatus == ConnectivityManager.RESTRICT_BACKGROUND_STATUS_ENABLED
    }

    private fun reportDataSaver() {
        dataSaver?.invokeMethod("changed", dataSaverOn())
    }

    override fun onResume() {
        super.onResume()
        registerReceiver(
            dataSaverChanged,
            IntentFilter(ConnectivityManager.ACTION_RESTRICT_BACKGROUND_CHANGED),
        )
        reportDataSaver()
    }

    override fun onPause() {
        unregisterReceiver(dataSaverChanged)
        super.onPause()
    }

    override fun onDestroy() {
        // The call lives in this engine, so it ends with the activity.
        CallService.onHangUp = null
        if (isFinishing) CallService.stop(this)
        StayConnectedService.uiGone(this)
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "matterleast/display")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "autoRotate" -> result.success(
                        Settings.System.getInt(
                            contentResolver,
                            Settings.System.ACCELEROMETER_ROTATION,
                            0,
                        ) == 1,
                    )
                    else -> result.notImplemented()
                }
            }
        dataSaver = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "matterleast/data_saver")
            .also { channel ->
                channel.setMethodCallHandler { call, result ->
                    when (call.method) {
                        "restricted" -> result.success(dataSaverOn())
                        else -> result.notImplemented()
                    }
                }
            }
        val calls = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "matterleast/call_service")
        CallService.onHangUp = { runOnUiThread { calls.invokeMethod("hangUp", null) } }
        calls.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    CallService.start(
                        this,
                        call.argument<String>("title"),
                        call.argument<String>("text"),
                    )
                    result.success(null)
                }
                "stop" -> {
                    CallService.stop(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "matterleast/stay_connected")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isEnabled" -> result.success(StayConnectedService.isEnabled(this))
                    "enable" -> {
                        StayConnectedService.enable(this)
                        result.success(null)
                    }
                    "disable" -> {
                        StayConnectedService.disable(this)
                        result.success(null)
                    }
                    "resume" -> {
                        StayConnectedService.resume(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
