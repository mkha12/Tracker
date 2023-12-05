import UIKit
import YandexMobileMetrica

final class TrackersViewController: UIViewController, UICollectionViewDataSource, CreateTrackerDelegate, UICollectionViewDelegate, FilterViewControllerDelegate {
    
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
    var pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: [])
    var trackerCategoryMap: [UUID: Int] = [:]
    let filterButton = UIButton(type: .system)
    var recordStore: TrackerRecordStore?
    var currentFilter: TrackerFilter = .today
    var cancelButton = UIButton(type: .system)
    private var searchBarToCancelButtonConstraint: NSLayoutConstraint?
    private var searchBarTrailingConstraint: NSLayoutConstraint?

    
    override func viewDidLoad() {
        AnalyticsService().report(event: "open", params: ["screen": "Main"])
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
        
        categoryStore = TrackerCategoryStore(context: CoreDataManager.shared.persistentContainer.viewContext)
        trackerStore = TrackerStore(context: CoreDataManager.shared.persistentContainer.viewContext, categoryStore: categoryStore!)
        
        trackers = trackerStore?.fetchAllTrackers() ?? []
        recordStore = TrackerRecordStore(context: CoreDataManager.shared.persistentContainer.viewContext)
        
        updateCategories()
        loadTrackers()
        collectionView.reloadData()
        updateEmptyTrackersVisibility()
        filterVisibleCategories()
        updateSearchVisibility()
        
    }
    
    
    
    
    private func setupUI() {
        
        self.navigationItem.title = NSLocalizedString("title_trackers", comment: "")
        
        let plusImage = UIImage(systemName: "plus")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let addButton = UIBarButtonItem(image: plusImage, style: .plain, target: self, action: #selector(presentAddNewTrackerScreen))
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
        searchBar.placeholder = NSLocalizedString("search_placeholder", comment: "")
        searchBar.backgroundColor = .white
        searchBar.clearButtonMode = .never
        searchBar.addTarget(self, action: #selector(searchBarTextDidChanged), for: .editingChanged)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelButton.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        cancelButton.isHidden = true
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        
        filterButton.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        filterButton.backgroundColor = .blue
        filterButton.addTarget(self, action: #selector(showFilterOptions), for: .touchUpInside)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.layer.cornerRadius = 20
        filterButton.clipsToBounds = true
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        
        separatorView.backgroundColor = .separatorColour
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorView)
        
        emptyTrackersImageView = UIImageView(image: UIImage(named: "zaglishka"))
        emptyTrackersImageView.contentMode = .scaleAspectFit
        
        
        emptyTrackersLabel = UILabel()
        emptyTrackersLabel.text = NSLocalizedString("empty_trackers_message", comment: "")
        emptyTrackersLabel.textColor = .black
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
        collectionView.backgroundColor = UIColor.white
        
        notFoundImageView = UIImageView(image: UIImage(named: "Zaglushka2"))
        notFoundImageView.contentMode = .scaleAspectFit
        
        notFoundLabel = UILabel()
        notFoundLabel.text = NSLocalizedString("not_found_message", comment: "")
        notFoundLabel.textColor = .black
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


        searchBarTrailingConstraint = searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        searchBarToCancelButtonConstraint = searchBar.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8)
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
           
           NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBarTrailingConstraint!,
                   
            cancelButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 83),
            
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
            notFoundStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            filterButton.widthAnchor.constraint(equalToConstant: 100),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    
    func addNewTracker(_ tracker: Tracker, toCategory categoryName: String) {
        AnalyticsService().report(event: "click", params: ["screen": "Main", "item": "add_track"])
        if let index = categories.firstIndex(where: { $0.title == categoryName }) {
            trackerCategoryMap[tracker.id] = index
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            
            let updatedCategory = TrackerCategory(title: categoryName, trackers: updatedTrackers)
            categories[index] = updatedCategory
        } else {
            trackerCategoryMap[tracker.id] = categories.count
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
    
    @objc private func cancelSearch() {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        updateSearchVisibility()
        filterVisibleCategories()
        collectionView.reloadData()
    }
    
    @objc func searchBarTextDidChanged(_ searchBar: UISearchBar) {
        updateSearchVisibility()
        updateEmptyTrackersVisibility()
    }

    func updateSearchVisibility() {
        let isSearching = !(searchBar.text?.isEmpty ?? true)
        cancelButton.isHidden = !isSearching

        if isSearching {
            searchBarTrailingConstraint?.isActive = false
            searchBarToCancelButtonConstraint?.isActive = true
        } else {
            searchBarTrailingConstraint?.isActive = true
            searchBarToCancelButtonConstraint?.isActive = false
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    
    func didCreateTracker(tracker: Tracker, categoryName: String) {
        addNewTracker(tracker, toCategory: categoryName)
        filterVisibleCategories()
        updateEmptyTrackersVisibility()
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
        var updatedVisibleCategories: [TrackerCategory] = []
        if !pinnedCategory.trackers.isEmpty {
            updatedVisibleCategories.append(pinnedCategory)
        }
        updatedVisibleCategories += categories.filter { !$0.trackers.isEmpty }
        visibleCategories = updatedVisibleCategories
        collectionView.reloadData()
    }
    
    
    
    @objc func dateChanged() {
        AnalyticsService().report(event: "click", params: ["screen": "Main", "item": "func dateChanged"])
        currentDate = datePicker.date
        filterVisibleCategories()
        updateEmptyTrackersVisibility()
        collectionView.reloadData()
    }

    private func filterVisibleCategories() {

        let searchText = searchBar.text?.lowercased() ?? ""
        let isSearchActive = !searchText.isEmpty

        visibleCategories = categories.flatMap { category -> [TrackerCategory] in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSearch = isSearchActive ? tracker.name.lowercased().contains(searchText) : true
                let scheduleIsEmpty = tracker.schedule?.isEmpty ?? true
                let isCompletedOnSelectedDate = recordStore?.recordExistsFor(trackerId: tracker.id, date: currentDate) ?? false
                let isCompletedBeforeSelectedDate = recordStore?.recordExistsBeforeDate(trackerId: tracker.id, date: currentDate) ?? false

                let matchesDateAndSchedule: Bool
                switch currentFilter {
                case .all:
                    matchesDateAndSchedule = scheduleIsEmpty ? !isCompletedBeforeSelectedDate : (tracker.schedule?[currentDate.weekday] ?? false)
                case .today:
                    matchesDateAndSchedule = scheduleIsEmpty ? !isCompletedBeforeSelectedDate : (tracker.schedule?[currentDate.weekday] ?? false)
                case .completed:
                    matchesDateAndSchedule = isCompletedOnSelectedDate
                    
                case .notCompleted:
                    matchesDateAndSchedule = scheduleIsEmpty ? !isCompletedBeforeSelectedDate && !isCompletedOnSelectedDate : !isCompletedOnSelectedDate && (tracker.schedule?[currentDate.weekday] ?? false)

                }
                return matchesSearch && matchesDateAndSchedule
            }

            return filteredTrackers.isEmpty ? [] : [TrackerCategory(title: category.title, trackers: filteredTrackers)]
        }
    }

        
    func updateEmptyTrackersVisibility() {
        let isSearchActive = !(searchBar.text ?? "").isEmpty
        let isFilterActive = currentFilter != .all
        let noVisibleTrackersAvailable = visibleCategories.isEmpty

        if trackers.isEmpty {

            emptyTrackersStackView.isHidden = false
            notFoundStackView.isHidden = true
        } else if (isSearchActive || isFilterActive) && noVisibleTrackersAvailable {
          
            notFoundStackView.isHidden = false
            emptyTrackersStackView.isHidden = true
        } else {
        
            emptyTrackersStackView.isHidden = true
            notFoundStackView.isHidden = true
        }
    }

        
        func loadTrackers() {
            guard let trackerStore = trackerStore else {
                return
            }
            
            trackers = trackerStore.fetchAllTrackers()
            updateCategories()
            updateCompletedTrackers()
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
        
        
        @objc private func showFilterOptions() {
            AnalyticsService().report(event: "click", params: ["screen": "Main", "item": "func showFilterOptions"])
            let filterVC = FilterViewController()
            filterVC.delegate = self
            filterVC.selectedFilter = currentFilter
            let navigationController = UINavigationController(rootViewController: filterVC)
            present(navigationController, animated: true)
        }
        
        
        private func updateCompletedTrackers() {
            guard let trackerStore = trackerStore else {
                return
            }
            
            let recordStore = TrackerRecordStore(context: CoreDataManager.shared.persistentContainer.viewContext)
            completedTrackers.removeAll()
            
            for tracker in trackerStore.fetchAllTrackers() {
                if recordStore.recordExistsFor(trackerId: tracker.id, date: currentDate) {
                    completedTrackers.insert(tracker.id)
                } else {
                }
            }
        }
        
        
    
    func didChooseFilter(_ filterIndex: Int) {
        if let filter = TrackerFilter(rawValue: filterIndex) {
            currentFilter = filter
            if filter == .today {
      
                currentDate = Date()
                datePicker.setDate(currentDate, animated: true)
            }
            filterVisibleCategories()
            updateEmptyTrackersVisibility()
            collectionView.reloadData()
        }
    }

        
        func filterForToday() {
            let currentWeekday = currentDate.weekday
            visibleCategories = categories.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.schedule?[currentWeekday] ?? true
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        
        func filterForCompleted() {
            visibleCategories = categories.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    let isCompleted = completedTrackers.contains(tracker.id)
                    return isCompleted
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        
        func filterForNotCompleted() {
            visibleCategories = categories.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    let isNotCompleted = !completedTrackers.contains(tracker.id)
                    return isNotCompleted
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        
        
    }

extension TrackersViewController {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.filter { !$0.trackers.isEmpty }.count
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

        let todayIsScheduled = tracker.schedule?[currentDate.weekday] ?? false

        let isCompleted: Bool
        if let schedule = tracker.schedule, schedule[currentDate.weekday] ?? false {
            isCompleted = trackerRecords.contains {
                $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
            }
        } else {
            isCompleted = trackerRecords.contains { $0.trackerId == tracker.id }
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
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Invalid element type")
        }

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryHeader.reuseIdentifier, for: indexPath) as! CategoryHeader
        
        let category = visibleCategories[indexPath.section]
        header.configure(with: category.title)
        header.isHidden = category.trackers.isEmpty // Скрыть заголовок, если нет трекеров
        
        return header
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
            if visibleCategories[section].trackers.isEmpty {
                return CGSize.zero
            } else {
                return CGSize(width: collectionView.bounds.width, height: 50)
            }
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
extension TrackersViewController {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        AnalyticsService().report(event: "click", params: ["screen": "Main", "item": "context_menu_open"])
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            AnalyticsService().report(event: "click", params: ["screen": "Main", "item": "zakrepit"])
            let pinActionTitle = self.isTrackerPinned(tracker) ? "Открепить" : "Закрепить"
            let pinAction = UIAction(
                title: pinActionTitle,
                image: nil,
                identifier: nil,
                discoverabilityTitle: nil,
                state: .off) { [weak self] action in
                    if self?.isTrackerPinned(tracker) == true {
                        self?.unpinTracker(tracker)
                    } else {
                        self?.pinTracker(tracker)
                    }
                }
            
            let editAction = UIAction(
                title: "Редактировать",
                image: nil,
                identifier: nil,
                discoverabilityTitle: nil,
                state: .off) { [weak self] action in
                    guard let self = self else { return }

                    let trackerToEdit = self.visibleCategories[indexPath.section].trackers[indexPath.item]
                    let daysCount = self.countDays(for: trackerToEdit.id)

                    let editController = TrackerCreationViewController()
                    editController.mode = .edit(trackerToEdit)
                    editController.hidesBottomBarWhenPushed = true
                    editController.filledDaysCount = daysCount
                    editController.delegate = self
                    editController.trackerStore = self.trackerStore
                    AnalyticsService().report(event: "click", params: ["screen": "Main", "item": "redaktirovat"])
                    self.navigationController?.present(editController, animated: true)
        

                }

            let deleteAction = UIAction(
                        title: "Удалить",
                        image: nil,
                        identifier: nil,
                        discoverabilityTitle: nil,
                        attributes: .destructive,
                        state: .off) { [weak self] action in
                            guard let self = self else { return }
                            let trackerToDelete = self.visibleCategories[indexPath.section].trackers[indexPath.item]
                            self.showDeletionAlert(for: trackerToDelete, at: indexPath)
                    
                }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    func showDeletionAlert(for tracker: Tracker, at indexPath: IndexPath) {
            let alertController = UIAlertController(
                title: nil,
                message: "Уверены, что хотите удалить этот трекер?",
                preferredStyle: .actionSheet
            )

            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                self.trackerStore?.deleteTracker(tracker)
                self.loadTrackers()
                self.updateCategories()
                self.filterVisibleCategories()
                self.collectionView.reloadData()
                self.updateEmptyTrackersVisibility()

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                AnalyticsService().report(event: "click", params: ["screen": "Main", "item": "delete"])
            }

            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)

            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            DispatchQueue.main.async {
                self.present(alertController, animated: true)
            }
        }
    }



extension TrackersViewController {
    func pinTracker(_ tracker: Tracker) {
        if let originalCategoryIndex = categories.firstIndex(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
             trackerCategoryMap[tracker.id] = originalCategoryIndex
         }

        categories = categories.map { category in
            let updatedTrackers = category.trackers.filter { $0.id != tracker.id }
            return TrackerCategory(title: category.title, trackers: updatedTrackers)
        }

        let updatedPinnedTrackers = pinnedCategory.trackers + [tracker]
        pinnedCategory = TrackerCategory(title: pinnedCategory.title, trackers: updatedPinnedTrackers)

        updateVisibleCategories()
        collectionView.reloadData()
    }

    func unpinTracker(_ tracker: Tracker) {

        let updatedPinnedTrackers = pinnedCategory.trackers.filter { $0.id != tracker.id }
        pinnedCategory = TrackerCategory(title: pinnedCategory.title, trackers: updatedPinnedTrackers)

        if let originalCategoryIndex = trackerCategoryMap[tracker.id], originalCategoryIndex < categories.count {
                var originalCategory = categories[originalCategoryIndex]
                if !originalCategory.trackers.contains(where: { $0.id == tracker.id }) {
                    var updatedTrackers = originalCategory.trackers
                    updatedTrackers.append(tracker)
                    categories[originalCategoryIndex] = TrackerCategory(title: originalCategory.title, trackers: updatedTrackers)
                }
            } else {
        }

        updateVisibleCategories()
        collectionView.reloadData()
    }

}


extension TrackersViewController {
    func isTrackerPinned(_ tracker: Tracker) -> Bool {
        return pinnedCategory.trackers.contains(where: { $0.id == tracker.id })
    }
}


extension TrackersViewController {

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }

        cell.layoutIfNeeded() 

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        let preview = UITargetedPreview(view: cell.trackerView, parameters: parameters)
        return preview
    }


}
