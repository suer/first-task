import XCTest
@testable import FirstTask

class DateExtensionTests: XCTestCase {

    var calendar: Calendar!
    var date: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: 2023, month: 1, day: 1, hour: 12, minute: 30, second: 45)
        date = calendar.date(from: components)!
    }

    func testStartOfDay() {
        let startOfDay = date.startOfDay(with: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(components.year, 2023)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testEndOfDay() {
        let endOfDay = date.endOfDay(with: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: endOfDay)
        XCTAssertEqual(components.year, 2023)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.hour, 23)
        XCTAssertEqual(components.minute, 59)
        XCTAssertEqual(components.second, 59)
    }

    func testStartOfNextDay() {
        let startOfNextDay = date.startOfNextDay(with: calendar)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startOfNextDay)
        XCTAssertEqual(components.year, 2023)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 2)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
}
