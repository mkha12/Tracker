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
        print("Создаем категорию: \(title)")
        saveContext()
        CoreDataManager.shared.saveContext()  // сохранение в persistentContainer
        print("Категория сохранена.")
        return TrackerCategory(categoryCoreData: category)
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        print("Метод fetchAllCategories был вызван")
        let fetchedObjects = fetchedResultsController.fetchedObjects ?? []
        print("Извлечено категорий из Core Data: \(fetchedObjects.count)")
        return fetchedObjects.map { TrackerCategory(categoryCoreData: $0) }
    }
    
    func saveContext() {
        do {
            try context.save()
            CoreDataManager.shared.saveContext()
            print("Контекст успешно сохранен.")
        } catch {
            print("Ошибка при сохранении контекста: \(error)")
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
