import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDataSource {
    // Элементы UI, которые нам понадобятся
    var datePicker: UIDatePicker!
    var searchBar: UISearchTextField!
    var collectionView: UICollectionView!
    var emptyTrackersImageView: UIImageView!
    var emptyTrackersLabel: UILabel!
    var emptyTrackersStackView: UIStackView!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
        updateEmptyTrackersVisibility()
    }

    private func setupUI() {
        // Заголовок и NavBarItem
        self.navigationItem.title = "Трекеры"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTracker))

        // UIDatePicker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    


        // UISearchTextField
        searchBar = UISearchTextField()
        searchBar.delegate = self
        searchBar.placeholder = "Поиск трекеров"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        // UICollectionView
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        // UIImageView для заглушки
        emptyTrackersImageView = UIImageView(image: UIImage(named: "zaglishka"))
        emptyTrackersImageView.contentMode = .scaleAspectFit

        // UILabel для надписи
        emptyTrackersLabel = UILabel()
        emptyTrackersLabel.text = "Что будем отслеживать?"
        emptyTrackersLabel.textColor = .blackDay
        emptyTrackersLabel.textAlignment = .center

        // UIStackView для вертикального размещения картинки и текста
        emptyTrackersStackView = UIStackView(arrangedSubviews: [emptyTrackersImageView, emptyTrackersLabel])
        emptyTrackersStackView.axis = .vertical
        emptyTrackersStackView.spacing = 10
        emptyTrackersStackView.translatesAutoresizingMaskIntoConstraints = false
        emptyTrackersStackView.isHidden = true // Сначала скрываем заглушку
        view.addSubview(emptyTrackersStackView)


        // Настройка AutoLayout
        setupConstraints()
    }

    private func setupConstraints() {
        // Задайте здесь AutoLayout для searchBar и collectionView
        // Например:
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyTrackersStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyTrackersStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)


        ])
    }

    @objc func addNewTracker() {
        let typeSelectionVC = TrackerTypeSelectionViewController()
        typeSelectionVC.modalPresentationStyle = .automatic
        present(typeSelectionVC, animated: true)
    }


    @objc func dateChanged() {
        // Здесь будет ваша логика для изменения даты
    }
    
    func updateEmptyTrackersVisibility() {
        let areTrackersAvailable = false  // временно установлено в false для демонстрации заглушки
        emptyTrackersStackView.isHidden = areTrackersAvailable
    }

}

extension TrackersViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0 // Верните число трекеров, которые вы хотите показать
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) // Идентификатор "TrackerCell" нужно зарегистрировать заранее
        // Настройте ячейку здесь
        return cell
    }
}

extension TrackersViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // Обновите список трекеров на основе введенного текста
    }
}
