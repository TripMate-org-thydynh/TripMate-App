package com.tripmate.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.provider.Settings
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest
import java.security.MessageDigest
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, trustChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "androidId" -> result.success(androidId())
                    "integrityToken" -> {
                        val project = call.argument<Number>("cloudProjectNumber")?.toLong()
                        val deviceId = call.argument<String>("deviceId")
                        if (project == null || deviceId == null) {
                            result.error("BAD_ARGS", "thiếu tham số", null)
                        } else {
                            integrityToken(project, deviceId, result)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Mã thiết bị và token Play Integrity cho việc xin dùng thử.
     *
     * Android ID (SSAID) riêng cho từng app ký bằng một khoá và từng người
     * dùng trên máy: gỡ cài đặt lại hay xoá dữ liệu vẫn giữ nguyên, nhưng app
     * khác không đọc ra cùng giá trị — đủ để server biết "máy này đã thử chưa"
     * mà không lần ra được con người. Server chỉ lưu băm có salt.
     *
     * Token Integrity gắn với mã đó qua `requestHash = sha256("trial:" + id)`,
     * nên không ghép được token máy này với mã máy khác.
     */
    private val trustChannel = "tripmate/device_trust"

    private fun androidId(): String? =
        runCatching {
            Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
        }.getOrNull()

    private fun integrityToken(project: Long, deviceId: String, result: MethodChannel.Result) {
        val hash = MessageDigest.getInstance("SHA-256")
            .digest("trial:$deviceId".toByteArray(Charsets.UTF_8))
            .joinToString("") { "%02x".format(it) }
        val manager = IntegrityManagerFactory.createStandard(applicationContext)
        manager.prepareIntegrityToken(
            PrepareIntegrityTokenRequest.builder().setCloudProjectNumber(project).build()
        ).addOnSuccessListener { provider ->
            provider.request(
                StandardIntegrityTokenRequest.builder().setRequestHash(hash).build()
            ).addOnSuccessListener { response -> result.success(response.token()) }
                .addOnFailureListener { e -> result.error("INTEGRITY", e.message, null) }
        }.addOnFailureListener { e -> result.error("INTEGRITY", e.message, null) }
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
