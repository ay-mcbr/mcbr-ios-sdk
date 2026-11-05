import SwiftUI
import WebKit

/// A SwiftUI view that renders the MCBR cashback rewards experience.
///
/// Wraps the MCBR JavaScript SDK in a WKWebView, providing a native interface
/// for authentication events and reward interactions.
///
/// ```swift
/// MCBRRewardsView(config: config)
///     .onRewardSelected { reward in
///         print("Selected: \(reward.merchantName)")
///     }
/// ```
public struct MCBRRewardsView: UIViewRepresentable {
    let config: MCBRConfig
    var onAuthenticated: ((MCBRUser) -> Void)?
    var onRewardSelected: ((MCBRReward) -> Void)?
    var onError: ((MCBRError) -> Void)?

    public init(config: MCBRConfig) {
        self.config = config
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let contentController = configuration.userContentController

        contentController.add(context.coordinator, name: "mcbrBridge")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false

        loadSDK(in: webView)
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onAuthenticated: onAuthenticated,
            onRewardSelected: onRewardSelected,
            onError: onError
        )
    }

    private func loadSDK(in webView: WKWebView) {
        let sdkURL = config.environment.sdkBaseURL
        let apiURL = config.environment.apiBaseURL

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; }
                #mcbr-root { width: 100vw; min-height: 100vh; }
            </style>
        </head>
        <body>
            <div id="mcbr-root"></div>
            <script src="\(sdkURL)/mcbr-sdk.min.js"></script>
            <script>
                var client = new MCBR.Client({
                    partnerId: '\(config.partnerId)',
                    apiKey: '\(config.apiKey)',
                    apiUrl: '\(apiURL)',
                    container: '#mcbr-root'
                });

                client.on('auth:success', function(user) {
                    window.webkit.messageHandlers.mcbrBridge.postMessage({
                        type: 'auth:success',
                        payload: user
                    });
                });

                client.on('reward:selected', function(reward) {
                    window.webkit.messageHandlers.mcbrBridge.postMessage({
                        type: 'reward:selected',
                        payload: reward
                    });
                });

                client.on('error', function(err) {
                    window.webkit.messageHandlers.mcbrBridge.postMessage({
                        type: 'error',
                        payload: { message: err.message || 'Unknown error' }
                    });
                });

                client.render();
            </script>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: URL(string: sdkURL))
    }

    // MARK: - Modifiers

    public func onAuthenticated(_ handler: @escaping (MCBRUser) -> Void) -> MCBRRewardsView {
        var view = self
        view.onAuthenticated = handler
        return view
    }

    public func onRewardSelected(_ handler: @escaping (MCBRReward) -> Void) -> MCBRRewardsView {
        var view = self
        view.onRewardSelected = handler
        return view
    }

    public func onError(_ handler: @escaping (MCBRError) -> Void) -> MCBRRewardsView {
        var view = self
        view.onError = handler
        return view
    }
}

// MARK: - Coordinator

extension MCBRRewardsView {
    public class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onAuthenticated: ((MCBRUser) -> Void)?
        var onRewardSelected: ((MCBRReward) -> Void)?
        var onError: ((MCBRError) -> Void)?

        init(
            onAuthenticated: ((MCBRUser) -> Void)?,
            onRewardSelected: ((MCBRReward) -> Void)?,
            onError: ((MCBRError) -> Void)?
        ) {
            self.onAuthenticated = onAuthenticated
            self.onRewardSelected = onRewardSelected
            self.onError = onError
        }

        public func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let body = message.body as? [String: Any],
                  let type = body["type"] as? String,
                  let payload = body["payload"] as? [String: Any] else { return }

            switch type {
            case "auth:success":
                let user = MCBRUser(
                    email: payload["email"] as? String ?? "",
                    name: payload["name"] as? String ?? ""
                )
                onAuthenticated?(user)

            case "reward:selected":
                let reward = MCBRReward(
                    id: payload["id"] as? String ?? "",
                    merchantName: payload["name"] as? String ?? "",
                    cashbackLabel: payload["cashback_label"] as? String ?? "",
                    category: payload["category"] as? String ?? ""
                )
                onRewardSelected?(reward)

            case "error":
                let error = MCBRError.sdkError(payload["message"] as? String ?? "Unknown error")
                onError?(error)

            default:
                break
            }
        }
    }
}
