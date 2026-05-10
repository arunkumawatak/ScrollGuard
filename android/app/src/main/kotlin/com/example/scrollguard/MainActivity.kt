package com.example.scrollguard

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "scroll_guard"

    // override fun onCreate(savedInstanceState: Bundle?) {
    //     super.onCreate(savedInstanceState)

    //     // 🔥 Auto start monitoring service when app opens
    //     android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
    //         ScrollGuardService.startService(this)
    //         Log.d("ScrollGuard", "🚀 Service auto-started from MainActivity")
    //     }, 1500) // 1.5 seconds delay
    // }

    //change the on create funtion 9may
//     override fun onCreate(savedInstanceState: Bundle?) {
//     super.onCreate(savedInstanceState)

//     android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
//         ScrollGuardService.startService(this)
        
//         // Prompt user to enable Accessibility Service
//         promptAccessibilityService()
        
//         Log.d("ScrollGuard", "🚀 Service + Accessibility prompt started")
//     }, 2000)
// }

override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // Auto start everything
    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
        ScrollGuardService.startService(this)
        
        // Open Accessibility Settings so user can enable it
        openAccessibilitySettings()
        
        Log.d("ScrollGuard", "🚀 Service started + Accessibility prompt shown")
    }, 2000)
}

// 🔥 Add this new function
private fun openAccessibilitySettings() {
    try {
        val intent = Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
        
        android.widget.Toast.makeText(
            this,
            "Please ENABLE 'ScrollGuard' in the list",
            android.widget.Toast.LENGTH_LONG
        ).show()
    } catch (e: Exception) {
        Log.e("ScrollGuard", "Could not open accessibility settings", e)
    }
}
//new func added 
private fun promptAccessibilityService() {
    try {
        val intent = Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
        android.widget.Toast.makeText(
            this, 
            "Please enable 'ScrollGuard' in Accessibility Settings", 
            android.widget.Toast.LENGTH_LONG
        ).show()
    } catch (e: Exception) {
        Log.e("ScrollGuard", "Failed to open accessibility settings", e)
    }
}
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ================= PERMISSION =================
                "checkUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }

                // ================= SET APP LIMIT =================
                "setAppLimit" -> {
                    val packageName = call.argument<String>("packageName")
                    val limitMinutes = call.argument<Int>("limitMinutes") ?: 0
                    val mode = call.argument<String>("mode") ?: "notification"

                    if (packageName != null) {
                        LimitManager.saveLimit(this, packageName, limitMinutes, mode)
                        Log.d("ScrollGuard", "💾 Limit saved for $packageName | $limitMinutes min | Mode: $mode")
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Missing packageName", null)
                    }
                }

                // ================= INSTALLED APPS =================
                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }

                // ================= USAGE STATS =================
                "getUsageStats" -> {
                    val days = call.argument<Int>("days") ?: 1
                    result.success(getUsageStats(days))
                }

                // ================= START SERVICE =================
                "startMonitoring" -> {
                    ScrollGuardService.startService(this)
                    Log.d("ScrollGuard", "✅ startMonitoring called from Flutter")
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ====================== USAGE PERMISSION ======================
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager

        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }

        return mode == AppOpsManager.MODE_ALLOWED
    }

    // ====================== INSTALLED APPS ======================
    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm: PackageManager = packageManager
        val apps = mutableListOf<Map<String, Any>>()

        val installedApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)

        for (app in installedApps) {
            if (pm.getLaunchIntentForPackage(app.packageName) != null) {
                val appName = pm.getApplicationLabel(app).toString()
                val iconBase64 = getAppIconAsBase64(pm, app)

                apps.add(
                    mapOf(
                        "name" to appName,
                        "packageName" to app.packageName,
                        "icon" to iconBase64
                    )
                )
            }
        }
        return apps
    }

    private fun getAppIconAsBase64(
        pm: PackageManager,
        appInfo: android.content.pm.ApplicationInfo
    ): String {
        return try {
            val drawable = pm.getApplicationIcon(appInfo)
            val bitmap = Bitmap.createBitmap(128, 128, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, 128, 128)
            drawable.draw(canvas)

            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)

            android.util.Base64.encodeToString(
                stream.toByteArray(),
                android.util.Base64.DEFAULT
            )
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
                "totalTime" to (it.totalTimeInForeground / 60000)
            )
        }
    }
}