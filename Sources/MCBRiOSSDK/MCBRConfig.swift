import Foundation

/// Configuration for the MCBR SDK.
public struct MCBRConfig {
    public let partnerId: String
    public let apiKey: String
    public let environment: MCBREnvironment

    public init(partnerId: String, apiKey: String, environment: MCBREnvironment = .production) {
        self.partnerId = partnerId
        self.apiKey = apiKey
        self.environment = environment
    }
}

public enum MCBREnvironment: String {
    case production
    case development

    var apiBaseURL: String {
        switch self {
        case .production:
            return "https://api.morecashback.app"
        case .development:
            return "https://api.dev.morecashback.app"
        }
    }

    var sdkBaseURL: String {
        switch self {
        case .production:
            return "https://sdk.morecashback.app"
        case .development:
            return "https://sdk.dev.morecashback.app"
        }
    }
}
