package com.tripmate.app

import android.graphics.Bitmap
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import kotlin.math.min

/**
 * Vẽ chồng ảnh cho widget màn hình chính.
 *
 * Tất cả gom vào **một** bitmap vì `RemoteViews` không xoay được view, không đổ
 * bóng và không cắt bo góc ảnh. Ghép nhiều `ImageView` lệch nhau chỉ ra được
 * các hình chữ nhật thẳng đứng — trông như lỗi layout chứ không ra chồng ảnh.
 *
 * ## Vì sao bố cục là như thế này
 *
 * Locket tự mô tả là *"a small, live photo window"* — cửa sổ ảnh sống trên màn
 * hình chính, thay cho một feed rối. Nghĩa là **ảnh chính là widget**, không
 * phải một tấm ảnh nhỏ đặt giữa một tấm nền.
 *
 * Bản đầu tiên ở đây làm ngược: ảnh chỉ chiếm 62% bề ngang, phần còn lại là nền
 * kem, chữ xếp dưới đáy — nhìn trống hoác. Nay:
 *
 * - ảnh trên cùng chiếm **88%** bề ngang, gần chạm mép widget;
 * - tên và caption **đè lên ảnh** trên dải tối chuyển sắc, lấy lại toàn bộ
 *   khoảng chiều cao mà chữ từng chiếm riêng;
 * - các lớp cũ vẫn thò ra sau với góc nghiêng — đó là phần TripMate thêm vào so
 *   với Locket, để thấy ngay "còn nữa ở trong".
 */
object WidgetCanvas {

    /**
     * Cạnh bitmap xuất ra.
     *
     * Giữ 720 dù widget mặc định là ô 2x2: người dùng kéo to ra được, và bitmap
     * nhỏ thì lúc đó sẽ vỡ. 720x720 ARGB ~2MB, vẫn trong hạn của RemoteViews.
     */
    private const val SIZE = 720

    private const val CREAM = 0xFFFDF6D3.toInt()
    private const val INK = 0xFF141210.toInt()
    private const val FRAME = 0xFFFFFDF5.toInt()
    private const val YELLOW = 0xFFFFD84D.toInt()

    /**
     * Góc nghiêng từng lớp, phần tử cuối là lớp trên cùng (không nghiêng).
     *
     * Nghiêng vừa phải: ở ô 2x2 mỗi độ nghiêng ăn vào bề ngang thật của ảnh
     * chính, nghiêng nhiều thì chồng ảnh rối mà ảnh lại nhỏ đi.
     */
    private val TILTS = floatArrayOf(-6f, 4f, 0f)

    /**
     * @param timeLabel nhãn kiểu "2 giờ trước"; rỗng thì không vẽ
     * @param nudge lời nhắc khi squad lâu chưa đăng ảnh; null thì không vẽ
     */
    fun render(
        photos: List<Bitmap>,
        author: String,
        subtitle: String,
        extraCount: Int,
        timeLabel: String = "",
        nudge: String? = null,
    ): Bitmap {
        val out = Bitmap.createBitmap(SIZE, SIZE, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(out)

        drawBackground(canvas)

        val layers = photos.take(3)
        val tilts = TILTS.takeLast(layers.size)
        // Vẽ từ lớp sau ra trước để ảnh mới nhất nằm trên cùng.
        for (i in layers.indices.reversed()) {
            drawPolaroid(canvas, layers[i], tilts[i], depth = i, isTop = i == 0)
        }

        if (layers.isNotEmpty()) {
            drawOverlayText(canvas, author, subtitle, hasNudge = !nudge.isNullOrBlank())
        }
        if (extraCount > 0) drawExtraBadge(canvas, extraCount)
        if (timeLabel.isNotBlank()) drawTimeChip(canvas, timeLabel)
        if (!nudge.isNullOrBlank()) drawNudge(canvas, nudge)
        return out
    }

    private fun drawBackground(canvas: Canvas) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = CREAM }
        canvas.drawRoundRect(RectF(0f, 0f, SIZE.toFloat(), SIZE.toFloat()), 56f, 56f, paint)
    }

    /**
     * Một tấm ảnh: viền trắng + bóng mềm, xoay quanh tâm.
     *
     * Lớp trên cùng gần vuông và chiếm gần hết bề ngang. Các lớp sau thu nhỏ
     * dần và lệch lên trên, chỉ cần ló ra đủ để thấy là có nhiều tấm.
     */
    private fun drawPolaroid(
        canvas: Canvas,
        photo: Bitmap,
        tilt: Float,
        depth: Int,
        isTop: Boolean,
    ) {
        val shrink = 1f - depth * 0.045f
        val frameW = SIZE * 0.88f * shrink
        val border = SIZE * 0.019f
        val frameH = frameW

        val cx = SIZE / 2f
        val cy = SIZE * 0.5f - depth * SIZE * 0.018f

        canvas.save()
        canvas.rotate(tilt, cx, cy)

        val frame = RectF(cx - frameW / 2, cy - frameH / 2, cx + frameW / 2, cy + frameH / 2)

        val shadow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(66, 20, 18, 16)
            maskFilter = android.graphics.BlurMaskFilter(
                16f,
                android.graphics.BlurMaskFilter.Blur.NORMAL,
            )
        }
        canvas.drawRoundRect(RectF(frame).apply { offset(0f, 9f) }, 26f, 26f, shadow)
        canvas.drawRoundRect(frame, 26f, 26f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = FRAME })

        val photoRect = RectF(
            frame.left + border,
            frame.top + border,
            frame.right - border,
            frame.bottom - border,
        )
        drawBitmapCenterCrop(canvas, photo, photoRect, 18f)

        // Dải tối chỉ vẽ ở lớp trên cùng — nơi chữ sẽ nằm đè lên.
        if (isTop) drawScrim(canvas, photoRect)

        canvas.restore()
    }

    /** Dải chuyển sắc ở đáy ảnh, để chữ trắng luôn đọc được dù ảnh sáng. */
    private fun drawScrim(canvas: Canvas, photo: RectF) {
        val top = photo.bottom - photo.height() * 0.40f
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                0f, top, 0f, photo.bottom,
                intArrayOf(Color.TRANSPARENT, Color.argb(210, 10, 9, 8)),
                floatArrayOf(0f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.save()
        canvas.clipRect(photo)
        canvas.drawRoundRect(photo, 18f, 18f, paint)
        canvas.restore()
    }

    /**
     * Vẽ ảnh lấp đầy khung theo kiểu center-crop, bo góc.
     *
     * Dùng `BitmapShader` thay vì `drawBitmap(src, dst)` để bo góc được — cắt
     * theo `Path` rồi vẽ sẽ răng cưa ở góc nghiêng.
     */
    private fun drawBitmapCenterCrop(canvas: Canvas, bmp: Bitmap, dst: RectF, radius: Float) {
        val scale = maxOf(dst.width() / bmp.width, dst.height() / bmp.height)
        val dx = dst.left + (dst.width() - bmp.width * scale) / 2f
        val dy = dst.top + (dst.height() - bmp.height * scale) / 2f

        val shader = BitmapShader(bmp, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        shader.setLocalMatrix(Matrix().apply {
            setScale(scale, scale)
            postTranslate(dx, dy)
        })
        canvas.drawRoundRect(dst, radius, radius, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.shader = shader
        })
    }

    /**
     * Tên người đăng + caption, đè lên đáy ảnh.
     *
     * Đặt chữ lên ảnh thay vì xếp dưới là chỗ lấy lại được nhiều không gian
     * nhất — trước đây riêng khối chữ đã ăn hơn một phần năm chiều cao widget.
     */
    private fun drawOverlayText(
        canvas: Canvas,
        author: String,
        subtitle: String,
        hasNudge: Boolean,
    ) {
        val cx = SIZE / 2f
        val namePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = SIZE * 0.074f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        val subPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(225, 255, 255, 255)
            textSize = SIZE * 0.054f
            textAlign = Paint.Align.CENTER
        }

        // Giữ chữ cách mép ảnh một khoảng: viền trắng dày + bo góc sẽ liếm vào
        // phần chữ nếu đặt sát đáy, và ở cỡ widget nhỏ thì mất hẳn dòng dưới.
        // Dải nhắc chiếm chỗ ở đáy, nên khi có nó thì nhấc cả khối chữ lên —
        // nếu không, băng vàng liếm mất dòng tên chuyến.
        val lift = if (hasNudge) SIZE * 0.088f else 0f
        val hasSub = subtitle.isNotBlank()
        val baseName = (if (hasSub) SIZE * 0.800f else SIZE * 0.845f) - lift
        canvas.drawText(ellipsize(author, namePaint), cx, baseName, namePaint)
        if (hasSub) {
            canvas.drawText(
                ellipsize(subtitle, subPaint), cx, SIZE * 0.874f - lift, subPaint,
            )
        }
    }

    /**
     * Chip thời gian ở góc trên trái ảnh.
     *
     * Biến widget từ một tấm ảnh tĩnh thành cửa sổ đang sống: liếc qua là biết
     * ảnh vừa mới hay đã cũ — chính điều khiến người ta nhìn lại nhiều lần.
     */
    private fun drawTimeChip(canvas: Canvas, label: String) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = SIZE * 0.042f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        val padH = SIZE * 0.028f
        val padV = SIZE * 0.018f
        val w = paint.measureText(label) + padH * 2
        val h = paint.textSize + padV * 2
        val left = SIZE * 0.10f
        val top = SIZE * 0.115f
        val r = RectF(left, top, left + w, top + h)

        canvas.drawRoundRect(
            r, h / 2, h / 2,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(150, 10, 9, 8) },
        )
        canvas.drawText(label, left + padH, top + padV + paint.textSize * 0.82f, paint)
    }

    /**
     * Dải nhắc khi squad lâu chưa đăng ảnh.
     *
     * Widget im lặng khi không có gì mới thì dần bị bỏ qua. Một dòng nhắc biến
     * khoảng lặng đó thành lời mời chụp tấm tiếp theo.
     */
    private fun drawNudge(canvas: Canvas, text: String) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = INK
            textSize = SIZE * 0.040f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        val h = SIZE * 0.082f
        val top = SIZE - h - SIZE * 0.022f
        val r = RectF(SIZE * 0.09f, top, SIZE * 0.91f, top + h)
        canvas.drawRoundRect(r, h / 2, h / 2, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = YELLOW })
        canvas.drawText(
            ellipsize(text, paint), SIZE / 2f,
            top + h / 2 + paint.textSize * 0.36f, paint,
        )
    }

    /** Huy hiệu "+N" cho những ảnh chưa hiện — gợi ý chạm vào để xem tiếp. */
    private fun drawExtraBadge(canvas: Canvas, count: Int) {
        val r = SIZE * 0.068f
        val cx = SIZE * 0.845f
        val cy = SIZE * 0.155f

        canvas.drawCircle(cx, cy, r, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = INK })
        canvas.drawCircle(cx, cy, r - 5f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = YELLOW })

        val text = "+$count"
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = INK
            textSize = r * 0.8f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
        }
        val bounds = Rect()
        paint.getTextBounds(text, 0, text.length, bounds)
        canvas.drawText(text, cx, cy + bounds.height() / 2f, paint)
    }

    /** Cắt bớt chuỗi cho vừa bề ngang, thêm dấu ba chấm. */
    private fun ellipsize(text: String, paint: Paint): String {
        val maxW = SIZE * 0.78f
        if (paint.measureText(text) <= maxW) return text
        var end = text.length
        while (end > 1 && paint.measureText(text.substring(0, end) + "…") > maxW) end--
        return text.substring(0, min(end, text.length)) + "…"
    }
}
