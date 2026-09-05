import SwiftUI
import WidgetKit

/// Widget khoảnh khắc squad — bản iOS.
///
/// Ý tưởng mượn từ Locket: ảnh bạn bè gửi hiện ngay trên màn hình chính, không
/// cần mở app. Khác Locket ở chỗ widget nói rõ ảnh thuộc **chuyến nào**, vì
/// vòng bạn của TripMate là squad theo chuyến chứ không phải danh sách bạn bè
/// vĩnh viễn.
///
/// Dữ liệu do Flutter ghi vào UserDefaults của App Group qua package
/// `home_widget` (xem `lib/core/services/widget_sync.dart`).

// MARK: - Dữ liệu

/// Phải khớp với `WidgetSync.appGroupId` bên Flutter.
let appGroupId = "group.com.tripmate.app"

struct SquadMoment {
    let authorName: String
    let tripName: String
    let caption: String?
    let imageUrl: String

    /// Dòng phụ: ưu tiên caption, không có thì hiện tên chuyến để biết ảnh từ đâu.
    var subtitle: String {
        if let c = caption, !c.isEmpty { return c }
        return tripName
    }
}

struct MomentEntry: TimelineEntry {
    let date: Date
    let moment: SquadMoment?
    let image: UIImage?
}

// MARK: - Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MomentEntry {
        MomentEntry(date: Date(), moment: nil, image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (MomentEntry) -> Void) {
        completion(loadEntry(image: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MomentEntry>) -> Void) {
        let entry = loadEntry(image: nil)

        guard let moment = entry.moment, let url = URL(string: moment.imageUrl) else {
            completion(refreshTimeline(with: entry))
            return
        }

        // Tải ảnh rồi mới dựng timeline — widget không vẽ lại được sau khi
        // timeline đã trả về, nên ảnh phải có sẵn ở thời điểm này.
        URLSession.shared.dataTask(with: url) { data, _, _ in
            let image = data.flatMap { UIImage(data: $0) }
            let filled = MomentEntry(date: Date(), moment: moment, image: image)
            completion(refreshTimeline(with: filled))
        }.resume()
    }

    /// Làm mới sau 30 phút. Hệ điều hành có thể giãn ra nếu máy tiết kiệm pin.
    ///
    /// Chưa dùng push để đánh thức widget: cần APNs, mà dự án chưa cấu hình
    /// (xem EXTERNAL_SETUP.md). App cũng đẩy dữ liệu ngay sau khi người dùng
    /// gửi ảnh, nên trường hợp thường gặp nhất vẫn cập nhật tức thì.
    private func refreshTimeline(with entry: MomentEntry) -> Timeline<MomentEntry> {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        return Timeline(entries: [entry], policy: .after(next))
    }

    private func loadEntry(image: UIImage?) -> MomentEntry {
        guard
            let defaults = UserDefaults(suiteName: appGroupId),
            let raw = defaults.string(forKey: "tm_latest_moment"),
            !raw.isEmpty,
            let data = raw.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return MomentEntry(date: Date(), moment: nil, image: image)
        }

        let moment = SquadMoment(
            authorName: json["authorName"] as? String ?? "",
            tripName: json["tripName"] as? String ?? "",
            caption: json["caption"] as? String,
            imageUrl: json["imageUrl"] as? String ?? ""
        )
        return MomentEntry(date: Date(), moment: moment, image: image)
    }
}

// MARK: - Giao diện

struct TripMateWidgetEntryView: View {
    var entry: MomentEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = entry.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                // Chưa có ảnh: nền vàng thương hiệu + lời mời, thay vì ô trống.
                Color(red: 1.0, green: 0.847, blue: 0.302)
            }

            // Dải tối để chữ đọc được trên mọi ảnh.
            LinearGradient(
                colors: [.black.opacity(0.75), .clear],
                startPoint: .bottom,
                endPoint: .center
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.moment?.authorName ?? "Chưa có khoảnh khắc")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(entry.moment?.subtitle ?? "Chạm để chụp gửi cả nhóm")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
            .padding(12)
        }
        .widgetURL(URL(string: "tripmate://moments"))
    }
}

// MARK: - Khai báo widget

@main
struct TripMateWidget: Widget {
    /// Phải khớp với `WidgetSync.iOSWidgetName` bên Flutter.
    let kind: String = "TripMateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TripMateWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                TripMateWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("TripMate")
        .description("Khoảnh khắc mới nhất của squad")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
