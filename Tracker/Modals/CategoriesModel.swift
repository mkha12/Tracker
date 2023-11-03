import UIKit


final class CategoriesViewModel {
    
    
    private var trackerCategoryStore: TrackerCategoryStore
    var categories: [TrackerCategory] = [] {
        didSet {
            self.updateView?()
        }
    }
    
    var updateView: (() -> Void)?

    init() {
        trackerCategoryStore = TrackerCategoryStore(context: CoreDataManager.shared.persistentContainer.viewContext)
        trackerCategoryStore.delegate = self
        loadCategories()
        
        }
    
    func addCategory(title: String, trackers: [Tracker]) {
           let newCategory = trackerCategoryStore.createCategory(title: title, trackers: trackers)
           self.categories.append(newCategory)
       }
    
    private func loadCategories() {
           self.categories = trackerCategoryStore.fetchAllCategories()
       }
    
}


extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didChangeCategories(categories: [TrackerCategory]) {
        self.categories = categories
        self.updateView?()
    }
}

