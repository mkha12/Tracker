import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDataSource, CreateTrackerDelegate {
    
    var datePicker: UIDatePicker!
    var searchBar: UISearchTextField!
    var collectionView: UICollectionView!
    var emptyTrackersImageView: UIImageView!
    var emptyTrackersLabel: UILabel!
    var emptyTrackersStackView: UIStackView!
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<UUID> = []
    var currentDate: Date = Date()
    var visibleCategories: [TrackerCategory] = []
    private let cellIdentifier = "TrackerCell"
    private let headerIdentifier = "CategoryHeader"
    let separatorView = UIView()
    let layout = UICollectionViewFlowLayout()
    var trackerRecords: [TrackerRecord] = []
    var notFoundImageView: UIImageView!
    var notFoundLabel: UILabel!
    var notFoundStackView: UIStackView!
    var trackers: [Tracker] = []
    var trackerStore: TrackerStoreProtocol?
    var viewModel: CategoriesViewModel!
    var categoryStore: TrackerCategoryStore?
    var categoriesViewModel: CategoriesViewModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
        updateEmptyTrackersVisibility()
        filterVisibleCategories()
        trackerStore = TrackerStore(context: CoreDataManager.shared.persistentContainer.viewContext)
        trackers = trackerStore?.fetchAllTrackers() ?? []
        
        updateCategories()
        loadTrackers()
        collectionView.reloadData()
        
    }
    
    private func setupUI() {
        
        self.navigationItem.title = "Трекеры"
        
        let addImage = UIImage(named: "Plus")?.withRenderingMode(.alwaysOriginal)
        let addButton = UIBarButtonItem(image: addImage, style: .plain, target: self, action: #selector(presentAddNewTrackerScreen))
        navigationItem.leftBarButtonItem = addButton
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        datePicker = UIDatePicker()
        datePicker.calendar.firstWeekday = 2
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        searchBar = UISearchTextField()
        searchBar.delegate = self
        searchBar.placeholder = "Поиск"
        searchBar.backgroundColor = .white
        searchBar.clearButtonMode = .never
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        
        separatorView.backgroundColor = .gray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorView)
        
        emptyTrackersImageView = UIImageView(image: UIImage(named: "zaglishka"))
        emptyTrackersImageView.contentMode = .scaleAspectFit
        
        emptyTrackersLabel = UILabel()
        emptyTrackersLabel.text = "Что будем отслеживать?"
        emptyTrackersLabel.textColor = .blackDay
        emptyTrackersLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyTrackersLabel.textAlignment = .center
        
        emptyTrackersStackView = UIStackView(arrangedSubviews: [emptyTrackersImageView, emptyTrackersLabel])
        emptyTrackersStackView.axis = .vertical
        emptyTrackersStackView.spacing = 10
        emptyTrackersStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackersStackView.isHidden = true
        view.addSubview(emptyTrackersStackView)
        
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeader.reuseIdentifier)
        
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        
        notFoundImageView = UIImageView(image: UIImage(named: "Zaglushka2"))
        notFoundImageView.contentMode = .scaleAspectFit
        
        notFoundLabel = UILabel()
        notFoundLabel.text = "Ничего не найдено"
        notFoundLabel.textColor = .blackDay
        notFoundLabel.font = UIFont.systemFont(ofSize: 12)
        notFoundLabel.textAlignment = .center
        
        notFoundStackView = UIStackView(arrangedSubviews: [notFoundImageView, notFoundLabel])
        notFoundStackView.axis = .vertical
        notFoundStackView.spacing = 10
        notFoundStackView.translatesAutoresizingMaskIntoConstraints = false
        notFoundStackView.isHidden = true
        view.addSubview(notFoundStackView)
        setupConstraints()
        
        
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            //не спрашивайте зачем тут 12, это я вычла 8 из тех отступов, что есть внутри самих ячеек)))

            
            separatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            emptyTrackersStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyTrackersStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            notFoundStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notFoundStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    func addNewTracker(_ tracker: Tracker, toCategory categoryName: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryName }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            
            let updatedCategory = TrackerCategory(title: categoryName, trackers: updatedTrackers)
            categories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(title: categoryName, trackers: [tracker])
            categories.append(newCategory)
        }
        
        visibleCategories = categories
        updateCategories ()
        updateVisibleCategories()
        updateEmptyTrackersVisibility()
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func didCreateTracker(tracker: Tracker, categoryName: String) {
        addNewTracker(tracker, toCategory: categoryName)
        collectionView.reloadData()
    }

    @objc func presentAddNewTrackerScreen() {
        let trackerTypeSelectionVC = TrackerTypeSelectionViewController()
        trackerTypeSelectionVC.delegate = self
        trackerTypeSelectionVC.trackerStore = self.trackerStore // Передаем trackerStore
        let navigationController = UINavigationController(rootViewController: trackerTypeSelectionVC)
        present(navigationController, animated: true)
    }
    
    func updateVisibleCategories() {
        let areTrackersAvailable = !visibleCategories.isEmpty
        emptyTrackersStackView.isHidden = areTrackersAvailable
    }
    
    @objc func dateChanged() {
        currentDate = datePicker.date
        
        filterVisibleCategories()
        collectionView.reloadData()
    }
    
    private func filterVisibleCategories() {
        let currentWeekday = currentDate.weekday
        
        if let query = searchBar.text, !query.isEmpty {
            visibleCategories = categories.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    let isNameMatching = tracker.name.lowercased().contains(query.lowercased())
                    let isScheduledToday = tracker.schedule?[currentWeekday] ?? false
                    return isNameMatching && isScheduledToday
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        } else {
            visibleCategories = categories.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    let isScheduledToday = tracker.schedule?[currentWeekday] ?? false
                    return isScheduledToday
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        
        updateEmptyTrackersVisibility()
        collectionView.reloadData()
    }
    
    func updateEmptyTrackersVisibility() {
        let isSearchActive = !(searchBar.text ?? "").isEmpty
        let noTrackersAvailable = visibleCategories.isEmpty
        
        
        if isSearchActive && noTrackersAvailable {
            emptyTrackersStackView.isHidden = true
            notFoundStackView.isHidden = false
        } else if !isSearchActive && noTrackersAvailable {
            emptyTrackersStackView.isHidden = false
            notFoundStackView.isHidden = true
        } else {
            emptyTrackersStackView.isHidden = true
            notFoundStackView.isHidden = true
        }
    }
    
    func loadTrackers() {
        guard let trackerStore = trackerStore else {
            print("Error: trackerStore is nil")
            return
        }
        
        trackers = trackerStore.fetchAllTrackers()
        updateCategories()
        filterVisibleCategories()
        collectionView.reloadData()
        
        let recordStore = TrackerRecordStore(context: CoreDataManager.shared.persistentContainer.viewContext)
        trackerRecords = recordStore.fetchAllRecords()
    }
    
    func updateCategories() {
        guard let fetchedCategories = categoryStore?.fetchAllCategories() else {
            return
        }
        
        categories = fetchedCategories
        filterVisibleCategories()
        collectionView.reloadData()
    }
    
}

extension TrackersViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        cell.getDaysCount = { [weak self] id in
            return self?.countDays(for: id) ?? 0
        }
        
        cell.configure(with: tracker, currentDate: currentDate)
        
        let isCompleted = trackerRecords.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        if isCompleted {
            cell.showCompletedState()
        } else {
            cell.showNotCompletedState()
        }
        
        cell.addButtonTapped = { [weak self] in
            self?.handleAddButtonTap(for: tracker)
        }
        
        return cell
    }
    
    private func handleAddButtonTap(for tracker: Tracker) {
        if currentDate > Date() { return }

        let recordStore = TrackerRecordStore(context: CoreDataManager.shared.persistentContainer.viewContext)

        if recordStore.recordExistsFor(trackerId: tracker.id, date: currentDate) {
            recordStore.removeRecordFor(trackerId: tracker.id, date: currentDate)
            completedTrackers.remove(tracker.id)
        } else {
            completedTrackers.insert(tracker.id)
            let _ = recordStore.addRecord(trackerId: tracker.id, date: currentDate)
        }
        loadTrackers()
    }


    
    func countDays(for trackerId: UUID) -> Int {
        return trackerRecords.filter { $0.trackerId == trackerId }.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryHeader.reuseIdentifier, for: indexPath) as! CategoryHeader
            header.configure(with: visibleCategories[indexPath.section].title)
            return header
        default:
            assert(false, "Invalid element type")
        }
    }
    
    
}

extension TrackersViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        filterVisibleCategories()
        collectionView.reloadData()
    }
}


extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
