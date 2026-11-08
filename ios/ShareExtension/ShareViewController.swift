import Intents
import UIKit
import UniformTypeIdentifiers

/// Copies what is shared into the App Group under names of our own, writes
/// `share.json` last, then opens Matterleast, which picks the share up.
class ShareViewController: UIViewController {
    private let status = UILabel()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let done = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        status.text = "Preparing…"
        status.numberOfLines = 0
        status.textAlignment = .center
        status.font = .preferredFont(forTextStyle: .body)
        status.adjustsFontForContentSizeCategory = true
        done.setTitle("Done", for: .normal)
        done.isHidden = true
        done.addTarget(self, action: #selector(finish), for: .touchUpInside)
        spinner.startAnimating()
        let stack = UIStackView(arrangedSubviews: [spinner, status, done])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        Task { await take() }
    }

    @objc private func finish() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func show(_ message: String) {
        spinner.stopAnimating()
        status.text = message
        done.isHidden = false
    }

    @MainActor
    private func take() async {
        guard let group = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as? String,
              let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
        else {
            show("Matterleast can't take shares in this build.")
            return
        }
        let folder = container
            .appendingPathComponent("shares", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let manifest = try await copy(into: folder)
            let data = try JSONEncoder().encode(manifest)
            try data.write(to: folder.appendingPathComponent("share.json"), options: .atomic)
        } catch {
            try? FileManager.default.removeItem(at: folder)
            show(error.localizedDescription)
            return
        }
        if await openApp() {
            finish()
        } else {
            show("Open Matterleast to finish sharing.")
        }
    }

    private func copy(into folder: URL) async throws -> Manifest {
        var texts: [String] = []
        var files: [Manifest.File] = []
        var refused: [String] = []
        var taken = Set<String>()
        let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? [])
            .flatMap { $0.attachments ?? [] }
        for provider in providers {
            if let type = Self.fileType(of: provider) {
                let suggested = provider.suggestedName
                do {
                    let (name, mime) = try await Self.copyFile(
                        provider, type: type, into: folder, suggested: suggested, taken: &taken)
                    files.append(Manifest.File(name: name, mime: mime))
                } catch let error as CocoaError where error.code == .fileWriteOutOfSpace {
                    throw error
                } catch {
                    refused.append(suggested ?? "file")
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
                      let url = try? await provider.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL {
                texts.append(url.absoluteString)
            } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
                      let text = try? await provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) as? String {
                texts.append(text)
            }
        }
        let target = (extensionContext?.intent as? INSendMessageIntent)?.conversationIdentifier
        return Manifest(text: texts.joined(separator: "\n\n"), files: files, refused: refused, target: target)
    }

    /// The type to copy as a file: the first that is data but not a web link
    /// or plain text, which are taken as text.
    private static func fileType(of provider: NSItemProvider) -> UTType? {
        provider.registeredTypeIdentifiers
            .compactMap { UTType($0) }
            .first { type in
                (type.conforms(to: .data) || type.conforms(to: .package))
                    && !type.conforms(to: .url) && !type.conforms(to: .plainText)
            }
    }

    private static func copyFile(
        _ provider: NSItemProvider, type: UTType, into folder: URL, suggested: String?, taken: inout Set<String>
    ) async throws -> (String, String?) {
        let source: URL = try await withCheckedThrowingContinuation { continuation in
            _ = provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { url, error in
                guard let url = url else {
                    continuation.resume(throwing: error ?? CocoaError(.fileReadUnknown))
                    return
                }
                // The file only lives until this returns: keep a copy next to it.
                let keep = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                do {
                    try FileManager.default.copyItem(at: url, to: keep)
                    continuation.resume(returning: keep)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        defer { try? FileManager.default.removeItem(at: source) }
        let fileType = UTType(filenameExtension: source.pathExtension) ?? type
        let name = unique(cleanName(suggested.map { withExtension($0, of: source) } ?? source.lastPathComponent,
                                    type: fileType), taken: &taken)
        try FileManager.default.moveItem(at: source, to: folder.appendingPathComponent(name))
        return (name, fileType.preferredMIMEType)
    }

    /// Photos suggests a name without an extension; the file has one.
    private static func withExtension(_ name: String, of file: URL) -> String {
        (name as NSString).pathExtension.isEmpty && !file.pathExtension.isEmpty
            ? "\(name).\(file.pathExtension)" : name
    }

    /// A file name of our own: the last path segment, without control
    /// characters or leading dots, at most 200 bytes.
    static func cleanName(_ display: String, type: UTType?) -> String {
        let last = display.split(whereSeparator: { $0 == "/" || $0 == "\\" }).last.map(String.init) ?? ""
        var name = String(String.UnicodeScalarView(last.unicodeScalars.filter {
            $0.value >= 0x20 && $0.value != 0x7f
        }))
        while name.hasPrefix(".") || name.hasPrefix(" ") { name.removeFirst() }
        while name.hasSuffix(".") || name.hasSuffix(" ") { name.removeLast() }
        if name.isEmpty {
            name = type?.preferredFilenameExtension.map { "file.\($0)" } ?? "file"
        }
        let ext = (name as NSString).pathExtension
        let suffix = ext.isEmpty || ext.count > 15 ? "" : ".\(ext)"
        var stem = String(name.dropLast(suffix.count))
        while (stem + suffix).utf8.count > 200 { stem.removeLast() }
        return stem + suffix
    }

    private static func unique(_ name: String, taken: inout Set<String>) -> String {
        let ext = (name as NSString).pathExtension
        let stem = (name as NSString).deletingPathExtension
        var candidate = name
        var n = 2
        while candidate == "share.json" || !taken.insert(candidate.lowercased()).inserted {
            candidate = ext.isEmpty ? "\(stem) (\(n))" : "\(stem) (\(n)).\(ext)"
            n += 1
        }
        return candidate
    }

    /// Share extensions have no API to open their app; the responder chain
    /// reaches the application object, as every share extension does.
    @MainActor
    private func openApp() async -> Bool {
        guard let url = URL(string: "matterleast-share://open") else { return false }
        var responder: UIResponder? = self
        while let current = responder {
            if let application = current as? UIApplication {
                return await application.open(url, options: [:])
            }
            responder = current.next
        }
        return false
    }
}

/// Read by the app's share_intake plugin.
struct Manifest: Encodable {
    struct File: Encodable {
        let name: String
        let mime: String?
    }

    let text: String
    let files: [File]
    let refused: [String]
    let target: String?
}
