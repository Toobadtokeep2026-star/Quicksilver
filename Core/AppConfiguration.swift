import Foundation

/// Application-wide configuration.
/// Static values today. Future: load from UserDefaults, remote config, or encrypted storage.
public struct AppConfiguration: Sendable {
    public static let shared = AppConfiguration()

    public let appName: String
    public let version: String
    public let build: String
    public let minimumOSVersion: String
    public let privacyPolicyURL: URL?
    public let supportEmail: String

    public init(
        appName: String = "Quicksilver",
        version: String = "0.1.0",
        build: String = "2",
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

    public var fullVersionString: String {
        "\(version) (\(build))"
    }
}
