package com.example.scrollguard

import android.content.Context
import android.content.SharedPreferences
import java.util.Calendar

object LimitManager {
    private const val LIMITS_PREF = "scrollguard_limits"
    private const val USAGE_PREF = "scrollguard_usage"

    private fun limitsPrefs(c: Context) = c.getSharedPreferences(LIMITS_PREF, Context.MODE_PRIVATE)
    private fun usagePrefs(c: Context) = c.getSharedPreferences(USAGE_PREF, Context.MODE_PRIVATE)

    fun saveLimit(context: Context, pkg: String, minutes: Int, mode: String) {
        limitsPrefs(context).edit()
            .putInt("${pkg}_limit", minutes)
            .putString("${pkg}_mode", mode)
            .apply()
    }

    fun getLimitMinutes(context: Context, pkg: String): Int = limitsPrefs(context).getInt("${pkg}_limit", 0)
    fun getMode(context: Context, pkg: String): String = limitsPrefs(context).getString("${pkg}_mode", "notification") ?: "notification"

    fun hasLimit(context: Context, pkg: String) = getLimitMinutes(context, pkg) > 0

    private fun todayKey(): String {
        val cal = Calendar.getInstance()
        return "${cal.get(Calendar.YEAR)}-${cal.get(Calendar.MONTH)+1}-${cal.get(Calendar.DAY_OF_MONTH)}"
    }

    fun getTodayUsage(context: Context, pkg: String): Int {
        return usagePrefs(context).getInt("${pkg}_${todayKey()}", 0)
    }

    fun incrementUsage(context: Context, pkg: String, minutes: Int) {
        val key = "${pkg}_${todayKey()}"
        val current = getTodayUsage(context, pkg)
        usagePrefs(context).edit().putInt(key, current + minutes).apply()
    }

    fun isExceeded(context: Context, pkg: String): Boolean {
        if (!hasLimit(context, pkg)) return false
        return getTodayUsage(context, pkg) >= getLimitMinutes(context, pkg)
    }

    fun resetTodayUsage(context: Context, pkg: String) {
        usagePrefs(context).edit().remove("${pkg}_${todayKey()}").apply()
    }
}