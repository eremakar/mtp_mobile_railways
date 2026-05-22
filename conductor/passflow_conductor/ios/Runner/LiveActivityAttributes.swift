import ActivityKit

struct PassflowAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var eta: String
    }

    var name: String
}
