import UIKit

final class TrackerTypeSelectionViewController: UIViewController, CreateTrackerDelegate {
    
    var trackerCreationViewController: TrackerCreationViewController?
    var delegate: CreateTrackerDelegate?
    var trackerStore: TrackerStoreProtocol?
    
    
    let habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let irregularEventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    
    func setupUI() {
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        
        
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 281),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
        
        habitButton.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventTapped), for: .touchUpInside)
    }
    
    func didCreateTracker(tracker: Tracker, categoryName: String) {
        delegate?.didCreateTracker(tracker: tracker, categoryName: categoryName)
    
        
    }
    
    @objc func habitTapped() {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.delegate = self
        trackerCreationVC.isHabit = true
        trackerCreationVC.trackerStore = self.trackerStore
        trackerCreationVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(trackerCreationVC, animated: true)
    }
    
    @objc func irregularEventTapped() {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.delegate = self
        trackerCreationVC.isHabit = false
        trackerCreationVC.trackerStore = self.trackerStore
        trackerCreationVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(trackerCreationVC, animated: true)
    }
    
}
