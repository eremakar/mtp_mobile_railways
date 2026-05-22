import ActivityKit
import Flutter

@available(iOS 16.1, *)
class LiveActivityManager {
    private var activity: Activity<LiveActivityAttributes>?

    func startLiveActivity(data: [String: Any]) {
        let attributes = LiveActivityAttributes()
        let contentState = LiveActivityAttributes.ContentState(
            title: data["title"] as? String ?? "",
            eta: data["eta"] as? String ?? ""
        )

        do {
            activity = try Activity<LiveActivityAttributes>.request(
                attributes: attributes,
                contentState: contentState
            )
        } catch {
            print("Ошибка при запуске Live Activity: \(error)")
        }
    }

    func updateLiveActivity(data: [String: Any]) {
        let updatedState = LiveActivityAttributes.ContentState(
            title: data["title"] as? String ?? "",
            eta: data["eta"] as? String ?? ""
        )

        Task {
            await activity?.update(using: updatedState)
        }
    }

    func endLiveActivity() {
        Task {
            await activity?.end(dismissalPolicy: .immediate)
        }
    }
}
