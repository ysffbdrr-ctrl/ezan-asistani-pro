package com.xnx.ezanasistanipro

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.graphics.Color

class CountdownForegroundService : Service() {

    companion object {
        private const val NOTIFICATION_ID = 9001

        private const val EXTRA_TITLE = "title"
        private const val EXTRA_BODY = "body"
        private const val EXTRA_TARGET_EPOCH_MS = "targetEpochMs"

        const val ACTION_START_OR_UPDATE = "com.xnx.ezanasistanipro.action.COUNTDOWN_START_OR_UPDATE"
        const val ACTION_STOP = "com.xnx.ezanasistanipro.action.COUNTDOWN_STOP"

        private const val CHANNEL_ID = "countdown_channel"
        private const val CHANNEL_NAME = "Vakit Geri Sayım"
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action

        if (action == ACTION_STOP) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        if (action == ACTION_START_OR_UPDATE) {
            val title = intent.getStringExtra(EXTRA_TITLE) ?: ""
            val body = intent.getStringExtra(EXTRA_BODY) ?: ""
            val targetEpochMs = intent.getLongExtra(EXTRA_TARGET_EPOCH_MS, -1L)

            ensureChannel()

            val notification = buildNotification(title = title, body = body, targetEpochMs = targetEpochMs)
            startForeground(NOTIFICATION_ID, notification)
        }

        return START_STICKY
    }

    private fun buildNotification(title: String, body: String, targetEpochMs: Long): Notification {
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setAutoCancel(false)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setColor(Color.parseColor("#FFC107"))
            .setColorized(true)

        if (targetEpochMs > 0) {
            builder.setWhen(targetEpochMs)
            builder.setUsesChronometer(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                builder.setChronometerCountDown(true)
            }
            builder.setShowWhen(true)
        }

        return builder.build()
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val mgr = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = mgr.getNotificationChannel(CHANNEL_ID)
        if (existing != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW
        )
        channel.setShowBadge(false)
        mgr.createNotificationChannel(channel)
    }
}
