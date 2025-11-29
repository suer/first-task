import Foundation
import Testing

@testable import FirstTask

struct DateExtensionTests {

    func setupTestDate() -> (Calendar, Date) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: 2023, month: 1, day: 1, hour: 12, minute: 30, second: 45)
        let date = calendar.date(from: components)!
        return (calendar, date)
    }

    @Test
    func testStartOfDay() {
        let (calendar, date) = setupTestDate()
        let startOfDay = date.startOfDay(with: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startOfDay)
        #expect(components.year == 2023)
        #expect(components.month == 1)
        #expect(components.day == 1)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Test
    func testEndOfDay() {
        let (calendar, date) = setupTestDate()
        let endOfDay = date.endOfDay(with: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: endOfDay)
        #expect(components.year == 2023)
        #expect(components.month == 1)
        #expect(components.day == 1)
        #expect(components.hour == 23)
        #expect(components.minute == 59)
        #expect(components.second == 59)
    }

    @Test
    func testStartOfNextDay() {
        let (calendar, date) = setupTestDate()
        let startOfNextDay = date.startOfNextDay(with: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startOfNextDay)
        #expect(components.year == 2023)
        #expect(components.month == 1)
        #expect(components.day == 2)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }
}
