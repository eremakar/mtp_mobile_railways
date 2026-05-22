import UIKit
import Flutter
import ActivityKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    // 🔹 Live Activity channel
    let liveActivityChannel = FlutterMethodChannel(name: "live_activity", binaryMessenger: controller.binaryMessenger)
    liveActivityChannel.setMethodCallHandler { call, result in
      if call.method == "startLiveActivity" {
        guard let args = call.arguments as? [String: String],
              let title = args["title"],
              let eta = args["eta"] else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
          return
        }

        if #available(iOS 16.2, *) {
          let attr = PassflowAttributes(name: title)
          let state = PassflowAttributes.ContentState(title: title, eta: eta)
          let content = ActivityContent(state: state, staleDate: nil)

          do {
            let activity = try Activity<PassflowAttributes>.request(
              attributes: attr,
              content: content,
              pushType: nil
            )
            result(activity.id)
          } catch {
            result(FlutterError(code: "ACTIVITY_ERROR", message: "Failed to start activity", details: error.localizedDescription))
          }

        } else if #available(iOS 16.1, *) {
          let attr = PassflowAttributes(name: title)
          let state = PassflowAttributes.ContentState(title: title, eta: eta)

          do {
            let activity = try Activity<PassflowAttributes>.request(
              attributes: attr,
              contentState: state,
              pushType: nil
            )
            result(activity.id)
          } catch {
            result(FlutterError(code: "ACTIVITY_ERROR", message: "Failed to start activity", details: error.localizedDescription))
          }

        } else {
          result(FlutterError(code: "UNSUPPORTED", message: "Requires iOS 16.1+", details: nil))
        }

      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // 🔹 Custom notification channel
    let notificationChannel = FlutterMethodChannel(name: "custom_notification", binaryMessenger: controller.binaryMessenger)
    notificationChannel.setMethodCallHandler { call, result in
      if call.method == "showNotification" {
        guard let args = call.arguments as? [String: String],
              let title = args["title"],
              let message = args["message"] else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing args", details: nil))
          return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        // ✅ iOS 15+: show on lock screen with time-sensitive level
        if #available(iOS 15.0, *) {
          content.interruptionLevel = .timeSensitive
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
            result(FlutterError(code: "NOTIFICATION_ERROR", message: "Failed to schedule notification", details: error.localizedDescription))
          } else {
            result(nil)
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // 🔔 Request notification permission
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        print("⚠️ Notification permission error: \(error)")
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

