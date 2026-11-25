# 📱 Hướng dẫn chạy TripMate trên iPhone (iOS)

> **Môi trường:** Windows PC + iPhone cắm dây USB · Flutter 3.38.5  
> **Thiết bị test hiện tại:** FPTDaigakuNO1 (iPhone 15 Plus · `00008120-000C618026D1A01E`)

---

## ⚡ Cách nhanh nhất — Chạy 1 lệnh

```bat
E:\TripMate\TripMate_app\run-ios.bat
```

Lệnh này dùng `builder.exe` để tự động build code Flutter, đẩy sang iPhone qua USB và bật Hot Reload. **Không cần macOS.**

> 💡 Nếu bấm đôi vào file `.bat` không chạy, nhấn chuột phải → **Chạy với tư cách quản trị viên**.

---

## 🔧 Yêu cầu trước khi chạy

### 1. Phần mềm cần cài

| Phần mềm | Phiên bản | Tải về |
|---|---|---|
| Flutter SDK | **3.38.5** | [flutter.dev](https://flutter.dev/docs/get-started/install/windows) |
| MobAI | 3.4.x | Đã cài sẵn tại `C:\Program Files\MobAI\MobAI.exe` |
| iTunes / Apple Devices | Mới nhất | Microsoft Store |

### 2. Chuẩn bị iPhone

- ✅ Kết nối iPhone với máy tính qua **cáp USB**
- ✅ Trên iPhone bấm **"Tin cậy"** khi được hỏi
- ✅ Bật chế độ **Developer Mode**: `Cài đặt → Chế độ bảo mật & Quyền riêng tư → Chế độ nhà phát triển`
- ✅ iPhone **phải mở khóa** (màn hình không ở trạng thái ngủ)

---

## 🟢 Phương pháp 1: Hot Reload (phát triển hàng ngày)

### Bước 1 — Mở MobAI

```bat
"C:\Program Files\MobAI\MobAI.exe"
```

Kiểm tra MobAI thấy iPhone trong danh sách thiết bị (icon ở thanh taskbar).

### Bước 2 — Chạy app với builder.exe

Mở PowerShell / CMD tại thư mục dự án:

```bat
cd E:\TripMate\TripMate_app
run-ios.bat
```

Hoặc chạy lệnh trực tiếp:

```bat
"E:\TripMate\TripMate_app\builder.exe" dev flutter --skip-install --bundle-id com.tripmate.tripmate.P8ZFA6VWMX
```

### Bước 3 — Chờ khởi động

```
✓ Flutter bundle built
✓ Hot reload server ready
✓ App launched on FPTDaigakuNO1
```

Khi thấy thông báo trên, app đã chạy trên điện thoại.

### Các phím tắt trong terminal

| Phím | Chức năng |
|---|---|
| `r` (thường) | **Hot Reload** — nạp lại code, giữ nguyên trạng thái app |
| `R` (hoa) | **Hot Restart** — khởi động lại toàn bộ app từ đầu |
| `q` | Thoát |

> ⚠️ **Khi nào phải gõ `R` (Hot Restart)?**  
> Khi sửa: file `main.dart`, provider, router, global state, hoặc các sửa đổi liên quan đến native code.

---

## 🔴 Phương pháp 2: Build & Ký IPA (cài app không cần kết nối)

Dùng khi muốn **cài app để dùng độc lập** (không cần cắm dây máy tính), hoặc khi đã thay đổi native iOS code (Swift, Podfile, Info.plist, Widget Extension...).

### Bước 1 — Build IPA

```bat
"E:\TripMate\TripMate_app\builder.exe" ios build
```

File IPA xuất hiện tại: `E:\TripMate\TripMate_app\dist\TripMate-*.ipa`

### Bước 2 — Ký và cài IPA lên iPhone

```bat
E:\TripMate\TripMate_app\sign-ios.bat
```

Script này sẽ:
1. Đăng nhập Apple ID (`thihtktk@gmail.com`)
2. Ký IPA bằng `iloader-cli.exe`
3. Sideload lên iPhone (`00008120-000C618026D1A01E`)

> 💡 **Nếu iPhone hiển thị mã 6 số** (two-factor authentication): nhập 6 số đó vào terminal đang chờ.

### Bước 3 — Tin cậy nhà phát triển trên iPhone

Sau khi cài xong, vào **Cài đặt iPhone**:

```
Cài đặt → Cài đặt chung → Quản lý VPN & Thiết bị
→ Chọn "thihtktk@gmail.com" → Bấm "Tin cậy"
```

---

## 🌐 Backend & Cloudflare Tunnel

App cần backend để hoạt động. Mở **hai terminal riêng biệt**:

### Terminal 1 — Chạy Backend

```bat
cd E:\TripMate\TripMate_be
node dist/main
```

Server khởi động tại `http://localhost:3000`. Kiểm tra:

```bash
curl http://localhost:3000/api/v1/health
# Kết quả: {"status":"ok"}
```

### Terminal 2 — Cloudflare Tunnel (để iPhone truy cập backend)

```bat
"C:\Program Files (x86)\cloudflared\cloudflared.exe" tunnel --url http://localhost:3000
```

Sau vài giây, terminal hiển thị:

```
Your quick Tunnel has been created! Visit it at (it may take some time to start up):
https://assistance-charging-chances-controversy.trycloudflare.com
```

> ⚠️ URL tunnel thay đổi mỗi lần restart. Nếu URL thay đổi, cần cập nhật lại `baseUrl` trong file cấu hình của Flutter.

---

## 🪟 Widget iOS (màn hình chính)

Widget hiển thị ảnh Polaroid giống Locket cần được build kèm trong IPA. Hot Reload **không** cập nhật widget.

**Khi nào cần build lại IPA?**
- Lần đầu cài widget
- Khi sửa code Swift trong `ios/TripMateWidget/`
- Khi đổi cấu hình App Group

**Quy trình:**
```bat
builder.exe ios build   ← Build IPA mới kèm Widget Extension
sign-ios.bat            ← Ký và cài lên iPhone
```

Chi tiết cấu hình Widget → xem: [`ios/WIDGET_SETUP.md`](ios/WIDGET_SETUP.md)

---

## 🔍 Debug & Xem Log

### Xem log trong terminal

```powershell
# Lọc log của TripMate trên iPhone đang cắm
flutter logs
```

### Xem lỗi bằng Flutter DevTools

```bash
flutter devtools
```

Mở trình duyệt tại `http://localhost:9100` để:
- Xem widget tree
- Profile performance (FPS, memory)
- Debug network

### Kiểm tra lỗi code trước khi chạy

```bat
cd E:\TripMate\TripMate_app
flutter analyze --no-pub
```

Kết quả mong đợi: `No issues found!`

---

## 🧯 Xử lý sự cố thường gặp

### App bị đơ / treo UI

```
Giải pháp: Gõ R (Hot Restart) trong terminal đang chạy Flutter
```

Nếu không được, đóng hoàn toàn app trên iPhone rồi mở lại.

### "App not installed" / bundle ID không tìm thấy

```
Nguyên nhân: App chưa được cài hoặc IPA đã hết hạn ký (7 ngày)
Giải pháp: Chạy lại sign-ios.bat để cài lại
```

### MobAI không thấy iPhone

```
Kiểm tra:
1. Cáp USB có chắc không?
2. iPhone đã bấm "Tin cậy" chưa?
3. iTunes/Apple Devices đã cài chưa?
4. Khởi động lại MobAI
```

### builder.exe báo lỗi "device not found"

```powershell
# Liệt kê thiết bị đang kết nối
flutter devices

# Nếu thấy iPhone, thử chạy trực tiếp
flutter run -d 00008120-000C618026D1A01E
```

### Pod / CocoaPods lỗi (cần macOS)

> ⚠️ CocoaPods (`pod install`) chỉ chạy trên **macOS**. Khi thêm native plugin mới vào `pubspec.yaml`, cần một máy Mac để chạy `pod install` trong thư mục `ios/`.

### Cloudflare URL thay đổi sau restart

Cập nhật base URL trong:

```
E:\TripMate\TripMate_app\lib\core\network\api_client.dart
```

---

## 📁 Cấu trúc file quan trọng

```
E:\TripMate\
├── TripMate_app\
│   ├── run-ios.bat              ← Chạy Hot Reload (dùng hàng ngày)
│   ├── sign-ios.bat             ← Ký & cài IPA lên iPhone
│   ├── builder.exe              ← CLI build tool chính
│   ├── builder.json             ← Cấu hình: bundle ID, device ID
│   ├── dist\
│   │   └── TripMate-*.ipa       ← File IPA đã build
│   ├── ios\
│   │   ├── Runner\              ← Native iOS code
│   │   ├── TripMateWidget\      ← Widget Extension (Locket-style)
│   │   └── WIDGET_SETUP.md      ← Hướng dẫn cài Widget trong Xcode
│   └── lib\                     ← Source code Flutter (Dart)
└── TripMate_be\                 ← Backend NestJS
    └── dist\main.js             ← Server đã build
```

---

## 🔑 Thông tin quan trọng

| Thông tin | Giá trị |
|---|---|
| Bundle ID | `com.tripmate.tripmate` |
| Device ID iPhone | `00008120-000C618026D1A01E` |
| Apple ID (ký app) | `thihtktk@gmail.com` |
| App Group (Widget) | `group.com.tripmate.app` |
| Backend URL | `http://localhost:3000` |
| Flutter version | `3.38.5` |
| MobAI API | `http://127.0.0.1:8686` |

---

*Tài liệu cập nhật: Tháng 10/2026 · TripMate Squad 🏔️*
