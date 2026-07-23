import Foundation

/// Application-wide configuration.
/// Day One: Static values. Future: load from UserDefaults, remote config, or encrypted storage.
struct AppConfiguration: Sendable {
    static let shared = AppConfiguration()

    let appName: String
    let version: String
    let build: String
    let minimumOSVersion: String
    let privacyPolicyURL: URL?
    let supportEmail: String

    init(
        appName: String = "Quicksilver",
        version: String = "0.1.0",
        build: String = "day1",
        minimumOSVersion: String = "17.0",
        privacyPolicyURL: URL? = nil,
        supportEmail: String = "support@quicksilver.local"
    ) {
        self.appName = appName
        self.version = version
        self.build = build
        self.minimumOSVersion = minimumOSVersion
        self.privacyPolicyURL = privacyPolicyURL
        self.supportEmail = supportEmail
    }

    var fullVersionString: String {
        "\(version)-\(build)"
    }
}
