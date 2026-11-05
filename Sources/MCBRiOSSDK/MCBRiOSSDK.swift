/// MoreCashBack Rewards iOS SDK
///
/// Integrate cashback rewards into your iOS app with a single view:
///
/// ```swift
/// import MCBRiOSSDK
///
/// let config = MCBRConfig(
///     partnerId: "yourbank",
///     apiKey: "your-api-key"
/// )
///
/// MCBRRewardsView(config: config)
///     .onAuthenticated { user in
///         print("User signed in: \(user.email)")
///     }
///     .onRewardSelected { reward in
///         print("Selected: \(reward.merchantName)")
///     }
/// ```
public enum MCBRiOSSDK {
    public static let version = "1.0.0"
}
