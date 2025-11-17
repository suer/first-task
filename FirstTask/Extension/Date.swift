import Foundation

extension Date {
    var startOfDay: Date {
        startOfDay(with: .current)
    }

    var endOfDay: Date {
        endOfDay(with: .current)
    }

    var startOfNextDay: Date {
        startOfNextDay(with: .current)
    }

    func startOfDay(with calendar: Calendar) -> Date {
        calendar.startOfDay(for: self)
    }

    func endOfDay(with calendar: Calendar) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfDay(with: calendar))!
    }

    func startOfNextDay(with calendar: Calendar) -> Date {
        var components = DateComponents()
        components.day = 1
        return calendar.date(byAdding: components, to: startOfDay(with: calendar))!
    }
}
