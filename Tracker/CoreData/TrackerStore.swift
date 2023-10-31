import Foundation
import CoreData
import UIKit

protocol TrackerStoreProtocol {
    func addTrackerToCategory(_ tracker: Tracker, toCategory category: TrackerCategory)
    func fetchAllTrackers() -> [Tracker]
    func createTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay: Bool]) -> Tracker
}

protocol TrackerStoreDelegate: AnyObject {
    func didChangeTrackers(trackers: [Tracker])
}


final class TrackerStore: NSObject, TrackerStoreProtocol, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
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
            print("Fetched results controller performed fetch successfully")
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
