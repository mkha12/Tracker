import UIKit

struct Statistic {
    let title: String
    let value: String
}
final class StatisticsViewModel {
    
    private let trackerStore: TrackerStoreProtocol
    private let trackerRecordStore: TrackerRecordStore
    var onStatisticsUpdated: (() -> Void)?
    var statistics: [Statistic] = []
    
    
    init(trackerStore: TrackerStoreProtocol, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        
    }
    
    func loadStatistics() {
        let allTrackers = trackerStore.fetchAllTrackers()
        let allTrackerRecords = trackerRecordStore.fetchAllRecords()
        
        let longestStreak = calculateLongestStreak(trackerRecords: allTrackerRecords, trackers: allTrackers)
        let perfectDays = countPerfectDays(trackerRecords: allTrackerRecords, trackers: allTrackers)
        let completedTrackers = countCompletedTrackers(trackerRecords: allTrackerRecords)
        let averageCompletion = calculateAverageCompletionDays(trackerRecords: allTrackerRecords, trackers: allTrackers)
        
        statistics = [
            Statistic(title: "Лучший период", value: "\(longestStreak)"),
            Statistic(title: "Идеальные дни", value: "\(perfectDays)"),
            Statistic(title: "Трекеров завершено", value: "\(completedTrackers)"),
            Statistic(title: "Среднее значение", value: "\(averageCompletion)")
        ]
        onStatisticsUpdated?()
    }
    
    private func calculateLongestStreak(trackerRecords: [TrackerRecord], trackers: [Tracker]) -> Int {
        var longestStreak = 0
        
        for tracker in trackers {
            var currentStreak = 0
            var maxStreak = 0
            var lastDate: Date?
            
            let sortedRecords = trackerRecords.filter { $0.trackerId == tracker.id }.sorted(by: { $0.date < $1.date })
            for record in sortedRecords {
                if let lastDate = lastDate {
                    let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastDate)!
                    if record.date >= nextDay {
                        currentStreak += 1
                    } else {
                        currentStreak = 1
                    }
                } else {
                    currentStreak = 1
                }
                lastDate = record.date
                maxStreak = max(maxStreak, currentStreak)
            }
            
            longestStreak = max(longestStreak, maxStreak)
        }
        onStatisticsUpdated?()
        return longestStreak
    }
    
    private func countPerfectDays(trackerRecords: [TrackerRecord], trackers: [Tracker]) -> Int {
        let groupedRecords = Dictionary(grouping: trackerRecords, by: { $0.date.startOfDay })
        var perfectDaysCount = 0
        
        for (date, records) in groupedRecords {
            let completedTrackers = Set(records.map { $0.trackerId })
            let activeTrackers = trackers.filter { tracker in
                if let schedule = tracker.schedule {
                    return schedule[date.weekday] ?? false
                } else {
                    return !records.contains(where: { $0.trackerId == tracker.id && $0.date < date })
                }
            }
            
            let allActiveTrackersCompleted = activeTrackers.allSatisfy { tracker in
                completedTrackers.contains(tracker.id)
            }
            
            if allActiveTrackersCompleted {
                perfectDaysCount += 1
            }
        }
        
        return perfectDaysCount
    }
    
    private func countCompletedTrackers(trackerRecords: [TrackerRecord]) -> Int {
        return Set(trackerRecords.map { $0.trackerId }).count
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
        onStatisticsUpdated?()
        return totalTrackers > 0 ? totalDays / totalTrackers : 0
    }
}

extension StatisticsViewModel: TrackerStoreDelegate, TrackerRecordStoreDelegate {
    func didChangeTrackerData() {
        loadStatistics()
        onStatisticsUpdated?()
    }
    
    func didChangeTrackers(trackers: [Tracker]) {
        loadStatistics()
        onStatisticsUpdated?()
    }
    
    func didChangeRecords(records: [TrackerRecord]) {
        loadStatistics()
        onStatisticsUpdated?()
    }
    
}
