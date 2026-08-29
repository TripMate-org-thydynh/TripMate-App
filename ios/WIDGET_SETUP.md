# Widget iOS — các bước cần làm trong Xcode

Toàn bộ mã Swift đã viết sẵn trong `ios/TripMateWidget/`. Phần còn lại **bắt
buộc làm trong Xcode**: thêm một target vào project là thao tác IDE, không sinh
an toàn từ dòng lệnh được (sửa tay `project.pbxproj` rất dễ làm hỏng project).

Cần một máy macOS có Xcode. Khoảng 10 phút.

---

## 1. Tạo widget extension

1. Mở `ios/Runner.xcworkspace` bằng Xcode (**không** phải `.xcodeproj`)
2. **File → New → Target…**
3. Chọn **Widget Extension** → Next
4. Điền:
   - Product Name: **`TripMateWidget`** (phải đúng chính tả — khớp với
     `WidgetSync.iOSWidgetName` trong `lib/core/services/widget_sync.dart`)
   - **Bỏ tick** "Include Live Activity"
   - **Bỏ tick** "Include Configuration App Intent"
5. Finish → khi Xcode hỏi "Activate scheme?" chọn **Cancel** (không cần đổi
   scheme đang chạy)

Xcode sẽ tạo một thư mục `TripMateWidget` với file mẫu.

## 2. Thay bằng mã đã viết sẵn

1. Trong Xcode, xoá file `TripMateWidget.swift` mà Xcode vừa sinh
   (chọn **Move to Trash**)
2. Kéo `ios/TripMateWidget/TripMateWidget.swift` (file trong repo) vào target
   `TripMateWidget` trên Xcode
   - Tick **Copy items if needed**: **KHÔNG** (giữ nguyên file trong repo)
   - Add to targets: chỉ tick **TripMateWidget**

## 3. Bật App Group cho **cả hai** target

App Group là vùng lưu chung — không có nó thì widget không đọc được dữ liệu app
ghi ra, và widget sẽ luôn trống.

Làm **hai lần**, một cho mỗi target:

1. Chọn project **Runner** ở cột trái
2. Chọn target **Runner** → tab **Signing & Capabilities**
3. Bấm **+ Capability** → chọn **App Groups**
4. Bấm **+** trong ô App Groups → nhập:
   ```
   group.com.tripmate.app
   ```
5. **Lặp lại đúng các bước trên cho target `TripMateWidget`**

> Chuỗi `group.com.tripmate.app` phải giống hệt ở ba nơi: hai target trên Xcode
> và hằng `WidgetSync.appGroupId` trong Flutter.

## 4. Kiểm tra Info.plist của app

`ios/Runner/Info.plist` đã được thêm sẵn ba khoá bắt buộc (nếu thiếu, Apple sẽ
từ chối duyệt):

- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription` — cần cho clip ngắn có tiếng
- `NSPhotoLibraryUsageDescription`

Không phải làm gì thêm, chỉ mở ra xác nhận là đủ.

## 5. Chạy thử

```bash
flutter run -d <iphone>
```

Trên máy/simulator: giữ màn hình chính → **+** → tìm **TripMate** → thêm widget.

Lần đầu widget sẽ hiện "Chưa có khoảnh khắc". Mở app, gửi một ảnh bằng Squad
Cam, widget sẽ đổi trong vài giây.

---

## Nếu widget vẫn trống

1. **Sai App Group** — nguyên nhân phổ biến nhất. Kiểm tra chuỗi ở cả hai
   target, để ý dấu chấm và chữ hoa/thường.
2. **Sai tên kind** — `kind` trong `TripMateWidget.swift` phải là
   `"TripMateWidget"`, khớp `WidgetSync.iOSWidgetName`.
3. **Chưa gửi ảnh nào** — widget đọc `tm_latest_moment`; chưa có moment nào
   trong squad thì nó trống là đúng.
4. **Ảnh không tải được** — widget tải ảnh qua HTTPS từ Cloudinary; kiểm tra
   máy có mạng.

---

## Giới hạn đã biết

**Widget không cập nhật tức thì khi *người khác* gửi ảnh.** App đẩy dữ liệu
ngay sau khi *chính bạn* gửi, còn lại phụ thuộc lịch làm mới của iOS (đặt 30
phút, hệ điều hành có thể giãn thêm nếu máy tiết kiệm pin) hoặc lần mở app kế
tiếp.

Muốn tức thì như Locket thì cần **push notification im lặng** để đánh thức
widget — việc này cần APNs, mà dự án chưa cấu hình Firebase/APNs (xem
`EXTERNAL_SETUP.md` mục 6). Đây là giới hạn thật, không phải lỗi.
