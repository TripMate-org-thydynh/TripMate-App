package com.tripmate.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    /**
     * Cho phép app tự xin ghim widget lên màn hình chính.
     *
     * Không có kênh này thì người dùng phải tự biết đường: nhấn giữ màn hình
     * chính → khay tiện ích → cuộn tìm TripMate → kéo thả. Phần lớn sẽ không
     * làm, và widget dù đã cài vẫn không ai thấy.
     *
     * `requestPinAppWidget` là API 26+; launcher nào không hỗ trợ thì
     * `isRequestPinAppWidgetSupported` trả false và ta báo lại cho Flutter để
     * hiện hướng dẫn thủ công thay vì im lặng không làm gì.
     */
    private val channel = "tripmate/widget_pin"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(isPinSupported())
                    "requestPin" -> result.success(requestPin())
                    else -> result.notImplemented()
                }
            }
    }

    private fun isPinSupported(): Boolean {
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.O) return false
        return AppWidgetManager.getInstance(this).isRequestPinAppWidgetSupported
    }

    private fun requestPin(): Boolean {
        if (!isPinSupported()) return false
        val manager = AppWidgetManager.getInstance(this)
        val provider = ComponentName(this, TripMateWidgetProvider::class.java)
        return runCatching { manager.requestPinAppWidget(provider, null, null) }
            .getOrDefault(false)
    }
}
