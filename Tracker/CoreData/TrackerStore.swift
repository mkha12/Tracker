import Foundation
import CoreData
import UIKit

protocol TrackerStoreProtocol {
    func addTrackerToCategory(_ tracker: Tracker, toCategory category: TrackerCategory)
    func fetchAllTrackers() -> [Tracker]
    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay: Bool]) -> Tracker
    func updateTracker(_ tracker: Tracker, category: TrackerCategory?)
}

protocol TrackerStoreDelegate: AnyObject {
    func didChangeTrackers(trackers: [Tracker])
}


final class TrackerStore: NSObject, TrackerStoreProtocol, NSFetchedResultsControllerDelegate {
   
    
    private let categoryStore: TrackerCategoryStore
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext, categoryStore: TrackerCategoryStore) {
        self.context = context
        self.categoryStore = categoryStore
        super.init()
        setupFetchedResultsController()
    }

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    
    private func setupFetchedResultsController() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay: Bool]) -> Tracker {
        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.name = name
        tracker.color = color
        tracker.emoji = emoji
        tracker.schedule = schedule as NSObject
        saveContext()
        CoreDataManager.shared.saveContext()
        return Tracker(trackerCoreData: tracker)
    }
    

    func updateTracker(_ tracker: Tracker, category: TrackerCategory?) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let trackerToUpdate = results.first {
                trackerToUpdate.name = tracker.name
                trackerToUpdate.color = tracker.color
                trackerToUpdate.emoji = tracker.emoji
                trackerToUpdate.schedule = tracker.schedule as? NSObject

                // Обновляем категорию, если это необходимо
                if let category = category,
                   let categoryCoreData = categoryStore.fetchCategoryCoreData(for: category) {
                    trackerToUpdate.category = categoryCoreData
                }

                saveContext()
            }
        } catch {
            print("Ошибка при обновлении трекера: \(error)")
        }
    }


    
    func fetchAllTrackers() -> [Tracker] {
        let fetchedObjects = fetchedResultsController.fetchedObjects ?? []
        return fetchedObjects.map { Tracker(trackerCoreData: $0) }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully")
            } catch {
                print("Failed to save context: \(error)")
            }
        } else {
            print("No changes in context to save")
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let trackers = fetchedResultsController.fetchedObjects?.map { Tracker(trackerCoreData: $0) } ?? []
        delegate?.didChangeTrackers(trackers: trackers)
        
        
    }
    func addTrackerToCategory(_ tracker: Tracker, toCategory category: TrackerCategory) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", tracker.name)
        
        do {
            if let trackerCoreData = try context.fetch(fetchRequest).first {
                let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
                
                if let categoryCoreData = try context.fetch(categoryFetchRequest).first {
                    trackerCoreData.category = categoryCoreData
                    saveContext()
                } else {
                    print("Category with title \(category.title) not found")
                }
            }
        } catch {
            print("Error searching for tracker or category: \(error)")
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
//    func updateTracker(_ tracker: Tracker) {
//        print("Обновление трекера: \(tracker.name)")
//        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
//
//        do {
//            if let trackerCoreData = try context.fetch(fetchRequest).first {
//                trackerCoreData.name = tracker.name
//                trackerCoreData.color = tracker.color
//                trackerCoreData.emoji = tracker.emoji
//                trackerCoreData.schedule = tracker.schedule as? NSObject
//
//                saveContext()
//
//                // Оповещение делегата об изменении данных
//                if let trackers = fetchedResultsController.fetchedObjects {
//                    delegate?.didChangeTrackers(trackers: trackers.map { Tracker(trackerCoreData: $0) })
//                }
//            } else {
//                print("No tracker found with id: \(tracker.id)")
//            }
//        } catch {
//            print("Error fetching tracker for update: \(error)")
//        }
//    }
