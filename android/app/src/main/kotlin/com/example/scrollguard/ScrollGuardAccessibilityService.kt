// package com.example.scrollguard

// import android.accessibilityservice.AccessibilityService
// import android.content.Intent
// import android.view.accessibility.AccessibilityEvent
// import android.util.Log
// import java.util.concurrent.TimeUnit

// class ScrollGuardAccessibilityService : AccessibilityService() {

//     companion object {
//         var instance: ScrollGuardAccessibilityService? = null
//     }

//     private var currentPackage: String? = null
//     private var lastUpdateTime = System.currentTimeMillis()

//     override fun onServiceConnected() {
//         super.onServiceConnected()
//         instance = this
//         Log.d("ScrollGuard", "✅ Accessibility Service Connected Successfully")
//     }

//     override fun onAccessibilityEvent(event: AccessibilityEvent?) {
//         if (event?.packageName == null) return

//         val pkg = event.packageName.toString()

//         // Ignore our own app
//         if (pkg == this.packageName) return

//         if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
//             Log.d("ScrollGuard", "🔍 Window changed → $pkg")

//             if (pkg != currentPackage) {
//                 // Add usage time to previous app
//                 currentPackage?.let { prev ->
//                     val elapsedMinutes = TimeUnit.MILLISECONDS.toMinutes(
//                         System.currentTimeMillis() - lastUpdateTime
//                     ).toInt().coerceAtLeast(1)

//                     LimitManager.incrementUsage(this, prev, elapsedMinutes)
//                     Log.d("ScrollGuard", "⏱️ Added $elapsedMinutes min to $prev")
//                 }

//                 currentPackage = pkg
//                 lastUpdateTime = System.currentTimeMillis()

//                 Log.d("ScrollGuard", "🚀 Switched to foreground: $pkg")
//                 checkAndEnforceLimit(pkg)
//             }
//         }
//     }

//     private fun checkAndEnforceLimit(pkg: String) {
//         if (LimitManager.isExceeded(this, pkg)) {
//             val mode = LimitManager.getMode(this, pkg)
//             Log.d("ScrollGuard", "🚨 LIMIT EXCEEDED for $pkg | Mode: $mode")

//             if (mode == "block") {
//                 launchBlockingOverlay(pkg)
//             }
//         }
//     }

//     private fun launchBlockingOverlay(pkg: String) {
//         try {
//             val intent = Intent(this, BlockingOverlayActivity::class.java).apply {
//                 flags = Intent.FLAG_ACTIVITY_NEW_TASK or
//                         Intent.FLAG_ACTIVITY_CLEAR_TOP or
//                         Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
//                 putExtra("blocked_package", pkg)
//             }
//             startActivity(intent)
//             Log.d("ScrollGuard", "🛡️ Blocking overlay started for $pkg")
//         } catch (e: Exception) {
//             Log.e("ScrollGuard", "Failed to launch overlay", e)
//         }
//     }

//     override fun onInterrupt() {}
    
//     override fun onDestroy() {
//         instance = null
//         super.onDestroy()
//     }
// }


package com.example.scrollguard

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import java.util.concurrent.TimeUnit
import android.os.Handler
import android.os.Looper

class ScrollGuardAccessibilityService : AccessibilityService() {

    companion object {
        var instance: ScrollGuardAccessibilityService? = null
    }

    private var currentPackage: String? = null
    private var lastUpdateTime = System.currentTimeMillis()
    private val handler = Handler(Looper.getMainLooper())
    private val checkRunnable = Runnable { checkCurrentApp() }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.d("ScrollGuard", "✅ Accessibility Service Connected - Continuous Monitoring Active")
        startPeriodicCheck()
    }

    private fun startPeriodicCheck() {
        handler.postDelayed(checkRunnable, 15000) // Check every 15 seconds
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.packageName == null) return

        val pkg = event.packageName.toString()
        if (pkg == this.packageName) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            Log.d("ScrollGuard", "🔍 Window changed → $pkg")

            if (pkg != currentPackage) {
                // Save time for previous app
                currentPackage?.let { prev ->
                    val elapsed = TimeUnit.MILLISECONDS.toMinutes(System.currentTimeMillis() - lastUpdateTime)
                        .toInt().coerceAtLeast(1)
                    LimitManager.incrementUsage(this, prev, elapsed)
                    Log.d("ScrollGuard", "⏱️ Added $elapsed min to $prev")
                }

                currentPackage = pkg
                lastUpdateTime = System.currentTimeMillis()

                Log.d("ScrollGuard", "🚀 New Foreground App: $pkg")
            }
            checkLimit(pkg)
        }
    }

    private fun checkCurrentApp() {
        currentPackage?.let { pkg ->
            checkLimit(pkg)
        }
        handler.postDelayed(checkRunnable, 15000) // Continue checking
    }

    private fun checkLimit(pkg: String) {
        if (LimitManager.isExceeded(this, pkg)) {
            val mode = LimitManager.getMode(this, pkg)
            Log.d("ScrollGuard", "🚨 LIMIT EXCEEDED for $pkg | Mode: $mode")

            if (mode == "block") {
                launchBlockingOverlay(pkg)
            }
        }
    }

    private fun launchBlockingOverlay(pkg: String) {
        try {
            val intent = Intent(this, BlockingOverlayActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS or
                        Intent.FLAG_ACTIVITY_NO_HISTORY
                putExtra("blocked_package", pkg)
            }
            startActivity(intent)
            Log.d("ScrollGuard", "🛡️ BLOCKING OVERLAY LAUNCHED for $pkg")
        } catch (e: Exception) {
            Log.e("ScrollGuard", "Failed to launch overlay", e)
        }
    }

    override fun onInterrupt() {}
    
    override fun onDestroy() {
        handler.removeCallbacks(checkRunnable)
        instance = null
        super.onDestroy()
    }
}