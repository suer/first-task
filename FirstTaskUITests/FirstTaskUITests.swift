//
//  FirstTaskUITests.swift
//  FirstTaskUITests
//

import Testing
import XCUIAutomation

@MainActor
struct FirstTaskUITests {
    @Test
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use #expect and related functions to verify your tests produce the correct results.
    }
}
