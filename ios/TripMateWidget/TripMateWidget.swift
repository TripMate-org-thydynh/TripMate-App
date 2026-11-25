import ImageIO
import SwiftUI
import UIKit
import WidgetKit

// MARK: - App Group Resolution & Models

/// Resolves all candidate App Group identifiers so the widget works seamlessly
/// both on App Store builds (`group.com.tripmate.app`) and on sideloaded /
/// developer builds signed by `iloader-cli` (`ALTAppGroups` / `group.<appBundleId>`).
enum WidgetAppGroup {
    static let defaultGroupId = "group.com.tripmate.app"

    static var candidateGroupIds: [String] {
        var groups: [String] = []

        // 1. Check ALTAppGroups injected by iloader-cli / isideload in Info.plist
        if let altGroups = Bundle.main.object(forInfoDictionaryKey: "ALTAppGroups") as? [String] {
            for g in altGroups where !g.isEmpty && !groups.contains(g) {
                groups.append(g)
            }
        }

        // 2. Derive parent app bundle identifier by stripping ".TripMateWidget" suffix
        if let bundleId = Bundle.main.bundleIdentifier {
            let parts = bundleId.split(separator: ".")
            if parts.count > 1 {
                let parentBundleId = parts.dropLast().joined(separator: ".")
                let derivedGroup = "group.\(parentBundleId)"
                if !groups.contains(derivedGroup) {
                    groups.append(derivedGroup)
                }
            }
        }

        // 3. Standard App Store & fallback App Groups
        for fallback in [defaultGroupId, "group.com.tripmate.tripmate"] {
            if !groups.contains(fallback) {
                groups.append(fallback)
            }
        }

        return groups
    }

    /// Returns the first `UserDefaults` suite that contains synced TripMate widget data,
    /// or the primary candidate suite if none is populated yet.
    static func activeDefaults() -> (defaults: UserDefaults?, groupId: String) {
        let candidates = candidateGroupIds
        for groupId in candidates {
            if let defaults = UserDefaults(suiteName: groupId) {
                if let feed = defaults.string(forKey: "tm_feed"), !feed.isEmpty, feed != "[]" {
                    return (defaults, groupId)
                }
                if let latest = defaults.string(forKey: "tm_latest_moment"), !latest.isEmpty {
                    return (defaults, groupId)
                }
            }
        }
        let first = candidates.first ?? defaultGroupId
        return (UserDefaults(suiteName: first), first)
    }
}

struct SquadMomentItem: Identifiable {
    let id: String
    let tripId: String
    let authorName: String
    let tripName: String
    let caption: String?
    let imageUrl: String
    let createdAt: Date?

    var subtitle: String {
        if let c = caption?.trimmingCharacters(in: .whitespacesAndNewlines), !c.isEmpty {
            return c
        }
        return tripName.isEmpty ? "Chuyến đi cùng Squad" : tripName
    }

    var relativeTimeLabel: String {
        guard let createdAt = createdAt else { return "Mới đăng" }
        let diff = Date().timeIntervalSince(createdAt)
        if diff < 120 { return "vừa xong" }
        let minutes = Int(diff / 60)
        if minutes < 60 { return "\(minutes)p trước" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h trước" }
        let days = hours / 24
        if days < 7 { return "\(days) ngày trước" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: createdAt)
    }

    var isOlderThan24Hours: Bool {
        guard let createdAt = createdAt else { return false }
        return Date().timeIntervalSince(createdAt) > 24 * 3600
    }
}

struct MomentEntry: TimelineEntry {
    let date: Date
    let moments: [SquadMomentItem]
    let photos: [UIImage]
    let totalCount: Int

    var topMoment: SquadMomentItem? { moments.first }
    var extraCount: Int { max(0, totalCount - max(1, photos.count)) }
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    private let maxLayers = 3

    func placeholder(in context: Context) -> MomentEntry {
        MomentEntry(
            date: Date(),
            moments: [
                SquadMomentItem(
                    id: "sample-1",
                    tripId: "trip-1",
                    authorName: "Minh Nhật",
                    tripName: "Đà Lạt Săn Mây",
                    caption: "Bình minh trên đồi chè Cầu Đất 🌲☕",
                    imageUrl: "",
                    createdAt: Date().addingTimeInterval(-900)
                )
            ],
            photos: [],
            totalCount: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MomentEntry) -> Void) {
        let (items, cachedPhotos) = loadStoredFeed()
        if !cachedPhotos.isEmpty || items.isEmpty {
            completion(
                MomentEntry(
                    date: Date(),
                    moments: items,
                    photos: cachedPhotos,
                    totalCount: items.count
                )
            )
            return
        }
        // In widget gallery preview, fetch quickly with a 3-second timeout
        fetchPhotos(for: Array(items.prefix(maxLayers)), timeout: 3.0) { downloaded in
            completion(
                MomentEntry(
                    date: Date(),
                    moments: items,
                    photos: downloaded.isEmpty ? cachedPhotos : downloaded,
                    totalCount: items.count
                )
            )
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MomentEntry>) -> Void) {
        let (items, cachedPhotos) = loadStoredFeed()

        guard !items.isEmpty else {
            let emptyEntry = MomentEntry(date: Date(), moments: [], photos: [], totalCount: 0)
            completion(refreshTimeline(with: emptyEntry))
            return
        }

        let topItems = Array(items.prefix(maxLayers))
        if cachedPhotos.count >= topItems.count {
            let entry = MomentEntry(
                date: Date(),
                moments: items,
                photos: cachedPhotos,
                totalCount: items.count
            )
            completion(refreshTimeline(with: entry))
            return
        }

        fetchPhotos(for: topItems, timeout: 8.0) { downloaded in
            let finalPhotos = downloaded.isEmpty ? cachedPhotos : downloaded
            let entry = MomentEntry(
                date: Date(),
                moments: items,
                photos: finalPhotos,
                totalCount: items.count
            )
            completion(refreshTimeline(with: entry))
        }
    }

    private func refreshTimeline(with entry: MomentEntry) -> Timeline<MomentEntry> {
        let next = Calendar.current.date(byAdding: .minute, value: 20, to: Date()) ?? Date().addingTimeInterval(1200)
        return Timeline(entries: [entry], policy: .after(next))
    }

    private func loadStoredFeed() -> (items: [SquadMomentItem], cachedPhotos: [UIImage]) {
        let (defaultsOpt, groupId) = WidgetAppGroup.activeDefaults()
        guard let defaults = defaultsOpt else { return ([], []) }

        var items: [SquadMomentItem] = []

        if let rawFeed = defaults.string(forKey: "tm_feed"),
           let feedData = rawFeed.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: feedData) as? [[String: Any]] {
            items = jsonArray.compactMap { Self.parseMomentDict($0) }
        }

        if items.isEmpty,
           let rawLatest = defaults.string(forKey: "tm_latest_moment"),
           let latestData = rawLatest.data(using: .utf8),
           let jsonDict = try? JSONSerialization.jsonObject(with: latestData) as? [String: Any],
           let single = Self.parseMomentDict(jsonDict) {
            items = [single]
        }

        // Load pre-cached thumbnails saved by the main app into the App Group container or UserDefaults
        var cachedPhotos: [UIImage] = []
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)

        for idx in 0..<min(maxLayers, max(1, items.count)) {
            if let dir = containerURL?.appendingPathComponent("widget_cache", isDirectory: true) {
                let fileURL = dir.appendingPathComponent("photo_\(idx).jpg")
                if let data = try? Data(contentsOf: fileURL),
                   let img = Self.downsampleImage(data: data, maxPixelSize: 600) {
                    cachedPhotos.append(img)
                    continue
                }
            }
            if let b64 = defaults.string(forKey: "tm_cached_thumb_\(idx)"),
               let data = Data(base64Encoded: b64),
               let img = Self.downsampleImage(data: data, maxPixelSize: 600) {
                cachedPhotos.append(img)
            }
        }

        return (items, cachedPhotos)
    }

    private static func parseMomentDict(_ dict: [String: Any]) -> SquadMomentItem? {
        let author = (dict["authorName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trip = (dict["tripName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let imageUrl = (dict["imageUrl"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if author.isEmpty && trip.isEmpty && imageUrl.isEmpty { return nil }

        let id = (dict["id"] as? String) ?? UUID().uuidString
        let tripId = (dict["tripId"] as? String) ?? ""
        let rawCaption = dict["caption"] as? String
        let caption = (rawCaption == nil || rawCaption == "null" || rawCaption!.isEmpty) ? nil : rawCaption
        let createdAt = parseIsoDate(dict["createdAt"] as? String)

        return SquadMomentItem(
            id: id,
            tripId: tripId,
            authorName: author.isEmpty ? "Bạn đồng hành" : author,
            tripName: trip,
            caption: caption,
            imageUrl: imageUrl,
            createdAt: createdAt
        )
    }

    private static func parseIsoDate(_ raw: String?) -> Date? {
        guard let raw = raw, !raw.isEmpty else { return nil }
        let isoFractional = ISO8601DateFormatter()
        isoFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFractional.date(from: raw) { return d }

        let isoStandard = ISO8601DateFormatter()
        isoStandard.formatOptions = [.withInternetDateTime]
        return isoStandard.date(from: raw)
    }

    private func fetchPhotos(
        for items: [SquadMomentItem],
        timeout: TimeInterval,
        completion: @escaping ([UIImage]) -> Void
    ) {
        let urls: [URL] = items.compactMap { item in
            guard let u = URL(string: item.imageUrl),
                  let scheme = u.scheme?.lowercased(),
                  scheme == "http" || scheme == "https" else {
                return nil
            }
            return u
        }
        guard !urls.isEmpty else {
            completion([])
            return
        }

        let group = DispatchGroup()
        let lock = NSLock()
        var results = Array<UIImage?>(repeating: nil, count: urls.count)

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: config)

        for (index, url) in urls.enumerated() {
            group.enter()
            session.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                guard let data = data,
                      let img = Self.downsampleImage(data: data, maxPixelSize: 600) else {
                    return
                }
                lock.lock()
                results[index] = img
                lock.unlock()
            }.resume()
        }

        group.notify(queue: .global(qos: .userInitiated)) {
            completion(results.compactMap { $0 })
        }
    }

    /// Downsamples image data via ImageIO so WidgetKit never exceeds its 30MB memory limit.
    static func downsampleImage(data: Data, maxPixelSize: Int) -> UIImage? {
        let options: [CFString: Any] = [kCGImageSourceShouldCache: false]
        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return UIImage(data: data)
        }
        let thumbOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbOptions as CFDictionary) else {
            return UIImage(data: data)
        }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Theme Palette (Dark & Light Mode Support)

struct WidgetThemePalette {
    let isDark: Bool

    var boardBackground: Color {
        isDark
            ? Color(red: 0.11, green: 0.085, blue: 0.075) // Warm Espresso #1C1613
            : Color(red: 0.992, green: 0.965, blue: 0.827) // Warm Cream #FDF6D3
    }

    var polaroidPaper: Color {
        isDark
            ? Color(red: 0.175, green: 0.14, blue: 0.125) // Dark Warm Paper #2C2420
            : Color(red: 1.0, green: 0.992, blue: 0.961) // Ivory Frame #FFFDF5
    }

    var primaryInk: Color {
        isDark
            ? Color(red: 0.98, green: 0.96, blue: 0.92)
            : Color(red: 0.078, green: 0.071, blue: 0.063) // #141210
    }

    var secondaryInk: Color {
        isDark
            ? Color(red: 0.78, green: 0.73, blue: 0.67)
            : Color(red: 0.38, green: 0.33, blue: 0.28)
    }

    var accentYellow: Color {
        Color(red: 1.0, green: 0.847, blue: 0.302) // #FFD84D
    }

    var ropeColor: Color {
        isDark
            ? Color(red: 0.65, green: 0.49, blue: 0.32)
            : Color(red: 0.55, green: 0.39, blue: 0.23)
    }
}

// MARK: - Widget Views

struct TripMateWidgetEntryView: View {
    var entry: MomentEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    private var palette: WidgetThemePalette {
        WidgetThemePalette(isDark: colorScheme == .dark)
    }

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                MediumSquadWidgetView(entry: entry, palette: palette)
            case .systemLarge:
                LargeRopeBoardWidgetView(entry: entry, palette: palette)
            default:
                SmallStackedPolaroidWidgetView(entry: entry, palette: palette)
            }
        }
        .widgetURL(URL(string: "tripmate://moments/viewer"))
    }
}

/// 2x2 Small Widget — Exact iOS counterpart to Android's `WidgetCanvas.kt`
/// featuring up to 3 tilted Polaroid layers (`-6°`, `+4°`, `0°`), live relative
/// time chip, `+N` extra badge, bottom dark scrim, and 24-hour yellow nudge pill.
struct SmallStackedPolaroidWidgetView: View {
    let entry: MomentEntry
    let palette: WidgetThemePalette

    private let tilts: [Double] = [-6.0, 4.0, 0.0]

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let cardSize = side * 0.86

            ZStack {
                palette.boardBackground

                if let top = entry.topMoment {
                    let layerCount = max(1, min(3, entry.photos.isEmpty ? 1 : entry.photos.count))
                    let activeTilts = Array(tilts.suffix(layerCount))

                    // Back-to-front Polaroid stack
                    ForEach((0..<layerCount).reversed(), id: \.self) { depth in
                        let isTop = (depth == 0)
                        let scale = 1.0 - CGFloat(depth) * 0.045
                        let tilt = activeTilts[layerCount - 1 - depth]
                        let yOffset = -CGFloat(depth) * side * 0.018

                        PolaroidFrameCard(
                            image: depth < entry.photos.count ? entry.photos[depth] : nil,
                            palette: palette,
                            showScrim: isTop,
                            tripName: top.tripName
                        )
                        .frame(width: cardSize * scale, height: cardSize * scale)
                        .rotationEffect(.degrees(tilt))
                        .offset(y: yOffset)
                    }

                    // Top-left live time chip
                    VStack {
                        HStack {
                            Text(top.relativeTimeLabel)
                                .font(.system(size: max(9, side * 0.068), weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3.5)
                                .background(Color.black.opacity(0.62))
                                .clipShape(Capsule())

                            Spacer()

                            // Top-right "+N" extra moments badge
                            if entry.extraCount > 0 {
                                Text("+\(entry.extraCount)")
                                    .font(.system(size: max(10, side * 0.072), weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(red: 0.08, green: 0.07, blue: 0.06))
                                    .padding(.horizontal, 6.5)
                                    .padding(.vertical, 3.5)
                                    .background(palette.accentYellow)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(red: 0.08, green: 0.07, blue: 0.06), lineWidth: 1.5)
                                    )
                            }
                        }
                        .padding(.horizontal, side * 0.09)
                        .padding(.top, side * 0.09)

                        Spacer()

                        // Author & Caption overlay at bottom of top Polaroid
                        VStack(spacing: 1.5) {
                            Text(top.authorName)
                                .font(.system(size: max(12, side * 0.085), weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .shadow(color: .black.opacity(0.55), radius: 2, x: 0, y: 1)

                            Text(top.subtitle)
                                .font(.system(size: max(10, side * 0.068), weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.92))
                                .lineLimit(1)
                                .shadow(color: .black.opacity(0.55), radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal, side * 0.11)
                        .padding(.bottom, top.isOlderThan24Hours ? side * 0.02 : side * 0.10)

                        if top.isOlderThan24Hours {
                            Text("Hôm nay cả nhóm đi đâu? 📸")
                                .font(.system(size: max(8.5, side * 0.058), weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.08, green: 0.07, blue: 0.06))
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(palette.accentYellow)
                                .clipShape(Capsule())
                                .padding(.bottom, side * 0.06)
                        }
                    }
                } else {
                    EmptySquadWidgetPlaceholder(palette: palette, isCompact: true)
                }
            }
        }
    }
}

/// 4x2 Medium Widget — Stacked Polaroid on the left + Trip details, caption,
/// timestamp, and quick reaction CTA on the right.
struct MediumSquadWidgetView: View {
    let entry: MomentEntry
    let palette: WidgetThemePalette

    var body: some View {
        GeometryReader { geo in
            ZStack {
                palette.boardBackground

                if let top = entry.topMoment {
                    HStack(spacing: 12) {
                        // Left: Stacked Polaroid thumbnail
                        let photoSide = min(geo.size.height * 0.84, geo.size.width * 0.42)
                        ZStack(alignment: .topTrailing) {
                            PolaroidFrameCard(
                                image: entry.photos.count > 1 ? entry.photos[1] : nil,
                                palette: palette,
                                showScrim: false,
                                tripName: top.tripName
                            )
                            .frame(width: photoSide * 0.94, height: photoSide * 0.94)
                            .rotationEffect(.degrees(-5))

                            PolaroidFrameCard(
                                image: entry.photos.first,
                                palette: palette,
                                showScrim: false,
                                tripName: top.tripName
                            )
                            .frame(width: photoSide, height: photoSide)
                            .rotationEffect(.degrees(2))

                            if entry.extraCount > 0 {
                                Text("+\(entry.extraCount)")
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(red: 0.08, green: 0.07, blue: 0.06))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(palette.accentYellow)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(Color.black.opacity(0.8), lineWidth: 1.4)
                                    )
                                    .offset(x: 4, y: -4)
                            }
                        }
                        .padding(.leading, 12)

                        // Right: Story metadata + CTA
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 5) {
                                Text(top.tripName.isEmpty ? "TripMate Squad" : top.tripName)
                                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.08, green: 0.07, blue: 0.06))
                                    .lineLimit(1)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2.5)
                                    .background(palette.accentYellow)
                                    .clipShape(Capsule())

                                Spacer(minLength: 2)

                                Text(top.relativeTimeLabel)
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundColor(palette.secondaryInk)
                                    .lineLimit(1)
                            }

                            Text(top.authorName)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundColor(palette.primaryInk)
                                .lineLimit(1)

                            Text(top.subtitle)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(palette.secondaryInk)
                                .lineLimit(2)

                            Spacer(minLength: 2)

                            HStack(spacing: 6) {
                                Text("❤️ 😂 🔥 😮")
                                    .font(.system(size: 11))
                                Spacer()
                                Text("Chạm để thả cảm xúc →")
                                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                                    .foregroundColor(palette.primaryInk.opacity(0.85))
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.trailing, 14)
                    }
                } else {
                    EmptySquadWidgetPlaceholder(palette: palette, isCompact: false)
                }
            }
        }
    }
}

/// 4x4 Large Widget — Mini Rope & Clothespin Photo Board on the iOS Home Screen!
struct LargeRopeBoardWidgetView: View {
    let entry: MomentEntry
    let palette: WidgetThemePalette

    var body: some View {
        GeometryReader { geo in
            ZStack {
                palette.boardBackground

                if let top = entry.topMoment {
                    VStack(spacing: 8) {
                        // Top header bar with trip badge & time
                        HStack {
                            HStack(spacing: 5) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 12, weight: .bold))
                                Text(top.tripName.isEmpty ? "Bảng Kỷ Niệm Squad" : top.tripName)
                                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                                    .lineLimit(1)
                            }
                            .foregroundColor(Color(red: 0.08, green: 0.07, blue: 0.06))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(palette.accentYellow)
                            .clipShape(Capsule())

                            Spacer()

                            Text(top.relativeTimeLabel)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(palette.secondaryInk)
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 12)

                        // Featured Polaroid hanging from a rope
                        ZStack(alignment: .top) {
                            // Horizontal hemp rope line
                            Rectangle()
                                .fill(palette.ropeColor.opacity(0.75))
                                .frame(height: 2.5)
                                .padding(.top, 6)

                            VStack(spacing: 6) {
                                PolaroidFrameCard(
                                    image: entry.photos.first,
                                    palette: palette,
                                    showScrim: true,
                                    tripName: top.tripName,
                                    overlayAuthor: top.authorName,
                                    overlaySubtitle: top.subtitle
                                )
                                .frame(
                                    width: min(geo.size.width * 0.76, geo.size.height * 0.56),
                                    height: min(geo.size.width * 0.76, geo.size.height * 0.56)
                                )
                                .rotationEffect(.degrees(-1.8))
                            }
                            .padding(.top, 4)

                            // Wooden clothespin
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(Color(red: 0.82, green: 0.60, blue: 0.38))
                                .frame(width: 10, height: 18)
                        }

                        // Secondary mini Polaroid strip if multiple moments exist
                        if entry.moments.count > 1 {
                            HStack(spacing: 10) {
                                ForEach(Array(entry.moments.prefix(3).enumerated()), id: \.offset) { idx, item in
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(palette.accentYellow)
                                            .frame(width: 18, height: 18)
                                            .overlay(
                                                Text("#\(idx + 1)")
                                                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                                                    .foregroundColor(.black)
                                            )
                                        Text(item.authorName)
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(palette.primaryInk)
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(palette.polaroidPaper)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(.bottom, 10)
                        } else {
                            Text("Chạm để mở Bức tường Kỷ niệm & thả cảm xúc ❤️")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(palette.secondaryInk)
                                .padding(.bottom, 10)
                        }
                    }
                } else {
                    EmptySquadWidgetPlaceholder(palette: palette, isCompact: false)
                }
            }
        }
    }
}

struct PolaroidFrameCard: View {
    let image: UIImage?
    let palette: WidgetThemePalette
    let showScrim: Bool
    let tripName: String
    var overlayAuthor: String? = nil
    var overlaySubtitle: String? = nil

    var body: some View {
        GeometryReader { geo in
            let border = max(5.0, geo.size.width * 0.042)
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(palette.polaroidPaper)
                    .shadow(color: .black.opacity(0.24), radius: 6, x: 0, y: 3)

                ZStack(alignment: .bottom) {
                    if let uiImage = image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geo.size.width - border * 2,
                                height: geo.size.height - border * 2
                            )
                            .clipped()
                    } else {
                        // Aesthetic gradient fallback when photo is offline/not cached yet
                        LinearGradient(
                            colors: [
                                Color(red: 0.96, green: 0.62, blue: 0.25),
                                Color(red: 0.84, green: 0.36, blue: 0.31),
                                Color(red: 0.28, green: 0.22, blue: 0.42)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "camera.aperture")
                                    .font(.system(size: geo.size.width * 0.18, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.85))
                                if !tripName.isEmpty {
                                    Text(tripName)
                                        .font(.system(size: max(9, geo.size.width * 0.065), weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                        .lineLimit(1)
                                        .padding(.horizontal, 8)
                                }
                            }
                        )
                    }

                    if showScrim {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.82)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }

                    if let author = overlayAuthor {
                        VStack(spacing: 2) {
                            Text(author)
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            if let sub = overlaySubtitle {
                                Text(sub)
                                    .font(.system(size: 11.5, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                    }
                }
                .frame(
                    width: geo.size.width - border * 2,
                    height: geo.size.height - border * 2
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }
}

struct EmptySquadWidgetPlaceholder: View {
    let palette: WidgetThemePalette
    let isCompact: Bool

    var body: some View {
        VStack(spacing: isCompact ? 6 : 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.polaroidPaper)
                    .frame(width: isCompact ? 54 : 64, height: isCompact ? 54 : 64)
                    .rotationEffect(.degrees(-6))
                    .shadow(color: .black.opacity(0.16), radius: 4, x: 0, y: 2)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.accentYellow)
                    .frame(width: isCompact ? 54 : 64, height: isCompact ? 54 : 64)
                    .rotationEffect(.degrees(4))
                    .overlay(
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                            .foregroundColor(Color(red: 0.08, green: 0.07, blue: 0.06))
                    )
            }

            Text("Khoảnh khắc Squad")
                .font(.system(size: isCompact ? 13 : 15, weight: .heavy, design: .rounded))
                .foregroundColor(palette.primaryInk)
                .lineLimit(1)

            Text("Chạm để chụp & ghim ảnh chuyến đi 📸")
                .font(.system(size: isCompact ? 10.5 : 12, weight: .medium, design: .rounded))
                .foregroundColor(palette.secondaryInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 12)
        }
    }
}

// MARK: - Widget Declaration

@main
struct TripMateWidget: Widget {
    /// Must match `WidgetSync.iOSWidgetName` in Flutter.
    let kind: String = "TripMateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TripMateWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color.clear
                    }
            } else {
                TripMateWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("TripMate — Khoảnh khắc Squad")
        .description("Xem chồng ảnh Polaroid mới nhất của nhóm ngay trên Màn hình chính.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabledIfAvailable()
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
