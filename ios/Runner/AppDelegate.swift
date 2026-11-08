import Flutter
import UIKit
import flutter_local_notifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // The periodic notification check and notification actions run in
    // engines of their own, which need the plugins too.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    // iOS ends the app when a background task's handler is registered after
    // launching finishes, which the plugin would do when sign-in schedules
    // the first check. The identifier is PeriodicCheck.name.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "notification-check", earliestBeginInSeconds: NSNumber(value: 15 * 60))
    UNUserNotificationCenter.current().delegate = self
    excludeDataFromBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Like Android's allowBackup="false": the server databases hold messages
  // and stay on this phone.
  private func excludeDataFromBackup() {
    let files = FileManager.default
    guard var support = files.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    else { return }
    try? files.createDirectory(at: support, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? support.setResourceValues(values)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DeviceStatus") {
      DeviceStatus.register(with: registrar)
    }
  }
}
