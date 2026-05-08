package com.example.scrollguard

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log

class ScrollGuardAccessibilityService : AccessibilityService() {

    companion object {
        var instance: ScrollGuardAccessibilityService? = null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.d("ScrollGuard", "✅ Accessibility Service Connected Successfully")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            
            if (!packageName.isNullOrEmpty()) {
                Log.d("ScrollGuard", "🔍 Accessibility Detected Foreground: $packageName")

                if (LimitManager.hasLimit(this, packageName)) {
                    val mode = LimitManager.getMode(this, packageName)
                    if (mode == "block") {
                        Log.d("ScrollGuard", "🚫 BLOCKING via Accessibility: $packageName")
                        launchBlockingOverlay(packageName)
                    }
                }
            }
        }
    }

    private fun launchBlockingOverlay(packageName: String) {
        try {
            val intent = Intent(this, BlockingOverlayActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or 
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("blocked_package", packageName)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("ScrollGuard", "Failed to launch blocking overlay", e)
        }
    }

    override fun onInterrupt() {
        Log.d("ScrollGuard", "Accessibility Service Interrupted")
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }
}