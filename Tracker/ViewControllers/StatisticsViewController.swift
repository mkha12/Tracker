import UIKit

final class StatisticsViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    var emptyStateImageView: UIImageView!
    var emptyStateLabel: UILabel!
    var emptyStatStackView: UIStackView!
    private var viewModel: StatisticsViewModel!
    private var tableView: UITableView!
    private var titleLabel: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    
        
        tableView = UITableView()
        tableView.register(StatisticTableViewCell.self, forCellReuseIdentifier: "StatisticCell")
        
        setupUI()
        
        let trackerStore = TrackerStore(context: CoreDataManager.shared.persistentContainer.viewContext, categoryStore: TrackerCategoryStore(context: CoreDataManager.shared.persistentContainer.viewContext))
        let trackerRecordStore = TrackerRecordStore(context: CoreDataManager.shared.persistentContainer.viewContext)
        
        viewModel = StatisticsViewModel(trackerStore: trackerStore, trackerRecordStore: trackerRecordStore)
        
        trackerStore.delegate = viewModel
        trackerRecordStore.delegate = viewModel
        
        viewModel.onStatisticsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        tableView.delegate = self
        setupConstraints()
        viewModel.loadStatistics()
        updateEmptyStateVisibility()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    
    private func setupUI() {
        

        titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = NSLocalizedString("title_statistics", comment: "")
            titleLabel.textColor = .black
            titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
            //titleLabel.textAlignment = .center
            view.addSubview(titleLabel)

        
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        
        
        
        emptyStateImageView = UIImageView()
        emptyStateImageView = UIImageView(image: UIImage(named: "nothig to load"))
        emptyStateImageView.contentMode = .scaleAspectFit
        
        
        emptyStateLabel = UILabel()
        emptyStateLabel.text = NSLocalizedString("empty_stat_message", comment: "")
        emptyStateLabel.textColor = .black
        emptyStateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyStateLabel.textAlignment = .center
        
        emptyStatStackView = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateLabel])
        emptyStatStackView.axis = .vertical
        emptyStatStackView.spacing = 10
        emptyStatStackView.translatesAutoresizingMaskIntoConstraints = false
        //emptyStatStackView.isHidden = true
        view.addSubview(emptyStatStackView)
        
        
    }
    
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            emptyStatStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStatStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
                    titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                    
                    // Установка tableView ниже titleLabel
                    tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16), // Отступ от titleLabel
                    tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16), // Отступ слева
                    tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16), // Отступ справа
                    tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), // Прижимаем к нижней части safe area
        ])
    }
    

    
    private func updateEmptyStateVisibility() {
        if viewModel.statistics.isEmpty {
            emptyStatStackView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStatStackView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        cell.textLabel?.text = viewModel?.statistics[indexPath.row].title
        
        cell.backgroundColor = UIColor.background
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.statistics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell", for: indexPath) as! StatisticTableViewCell
        let statistic = viewModel.statistics[indexPath.section]
        cell.configure(with: statistic)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section < viewModel.statistics.count - 1 ? 12 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}
