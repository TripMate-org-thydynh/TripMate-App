# 🛠️ AI Developer Playbook & Workspace Guidelines (claude.md)

Chào mừng bạn đến với tài liệu hướng dẫn phát triển tự động dành cho AI (Claude, Antigravity, và các tác nhân mã hóa khác). File này đóng vai trò là **Nguồn Sự Thật Duy Nhất (Single Source of Truth)** để định hình kiến trúc, quy trình làm việc, thiết kế giao diện và ngăn ngừa các lỗi ảo giác (hallucinations) trong suốt quá trình xây dựng dự án **TripMate**.

---

## 🎯 1. Tổng Quan Dự Án & Định Hướng Sản Phẩm
*   **Tên dự án:** TripMate (Super App Du Lịch Nhóm dành cho Gen Z).
*   **Khẩu hiệu:** Plan chill. Chia tiền ez. Lưu moment.
*   **Kiến trúc Mobile:** Flutter (Dart) - Giao diện cao cấp, mượt mà, micro-animations sinh động.
*   **Kiến trúc Backend:** Supabase (Auth, PostgreSQL Database, Storage, Realtime Sync).
*   **Tích hợp AI:** Claude API (Anthropic) cho các tính năng Vibe Match, Debt Roast, OCR.

---

## 🎨 2. Nguyên Lý Thiết Kế & Hệ Thống Giao Diện (Visual Guidelines)
Gen Z đòi hỏi một giao diện cực kỳ cá tính, sống động và mượt mà. Mọi màn hình được tạo hoặc chỉnh sửa phải tuân theo các nguyên tắc sau:

### ⚠️ QUY TẮC BẮT BUỘC TOÀN CẦU (USER GLOBAL RULES):
1.  **Luôn kiểm tra lỗi phân tích tĩnh (Lint Error)** sau mỗi lần chỉnh sửa mã nguồn bằng lệnh `flutter analyze`.
2.  **Mọi màn hình khi được tạo mới hoặc chỉnh sửa PHẢI tích hợp đồng thời cả hai chế độ Sáng và Tối (Light & Dark Theme)** một cách trực quan, đẹp mắt và có độ tương phản cao.

### 🎨 Bộ màu sắc tiêu chuẩn (Design Tokens)

> **Cập nhật 2026-09-16 — bộ màu cũ (coral #E0533C / tím #8B5CF6, font Outfit, bo góc 20) ĐÃ BỊ THAY THẾ.**
> Nguồn sự thật hiện tại: [`docs/design/REFACTOR_UI_SPEC.md`](file:///E:/TripMate/docs/design/REFACTOR_UI_SPEC.md).
> Token thực thi ở `lib/core/theme/gen_z_tokens.g.dart`. **Không đưa bộ màu cũ trở lại.**

| Thuộc tính | Sáng | Tối |
| :--- | :--- | :--- |
| **Nền (scaffold)** | `#F7F3EC` kem | `#141617` graphite |
| **Bề mặt (thẻ, sheet)** | `#FFFFFF` | `#1D2022` |
| **Chữ chính** | `#1C1A17` | `#ECE7DF` |
| **Chữ phụ** | `#6B655C` | `#9A948B` |
| **Đường kẻ / viền** | `#E3DDD2` | `#2E3235` |
| **Nền chìm (input, chip)** | `#F0EBE2` | `#25292B` |
| **Màu nhấn (duy nhất)** | `#B4543A` đất nung | `#5C9A90` xanh mòng két |
| **Chữ trên màu nhấn** | `#FFFFFF` | `#0F1211` |

Trạng thái: `success #2F6D4F / #6FAF8C` · `warning #9A6B12 / #D8A94A` · `danger #A33A2C / #E0705C` · `info #3A6073 / #84A9BC`.
Phân loại/biểu đồ: `chart1…chart6` (xem spec). **Không dùng màu ngoài các token này.**

### ✍️ Typography & Components (đã đổi)
*   **Font:** `GoogleFonts.instrumentSans` cho tiêu đề và nội dung; `GoogleFonts.spaceMono` cho số tiền/ngày. Không dùng Baloo 2, Nunito, Outfit, Plus Jakarta.
*   **Thang cỡ chữ:** display 28 · title 22 · section 17 · body 15 · label 13 · caption 12. **Không có chữ dưới 12.**
*   **Viền:** 1px thường, 1.5px khi nhấn/chọn, 2px khi focus.
*   **Bán kính:** thẻ 14 · nút và input 10 · pill 999.
*   **Bóng:** bỏ bóng đặc brutalist. Chế độ sáng dùng bóng rất nhẹ (alpha 0.06, blur 12); chế độ tối **không bóng**, phân tách bằng viền.
*   **Một điểm nhấn mỗi màn:** mỗi màn chỉ một vùng dùng màu nhấn cho hành động chính; các nút khác là nút viền hoặc nút chữ.
*   **Chuyển động:** `Curves.easeOutCubic`, 150ms đổi trạng thái / 250ms chuyển màn. **Không hiệu ứng nảy, không animation lặp vô hạn để trang trí.**
*   **Không có tính năng đổi màu accent** — chỉ một bộ màu duy nhất.
*   **Icon:** `phosphor_flutter`. Không dùng `Icons.*` của Material, không emoji làm icon.

---

## 🏗️ 3. Kiến Trúc Mã Nguồn Flutter (Directory Structure)

Thư mục chính tuân thủ mô hình **Feature-First (Theo tính năng)** giúp tách biệt rõ ràng các phân hệ của Super App:

```text
lib/
├── core/
│   ├── constants/             # Các hằng số màu sắc, văn bản toàn cục
│   └── theme/                 # Quản lý giao diện
│       ├── theme.dart         # Định nghĩa cấu hình ThemeData (Light/Dark)
│       └── theme_provider.dart# Quản lý trạng thái chuyển đổi chủ đề (ChangeNotifier)
└── features/
    ├── dashboard/             # Màn hình chính Explore và điều hướng BottomNavigationBar
    │   └── presentation/      # Giao diện Dashboard, Carousel điểm đến, active trips
    ├── trip_planner/          # Lập lịch trình chi tiết (Itinerary Builder)
    │   ├── domain/            # Models: Trip, Activity (chuẩn bị cho API)
    │   └── presentation/      # Giao diện dòng thời gian lịch trình (Timeline Node UI)
    └── expense_tracker/       # Thống kê chi tiêu & Chia tiền (Expense & Splitter)
        ├── domain/            # Models: Expense, Debt
        └── presentation/      # Giao diện ví chi tiêu, tiến độ vòng tròn ngân sách
```

---

## 🗄️ 4. Sơ Đồ Cơ Sở Dữ Liệu Supabase (Database Schema)

Dưới đây là thiết kế các bảng dữ liệu PostgreSQL trên Supabase để đồng bộ thời gian thực:

```mermaid
erDiagram
    trips ||--o{ trip_members : has
    trips ||--o{ itinerary_items : contains
    trips ||--o{ expenses : records
    trips ||--o{ moments : collects
    trips ||--o{ game_sessions : runs
    expenses ||--o{ expense_splits : details
    
    trips {
        uuid id PK
        varchar name
        date start_date
        date end_date
        varchar cover_image
        uuid created_by
        timestamp created_at
    }
    trip_members {
        uuid trip_id FK
        uuid user_id FK
        varchar role
        timestamp joined_at
    }
    itinerary_items {
        uuid id PK
        uuid trip_id FK
        int day
        time start_time
        varchar place_name
        varchar place_address
        int duration_minutes
        text notes
    }
    expenses {
        uuid id PK
        uuid trip_id FK
        uuid paid_by
        numeric amount
        varchar category
        text description
        varchar split_type
        timestamp created_at
    }
    expense_splits {
        uuid expense_id FK
        uuid user_id FK
        numeric share_amount
        boolean is_paid
        timestamp paid_at
    }
    moments {
        uuid id PK
        uuid trip_id FK
        uuid user_id FK
        varchar media_url
        text caption
        numeric latitude
        numeric longitude
        timestamp created_at
    }
    game_sessions {
        uuid id PK
        uuid trip_id FK
        varchar game_type
        jsonb state_json
        timestamp updated_at
    }
```

---

## 🛡️ 5. Nguyên Tắc Lập Trình Để Tránh Ảo Giác (Anti-Hallucination Rules)

Khi viết hoặc cập nhật mã nguồn cho dự án này, AI bắt buộc phải tuân theo các quy tắc nghiêm ngặt sau:

### 🚫 Quy tắc viết Code & Tránh Lỗi Phổ Biến:
1.  **Không sử dụng thuộc tính màu cũ bị cảnh báo deprecated:**
    *   ❌ Không dùng `withOpacity(val)` trên đối tượng `Color`.
    *   ✅ Bắt buộc dùng `.withValues(alpha: val)`.
    *   ❌ Không khai báo thuộc tính `background` hoặc `onBackground` trong cấu hình `ColorScheme`.
    *   ✅ Hãy dùng `surface` và `onSurface` để thay thế.
    *   ❌ Không dùng widget `CardTheme(...)` bên trong cấu hình `ThemeData`.
    *   ✅ Bắt buộc dùng `CardThemeData(...)` thay thế.
2.  **Ràng buộc kiểu dữ liệu rõ ràng:**
    *   Tránh các lỗi ép kiểu ngầm định khi xử lý Map/List động. Luôn thực hiện ép kiểu an toàn, ví dụ: `gradient: dest['gradient'] as List<Color>`.
3.  **Tương thích với Widget Tests:**
    *   Khi thay đổi cấu trúc màn hình hoặc widget trong `main.dart`, hãy kiểm tra và cập nhật file kiểm thử [widget_test.dart](file:///e:/TripMate/test/widget_test.dart) để tránh lỗi kiểm thử khói (smoke test).
4.  **Bảo toàn chú thích (Preserve Comments):**
    *   Không tự ý xóa bỏ các comment giải thích kiến trúc hoặc ghi chú thiết kế của nhà phát triển trước đó trừ khi được yêu cầu thay thế trực tiếp.

---

## 🔄 6. Quy Trình Phát Triển Từng Bước Của AI (AI Agent Workflow)

Mỗi khi nhận được yêu cầu viết mã nguồn hoặc nâng cấp tính năng mới, AI cần thực hiện tuần tự theo quy trình 5 bước sau:

```mermaid
graph TD
    A[Bước 1: Nghiên cứu & Đọc claude.md] --> B[Bước 2: Thiết kế giao diện Light/Dark]
    B --> C[Bước 3: Thực hiện viết Code an toàn]
    C --> D[Bước 4: Chạy flutter analyze để dọn sạch Lint]
    D --> E[Bước 5: Tạo báo cáo Walkthrough hoàn tất]
```

### 📋 Mô tả chi tiết từng bước:

*   **Bước 1: Nghiên cứu (Research Phase)**
    *   Đọc kỹ file `claude.md` này để hiểu phong cách thiết kế và sơ đồ cơ sở dữ liệu.
    *   Kiểm tra sự nhất quán của mã nguồn hiện tại trong thư mục `lib/`.
*   **Bước 2: Thiết kế (Design Phase)**
    *   Lập sơ đồ cấu trúc của Widget/Screen cần viết.
    *   Xác định rõ ràng mã màu Sáng và Tối sẽ sử dụng (không dùng mã màu ngẫu nhiên ad-hoc ngoài bộ màu tiêu chuẩn).
*   **Bước 3: Triển khai (Implementation Phase)**
    *   Sử dụng các công cụ chỉnh sửa mã nguồn có phạm vi khoanh vùng hẹp nhất như `multi_replace_file_content` thay vì ghi đè toàn bộ file lớn để tối ưu hóa tài nguyên.
    *   Đảm bảo không tạo ra các import dư thừa hoặc sai đường dẫn.
*   **Bước 4: Xác thực (Verification Phase)**
    *   Bắt buộc chạy lệnh terminal `flutter analyze` tại thư mục dự án `e:\TripMate`.
    *   **TIÊU CHUẨN HOÀN THÀNH:** Báo cáo phân tích phải hiển thị: **`No issues found!`**. Nếu xuất hiện bất kỳ cảnh báo Info/Warning/Error nào, AI phải tự động sửa chữa ngay lập tức cho đến khi sạch lỗi.
*   **Bước 5: Báo cáo (Reporting Phase)**
    *   Cập nhật tệp báo cáo [walkthrough.md](file:///C:/Users/ASUS/.gemini/antigravity/brain/520bb115-e6a4-4655-bf1b-33ba160f288e/walkthrough.md) để mô tả rõ ràng các thay đổi đã thực hiện và phương thức xác thực cho lập trình viên (User).
