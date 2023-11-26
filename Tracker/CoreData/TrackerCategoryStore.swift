import Foundation
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didChangeCategories(categories: [TrackerCategory])
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerCategoryStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
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
    
    func createCategory(title: String, trackers: [Tracker]) -> TrackerCategory {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        let trackerCoreDataObjects = trackers.map { (tracker) -> TrackerCoreData in
            let trackerCoreData = TrackerCoreData(context: context)
            return trackerCoreData
        }
        category.trackers = NSSet(array: trackerCoreDataObjects)
        saveContext()
        CoreDataManager.shared.saveContext()  // сохранение в persistentContainer
        return TrackerCategory(categoryCoreData: category)
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let fetchedObjects = fetchedResultsController.fetchedObjects ?? []
        return fetchedObjects.map { TrackerCategory(categoryCoreData: $0) }
    }
    
    func saveContext() {
        do {
            try context.save()
            CoreDataManager.shared.saveContext()
        } catch {
            print("Ошибка при сохранении контекста: \(error)")
        }
    }

    func fetchCategoryCoreData(for trackerCategory: TrackerCategory) -> TrackerCategoryCoreData? { // добавила чторбы работали категории
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", trackerCategory.title)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            return nil
        }
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let categories = fetchedResultsController.fetchedObjects?.map { TrackerCategory(categoryCoreData: $0) } ?? []
        delegate?.didChangeCategories(categories: categories)
    }
}

extension TrackerCategory {
    init(categoryCoreData: TrackerCategoryCoreData) {
        self.title = categoryCoreData.title ?? ""
        self.trackers = (categoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.map(Tracker.init) ?? []
    }
}
extension TrackerCategory {
    func coreDataObject(context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", self.title)

        if let existingCategory = try? context.fetch(fetchRequest).first {
            return existingCategory
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.title = self.title
            return newCategory
        }
    }
}

