import Foundation
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didChangeRecords(records: [TrackerRecord])
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerRecordStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
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
    
    func addRecord(trackerId: UUID, date: Date) -> TrackerRecord {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date
        saveContext()
        CoreDataManager.shared.saveContext()
        return TrackerRecord(recordCoreData: record)
    }
    
    func fetchAllRecords() -> [TrackerRecord] {
        let fetchedObjects = fetchedResultsController.fetchedObjects ?? []
        return fetchedObjects.map { TrackerRecord(recordCoreData: $0) }
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let records = fetchedResultsController.fetchedObjects?.map { TrackerRecord(recordCoreData: $0) } ?? []
        delegate?.didChangeRecords(records: records)
    }
}

extension TrackerRecord {
    init(recordCoreData: TrackerRecordCoreData) {
        self.trackerId = recordCoreData.trackerId ?? UUID()
        self.date = recordCoreData.date ?? Date()
    }
}


