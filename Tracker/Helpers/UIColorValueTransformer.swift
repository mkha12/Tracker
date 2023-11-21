import UIKit

final class UIColorValueTransformer: NSSecureUnarchiveFromDataTransformer {

    override static var allowedTopLevelClasses: [AnyClass] {
        return [UIColor.self]
    }

    public static func register() {
        let transformer = UIColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: "UIColorValueTransformer"))
    }
}
