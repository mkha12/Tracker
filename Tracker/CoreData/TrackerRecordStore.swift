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
    
    func recordExistsFor(trackerId: UUID, date: Date) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@", trackerId as CVarArg, date.startOfDay as CVarArg, date.endOfDay as CVarArg)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to count TrackerRecordCoreData: \(error)")
            return false
        }
    }

    func removeRecordFor(trackerId: UUID, date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@ AND date >= %@ AND date < %@", trackerId as CVarArg, date.startOfDay as CVarArg, date.endOfDay as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            saveContext()
        } catch {
            print("Failed to fetch or delete TrackerRecordCoreData: \(error)")
        }
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context в записях : \(error.localizedDescription)")
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
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let components = DateComponents(day: 1, second: -1)
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
