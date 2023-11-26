import UIKit

final class StatisticsViewController: UIViewController, UITableViewDataSource {
    
    var emptyStateImageView: UIImageView!
    var emptyStateLabel: UILabel!
    var emptyStatStackView: UIStackView!
    private var viewModel: StatisticsViewModel!
    private var tableView: UITableView!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let trackerStore = TrackerStore(context: CoreDataManager.shared.persistentContainer.viewContext, categoryStore: TrackerCategoryStore(context: CoreDataManager.shared.persistentContainer.viewContext))
                let trackerRecordStore = TrackerRecordStore(context: CoreDataManager.shared.persistentContainer.viewContext)

                viewModel = StatisticsViewModel(trackerStore: trackerStore, trackerRecordStore: trackerRecordStore)

        setupUI()
        setupConstraints()
        viewModel.loadStatistics()
        updateEmptyStateVisibility()
        tableView.reloadData()
    }
    
    private func setupUI() {
        self.navigationItem.title = NSLocalizedString("title_statistics", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView = UITableView()
        tableView.dataSource = self
        tableView.register(StatisticTableViewCell.self, forCellReuseIdentifier: "StatisticCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
            
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
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                
    
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return viewModel.statistics.count
       }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell", for: indexPath) as! StatisticTableViewCell
        let statistic = viewModel.statistics[indexPath.row]
        cell.configure(with: statistic)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

   }
