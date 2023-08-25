import UIKit

class TrackerTypeSelectionViewController: UIViewController {
    
    let habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let irregularEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Создание трекера"
        
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        
        // Layout
        NSLayoutConstraint.activate([
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            habitButton.widthAnchor.constraint(equalToConstant: 335),
            habitButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 20),
            irregularEventButton.widthAnchor.constraint(equalToConstant: 335),
            irregularEventButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        // Targets
        habitButton.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventTapped), for: .touchUpInside)
    }
    
    @objc func habitTapped() {
        // Переход на экран создания привычки
    }
    
    @objc func irregularEventTapped() {
        // Переход на экран создания нерегулярного события
    }
}

