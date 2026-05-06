package com.example.scrollguard

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import android.app.usage.UsageStatsManager

class ScrollGuardService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private val monitorRunnable = Runnable { monitorForegroundApp() }

    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "scrollguard_monitor"

        fun startService(context: Context) {
            val intent = Intent(context, ScrollGuardService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ScrollGuard")
            .setContentText("Monitoring app usage & limits")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        startForeground(NOTIFICATION_ID, notification)

        handler.post(monitorRunnable)
        return START_STICKY
    }

    private fun monitorForegroundApp() {
        // In full production, use UsageEvents to detect foreground change more accurately.
        // For this version, we simulate by checking current limits (you can expand later).

        // Example: Get current foreground package (placeholder)
        val currentPackage = getCurrentForegroundPackage()

        if (currentPackage != null) {
            // Here you would read limit from SharedPreferences or send to Flutter via event channel.
            // For simplicity, we assume limit check is done and if exceeded + block mode, launch overlay.
            if (shouldBlockApp(currentPackage)) {
                launchBlockingOverlay(currentPackage)
            }
        }

        handler.postDelayed(monitorRunnable, 3000) // Check every 3 seconds
    }

    private fun getCurrentForegroundPackage(): String? {
    // Better implementation using UsageStats (you can improve further with UsageEvents)
    val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
    val time = System.currentTimeMillis()
    val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 1000*60, time)
    
    return stats?.maxByOrNull { it.lastTimeUsed }?.packageName
}

  private fun shouldBlockApp(packageName: String): Boolean {
    val limitMin = LimitManager.getLimitMinutes(this, packageName)
    if (limitMin <= 0) return false

    val mode = LimitManager.getMode(this, packageName)
    if (mode != "block") return false  // For now only block mode does hard block

    // TODO: Track actual usage time (you need a usage tracker)
    // For testing: return true if you want to force block
    val usage = getTodayUsage(packageName)  // implement this
    return usage >= limitMin
}
private fun getTodayUsage(packageName: String): Int {
    // Use UsageStatsManager to get today's foreground time
    return 0 // placeholder
}
    private fun launchBlockingOverlay(packageName: String) {
        val intent = Intent(this, BlockingOverlayActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("blocked_package", packageName)
        }
        startActivity(intent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "ScrollGuard Monitoring",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        handler.removeCallbacks(monitorRunnable)
        super.onDestroy()
    }
}