import Foundation
import CoreData
import UIKit

final class TrackerStore: TrackerStoreProtocol {
    private let context: NSManagedObjectContext
  
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay: Bool]) -> Tracker {
        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.name = name
        tracker.color = color
        tracker.emoji = emoji
        tracker.schedule = schedule as NSObject
        saveContext()
        return Tracker(trackerCoreData: tracker)
    }

    func fetchAllTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { Tracker(trackerCoreData: $0) }
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

}

extension Tracker {
    init(trackerCoreData: TrackerCoreData) {
        self.id = trackerCoreData.id ?? UUID()
        self.name = trackerCoreData.name ?? ""
        self.color = trackerCoreData.color as? UIColor ?? UIColor.black
        self.emoji = trackerCoreData.emoji ?? ""
        self.schedule = trackerCoreData.schedule as? [WeekDay: Bool] ?? [:]
    }
}

protocol TrackerStoreProtocol {
    func fetchAllTrackers() -> [Tracker]
    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay: Bool]) -> Tracker
}

