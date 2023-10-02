import Foundation
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    func addRecord(trackerId: UUID, date: Date) -> TrackerRecord {
        let record = TrackerRecordCoreData(context: context)
        record.trackerId = trackerId
        record.date = date
        saveContext()
        return TrackerRecord(recordCoreData: record)
    }
    func fetchAllRecords() -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { TrackerRecord(recordCoreData: $0) }
        } catch {
            print("Failed to fetch records: \(error)")
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
extension TrackerRecord {
    init(recordCoreData: TrackerRecordCoreData) {
        self.trackerId = recordCoreData.trackerId ?? UUID()
        self.date = recordCoreData.date ?? Date()
    }
}
extension TrackerRecordCoreData {
    convenience init(record: TrackerRecord, context: NSManagedObjectContext) {
        self.init(context: context)
        self.trackerId = record.trackerId
        self.date = record.date
    }
}
