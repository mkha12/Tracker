import UIKit

final class NewCategoryViewController: UIViewController {
    
    var viewModel: CategoriesViewModel?
    
    private let categoryNameTextField = UITextField()
    private let doneButton = UIButton()
    private let titleLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Категория"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryNameTextField.placeholder = "Введите название категории"
        categoryNameTextField.borderStyle = .roundedRect
        categoryNameTextField.clearButtonMode = .whileEditing
        categoryNameTextField.backgroundColor = UIColor.backgroundDay
        categoryNameTextField.layer.cornerRadius = 8
        view.addSubview(categoryNameTextField)
        
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: categoryNameTextField.frame.height))
        categoryNameTextField.leftView = paddingView
        categoryNameTextField.leftViewMode = .always
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        
        NSLayoutConstraint.activate([
            
            
            categoryNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    
        @objc private func doneButtonTapped() {
               if let categoryName = categoryNameTextField.text, !categoryName.isEmpty {
                   print("Создаем категорию с именем: \(categoryName)")
                   let context = CoreDataManager.shared.persistentContainer.viewContext
                   let trackerCategoryStore = TrackerCategoryStore(context: context)
                   _ = trackerCategoryStore.createCategory(title: categoryName, trackers: [])
                   navigationController?.popViewController(animated: true)
               }
           }
    
    
//    @objc private func doneButtonTapped() {
//        if let categoryName = categoryNameTextField.text, !categoryName.isEmpty {
//            print("Создаем категорию с именем: \(categoryName)")
//            let context = CoreDataManager.shared.persistentContainer.viewContext
//            let trackerCategoryStore = TrackerCategoryStore(context: context)
//            _ = trackerCategoryStore.createCategory(title: categoryName, trackers: [])
//            if let categoryVC = navigationController?.viewControllers.first(where: { $0 is CategoryViewController }) as? CategoryViewController {
//                categoryVC.loadCategories()
//            }
//            navigationController?.popViewController(animated: true)
//        }

}
