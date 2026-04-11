package com.example.scrollguard

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class ScrollGuardService : AccessibilityService() {
    private var methodChannel: MethodChannel? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Initialize platform channel
        val flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.scrollguard/scroll")
        Log.d("ScrollGuard", "Accessibility Service connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_VIEW_SCROLLED && event.packageName != null) {
            Log.d("ScrollGuard", "Scroll detected in ${event.packageName}")
            // Send scroll event to Flutter
            methodChannel?.invokeMethod("onScrollDetected", event.packageName.toString())
        }
    }

    override fun onInterrupt() {
        Log.d("ScrollGuard", "Accessibility Service interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        methodChannel = null
        Log.d("ScrollGuard", "Accessibility Service destroyed")
    }
}