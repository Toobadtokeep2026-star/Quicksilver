import XCTest
@testable import Quicksilver

final class ConfigurationTests: XCTestCase {
    func testSharedConfigurationDefaults() {
        let config = AppConfiguration.shared
        XCTAssertEqual(config.appName, "Quicksilver")
        XCTAssertFalse(config.version.isEmpty)
        XCTAssertEqual(config.minimumOSVersion, "17.0")
    }

    func testFullVersionString() {
        let config = AppConfiguration(version: "0.1.0", build: "day1")
        XCTAssertEqual(config.fullVersionString, "0.1.0-day1")
    }
}
