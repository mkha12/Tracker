

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay: Bool]?
}

struct TrackerCategory {
    let title: String
    var trackers: [Tracker]
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}
