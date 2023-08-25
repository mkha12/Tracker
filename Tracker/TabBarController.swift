import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersVC = TrackersViewController()
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackerIcon"), selectedImage: nil)

        let statisticsVC = UIViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statisticsIcon"), selectedImage: nil)

        viewControllers = [UINavigationController(rootViewController: trackersVC), statisticsVC]
    }

}
