import SwiftUI
import WebKit

struct FlameWebViewContainer: UIViewRepresentable {
    let url: URL
    @ObservedObject var themeController = BlazingThemeController.shared
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Apply flame theme styling
        webView.backgroundColor = UIColor(themeController.currentTheme.primaryColor)
        webView.scrollView.backgroundColor = UIColor(themeController.currentTheme.primaryColor)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        // Update theme colors
        webView.backgroundColor = UIColor(themeController.currentTheme.primaryColor)
        webView.scrollView.backgroundColor = UIColor(themeController.currentTheme.primaryColor)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: FlameWebViewContainer
        
        init(_ parent: FlameWebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            InfernoAnalyticsManager.shared.trackEvent("webview_navigation_start", parameters: [
                "url": webView.url?.absoluteString ?? "unknown"
            ])
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            InfernoAnalyticsManager.shared.trackEvent("webview_navigation_complete", parameters: [
                "url": webView.url?.absoluteString ?? "unknown"
            ])
            
            // Inject flame theme CSS
            let css = """
                body {
                    background: linear-gradient(135deg, #FF4500, #DC143C, #8B0000) !important;
                    color: white !important;
                }
            """
            
            let script = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            InfernoAnalyticsManager.shared.trackError(error, context: "webview_navigation")
            InfernoHapticManager.shared.errorFeedback()
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                // Validate URL through security vault
                if FlameSecurityVault.shared.validateGameEndpoint(url.absoluteString) {
                    decisionHandler(.allow)
                } else {
                    InfernoAnalyticsManager.shared.trackEvent("blocked_navigation", parameters: [
                        "blocked_url": url.absoluteString
                    ])
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}
