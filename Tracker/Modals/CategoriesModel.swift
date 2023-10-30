import UIKit


final class CategoriesViewModel {
    var categories: [TrackerCategory] = [] {
        didSet {
            self.updateView?()
        }
    }
    
    var updateView: (() -> Void)? {
        didSet {
            print("updateView установлен")
        }
    }

    
    func addCategory(_ category: TrackerCategory) {
        categories.append(category)
        print("Категория добавлена: \(category)")
    }
    
}
extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didChangeCategories(categories: [TrackerCategory]) {
        self.categories = categories
        print("Категории обновлены: \(categories)")
    }
}
