import UIKit

protocol CategoryViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory)
}

final class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var categories: [TrackerCategory] = []
    private let tableView = UITableView()
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    private let addButton = UIButton()
    private let categoryTitleLabel = UILabel()
    private var trackerCategoryStore: TrackerCategoryStore?

    var delegate: CategoryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        trackerCategoryStore = TrackerCategoryStore(context: CoreDataManager.shared.persistentContainer.viewContext)
        loadCategories()
        updateUIForEmptyState()
        
    }
    
    var viewModel: CategoriesViewModel? {
         didSet {
             viewModel?.updateView = { [weak self] in
                 DispatchQueue.main.async {
                     self?.tableView.reloadData()
                     self?.updateUIForEmptyState()
                 }
             }
         }
     }
    
    func setupUI() {

        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        view.addSubview(tableView)
        
        
        emptyImageView.contentMode = .scaleAspectFit
        emptyImageView.image = UIImage(named: "zaglishka")
        view.addSubview(emptyImageView)
        
        
        categoryTitleLabel.text = "Категория"
        categoryTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        categoryTitleLabel.textAlignment = .center
        view.addSubview(categoryTitleLabel)
        
        
        // Empty Label
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        emptyLabel.font = UIFont.systemFont(ofSize: 12)
        emptyLabel.text = "Привычки и события можно\nобъединить по смыслу"
        view.addSubview(emptyLabel)
        
        // Add Button
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        addButton.backgroundColor = .black
        addButton.layer.cornerRadius = 16
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(addButton)
        
        // Set constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 675),
            
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            categoryTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
      
        updateUIForEmptyState()
        
    }
    
    func updateUIForEmptyState() {
           let isEmpty = viewModel?.categories.isEmpty ?? true
           tableView.isHidden = isEmpty
           emptyImageView.isHidden = !isEmpty
           emptyLabel.isHidden = !isEmpty
       }
       
    func loadCategories() {
            guard let viewModel = viewModel, let trackerCategoryStore = trackerCategoryStore else {
                return
            }
            viewModel.categories = trackerCategoryStore.fetchAllCategories()
        }


       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return viewModel?.categories.count ?? 0
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
           if let categoryName = viewModel?.categories[indexPath.row].title {
               cell.textLabel?.text = categoryName
           } else {
               cell.textLabel?.text = nil
           }
           
           return cell
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCategory = viewModel?.categories[indexPath.row] {
            delegate?.didSelectCategory(selectedCategory)
            navigationController?.popViewController(animated: true)
        } else {
            print("Категория не найдена")
        }
    }

    
    @objc private func addCategory() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        newCategoryVC.viewModel = self.viewModel
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }

       
       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           updateUIForEmptyState()
       }

   }
extension CategoryViewController: NewCategoryViewControllerDelegate {
    func newCategoryViewController(_ controller: NewCategoryViewController, didCreateNewCategory category: TrackerCategory) {
        viewModel?.categories.append(category)
        tableView.reloadData()
        updateUIForEmptyState()
    }
}
