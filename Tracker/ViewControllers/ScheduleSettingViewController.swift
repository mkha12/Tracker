import UIKit

protocol ScheduleSettingViewControllerDelegate: AnyObject {
    func didUpdateSchedule(_ schedule: [WeekDay: Bool])
}


public enum WeekDay: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}

final class ScheduleSettingViewController: UIViewController {
    
    weak var delegate: ScheduleSettingViewControllerDelegate?
    
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .gray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var selectedDays: [WeekDay: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.hidesBackButton = true
        navigationItem.title = "Расписание"
        
        for day in WeekDay.allCases {
            if selectedDays[day] == nil {
                selectedDays[day] = false
            }
        }
        
        setupTableView()
        setupButton()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 525),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    
    private func setupButton() {
        button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func getSwitch(for indexPath: IndexPath) -> UISwitch {
        let switchView = UISwitch(frame: .zero)
        let day = WeekDay.allCases[indexPath.row]
        switchView.setOn(selectedDays[day] ?? false, animated: false)
        //switchView.setOn(false, animated: true)
        switchView.onTintColor = .blue
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return switchView
    }
    
    
    @objc private func doneButtonDidTap() {
        delegate?.didUpdateSchedule(selectedDays)
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc
    private func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        let day = WeekDay.allCases[index]
        selectedDays[day] = sender.isOn
        
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.textLabel?.textColor = sender.isOn ? UIColor.green : UIColor.red
        }
    }
    
}

extension ScheduleSettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
        cell.backgroundColor = .background
        cell.accessoryView = getSwitch(for: indexPath)
        
        if indexPath.row == 6 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
        
        let day = WeekDay.allCases[indexPath.row]
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = day.rawValue
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = day.rawValue
        }
        cell.selectionStyle = .none
        
        return cell
    }
}

extension WeekDay {
    func getShortName() -> String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
    
}

extension Date {
    var weekday: WeekDay {
        let calendarWeekday = Calendar.current.component(.weekday, from: self)
        let adjustedIndex = (calendarWeekday + 5) % 7
        return WeekDay.allCases[adjustedIndex]
    }
}

extension WeekDay {
    func toInt() -> Int {
        return WeekDay.allCases.firstIndex(of: self) ?? 0
    }
    
    static func fromInt(_ int: Int) -> WeekDay {
        return WeekDay.allCases[safe: int] ?? .monday // исправлено тут
    }
}

extension Dictionary {
    func mapKeys<Transformed>(_ transform: (Key) throws -> Transformed) rethrows -> [Transformed: Value] {
        var dictionary: [Transformed: Value] = [:]
        for (key, value) in self {
            dictionary[try transform(key)] = value
        }
        return dictionary
    }
}
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
