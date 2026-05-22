package com.example.Terminal

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val METHOD_CHANNEL_NOTIFICATION = "custom_notification"
    private val METHOD_CHANNEL_DEVICE_IDS = "device_ids"

    private val REQ_CODE_RUNTIME_PERMS = 1001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestRuntimePermissionsIfNeeded()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NOTIFICATION)
            .setMethodCallHandler { call, result ->
                if (call.method == "showNotification") {
                    val title = call.argument<String>("title") ?: "Заголовок"
                    val message = call.argument<String>("message") ?: "Сообщение"
                    val intent = android.content.Intent(this, MyForegroundService::class.java).apply {
                        putExtra("title", title)
                        putExtra("message", message)
                    }
                    ContextCompat.startForegroundService(this, intent)
                    result.success("ok")
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_DEVICE_IDS)
            .setMethodCallHandler { call, result ->
                if (call.method == "getImeis") {
                    result.success(getImeisSafe())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun requestRuntimePermissionsIfNeeded() {
        val toRequest = mutableListOf<String>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            toRequest.add(Manifest.permission.POST_NOTIFICATIONS)
        }

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            toRequest.add(Manifest.permission.READ_PHONE_STATE)
        }

        if (toRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, toRequest.toTypedArray(), REQ_CODE_RUNTIME_PERMS)
        }
    }

    private fun getImeisSafe(): List<String> {
        val out = mutableListOf<String>()

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            return out
        }

        return try {
            val tm = getSystemService(TELEPHONY_SERVICE) as TelephonyManager

            val slots = try { tm.phoneCount } catch (_: Throwable) { 1 }

            for (slot in 0 until slots) {
                val imei = when {
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> {
                        try { tm.getImei(slot) } catch (_: Throwable) { null }
                    }
                    else -> {
                        try { tm.deviceId } catch (_: Throwable) { null }
                    }
                }
                if (!imei.isNullOrBlank()) out.add(imei)
            }
            out
        } catch (_: SecurityException) {
            emptyList()
        } catch (_: Throwable) {
            emptyList()
        }
    }
}