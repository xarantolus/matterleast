import Flutter
import UIKit

/// Takes the shares the Share Extension left in the App Group: each
/// `shares/<uuid>/` with a finished `share.json` moves into
/// `<cacheDir>/share/<uuid>/` and goes to Dart.
public class ShareIntakePlugin: NSObject, FlutterPlugin {
    private let channel: FlutterMethodChannel
    private var cacheDir: URL?

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "matterleast/share_intake", binaryMessenger: registrar.messenger())
        let instance = ShareIntakePlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        NotificationCenter.default.addObserver(
            instance,
            selector: #selector(becameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            guard let args = call.arguments as? [String: Any], let dir = args["cacheDir"] as? String else {
                result(FlutterError(code: "args", message: "cacheDir missing", details: nil))
                return
            }
            cacheDir = URL(fileURLWithPath: dir, isDirectory: true)
            result(!finishedShares().isEmpty)
            deliver()
        case "cancel":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @objc private func becameActive() {
        deliver()
    }

    private var inbox: URL? {
        guard let group = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as? String, !group.isEmpty else { return nil }
        return FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: group)?
            .appendingPathComponent("shares", isDirectory: true)
    }

    private func finishedShares() -> [URL] {
        guard let inbox = inbox,
              let folders = try? FileManager.default.contentsOfDirectory(at: inbox, includingPropertiesForKeys: nil)
        else { return [] }
        return folders
            .filter { UUID(uuidString: $0.lastPathComponent) != nil }
            .filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("share.json").path) }
    }

    private func deliver() {
        guard let cacheDir = cacheDir else { return }
        let fm = FileManager.default
        for folder in finishedShares() {
            let target = cacheDir.appendingPathComponent("share", isDirectory: true)
                .appendingPathComponent(folder.lastPathComponent, isDirectory: true)
            do {
                let data = try Data(contentsOf: folder.appendingPathComponent("share.json"))
                let manifest = try JSONDecoder().decode(Manifest.self, from: data)
                try fm.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
                try fm.moveItem(at: folder, to: target)
                try? fm.removeItem(at: target.appendingPathComponent("share.json"))
                let files: [[String: String]] = manifest.files.compactMap { file in
                    // A name is a basename the extension made; anything else is not ours.
                    let url = target.appendingPathComponent(file.name)
                    guard url.lastPathComponent == file.name, file.name != "share.json",
                          fm.fileExists(atPath: url.path) else { return nil }
                    return ["path": url.path, "name": file.name, "mime": file.mime ?? ""]
                }
                channel.invokeMethod("shared", arguments: [
                    "text": manifest.text ?? "",
                    "files": files,
                    "refused": manifest.refused,
                    "target": manifest.target as Any,
                ])
            } catch {
                try? fm.removeItem(at: folder)
                channel.invokeMethod("failed", arguments: ["message": error.localizedDescription])
            }
        }
    }
}

/// `share.json`, written last by the Share Extension.
struct Manifest: Decodable {
    struct File: Decodable {
        let name: String
        let mime: String?
    }

    let text: String?
    let files: [File]
    let refused: [String]
    let target: String?
}
