package io.github.xarantolus.matterleast

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * Receives the server's SSO redirect (mmauth://callback…), also when it
 * arrives through Android's "Open with" chooser, and hands it to
 * MainActivity. NEW_TASK finds the app's existing task (this activity has no
 * task of its own to keep) and CLEAR_TOP closes the Custom Tab above
 * MainActivity in it; the link reaches Dart through app_links' new-intent handling.
 * Dart checks the link against the sign-in that is waiting for it.
 */
class SsoCallbackActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val url = intent?.data
        if (url != null && url.host == "callback" && url.scheme in SCHEMES) {
            startActivity(
                Intent(this, MainActivity::class.java)
                    .setData(url)
                    .addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP,
                    ),
            )
        }
        finish()
    }

    private companion object {
        val SCHEMES = setOf("mmauth", "matterleast")
    }
}
