package com.example.scrollguard

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import android.app.usage.UsageStatsManager
import java.util.SortedMap
import java.util.TreeMap

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
        Log.d("ScrollGuard", "✅ Service Started Successfully")
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        handler.post(monitorRunnable)
        return START_STICKY
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ScrollGuard Active")
            .setContentText("Enforcing app limits")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun monitorForegroundApp() {
        val currentPackage = getCurrentForegroundPackage()

        if (currentPackage != null) {
            Log.d("ScrollGuard", "✅ Foreground App Detected: $currentPackage")

            if (LimitManager.hasLimit(this, currentPackage)) {
                val limit = LimitManager.getLimitMinutes(this, currentPackage)
                val mode = LimitManager.getMode(this, currentPackage)

                Log.d("ScrollGuard", "🔥 LIMIT FOUND → $currentPackage | ${limit}min | Mode: $mode")

                if (mode == "block") {
                    Log.d("ScrollGuard", "🚫 BLOCKING → Launching overlay")
                    launchBlockingOverlay(currentPackage)
                }
            }
        }

        handler.postDelayed(monitorRunnable, 2000) 
    }

// for all devices
    private fun getCurrentForegroundPackage(): String? {
        try {
            val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val now = System.currentTimeMillis()
            val startTime = now - 300000 // Last 5 minutes

            val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, now)

            if (stats.isNotEmpty()) {
                val sortedMap: SortedMap<Long, android.app.usage.UsageStats> = TreeMap()
                for (usageStats in stats) {
                    sortedMap[usageStats.lastTimeUsed] = usageStats
                }
                return sortedMap[sortedMap.lastKey()]?.packageName
            }
            return null
        } catch (e: Exception) {
            Log.e("ScrollGuard", "Error detecting foreground app", e)
            return null
        }
    }

    private fun launchBlockingOverlay(packageName: String) {
        val intent = Intent(this, BlockingOverlayActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or 
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
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
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        handler.removeCallbacks(monitorRunnable)
        super.onDestroy()
    }
}