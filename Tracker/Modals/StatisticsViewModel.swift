import UIKit

struct Statistic {
    let title: String
    let value: String
}
final class StatisticsViewModel {
   

    var statistics: [Statistic] = []
    private let trackerStore: TrackerStoreProtocol
    private let trackerRecordStore: TrackerRecordStore

    init(trackerStore: TrackerStoreProtocol, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        
    }

    func loadStatistics() {
        let allTrackers = trackerStore.fetchAllTrackers()
        let allTrackerRecords = trackerRecordStore.fetchAllRecords()

        let longestStreak = calculateLongestStreak(trackerRecords: allTrackerRecords, trackers: allTrackers)
        let perfectDays = countPerfectDays(trackerRecords: allTrackerRecords, trackers: allTrackers)
        let completedIrregularTrackers = countCompletedIrregularTrackers(trackerRecords: allTrackerRecords, trackers: allTrackers)
        let averageCompletion = calculateAverageCompletionDays(trackerRecords: allTrackerRecords, trackers: allTrackers)

        statistics = [
            Statistic(title: "Лучший период", value: "\(longestStreak) дней"),
            Statistic(title: "Идеальные дни", value: "\(perfectDays) дней"),
            Statistic(title: "Трекеров завершено", value: "\(completedIrregularTrackers) трекеров"),
            Statistic(title: "Среднее значение", value: "\(averageCompletion) дней")
        ]
    }

    private func calculateLongestStreak(trackerRecords: [TrackerRecord], trackers: [Tracker]) -> Int {
        var longestStreak = 0

        for tracker in trackers {
            var currentStreak = 0
            var maxStreak = 0
            var lastDate: Date?

            for record in trackerRecords.filter({ $0.trackerId == tracker.id }).sorted(by: { $0.date < $1.date }) {
                if let lastDate = lastDate, Calendar.current.isDate(record.date, inSameDayAs: lastDate) {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
                maxStreak = max(maxStreak, currentStreak)
                lastDate = record.date
            }

            longestStreak = max(longestStreak, maxStreak)
        }

        return longestStreak
    }


    private func countPerfectDays(trackerRecords: [TrackerRecord], trackers: [Tracker]) -> Int {
        let groupedRecords = Dictionary(grouping: trackerRecords, by: { $0.date.startOfDay })
        var perfectDaysCount = 0

        for (date, records) in groupedRecords {
            let completedTrackers = Set(records.map { $0.trackerId })
            let allTrackersCompleted = trackers.allSatisfy { tracker in completedTrackers.contains(tracker.id) }
            if allTrackersCompleted {
                perfectDaysCount += 1
            }
        }

        return perfectDaysCount
    }

    private func countCompletedIrregularTrackers(trackerRecords: [TrackerRecord], trackers: [Tracker]) -> Int {
            let irregularTrackers = trackers.filter { $0.schedule == nil }
            let irregularTrackerIds = Set(irregularTrackers.map { $0.id })
            return trackerRecords.filter { irregularTrackerIds.contains($0.trackerId) }.count
        }

    private func calculateAverageCompletionDays(trackerRecords: [TrackerRecord], trackers: [Tracker]) -> Int {
        var totalDays = 0
        var totalTrackers = 0

        for tracker in trackers {
            let records = trackerRecords.filter { $0.trackerId == tracker.id }
            let uniqueDays = Set(records.map { $0.date.startOfDay })
            totalDays += uniqueDays.count
            totalTrackers += 1
        }

        return totalTrackers > 0 ? totalDays / totalTrackers : 0
    }

}

