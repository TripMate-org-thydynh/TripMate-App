import Flutter
import ImageIO
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "tripmate/widget_pin",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handleWidgetChannel(call: call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Resolves all candidate App Group identifiers for both App Store builds
  /// (`group.com.tripmate.app`) and sideloaded builds (`ALTAppGroups` / `group.<bundleId>`).
  private func candidateAppGroupIds() -> [String] {
    var groups: [String] = []

    if let altGroups = Bundle.main.object(forInfoDictionaryKey: "ALTAppGroups") as? [String] {
      for g in altGroups where !g.isEmpty && !groups.contains(g) {
        groups.append(g)
      }
    }

    if let bundleId = Bundle.main.bundleIdentifier, !bundleId.isEmpty {
      let derived = "group.\(bundleId)"
      if !groups.contains(derived) {
        groups.append(derived)
      }
    }

    for fallback in ["group.com.tripmate.app", "group.com.tripmate.tripmate"] {
      if !groups.contains(fallback) {
        groups.append(fallback)
      }
    }

    return groups
  }

  private func handleWidgetChannel(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      // iOS does not allow programmatic widget pinning without user action
      result(false)

    case "requestPin":
      result(false)

    case "getAppGroups":
      result(candidateAppGroupIds())

    case "getInstalledWidgetsCount":
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.getCurrentConfigurations { configResult in
          switch configResult {
          case .success(let infos):
            result(infos.count)
          case .failure:
            result(0)
          }
        }
      } else {
        result(0)
      }

    case "syncWidgetData":
      guard let args = call.arguments as? [String: Any] else {
        result(false)
        return
      }
      let latestJson = (args["latestJson"] as? String) ?? ""
      let feedJson = (args["feedJson"] as? String) ?? "[]"
      let updatedAt = (args["updatedAt"] as? String) ?? ""
      let imageUrls = (args["imageUrls"] as? [String]) ?? []

      let groups = candidateAppGroupIds()
      for groupId in groups {
        if let defaults = UserDefaults(suiteName: groupId) {
          defaults.set(latestJson, forKey: "tm_latest_moment")
          defaults.set(feedJson, forKey: "tm_feed")
          defaults.set(updatedAt, forKey: "tm_updated_at")
          defaults.synchronize()
        }
      }

      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }

      // Pre-cache up to 3 downsampled thumbnails into the App Group container
      // so the WidgetKit extension renders instantaneously even in getSnapshot / offline!
      if !imageUrls.isEmpty {
        precacheWidgetThumbnails(urls: Array(imageUrls.prefix(3)), groups: groups)
      }

      result(true)

    case "clearWidgetData":
      let groups = candidateAppGroupIds()
      for groupId in groups {
        if let defaults = UserDefaults(suiteName: groupId) {
          defaults.set("", forKey: "tm_latest_moment")
          defaults.set("[]", forKey: "tm_feed")
          for idx in 0..<3 {
            defaults.removeObject(forKey: "tm_cached_thumb_\(idx)")
          }
          defaults.synchronize()
        }
        if let containerURL = FileManager.default.containerURL(
          forSecurityApplicationGroupIdentifier: groupId
        ) {
          let cacheDir = containerURL.appendingPathComponent("widget_cache", isDirectory: true)
          try? FileManager.default.removeItem(at: cacheDir)
        }
      }
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func precacheWidgetThumbnails(urls: [String], groups: [String]) {
    let trimmed = urls.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    guard !trimmed.isEmpty else { return }

    let dispatchGroup = DispatchGroup()
    let lock = NSLock()
    var jpegSlots = Array<Data?>(repeating: nil, count: trimmed.count)

    for (idx, rawUrl) in trimmed.enumerated() {
      if rawUrl.hasPrefix("http://") || rawUrl.hasPrefix("https://"),
         let url = URL(string: rawUrl) {
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: url) { data, _, _ in
          defer { dispatchGroup.leave() }
          guard let raw = data,
                let thumb = Self.downsampleToJpeg(data: raw, maxPixelSize: 600) else {
            return
          }
          lock.lock()
          jpegSlots[idx] = thumb
          lock.unlock()
        }.resume()
      } else if rawUrl.hasPrefix("assets/") {
        let key = FlutterDartProject.lookupKey(forAsset: rawUrl)
        if let path = Bundle.main.path(forResource: key, ofType: nil),
           let raw = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let thumb = Self.downsampleToJpeg(data: raw, maxPixelSize: 600) {
          lock.lock()
          jpegSlots[idx] = thumb
          lock.unlock()
        }
      } else if FileManager.default.fileExists(atPath: rawUrl),
                let raw = try? Data(contentsOf: URL(fileURLWithPath: rawUrl)),
                let thumb = Self.downsampleToJpeg(data: raw, maxPixelSize: 600) {
        lock.lock()
        jpegSlots[idx] = thumb
        lock.unlock()
      }
    }

    dispatchGroup.notify(queue: .global(qos: .utility)) {
      let compact = jpegSlots.compactMap { $0 }
      guard !compact.isEmpty else { return }

      for groupId in groups {
        if let defaults = UserDefaults(suiteName: groupId) {
          for idx in 0..<3 {
            if idx < compact.count {
              defaults.set(compact[idx].base64EncodedString(), forKey: "tm_cached_thumb_\(idx)")
            } else {
              defaults.removeObject(forKey: "tm_cached_thumb_\(idx)")
            }
          }
          defaults.synchronize()
        }

        if let containerURL = FileManager.default.containerURL(
          forSecurityApplicationGroupIdentifier: groupId
        ) {
          let cacheDir = containerURL.appendingPathComponent("widget_cache", isDirectory: true)
          try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
          for (idx, jpegData) in compact.enumerated() {
            let fileURL = cacheDir.appendingPathComponent("photo_\(idx).jpg")
            try? jpegData.write(to: fileURL, options: .atomic)
          }
        }
      }

      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }
    }
  }

  private static func downsampleToJpeg(data: Data, maxPixelSize: Int) -> Data? {
    let options: [CFString: Any] = [kCGImageSourceShouldCache: false]
    guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
      return UIImage(data: data)?.jpegData(compressionQuality: 0.78)
    }
    let thumbOptions: [CFString: Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
    ]
    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbOptions as CFDictionary) else {
      return UIImage(data: data)?.jpegData(compressionQuality: 0.78)
    }
    return UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.78)
  }
}
