package com.example.controle_entregas

import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun getInitialRoute(): String? {
        return if (isAutomationSmokeIntent(intent)) {
            automationSmokeRoute()
        } else {
            super.getInitialRoute()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (isAutomationSmokeIntent(intent)) {
            val route = automationSmokeRoute()
            Log.d("DeliveryFlow", "AUTOMATION_DEEP_LINK_RECEIVED route=$route")
            flutterEngine?.navigationChannel?.pushRoute(route)
        }
    }

    private fun isAutomationSmokeIntent(intent: Intent?): Boolean {
        val data: Uri = intent?.data ?: return false
        return intent.action == Intent.ACTION_VIEW &&
            data.scheme == "deliveryflow" &&
            data.host == "automation" &&
            data.path == "/smoke"
    }

    private fun automationSmokeRoute(): String {
        return "/smoke?run=${System.currentTimeMillis()}"
    }
}
