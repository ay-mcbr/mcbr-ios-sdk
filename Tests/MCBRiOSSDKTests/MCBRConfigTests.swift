import XCTest
@testable import MCBRiOSSDK

final class MCBRConfigTests: XCTestCase {
    func testDefaultEnvironmentIsProduction() {
        let config = MCBRConfig(partnerId: "test", apiKey: "key")
        XCTAssertEqual(config.environment, .production)
    }

    func testDevelopmentEnvironmentURLs() {
        let config = MCBRConfig(partnerId: "test", apiKey: "key", environment: .development)
        XCTAssertTrue(config.environment.apiBaseURL.contains("dev"))
    }

    func testVersionExists() {
        XCTAssertFalse(MCBRiOSSDK.version.isEmpty)
    }
}
