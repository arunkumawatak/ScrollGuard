package com.example.scrollguard

import android.content.Context
import android.content.SharedPreferences

object LimitManager {
    private const val PREF_NAME = "scrollguard_limits"

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

    fun saveLimit(context: Context, packageName: String, limitMinutes: Int, mode: String) {
        getPrefs(context).edit()
            .putInt("${packageName}_limit", limitMinutes)
            .putString("${packageName}_mode", mode)
            .apply()
    }

    fun getLimitMinutes(context: Context, packageName: String): Int {
        return getPrefs(context).getInt("${packageName}_limit", 0)
    }

    fun getMode(context: Context, packageName: String): String {
        return getPrefs(context).getString("${packageName}_mode", "notification") ?: "notification"
    }

    fun removeLimit(context: Context, packageName: String) {
        getPrefs(context).edit().remove("${packageName}_limit").remove("${packageName}_mode").apply()
    }
}