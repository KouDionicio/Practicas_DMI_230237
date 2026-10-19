package com.example.toktik

import android.content.ComponentName
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val launcherIconChannel = "toktik/launcher_icon"
    private val launcherIconTag = "TokTikLauncherIcon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            launcherIconChannel
        ).setMethodCallHandler { call, result ->
            if (call.method != "setSeason") {
                Log.e(launcherIconTag, "Unsupported launcher-icon method")
                result.notImplemented()
                return@setMethodCallHandler
            }

            val season = call.argument<String>("season")
            Log.d(launcherIconTag, "setSeason received")
            val alias = when (season) {
                "normal" -> "MainActivityNormal"
                "halloween" -> "MainActivityHalloween"
                "christmas" -> "MainActivityChristmas"
                "valentines" -> "MainActivityValentines"
                else -> {
                    Log.e(launcherIconTag, "Received an unsupported season value")
                    result.error("invalid_season", "Unknown TokTik season", null)
                    return@setMethodCallHandler
                }
            }

            try {
                setLauncherAlias(alias)
                Log.d(launcherIconTag, "Launcher alias synchronized")
                result.success(null)
            } catch (exception: Exception) {
                Log.e(launcherIconTag, "Could not synchronize launcher alias", exception)
                result.error("launcher_icon_failed", exception.message, null)
            }
        }
    }

    private fun setLauncherAlias(activeAlias: String) {
        val aliases = listOf(
            "MainActivityNormal",
            "MainActivityHalloween",
            "MainActivityChristmas",
            "MainActivityValentines"
        )
        if (aliases.none(::isLauncherAliasEnabled)) {
            packageManager.setComponentEnabledSetting(
                componentFor("MainActivityNormal"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        }
        val activeIsEnabled = isLauncherAliasEnabled(activeAlias)
        val othersAreDisabled = aliases.filter { it != activeAlias }.all { alias ->
            !isLauncherAliasEnabled(alias)
        }
        if (activeIsEnabled && othersAreDisabled) return

        // Enable the requested alias first so the package never has zero
        // seasonal aliases enabled, even if a later package-manager call fails.
        packageManager.setComponentEnabledSetting(
            componentFor(activeAlias),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )
        aliases.filter { it != activeAlias }.forEach { alias ->
            packageManager.setComponentEnabledSetting(
                ComponentName(packageName, "$packageName.$alias"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }
        val enabledAliases = aliases.filter { alias ->
            isLauncherAliasEnabled(alias)
        }
        check(enabledAliases == listOf(activeAlias)) {
            "Expected only $activeAlias enabled; found $enabledAliases"
        }
    }

    private fun isLauncherAliasEnabled(alias: String): Boolean {
        val state = packageManager.getComponentEnabledSetting(componentFor(alias))
        return when (state) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED_USER,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED_UNTIL_USED -> false
            else -> alias == "MainActivityNormal" && applicationInfo.enabled
        }
    }

    private fun componentFor(alias: String) =
        ComponentName(packageName, "$packageName.$alias")
}
