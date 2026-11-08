import Flutter
import Intents
import UIKit

/// Donates each conversation a message arrives in, so the share sheet can
/// suggest it; the Share Extension gets its id back as the share's target.
public class ConversationShortcutsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "matterleast/conversation_shortcuts", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(ConversationShortcutsPlugin(), channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "push":
            guard let id = args["id"] as? String, let label = args["label"] as? String else {
                result(FlutterError(code: "args", message: "id and label needed", details: nil))
                return
            }
            let icon = (args["icon"] as? FlutterStandardTypedData).map { INImage(imageData: $0.data) }
            donate(id: id, label: label, icon: icon, group: args["group"] as? Bool ?? false, result: result)
        case "forgetServer":
            guard let url = args["serverUrl"] as? String else {
                result(FlutterError(code: "args", message: "serverUrl needed", details: nil))
                return
            }
            INInteraction.delete(with: url) { _ in result(nil) }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func donate(id: String, label: String, icon: INImage?, group: Bool, result: @escaping FlutterResult) {
        let sender = INPerson(
            personHandle: INPersonHandle(value: id, type: .unknown),
            nameComponents: nil,
            displayName: label,
            image: icon,
            contactIdentifier: nil,
            customIdentifier: id
        )
        let intent = INSendMessageIntent(
            recipients: nil,
            outgoingMessageType: .outgoingMessageText,
            content: nil,
            speakableGroupName: group ? INSpeakableString(spokenPhrase: label) : nil,
            conversationIdentifier: id,
            serviceName: nil,
            sender: sender,
            attachments: nil
        )
        if group, let icon = icon {
            intent.setImage(icon, forParameterNamed: \.speakableGroupName)
        }
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        // The server part of the id, so signing out withdraws them all.
        interaction.groupIdentifier = id.components(separatedBy: "\n").first
        interaction.donate { error in
            if let error = error {
                result(FlutterError(code: "donate", message: error.localizedDescription, details: nil))
            } else {
                result(nil)
            }
        }
    }
}
