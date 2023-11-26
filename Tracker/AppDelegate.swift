
import UIKit
import YandexMobileMetrica

@main

final class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate {
            return UIApplication.shared.delegate as! AppDelegate
        
        }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIColorValueTransformer.register()
            ScheduleValueTransformer.register()
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "76126919-6bda-4a1e-a47d-7a69744e45eb") else {
            return true
        }
            
        YMMYandexMetrica.activate(with: configuration)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }

}

