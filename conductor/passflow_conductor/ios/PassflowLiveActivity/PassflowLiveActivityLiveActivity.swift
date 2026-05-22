//
//  PassflowLiveActivityLiveActivity.swift
//  PassflowLiveActivity
//
//  Created by FCODE on 13.04.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PassflowLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PassflowLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PassflowLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PassflowLiveActivityAttributes {
    fileprivate static var preview: PassflowLiveActivityAttributes {
        PassflowLiveActivityAttributes(name: "World")
    }
}

extension PassflowLiveActivityAttributes.ContentState {
    fileprivate static var smiley: PassflowLiveActivityAttributes.ContentState {
        PassflowLiveActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PassflowLiveActivityAttributes.ContentState {
         PassflowLiveActivityAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PassflowLiveActivityAttributes.preview) {
   PassflowLiveActivityLiveActivity()
} contentStates: {
    PassflowLiveActivityAttributes.ContentState.smiley
    PassflowLiveActivityAttributes.ContentState.starEyes
}
