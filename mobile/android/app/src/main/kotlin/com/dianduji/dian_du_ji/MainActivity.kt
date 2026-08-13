package com.dianduji.dian_du_ji

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var pronunciation: PronunciationChannel? = null
    private var sharedFiles: SharedFileChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pronunciation = PronunciationChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        sharedFiles = SharedFileChannel(this, flutterEngine.dartExecutor.binaryMessenger)
        // Cold start: the launch intent may already be a share/open action.
        sharedFiles?.handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        sharedFiles?.handleIntent(intent)
    }

    override fun onDestroy() {
        pronunciation?.dispose()
        pronunciation = null
        sharedFiles?.dispose()
        sharedFiles = null
        super.onDestroy()
    }
}
