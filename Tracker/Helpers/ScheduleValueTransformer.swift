import Foundation

@objc(ScheduleValueTransformer)
class ScheduleValueTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? [WeekDay: Bool] else { return nil }
        let intBasedSchedule = value.mapKeys { $0.toInt() }
        return try? NSKeyedArchiver.archivedData(withRootObject: intBasedSchedule, requiringSecureCoding: false)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data,
              let intBasedSchedule = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Int: Bool] else { return nil }
        return intBasedSchedule.mapKeys { WeekDay.fromInt($0) }
    }
    
    public static func register() {
           let transformer = ScheduleValueTransformer()
           ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: "ScheduleValueTransformer"))
       }

}
