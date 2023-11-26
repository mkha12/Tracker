import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func newCategoryViewController(_ controller: NewCategoryViewController, didCreateNewCategory category: TrackerCategory)
}


final class NewCategoryViewController: UIViewController {
    
    var viewModel: CategoriesViewModel?
    weak var delegate: NewCategoryViewControllerDelegate?

    
    private let categoryNameTextField = UITextField()
    private let doneButton = UIButton()
    private let titleLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        doneButton.isEnabled = false
        doneButton.backgroundColor = .lightGray
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Новая категория"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
    
        
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        categoryNameTextField.placeholder = "Введите название категории"
        categoryNameTextField.clearButtonMode = .whileEditing
        categoryNameTextField.backgroundColor = UIColor.background
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.layer.cornerRadius = 16
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: categoryNameTextField.frame.height))
        categoryNameTextField.leftView = paddingView
        categoryNameTextField.leftViewMode = .always
        
        view.addSubview(categoryNameTextField)
        
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        //doneButton.backgroundColor = .black
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
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doneButton.isEnabled = true
            doneButton.backgroundColor = .black
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = .lightGray
        }
    }
    
    @objc private func doneButtonTapped() {
        if let categoryName = categoryNameTextField.text, !categoryName.isEmpty {
            print("Создаем категорию с именем: \(categoryName)")
            let context = CoreDataManager.shared.persistentContainer.viewContext
            let trackerCategoryStore = TrackerCategoryStore(context: context)
            let newCategory = trackerCategoryStore.createCategory(title: categoryName, trackers: [])
            delegate?.newCategoryViewController(self, didCreateNewCategory: newCategory)
            navigationController?.popViewController(animated: true)
        }
    }
    
}
