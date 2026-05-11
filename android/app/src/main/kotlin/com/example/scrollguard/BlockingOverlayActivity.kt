// package com.example.scrollguard

// import android.app.Activity
// import android.content.Intent
// import android.os.Bundle
// import android.view.WindowManager
// import android.widget.Button
// import android.widget.TextView

// class BlockingOverlayActivity : Activity() {

//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)

//         // Full screen overlay settings
//     window.setFlags(
//             WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
//             WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
//             WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
//             WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
//             WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
//             WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
//         )
//         setContentView(R.layout.activity_blocking_overlay)

//         val blockedPackage = intent.getStringExtra("blocked_package") ?: "This App"

//         findViewById<TextView>(R.id.tv_block_message).text = 
//             "⏰ Time's Up!\n\nYou have reached your daily limit for:\n\n$blockedPackage"

//         findViewById<Button>(R.id.btn_open_scrollguard).setOnClickListener {
//             // Open ScrollGuard app
//             val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
//             launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//             if (launchIntent != null) {
//                 startActivity(launchIntent)
//             }
//             finish()
//         }
//     }

//     override fun onBackPressed() {
//         // Prevent closing overlay easily
//     }
// }

package com.example.scrollguard

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView

class BlockingOverlayActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Critical for overlay
        window.setFlags(
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
        )

        // For Android 10+ overlay permission may be needed for full block
        setContentView(R.layout.activity_blocking_overlay)

        val blockedPackage = intent.getStringExtra("blocked_package") ?: "This app"

        findViewById<TextView>(R.id.tv_block_message).text =
            "⏰ Time's Up!\n\nLimit reached for:\n$blockedPackage"

        findViewById<Button>(R.id.btn_open_scrollguard).setOnClickListener {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            launchIntent?.let { startActivity(it) }
            finish()
        }
    }

    override fun onBackPressed() {
        // Prevent easy dismissal
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (!hasFocus) {
            // Re-launch if user tries to switch away
            // Optional: moveTaskToBack(true)
        }
    }
}