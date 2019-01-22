import XCTest
@testable import Apicalypse

final class ApicalypseTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Apicalypse().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
