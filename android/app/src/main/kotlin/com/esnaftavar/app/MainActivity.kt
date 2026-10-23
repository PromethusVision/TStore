package com.esnaftavar.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Notification
import android.app.PendingIntent
import android.content.Intent
import android.os.Build

class MainActivity: FlutterActivity() {
    private var pushChannel: MethodChannel? = null
    private val channelId = "esnaftavar_service"
    private val openAction = "com.esnaftavar.PUSH_OPEN"
    private val fields = listOf("notification_id", "user_id", "app_role")
    private fun development() = packageName == "com.esnaftavar.app.dev" ||
        packageName == "com.esnaftavar.app.merchant.pilot"
    private fun role() = if (packageName.endsWith(".merchant.pilot")) "merchant" else "customer"
    private fun data(intent: Intent?): Map<String, String>? {
        if (intent?.action != openAction) return null
        val values = fields.associateWith { intent.getStringExtra(it) ?: "" }
        val uuid = Regex("[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
        return if (uuid.matches(values.getValue("notification_id")) &&
            uuid.matches(values.getValue("user_id")) && values["app_role"] == role()) values else null
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!development()) return
        val manager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) {
            manager.createNotificationChannel(NotificationChannel(channelId,
                "Mesaj ve işlem bildirimleri", NotificationManager.IMPORTANCE_HIGH))
        }
        pushChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "esnaftavar/development_push")
        pushChannel?.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initialOpen" -> {
                        val initial = data(intent)
                        if (intent?.action == openAction) intent.action = Intent.ACTION_MAIN
                        result.success(initial)
                    }
                    "clear" -> { manager.cancelAll(); result.success(null) }
                    "showGeneric" -> {
                        val open = Intent(this, MainActivity::class.java).apply {
                            action = openAction
                            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                            fields.forEach { putExtra(it, call.argument<String>(it)) }
                        }
                        val payload = data(open)
                        if (payload == null) { result.error("invalid_push", "Invalid notification", null) }
                        else {
                            // Unique data prevents PendingIntent extras from being overwritten.
                            open.data = android.net.Uri.parse("esnaftavar-push://notification/" + payload["notification_id"])
                            val pending = PendingIntent.getActivity(this, 0, open,
                                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                            val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, channelId)
                                else Notification.Builder(this).setPriority(Notification.PRIORITY_HIGH)
                            manager.notify(payload["notification_id"], 0, builder
                                .setSmallIcon(R.drawable.ic_notification_esnaftavar)
                                .setContentTitle("EsnaftaVar")
                                .setContentText("Yeni bir bildirimin var.")
                                .setVisibility(Notification.VISIBILITY_PRIVATE)
                                .setAutoCancel(true).setContentIntent(pending).build())
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("push_unavailable", "Notification unavailable", null)
            }
        }
    }
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (!development()) return
        data(intent)?.let { pushChannel?.invokeMethod("notificationOpened", it) }
    }
}
