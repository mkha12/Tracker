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

class FilterViewController: UITableViewController {
    weak var delegate: FilterViewControllerDelegate?
    var selectedFilter: TrackerFilter = .today
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.tableFooterView = UIView()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.title = "Фильтры"
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = TrackerFilter(rawValue: indexPath.row)
        cell.textLabel?.text = filter?.description // Сюда нужно добавить локализацию в зависимости от значения enum
        cell.accessoryType = filter == selectedFilter ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let filter = TrackerFilter(rawValue: indexPath.row) {
            selectedFilter = filter
            delegate?.didChooseFilter(filter.rawValue)
            
            tableView.reloadData()
            dismiss(animated: true, completion: nil)
        }
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
