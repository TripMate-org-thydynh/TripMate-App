package com.tripmate.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

/**
 * Widget màn hình chính hiển thị khoảnh khắc mới nhất của squad.
 *
 * Ý tưởng mượn từ Locket: ảnh bạn bè gửi hiện ngay giữa các icon, không cần mở
 * app. Khác Locket ở chỗ widget nói rõ ảnh thuộc **chuyến nào** — vì vòng bạn
 * của TripMate là squad theo chuyến, không phải danh sách bạn bè vĩnh viễn.
 *
 * Dữ liệu do Flutter ghi vào SharedPreferences qua package `home_widget`
 * (xem `lib/core/services/widget_sync.dart`).
 */
class TripMateWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.tripmate_widget)

            val raw = widgetData.getString("tm_latest_moment", null)
            if (raw.isNullOrBlank()) {
                // Chưa có ảnh nào: mời chụp thay vì để ô trống khó hiểu.
                views.setTextViewText(R.id.widget_author, context.getString(R.string.widget_empty_title))
                views.setTextViewText(R.id.widget_trip, context.getString(R.string.widget_empty_body))
                views.setImageViewResource(R.id.widget_image, R.drawable.widget_placeholder)
                bindTapToOpenApp(context, views)
                appWidgetManager.updateAppWidget(widgetId, views)
                return@forEach
            }

            val moment = runCatching { JSONObject(raw) }.getOrNull()
            if (moment == null) {
                appWidgetManager.updateAppWidget(widgetId, views)
                return@forEach
            }

            val author = moment.optString("authorName")
            val trip = moment.optString("tripName")
            val caption = moment.optString("caption").takeIf { it.isNotBlank() && it != "null" }
            val imageUrl = moment.optString("imageUrl")

            views.setTextViewText(R.id.widget_author, author)
            // Ưu tiên caption; không có thì hiện tên chuyến để biết ảnh từ đâu.
            views.setTextViewText(R.id.widget_trip, caption ?: trip)
            bindTapToOpenApp(context, views)

            // Vẽ ngay phần chữ, ảnh tải xong thì cập nhật lần hai. Widget không
            // được phép làm việc mạng trên luồng chính.
            appWidgetManager.updateAppWidget(widgetId, views)
            if (imageUrl.isNotBlank()) {
                loadImageAsync(imageUrl) { bitmap ->
                    if (bitmap != null) {
                        views.setImageViewBitmap(R.id.widget_image, bitmap)
                        appWidgetManager.updateAppWidget(widgetId, views)
                    }
                }
            }
        }
    }

    /** Chạm vào widget là mở thẳng app. */
    private fun bindTapToOpenApp(context: Context, views: RemoteViews) {
        val intent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
        )
        views.setOnClickPendingIntent(R.id.widget_root, intent)
    }

    private fun loadImageAsync(url: String, onDone: (Bitmap?) -> Unit) {
        thread {
            val bitmap = runCatching {
                val conn = URL(url).openConnection() as HttpURLConnection
                conn.connectTimeout = 8000
                conn.readTimeout = 8000
                conn.doInput = true
                conn.connect()
                conn.inputStream.use { BitmapFactory.decodeStream(it) }
            }.getOrNull()
            onDone(bitmap)
        }
    }
}
