import Foundation
#if os(iOS)
import UIKit
#endif

class InfernoAnalyticsManager: ObservableObject {
    static let shared = InfernoAnalyticsManager()
    
    private let analyticsEndpoint = "https://escapeteflanes.com/analytics"
    private let sessionId: String
    private let userDefaults = UserDefaults.standard
    
    @Published var isTrackingEnabled: Bool = true
    
    private let trackingEnabledKey = "InfernoAnalyticsEnabled"
    private let sessionKey = "InfernoSessionData"
    
    private init() {
        self.sessionId = UUID().uuidString
        loadSettings()
        startSession()
    }
    
    func trackEvent(_ eventName: String, parameters: [String: Any] = [:]) {
        guard isTrackingEnabled else { return }
        
        var eventData: [String: Any] = [
            "event": eventName,
            "timestamp": Date().timeIntervalSince1970,
            "session_id": sessionId,
            "app_version": "1.0.0",
            "platform": "iOS"
        ]
        
        // Merge custom parameters
        for (key, value) in parameters {
            eventData[key] = value
        }
        
        // Store locally (in a real app, you'd send to server)
        storeEventLocally(eventData)
    }
    
    func trackFlameIgnition(intensity: Double) {
        trackEvent("flame_ignition", parameters: [
            "intensity": intensity,
            "theme": BlazingThemeController.shared.currentTheme.rawValue
        ])
    }
    
    func trackThemeChange(from oldTheme: String, to newTheme: String) {
        trackEvent("theme_changed", parameters: [
            "old_theme": oldTheme,
            "new_theme": newTheme
        ])
    }
    
    func trackGameAction(_ action: String, success: Bool) {
        trackEvent("game_action", parameters: [
            "action": action,
            "success": success
        ])
    }
    
    func trackPerformanceMetric(name: String, value: Double, unit: String) {
        trackEvent("performance_metric", parameters: [
            "metric_name": name,
            "value": value,
            "unit": unit
        ])
    }
    
    func trackUserPreference(setting: String, value: Any) {
        trackEvent("user_preference", parameters: [
            "setting": setting,
            "value": value
        ])
    }
    
    func trackError(_ error: Error, context: String) {
        trackEvent("error_occurred", parameters: [
            "error_description": error.localizedDescription,
            "context": context,
            "error_code": (error as NSError).code
        ])
    }
    
    func trackScreenView(_ screenName: String) {
        trackEvent("screen_view", parameters: [
            "screen_name": screenName
        ])
    }
    
    private func startSession() {
        #if os(iOS)
        let deviceInfo: [String: Any] = [
            "device_model": UIDevice.current.model,
            "os_version": UIDevice.current.systemVersion
        ]
        #else
        let deviceInfo: [String: Any] = [
            "device_model": "Unknown",
            "os_version": "Unknown"
        ]
        #endif
        
        trackEvent("session_start", parameters: deviceInfo)
    }
    
    func endSession() {
        trackEvent("session_end")
        uploadPendingEvents()
    }
    
    private func storeEventLocally(_ eventData: [String: Any]) {
        var storedEvents = getStoredEvents()
        storedEvents.append(eventData)
        
        // Keep only last 1000 events
        if storedEvents.count > 1000 {
            storedEvents = Array(storedEvents.suffix(1000))
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: storedEvents) {
            userDefaults.set(data, forKey: sessionKey)
        }
    }
    
    private func getStoredEvents() -> [[String: Any]] {
        guard let data = userDefaults.data(forKey: sessionKey),
              let events = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return events
    }
    
    private func uploadPendingEvents() {
        guard isTrackingEnabled else { return }
        
        let events = getStoredEvents()
        guard !events.isEmpty else { return }
        
        // In a real app, you'd send these to your analytics server
        print("Would upload \(events.count) analytics events")
        
        // Clear stored events after successful upload
        userDefaults.removeObject(forKey: sessionKey)
    }
    
    func toggleTracking() {
        isTrackingEnabled.toggle()
        saveSettings()
        
        trackEvent("tracking_toggled", parameters: [
            "enabled": isTrackingEnabled
        ])
    }
    
    func setTrackingEnabled(_ enabled: Bool) {
        isTrackingEnabled = enabled
        saveSettings()
    }
    
    private func loadSettings() {
        isTrackingEnabled = userDefaults.bool(forKey: trackingEnabledKey)
        
        // Default to enabled if no setting exists
        if userDefaults.object(forKey: trackingEnabledKey) == nil {
            isTrackingEnabled = true
        }
    }
    
    private func saveSettings() {
        userDefaults.set(isTrackingEnabled, forKey: trackingEnabledKey)
    }
    
    func getAnalyticsSummary() -> [String: Any] {
        let events = getStoredEvents()
        
        return [
            "total_events": events.count,
            "session_id": sessionId,
            "tracking_enabled": isTrackingEnabled,
            "last_event_time": events.last?["timestamp"] as? TimeInterval ?? 0
        ]
    }
}
