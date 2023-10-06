import Foundation
import CoreData
import UIKit

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
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let trackers = fetchedResultsController.fetchedObjects?.map { Tracker(trackerCoreData: $0) } ?? []
        delegate?.didChangeTrackers(trackers: trackers)
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

protocol TrackerStoreDelegate: AnyObject {
    func didChangeTrackers(trackers: [Tracker])
}

