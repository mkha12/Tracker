
import UIKit

protocol CategoryViewControllerDelegate {
    func didSelectCategory(_ category: TrackerCategory)
}

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var categories: [TrackerCategory] = []
    private let tableView = UITableView()
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    private let addButton = UIButton()
    var delegate: CategoryViewControllerDelegate?
    var defaultCategory = TrackerCategory(title: "Общая", trackers: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
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

        // Empty Label
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        emptyLabel.font = UIFont.systemFont(ofSize: 12)
        emptyLabel.text = "Привычки и события можно\nобъединить по смыслу"
        view.addSubview(emptyLabel)

        // Add Button
        addButton.setTitle("Добавить", for: .normal)
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

        NSLayoutConstraint.activate([
              tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
              tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
              tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
              tableView.heightAnchor.constraint(equalToConstant: 75),

              emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

              emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
              emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
              emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

              addButton.heightAnchor.constraint(equalToConstant: 60),
              addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
              addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
              addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
          ])
        if categories.isEmpty {
            categories.append(defaultCategory)
        }

        tableView.isHidden = false
        emptyImageView.isHidden = true
        emptyLabel.isHidden = true


    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].title
        return cell
    }

    @objc private func addCategory() {
            let selectedCategory = defaultCategory
            delegate?.didSelectCategory(selectedCategory)
            self.navigationController?.popViewController(animated: true)
        }

}
