package com.tripmate.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import kotlin.concurrent.thread

/**
 * Widget màn hình chính: chồng ảnh mới nhất của squad.
 *
 * Ý tưởng mượn từ Locket — ảnh bạn bè gửi hiện ngay giữa các icon, không cần mở
 * app. Khác Locket ở chỗ widget nói rõ ảnh thuộc **chuyến nào**, vì vòng bạn của
 * TripMate là squad theo chuyến chứ không phải danh sách bạn bè vĩnh viễn.
 *
 * Chạm vào widget mở thẳng màn xem khoảnh khắc (`/moments/viewer`) để thả cảm
 * xúc, thay vì chỉ mở app rồi bắt người dùng tự tìm đường.
 *
 * Dữ liệu do Flutter ghi vào SharedPreferences qua `home_widget`
 * (xem `lib/core/services/widget_sync.dart`).
 */
class TripMateWidgetProvider : HomeWidgetProvider() {

    /** Số ảnh vẽ chồng lên nhau; phần dư hiện thành huy hiệu "+N". */
    private val maxLayers = 3

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val feed = parseFeed(widgetData.getString("tm_feed", null))

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.tripmate_widget)
            bindTap(context, views)

            if (feed.isEmpty()) {
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                views.setImageViewResource(R.id.widget_image, R.drawable.widget_placeholder)
                appWidgetManager.updateAppWidget(widgetId, views)
                return@forEach
            }

            views.setViewVisibility(R.id.widget_empty, View.GONE)
            // Vẽ khung rỗng trước để widget không đứng hình chờ mạng; ảnh tải
            // xong thì cập nhật lần hai. Widget không được làm việc mạng trên
            // luồng chính.
            appWidgetManager.updateAppWidget(widgetId, views)

            val top = feed.first()
            val urls = feed.take(maxLayers).map { it.imageUrl }.filter { it.isNotBlank() }

            loadAllAsync(urls) { photos ->
                if (photos.isEmpty()) return@loadAllAsync
                val ageMs = System.currentTimeMillis() - top.createdAtMs
                val bitmap = WidgetCanvas.render(
                    photos = photos,
                    author = top.authorName,
                    subtitle = top.caption ?: top.tripName,
                    extraCount = (feed.size - photos.size).coerceAtLeast(0),
                    timeLabel = relativeTime(context, top.createdAtMs),
                    // Quá một ngày không có ảnh mới thì nhắc — đó là lúc vòng
                    // lặp "gửi ảnh → bạn bè thấy" nguội đi và cần một cú hích.
                    nudge = if (top.createdAtMs > 0 && ageMs > 24 * 3600_000L) {
                        context.getString(R.string.widget_nudge)
                    } else {
                        null
                    },
                )
                views.setImageViewBitmap(R.id.widget_image, bitmap)
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }
    }

    private data class FeedItem(
        val id: String,
        val imageUrl: String,
        val authorName: String,
        val tripName: String,
        val caption: String?,
        /** Mốc đăng ảnh, milli epoch. 0 nghĩa là không đọc được. */
        val createdAtMs: Long,
    )

    private fun parseFeed(raw: String?): List<FeedItem> {
        if (raw.isNullOrBlank()) return emptyList()
        val arr = runCatching { JSONArray(raw) }.getOrNull() ?: return emptyList()
        return (0 until arr.length()).mapNotNull { i ->
            val o = arr.optJSONObject(i) ?: return@mapNotNull null
            FeedItem(
                id = o.optString("id"),
                imageUrl = o.optString("imageUrl"),
                authorName = o.optString("authorName"),
                tripName = o.optString("tripName"),
                caption = o.optString("caption").takeIf { it.isNotBlank() && it != "null" },
                createdAtMs = parseIso(o.optString("createdAt")),
            )
        }
    }

    /**
     * Đọc mốc thời gian ISO-8601 mà Flutter ghi ra.
     *
     * Dùng `Instant` thay vì `SimpleDateFormat`: chuỗi có phần mili và hậu tố
     * `Z`, và `SimpleDateFormat` không phải thread-safe — widget giải mã ảnh
     * trên nhiều luồng.
     */
    private fun parseIso(raw: String?): Long {
        if (raw.isNullOrBlank()) return 0L
        return runCatching { java.time.Instant.parse(raw).toEpochMilli() }
            .getOrElse {
                runCatching {
                    java.time.LocalDateTime.parse(raw)
                        .toInstant(java.time.ZoneOffset.UTC).toEpochMilli()
                }.getOrDefault(0L)
            }
    }

    /**
     * Nhãn thời gian ngắn cho ảnh mới nhất: "vừa xong", "2 giờ trước"...
     *
     * Đây là thứ biến widget từ một tấm ảnh tĩnh thành **cửa sổ đang sống**:
     * người xem biết ngay ảnh này vừa mới hay đã cũ, nên có lý do liếc lại.
     */
    private fun relativeTime(context: Context, whenMs: Long): String {
        if (whenMs <= 0L) return ""
        val diff = System.currentTimeMillis() - whenMs
        if (diff < 0) return context.getString(R.string.widget_time_now)
        val min = diff / 60_000
        val hour = min / 60
        val day = hour / 24
        return when {
            min < 2 -> context.getString(R.string.widget_time_now)
            min < 60 -> context.getString(R.string.widget_time_min, min)
            hour < 24 -> context.getString(R.string.widget_time_hour, hour)
            day < 7 -> context.getString(R.string.widget_time_day, day)
            else -> ""
        }
    }

    /** Chạm vào widget mở thẳng màn xem khoảnh khắc. */
    private fun bindTap(context: Context, views: RemoteViews) {
        val intent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("tripmate://moments/viewer"),
        )
        views.setOnClickPendingIntent(R.id.widget_root, intent)
    }

    /**
     * Tải song song rồi gọi lại **một lần** khi xong hết.
     *
     * Giữ đúng thứ tự đầu vào: thứ tự quyết định ảnh nào nằm trên cùng.
     * Ảnh nào hỏng thì bỏ qua, không chặn cả chồng ảnh.
     */
    private fun loadAllAsync(urls: List<String>, onDone: (List<Bitmap>) -> Unit) {
        if (urls.isEmpty()) {
            onDone(emptyList())
            return
        }
        thread {
            val slots = arrayOfNulls<Bitmap>(urls.size)
            val workers = urls.mapIndexed { i, url ->
                thread { slots[i] = fetchBitmap(url) }
            }
            workers.forEach { it.join() }
            onDone(slots.filterNotNull())
        }
    }

    private fun fetchBitmap(url: String): Bitmap? = runCatching {
        val conn = URL(url).openConnection() as HttpURLConnection
        conn.connectTimeout = 8000
        conn.readTimeout = 8000
        conn.doInput = true
        conn.connect()
        conn.inputStream.use {
            // Giảm mẫu khi giải mã: ảnh gốc 600px vẽ vào ô ~450px, không cần
            // giữ nguyên kích thước trong bộ nhớ.
            BitmapFactory.decodeStream(it, null, BitmapFactory.Options().apply { inSampleSize = 1 })
        }
    }.getOrNull()
}
