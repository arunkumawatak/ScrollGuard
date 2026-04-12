package com.example.scrollguard
import android.content.Intent          // ← This line was missing
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap
import android.graphics.Canvas
import android.content.pm.PackageManager
import android.app.usage.UsageStatsManager
import android.os.Build
import com.example.scrollguard.ScrollGuardService
class MainActivity : FlutterActivity() {
fun startScrollGuardService() {
        val intent = Intent(this, ScrollGuardService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }
    private val CHANNEL = "com.scrollguard/methods"   // Must match Flutter side

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }
                "getUsageStats" -> {
                    val days = call.argument<Int>("days") ?: 1
                    result.success(getUsageStats(days))
                }
                "startMonitoring" -> {
                    ScrollGuardService.startService(this)
                    result.success(null)
                }
                "setAppLimit" -> {
                    val packageName = call.argument<String>("packageName")
                    val limitMinutes = call.argument<Int>("limitMinutes")
                    val mode = call.argument<String>("mode")
                    if (packageName != null && limitMinutes != null && mode != null) {
                        // For now we just acknowledge - actual limit check is in service
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "Missing parameters", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    // ====================== INSTALLED APPS ======================
    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm: PackageManager = packageManager
        val apps = mutableListOf<Map<String, Any>>()

        val installedApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)

        for (app in installedApps) {
            if (pm.getLaunchIntentForPackage(app.packageName) != null) {  // Only user apps
                val appName = pm.getApplicationLabel(app).toString()
                val iconBase64 = getAppIconAsBase64(pm, app)

                apps.add(mapOf(
                    "name" to appName,
                    "packageName" to app.packageName,
                    "icon" to iconBase64
                ))
            }
        }
        return apps
    }

    private fun getAppIconAsBase64(pm: PackageManager, appInfo: android.content.pm.ApplicationInfo): String {
        return try {
            val drawable = pm.getApplicationIcon(appInfo)
            val bitmap = Bitmap.createBitmap(128, 128, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, 128, 128)
            drawable.draw(canvas)

            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
            android.util.Base64.encodeToString(stream.toByteArray(), android.util.Base64.DEFAULT)
        } catch (e: Exception) {
            ""
        }
    }

    // ====================== USAGE STATS ======================
    private fun getUsageStats(days: Int): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = java.util.Calendar.getInstance()
        calendar.add(java.util.Calendar.DAY_OF_YEAR, -days)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        return stats.map {
            mapOf(
                "packageName" to it.packageName,
                "totalTime" to (it.totalTimeInForeground / 60000)  // convert to minutes
            )
        }
    }
}