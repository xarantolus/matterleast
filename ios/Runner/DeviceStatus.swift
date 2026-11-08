import Flutter
import Network
import UIKit

/// What the Dart side asks the phone: whether Low Data Mode holds the
/// network back (reported on every change, like Android's Data Saver) and
/// whether iOS lets the app check for messages in the background.
class DeviceStatus: NSObject, FlutterPlugin {
    private let dataSaver: FlutterMethodChannel
    private let monitor = NWPathMonitor()
    private var constrained = false

    init(dataSaver: FlutterMethodChannel) {
        self.dataSaver = dataSaver
    }

    static func register(with registrar: FlutterPluginRegistrar) {
        let dataSaver = FlutterMethodChannel(name: "matterleast/data_saver", binaryMessenger: registrar.messenger())
        let instance = DeviceStatus(dataSaver: dataSaver)
        registrar.addMethodCallDelegate(instance, channel: dataSaver)
        let refresh = FlutterMethodChannel(
            name: "matterleast/background_refresh", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: refresh)
        instance.monitor.pathUpdateHandler = { [weak instance] path in
            DispatchQueue.main.async {
                guard let instance = instance, instance.constrained != path.isConstrained else { return }
                instance.constrained = path.isConstrained
                instance.dataSaver.invokeMethod("changed", arguments: path.isConstrained)
            }
        }
        instance.monitor.start(queue: DispatchQueue(label: "matterleast.data_saver"))
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "restricted":
            result(monitor.currentPath.isConstrained)
        case "status":
            switch UIApplication.shared.backgroundRefreshStatus {
            case .available: result("available")
            case .denied: result("denied")
            case .restricted: result("restricted")
            @unknown default: result("available")
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
