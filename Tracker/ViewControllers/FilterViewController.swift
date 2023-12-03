import UIKit

public enum TrackerFilter: Int {
    case all = 0
    case today
    case completed
    case notCompleted
    
}

protocol FilterViewControllerDelegate: AnyObject {
    func didChooseFilter(_ filterIndex: Int)
}

final class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: FilterViewControllerDelegate?
    var selectedFilter: TrackerFilter?
    private var tableView: UITableView!
    private let filterTitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupFilterTitleLabel()
        setupTableView()
    }
    
    private func setupFilterTitleLabel() {
        filterTitleLabel.text = "Фильтры"
        filterTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        filterTitleLabel.textAlignment = .center
        view.addSubview(filterTitleLabel)
        filterTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            filterTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: filterTitleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let filter = TrackerFilter(rawValue: indexPath.row)
        cell.textLabel?.text = filter?.description
        cell.backgroundColor = UIColor.background
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        
        if let selectedFilter = selectedFilter, selectedFilter == filter {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = TrackerFilter(rawValue: indexPath.row)
        if self.selectedFilter == selectedFilter {
            self.selectedFilter = nil
            delegate?.didChooseFilter(-1)
        } else {
            self.selectedFilter = selectedFilter
            delegate?.didChooseFilter(selectedFilter?.rawValue ?? -1)
        }
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
}

extension TrackerFilter: CaseIterable {
    var description: String {
        switch self {
        case .all:
            return "Все трекеры"
        case .today:
            return "Трекеры на сегодня"
        case .completed:
            return "Завершенные"
        case .notCompleted:
            return "Не завершенные"
        }
    }
}
