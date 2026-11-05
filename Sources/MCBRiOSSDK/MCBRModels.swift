import Foundation

public struct MCBRUser {
    public let email: String
    public let name: String
}

public struct MCBRReward {
    public let id: String
    public let merchantName: String
    public let cashbackLabel: String
    public let category: String
}

public enum MCBRError: Error, LocalizedError {
    case sdkError(String)
    case networkError(String)
    case authenticationFailed

    public var errorDescription: String? {
        switch self {
        case .sdkError(let message): return message
        case .networkError(let message): return message
        case .authenticationFailed: return "Authentication failed"
        }
    }
}
