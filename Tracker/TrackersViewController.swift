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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
        updateEmptyTrackersVisibility()
        filterVisibleCategories()
    }
    
    private func setupUI() {
        
        self.navigationItem.title = "Трекеры"
        
        let addImage = UIImage(named: "Plus")?.withRenderingMode(.alwaysOriginal)
        let addButton = UIBarButtonItem(image: addImage, style: .plain, target: self, action: #selector(presentAddNewTrackerScreen))
        navigationItem.leftBarButtonItem = addButton

        navigationController?.navigationBar.prefersLargeTitles = true

        
        datePicker = UIDatePicker()
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
        emptyTrackersLabel.font = UIFont.systemFont(ofSize: 12)
        emptyTrackersLabel.textAlignment = .center

        emptyTrackersStackView = UIStackView(arrangedSubviews: [emptyTrackersImageView, emptyTrackersLabel])
        emptyTrackersStackView.axis = .vertical
        emptyTrackersStackView.spacing = 10
        emptyTrackersStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackersStackView.isHidden = true
        view.addSubview(emptyTrackersStackView)
        
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategoryHeader")
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        
        
        setupConstraints()
        
        
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            emptyTrackersStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyTrackersStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
            
        ])
    }
    
    
    func addNewTracker(_ tracker: Tracker, toCategory categoryName: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryName }) {
            categories[index].trackers.append(tracker)
        } else {
            let newCategory = TrackerCategory(title: categoryName, trackers: [tracker])
            categories.append(newCategory)
        }
        
        visibleCategories = categories
        
        updateVisibleCategories()
        updateEmptyTrackersVisibility()
        collectionView.reloadData()
    }
    
    func didCreateTracker(tracker: Tracker) {
        addNewTracker(tracker, toCategory: "Общая")
        collectionView.reloadData()
    }
    
    
    @objc func presentAddNewTrackerScreen() {
        let trackerTypeSelectionVC = TrackerTypeSelectionViewController()
        trackerTypeSelectionVC.delegate = self 
        let navigationController = UINavigationController(rootViewController: trackerTypeSelectionVC)
        present(navigationController, animated: true)
    }
    
    
    func updateVisibleCategories() {
        let areTrackersAvailable = !visibleCategories.isEmpty
        emptyTrackersStackView.isHidden = areTrackersAvailable
    }
    
    @objc func dateChanged() {
        currentDate = datePicker.date
        
        if currentDate > Date() {
            let alert = UIAlertController(title: "Ошибка", message: "Невозможно выбрать будущую дату.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            datePicker.setDate(currentDate, animated: true)
            return
        }
        
        filterVisibleCategories()
        collectionView.reloadData()
    }

    private func filterVisibleCategories() {
        guard let query = searchBar.text else {
            visibleCategories = categories
            collectionView.reloadData()
            return
        }

        let activeTrackersOnSelectedDate = trackerRecords.filter {
            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }.map { $0.trackerId }

        visibleCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter {
                $0.name.lowercased().contains(query.lowercased()) && activeTrackersOnSelectedDate.contains($0.id)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }

        collectionView.reloadData()
    }

    
    func updateEmptyTrackersVisibility() {
        emptyTrackersStackView.isHidden = !visibleCategories.isEmpty
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

        cell.configure(with: tracker)

        cell.addButtonTapped = { [weak self] in
            self?.handleAddButtonTap(for: tracker)
        }

        return cell
    }
    
    private func handleAddButtonTap(for tracker: Tracker) {
        if completedTrackers.contains(tracker.id) {
            completedTrackers.remove(tracker.id)
            trackerRecords.removeAll { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        } else {
            completedTrackers.insert(tracker.id)
            let record = TrackerRecord(trackerId: tracker.id, date: currentDate)
            trackerRecords.append(record)
        }
        collectionView.reloadData()
    }

    func countDays(for trackerId: UUID) -> Int {
        return trackerRecords.filter { $0.trackerId == trackerId }.count
    }

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CategoryHeader", for: indexPath)
            let titleLabel = UILabel(frame: header.bounds)
            titleLabel.text = visibleCategories[indexPath.section].title
            header.addSubview(titleLabel)  // Добавляем лейбл на header
            
            return header
            
        default:
            assert(false, "Invalid element type")
        }
    } }


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



