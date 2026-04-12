package com.scrollguard.scrollguard

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Build
import android.app.usage.UsageStatsManager
import android.app.usage.UsageStats
import android.provider.Settings
import java.io.ByteArrayOutputStream
import java.util.*

object MethodChannelHandler {

    fun getInstalledApps(context: Context): List<Map<String, Any>> {
        val pm = context.packageManager
        val apps = mutableListOf<Map<String, Any>>()

        val installedApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        for (app in installedApps) {
            if (pm.getLaunchIntentForPackage(app.packageName) != null) { // Only launchable apps
                val name = pm.getApplicationLabel(app).toString()
                val icon = getAppIconBase64(pm, app)
                apps.add(mapOf(
                    "name" to name,
                    "packageName" to app.packageName,
                    "icon" to icon
                ))
            }
        }
        return apps
    }

    private fun getAppIconBase64(pm: PackageManager, appInfo: android.content.pm.ApplicationInfo): String {
        return try {
            val drawable = pm.getApplicationIcon(appInfo)
            val bitmap = Bitmap.createBitmap(128, 128, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)

            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            android.util.Base64.encodeToString(stream.toByteArray(), android.util.Base64.DEFAULT)
        } catch (e: Exception) {
            ""
        }
    }

    fun getUsageStats(context: Context, days: Int = 1): List<Map<String, Any>> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -days)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        return stats.map { usage ->
            mapOf(
                "packageName" to usage.packageName,
                "totalTime" to usage.totalTimeInForeground / 60000 // minutes
            )
        }
    }

    // Simple foreground app detection (used by service)
    fun getForegroundApp(context: Context): String? {
        // This is simplified. In real production, use UsageEvents for better accuracy.
        // For now we rely on the service polling.
        return null // Handled inside service
    }

    fun setAppLimit(context: Context, packageName: String, limitMinutes: Int, mode: String) {
        // Limits are stored in Flutter Hive. Native service will read them via SharedPreferences or another channel if needed.
        // For simplicity, we can broadcast or use a static map, but we'll handle in service later.
    }
}