import Foundation
import CoreData

final class TrackerCateroryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    func createCategory(title: String, trackers: [Tracker]) -> TrackerCategory {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        let trackerCoreDataObjects = trackers.map { (tracker) -> TrackerCoreData in
            let trackerCoreData = TrackerCoreData(context: context)
            return trackerCoreData
        }
        category.trackers = NSSet(array: trackerCoreDataObjects)
        saveContext()
        return TrackerCategory(categoryCoreData: category)
    }



    func fetchAllCategories() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { TrackerCategory(categoryCoreData: $0) }
        } catch {
            print("Failed to fetch categories: \(error)")
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

extension TrackerCategory {
    init(categoryCoreData: TrackerCategoryCoreData) {
        self.title = categoryCoreData.title ?? ""
        self.trackers = (categoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.map(Tracker.init) ?? []
    }

}
