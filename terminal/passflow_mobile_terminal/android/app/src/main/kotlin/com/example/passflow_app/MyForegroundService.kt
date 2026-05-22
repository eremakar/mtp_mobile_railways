package com.example.Terminal

import android.app.*
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class MyForegroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra("title") ?: "Астана → Алматы"
        val eta = intent?.getStringExtra("message") ?: "5 ч 35 мин"

        // Компактный вид
        val compactView = RemoteViews(packageName, R.layout.custom_notification_compact)
        compactView.setTextViewText(R.id.route_short, "$title • $eta")
        compactView.setImageViewResource(R.id.train_icon, R.drawable.ic_train)

        // Развёрнутый вид
        val expandedView = RemoteViews(packageName, R.layout.custom_notification_expanded)
        expandedView.setTextViewText(R.id.route_main, title)
        expandedView.setTextViewText(R.id.route_eta, eta)
        expandedView.setTextViewText(R.id.status_text, "Маршрут начался")
        expandedView.setProgressBar(R.id.progress_bar, 100, 70, false)
        expandedView.setImageViewResource(R.id.train_icon, R.drawable.ic_train)

        val notification = NotificationCompat.Builder(this, "route_channel")
            .setSmallIcon(R.drawable.ic_notification_circle)
            .setCustomContentView(compactView)
            .setCustomBigContentView(expandedView)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setOngoing(true)
            .build()

        startForeground(1, notification)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "route_channel",
                "Route Info",
                NotificationManager.IMPORTANCE_HIGH
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
