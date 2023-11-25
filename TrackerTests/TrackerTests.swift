import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewController() {
        let vc = TrackersViewController()
        vc.view.frame = UIScreen.main.bounds

        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        

        assertSnapshot(matching: vc, as: .image)
    }
}

