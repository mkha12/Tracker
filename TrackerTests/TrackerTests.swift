import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewControllerLightMode() {
        let vc = TrackersViewController()
        vc.view.frame = UIScreen.main.bounds
        vc.overrideUserInterfaceStyle = .light

        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        
        assertSnapshot(matching: vc, as: .image)
    }

    func testViewControllerDarkMode() {
        let vc = TrackersViewController()
        vc.view.frame = UIScreen.main.bounds
        vc.overrideUserInterfaceStyle = .dark

        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        
        assertSnapshot(matching: vc, as: .image)
    }
}

