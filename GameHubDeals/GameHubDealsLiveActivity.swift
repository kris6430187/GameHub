//
//  GameHubDealsLiveActivity.swift
//  GameHubDeals
//
//  Created by kris on 27/9/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GameHubDealsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GameHubDealsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GameHubDealsAttributes.self) { context in
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

extension GameHubDealsAttributes {
    fileprivate static var preview: GameHubDealsAttributes {
        GameHubDealsAttributes(name: "World")
    }
}

extension GameHubDealsAttributes.ContentState {
    fileprivate static var smiley: GameHubDealsAttributes.ContentState {
        GameHubDealsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GameHubDealsAttributes.ContentState {
         GameHubDealsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GameHubDealsAttributes.preview) {
   GameHubDealsLiveActivity()
} contentStates: {
    GameHubDealsAttributes.ContentState.smiley
    GameHubDealsAttributes.ContentState.starEyes
}
