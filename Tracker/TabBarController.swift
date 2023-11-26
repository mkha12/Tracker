import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersVC = TrackersViewController()
        trackersVC.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar_trackers", comment: ""), image: UIImage(named: "trackerIcon"), selectedImage: nil)
        let trackersNavController = UINavigationController(rootViewController: trackersVC)

        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar_stat", comment: ""), image: UIImage(named: "statisticsIcon"), selectedImage: nil)
        let statisticsNavController = UINavigationController(rootViewController: statisticsVC)

        viewControllers = [trackersNavController, statisticsNavController]
    }
}

