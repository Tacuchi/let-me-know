package dev.tacuchi.let_me_know

import android.app.ActivityManager
import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import com.gdelataillade.alarm.alarm.AlarmService as AlarmPluginService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "dev.tacuchi.let_me_know/app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "bringToForeground" -> {
                        bringToForeground()
                        result.success(true)
                    }
                    "getRingingAlarmIds" -> {
                        result.success(getRingingAlarmIds())
                    }
                    "canUseFullScreenIntent" -> {
                        result.success(canUseFullScreenIntent())
                    }
                    "getManufacturer" -> {
                        result.success(Build.MANUFACTURER)
                    }
                    "openOemPermissionSettings" -> {
                        result.success(openOemPermissionSettings())
                    }
                    "openFullScreenIntentSettings" -> {
                        result.success(openFullScreenIntentSettings())
                    }
                    "canDrawOverlays" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }
                    "openOverlaySettings" -> {
                        result.success(openOverlaySettings())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun bringToForeground() {
        // Wake lock para encender la pantalla
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!pm.isInteractive) {
                @Suppress("DEPRECATION")
                val wl = pm.newWakeLock(
                    PowerManager.SCREEN_BRIGHT_WAKE_LOCK or
                            PowerManager.ACQUIRE_CAUSES_WAKEUP or
                            PowerManager.ON_AFTER_RELEASE,
                    "let_me_know:BringToFront"
                )
                wl.acquire(10_000L)
            }
        } catch (_: Exception) {}

        // Estrategia 1: startActivity con FLAG_ACTIVITY_REORDER_TO_FRONT
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
            }
            startActivity(intent)
        } catch (_: Exception) {}

        // Estrategia 2: moveTaskToFront como respaldo
        try {
            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            am.moveTaskToFront(taskId, ActivityManager.MOVE_TASK_WITH_HOME)
        } catch (_: Exception) {}

        // Estrategia 3: Flags de ventana para lock screen
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)
                val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                keyguard.requestDismissKeyguard(this, null)
            }
        } catch (_: Exception) {}
    }

    private fun getRingingAlarmIds(): List<Int> {
        return try {
            AlarmPluginService.ringingAlarmIds
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return true
        }
        return try {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.canUseFullScreenIntent()
        } catch (_: Exception) {
            true
        }
    }

    private fun openFullScreenIntentSettings(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return try {
                startActivity(Intent(
                    Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                    Uri.parse("package:$packageName")
                ))
                true
            } catch (_: Exception) {
                false
            }
        }
        return false
    }

    private fun openOverlaySettings(): Boolean {
        return try {
            startActivity(Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            ))
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openOemPermissionSettings(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()

        val oemIntents = when {
            manufacturer.contains("xiaomi") || manufacturer.contains("redmi") || manufacturer.contains("poco") -> listOf(
                Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                    putExtra("extra_pkgname", packageName)
                },
                Intent().apply {
                    component = ComponentName(
                        "com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity"
                    )
                }
            )
            manufacturer.contains("huawei") || manufacturer.contains("honor") -> listOf(
                Intent().apply {
                    component = ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
                    )
                }
            )
            manufacturer.contains("oppo") || manufacturer.contains("realme") -> listOf(
                Intent().apply {
                    component = ComponentName(
                        "com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startup.StartupAppListActivity"
                    )
                }
            )
            else -> emptyList()
        }

        for (intent in oemIntents) {
            try {
                startActivity(intent)
                return true
            } catch (_: Exception) {
                continue
            }
        }

        // Fallback: abrir ajustes de la app
        return try {
            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            })
            true
        } catch (_: Exception) {
            false
        }
    }
}
