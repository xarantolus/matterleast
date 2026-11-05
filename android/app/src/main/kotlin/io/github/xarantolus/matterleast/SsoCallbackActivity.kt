package io.github.xarantolus.matterleast

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.linusu.flutter_web_auth_2.FlutterWebAuth2Plugin

/**
 * Receives the server's SSO redirect (mmauth://callback…). Hands it to the
 * waiting sign-in like flutter_web_auth_2's own callback activity, then
 * brings the app back over the Custom Tab, which stays on top otherwise
 * when the link came through Android's "Open with" chooser.
 */
class SsoCallbackActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val url = intent?.data
        val waiting = url?.scheme?.let { FlutterWebAuth2Plugin.callbacks.remove(it) }
        waiting?.success(url.toString())
        startActivity(
            Intent(this, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP),
        )
        finishAndRemoveTask()
    }
}
