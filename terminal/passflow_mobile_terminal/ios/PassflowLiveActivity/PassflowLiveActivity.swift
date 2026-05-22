import ActivityKit
import WidgetKit
import SwiftUI

struct PassflowAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var eta: String
    }

    var name: String
}

@main
struct PassflowLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PassflowAttributes.self) { context in
            // 🟢 Основной UI Live Activity (экран блокировки, уведомления)
            VStack(alignment: .leading, spacing: 8) {
                Text("🚄 \(context.state.title)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("⏱ Осталось: \(context.state.eta)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(Color.purple)
        } dynamicIsland: { context in
            // 🟣 Dynamic Island UI (опционально, если есть поддержка)
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("🚄")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.eta)
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.title)
                        .font(.caption)
                }
            } compactLeading: {
                Text("🚄")
            } compactTrailing: {
                Text("⏱")
            } minimal: {
                Text("•")
            }
        }
    }
}

