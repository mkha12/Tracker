import UIKit

protocol CreateTrackerDelegate {
    func didCreateTracker(tracker: Tracker, categoryName: String)
}

final class TrackerCreationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ColorSelectionDelegate, EmojiSelectionDelegate,ScheduleSettingViewControllerDelegate, CategoryViewControllerDelegate {
    
    
    var isHabit: Bool = true
    var delegate: CreateTrackerDelegate?
    
    private var selectedEmoji: String?
    private var selectedCategory: TrackerCategory?
    private var selectedColor: UIColor?
    private let emoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    private let tableView = UITableView()
    private let emojiHeaderLabel = UILabel()
    private let colorHeaderLabel = UILabel()
    private let categoryCell = UITableViewCell()
    private let scheduleCell = UITableViewCell()
    private let emojiCollectionView = EmojiCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let colorCollectionView = ColorCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var selectedSchedule: [WeekDay: Bool]?
    private let scrollView = UIScrollView()
    var trackerStore: TrackerStoreProtocol?
    var categoriesViewModel: CategoriesViewModel!
    var trackerCategoryStore: TrackerCategoryStore!
    var trackerToEdit: Tracker?
    var filledDaysCount: Int?
    private let daysCountLabel = UILabel()
    private let contentView = UIView()
    
    enum Mode {
        case create
        case edit(Tracker)
    }
    
    var mode: Mode = .create
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        tableView.delegate = self
        tableView.dataSource = self
        emojiCollectionView.emojiSelectionDelegate = self
        colorCollectionView.colorSelectionDelegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ScheduleCell")
        setupUI()
        categoriesViewModel = CategoriesViewModel()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        updateCreateButtonState()
        setupForMode()
        
    }
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.contentInsetAdjustmentBehavior = .never
        
        
        categoryCell.textLabel?.text = "Категория"
        scheduleCell.textLabel?.text = "Расписание"
        categoryCell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        scheduleCell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        contentView.addSubview(tableView)
        contentView.addSubview(daysCountLabel)
        
        // Title Label
        titleLabel.text = isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        // Text Field
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = UIColor.background
        textField.layer.cornerRadius = 8
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        contentView.addSubview(textField)
        
        
        // Cancel Button
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelCreation), for: .touchUpInside)
        cancelButton.backgroundColor = .white
        cancelButton.layer.borderWidth = 1
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.cornerRadius = 16
        contentView.addSubview(cancelButton)
        
        // Create Button
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createButton.addTarget(self, action: #selector(saveTracker), for: .touchUpInside)
        createButton.backgroundColor = .gray
        createButton.layer.cornerRadius = 16
        createButton.setTitleColor(.white, for: .normal)
        contentView.addSubview(createButton)
        
        // Emoji and Color CollectionViews
        contentView.addSubview(emojiCollectionView)
        colorCollectionView.colorSelectionDelegate = self
        contentView.addSubview(colorCollectionView)
        emojiCollectionView.emojiSelectionDelegate = self
        emojiCollectionView.emojis = self.emoji
        
        // Emoji and Color Header Labels
        emojiHeaderLabel.text = "Emoji"
        emojiHeaderLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        emojiHeaderLabel.textAlignment = .left
        
        colorHeaderLabel.text = "Цвет"
        colorHeaderLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        colorHeaderLabel.textAlignment = .left
        
        daysCountLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        daysCountLabel.textColor = .black
        daysCountLabel.isHidden = !(isHabit && trackerToEdit != nil)
        
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(emojiHeaderLabel)
        contentView.addSubview(colorHeaderLabel)
        
        
        // Set constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        colorHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        colorCollectionView.colors = [
            .colorSelection1, .colorSelection2, .colorSelection3,
            .colorSelection4, .colorSelection5, .colorSelection6,
            .colorSelection7, .colorSelection8, .colorSelection9,
            .colorSelection10, .colorSelection11, .colorSelection12,
            .colorSelection13, .colorSelection14, .colorSelection15,
            .colorSelection16, .colorSelection17, .colorSelection18
        ]
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 136),
            daysCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -136),
            daysCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            daysCountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 0), // Расстояние от daysCountLabel
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75), // Высота textField
            
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: isHabit ? 150 : 75),
            
            
            emojiHeaderLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiHeaderLabel.heightAnchor.constraint(equalToConstant: 19),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiHeaderLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            
            colorHeaderLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorHeaderLabel.heightAnchor.constraint(equalToConstant: 19),
            
            
            colorCollectionView.topAnchor.constraint(equalTo: colorHeaderLabel.bottomAnchor, constant: 0),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.widthAnchor.constraint(equalToConstant: 166),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            
        ])
        
    }
    
    
    private func setupForMode() {
        switch mode {
        case .create:
            daysCountLabel.isHidden = true
            titleLabel.text = isHabit ? "Новая привычка" : "Новое нерегулярное событие"
            
        case .edit(let tracker):
            isHabit = tracker.schedule != nil
            daysCountLabel.isHidden = !isHabit
            titleLabel.text = isHabit ? "Редактирование привычки" : "Редактирование нерегулярного события"
            
            textField.text = tracker.name
            selectedEmoji = tracker.emoji
            selectedColor = tracker.color
            
            selectedCategory = categoriesViewModel.categories.first { $0.trackers.contains(where: { $0.id == tracker.id }) }
            selectedSchedule = tracker.schedule
            if let daysCount = filledDaysCount {
                daysCountLabel.text = daysCountText(for: daysCount)
            }
            
        }
        tableView.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateCreateButtonState()
    }
    
    func allRequiredFieldsFilled() -> Bool {
        let isTextFieldFilled = !(textField.text?.isEmpty ?? true)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isCategorySelected = selectedCategory != nil
        let isScheduleValid = isHabit ? selectedSchedule != nil : true
        
        return isTextFieldFilled && isEmojiSelected && isColorSelected && isCategorySelected && isScheduleValid
    }
    
    
    
    func updateCreateButtonState() {
        if allRequiredFieldsFilled() {
            createButton.isEnabled = true
            createButton.backgroundColor = .black
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isHabit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if isHabit {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
                let categoryDetailText = selectedCategory?.title ?? ""
                cell.textLabel?.attributedText = attributedString(for: "Категория", detail: categoryDetailText)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath)
                if let selectedSchedule = selectedSchedule {
                    let allDays: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
                    let scheduleText: String
                    
                    if allDays.allSatisfy({ selectedSchedule[$0] == true }) {
                        scheduleText = "Каждый день"
                    } else {
                        let activeDays = selectedSchedule.compactMap { (day, isActive) -> String? in
                            return isActive ? day.getShortName() : nil
                        }
                        scheduleText = activeDays.joined(separator: ", ")
                    }
                    
                    cell.textLabel?.attributedText = attributedString(for: "Расписание", detail: scheduleText)
                } else {
                    cell.textLabel?.attributedText = attributedString(for: "Расписание", detail: nil)
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            let categoryDetailText = selectedCategory?.title ?? ""
            cell.textLabel?.attributedText = attributedString(for: "Категория", detail: categoryDetailText)
        }
        
        cell.backgroundColor = .background
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: UIImage(named: "Strelka"))
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    
    
    func attributedString(for title: String, detail: String?) -> NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let detailAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.gray]
        
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let attributedDetail = NSAttributedString(string: "\n\(detail ?? "")", attributes: detailAttributes)
        
        let combinedString = NSMutableAttributedString()
        combinedString.append(attributedTitle)
        combinedString.append(attributedDetail)
        return combinedString
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        updateCreateButtonState()
    }
    
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateCreateButtonState()
    }
    
    
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        let categoryCellIndexPath = IndexPath(row: 0, section: 0)
        categoryCell.textLabel?.text = category.title
        categoryCell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        tableView.reloadRows(at: [categoryCellIndexPath], with: .none)
        updateCreateButtonState()
    }
    func didUpdateSchedule(_ schedule: [WeekDay: Bool]) {
        selectedSchedule = schedule
        
        let allDays: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        if allDays.allSatisfy({ schedule[$0] == true }) {
            scheduleCell.textLabel?.text = "Каждый день"
        } else {
            let activeDays = schedule.compactMap { (day, isActive) -> String? in
                return isActive ? day.getShortName() : nil
            }
            let scheduleText = "Расписание\n" + activeDays.joined(separator: ", ")
            scheduleCell.textLabel?.text = scheduleText
        }
        
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        updateCreateButtonState()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if isHabit {
            
            if indexPath.row == 0 {
                let categorySelectionVC = CategoryViewController()
                categorySelectionVC.viewModel = self.categoriesViewModel // Передаём модель
                categorySelectionVC.delegate = self
                let navController = UINavigationController(rootViewController: categorySelectionVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                let scheduleSelectionVC = ScheduleSettingViewController()
                scheduleSelectionVC.selectedDays = self.selectedSchedule ?? [:]
                scheduleSelectionVC.delegate = self
                self.navigationController?.pushViewController(scheduleSelectionVC, animated: true)
            }
        } else {
            let categorySelectionVC = CategoryViewController()
            categorySelectionVC.viewModel = self.categoriesViewModel
            categorySelectionVC.delegate = self
            let navController = UINavigationController(rootViewController: categorySelectionVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
        
        if let category = selectedCategory {
            let indexPath = IndexPath(row: 0, section: 0)
            if let categoryCell = tableView.cellForRow(at: indexPath) {
                categoryCell.textLabel?.text = category.title
                categoryCell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        
        if let schedule = selectedSchedule {
            let scheduleString = schedule.map { $0.key.getShortName() + ": " + ($0.value ? "Yes" : "No") }.joined(separator: ", ")
            scheduleCell.textLabel?.text = scheduleString
            scheduleCell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
    }
    
    @objc private func cancelCreation() {
        dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @objc private func saveTracker() {
        guard let trackerName = textField.text, !trackerName.isEmpty else {
            return
        }
        guard let trackerName = textField.text, !trackerName.isEmpty,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor,
              let trackerStore = trackerStore else {
            let alertMessage = "Убедитесь, что все поля заполнены корректно."
            let alert = UIAlertController(title: "Ошибка", message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        switch mode {
        case .create:
            let newTracker = trackerStore.createTracker(id: UUID(), name: trackerName, color: selectedColor, emoji: selectedEmoji, schedule: selectedSchedule ?? [:])
            addOrUpdateTrackerInCategory(newTracker)
            delegate?.didCreateTracker(tracker: newTracker, categoryName: selectedCategory?.title ?? "Без категории")
            
        case .edit(let existingTracker):
            let updatedTracker = Tracker(id: existingTracker.id, name: trackerName, color: selectedColor, emoji: selectedEmoji, schedule: selectedSchedule ?? [:])
            trackerStore.updateTracker(updatedTracker, category: selectedCategory)
            addOrUpdateTrackerInCategory(updatedTracker)
            delegate?.didCreateTracker(tracker: updatedTracker, categoryName: selectedCategory?.title ?? "Без категории")
        }
        
        dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func addOrUpdateTrackerInCategory(_ tracker: Tracker) {
        if let selectedCategoryTitle = selectedCategory?.title {
            if let trackerStore = trackerStore {
                trackerStore.addTrackerToCategory(tracker, toCategory: selectedCategory!)
            }
            
        } else {
        }
    }
    private func daysCountText(for days: Int) -> String {
        switch days {
        case 1:
            return "\(days) день"
        case 2...4:
            return "\(days) дня"
        default:
            return "\(days) дней"
        }
    }
    
}
