package io.github.xarantolus.matterleast

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
