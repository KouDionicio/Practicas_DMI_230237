package com.example.toktik

import android.content.ComponentName
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val launcherIconChannel = "toktik/launcher_icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            launcherIconChannel
        ).setMethodCallHandler { call, result ->
            if (call.method != "setSeason") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val season = call.argument<String>("season")
            val alias = when (season) {
                "normal" -> "MainActivityNormal"
                "halloween" -> "MainActivityHalloween"
                "christmas" -> "MainActivityChristmas"
                "valentines" -> "MainActivityValentines"
                else -> {
                    result.error("invalid_season", "Unknown TokTik season", null)
                    return@setMethodCallHandler
                }
            }

            try {
                setLauncherAlias(alias)
                result.success(null)
            } catch (exception: Exception) {
                result.error("launcher_icon_failed", exception.message, null)
            }
        }
    }

    private fun setLauncherAlias(activeAlias: String) {
        if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0) return

        val aliases = listOf(
            "MainActivityNormal",
            "MainActivityHalloween",
            "MainActivityChristmas",
            "MainActivityValentines"
        )
        aliases.filter { it != activeAlias }.forEach { alias ->
            packageManager.setComponentEnabledSetting(
                ComponentName(packageName, "$packageName.$alias"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }
        packageManager.setComponentEnabledSetting(
            ComponentName(packageName, "$packageName.$activeAlias"),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )
    }
}
