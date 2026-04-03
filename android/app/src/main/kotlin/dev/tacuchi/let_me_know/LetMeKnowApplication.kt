package dev.tacuchi.let_me_know

import android.app.Application
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.view.View
import android.view.WindowManager
import androidx.lifecycle.Observer
import com.gdelataillade.alarm.alarm.AlarmService as AlarmPluginService
import com.gdelataillade.alarm.services.AlarmRingingLiveData
import io.flutter.Log

class LetMeKnowApplication : Application() {

    companion object {
        private const val TAG = "LetMeKnowApp"
    }

    private val alarmObserver = Observer<Boolean> { isRinging ->
        if (isRinging && AlarmPluginService.ringingAlarmIds.isNotEmpty()) {
            Log.d(TAG, "Alarm ringing detected, bringing app to foreground")
            bringAppToForeground()
        }
    }

    override fun onCreate() {
        super.onCreate()
        AlarmRingingLiveData.instance.observeForever(alarmObserver)
    }

    private fun bringAppToForeground() {
        wakeScreen()

        // Estrategia 1: Lanzar desde el contexto del AlarmService (foreground service)
        // Un foreground service tiene la exención oficial para iniciar actividades
        try {
            val service = AlarmPluginService.instance
            if (service != null) {
                val intent = createLaunchIntent()
                service.startActivity(intent)
                Log.d(TAG, "Strategy 1 OK: launched from AlarmService context")
                return
            }
        } catch (e: Exception) {
            Log.d(TAG, "Strategy 1 failed: ${e.message}")
        }

        // Estrategia 2: PendingIntent.send() — tiene privilegios de sistema
        // que pueden bypasear restricciones OEM
        try {
            val intent = createLaunchIntent()
            val pi = PendingIntent.getActivity(
                this, 0, intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            pi.send()
            Log.d(TAG, "Strategy 2 OK: PendingIntent.send()")
            return
        } catch (e: Exception) {
            Log.d(TAG, "Strategy 2 failed: ${e.message}")
        }

        // Estrategia 3: Overlay trick — crear ventana invisible para obtener
        // status de "visible", luego lanzar la activity
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && Settings.canDrawOverlays(this)) {
            try {
                val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
                val overlay = View(this)
                val params = WindowManager.LayoutParams(
                    0, 0,
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                    PixelFormat.TRANSLUCENT
                )
                wm.addView(overlay, params)

                startActivity(createLaunchIntent())
                Log.d(TAG, "Strategy 3 OK: overlay trick")

                Handler(Looper.getMainLooper()).postDelayed({
                    try { wm.removeView(overlay) } catch (_: Exception) {}
                }, 2000)
                return
            } catch (e: Exception) {
                Log.d(TAG, "Strategy 3 failed: ${e.message}")
            }
        }

        // Estrategia 4: startActivity directo como último recurso
        try {
            startActivity(createLaunchIntent())
            Log.d(TAG, "Strategy 4 OK: direct startActivity")
        } catch (e: Exception) {
            Log.d(TAG, "Strategy 4 failed: ${e.message}")
        }
    }

    private fun createLaunchIntent(): Intent {
        return Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
        }
    }

    private fun wakeScreen() {
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!pm.isInteractive) {
                @Suppress("DEPRECATION")
                val wl = pm.newWakeLock(
                    PowerManager.SCREEN_BRIGHT_WAKE_LOCK or
                            PowerManager.ACQUIRE_CAUSES_WAKEUP or
                            PowerManager.ON_AFTER_RELEASE,
                    "let_me_know:AlarmWakeLock"
                )
                wl.acquire(10_000L)
            }
        } catch (_: Exception) {}
    }
}
