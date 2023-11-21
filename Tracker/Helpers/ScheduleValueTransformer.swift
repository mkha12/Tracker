import Foundation

final class ScheduleValueTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? [WeekDay: Bool] else { return nil }
        let intBasedSchedule = value.mapKeys { $0.toInt() }
        return try? NSKeyedArchiver.archivedData(withRootObject: intBasedSchedule, requiringSecureCoding: false)
    }

    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }

        do {
            let intBasedSchedule = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: data) as? [Int: Bool]
            return intBasedSchedule?.mapKeys { WeekDay.fromInt($0) }
        } catch {
            print("Couldn't unarchive data: \(error)")
            return nil
        }
    }

    
    public static func register() {
           let transformer = ScheduleValueTransformer()
           ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: "ScheduleValueTransformer"))
       }

}
