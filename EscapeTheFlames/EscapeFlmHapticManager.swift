import Foundation
import UIKit

class InfernoHapticManager: ObservableObject {
    static let shared = InfernoHapticManager()
    
    @Published var isHapticsEnabled: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let hapticsEnabledKey = "InfernoHapticsEnabled"
    
    private init() {
        loadSettings()
    }
    
    func flameIgnitionFeedback() {
        guard isHapticsEnabled else { return }
        
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        #endif
    }
    
    func emberTouchFeedback() {
        guard isHapticsEnabled else { return }
        
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
    }
    
    func flameIntensityFeedback() {
        guard isHapticsEnabled else { return }
        
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        #endif
    }
    
    func successFeedback() {
        guard isHapticsEnabled else { return }
        
        #if os(iOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        #endif
    }
    
    func errorFeedback() {
        guard isHapticsEnabled else { return }
        
        #if os(iOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
        #endif
    }
    
    func warningFeedback() {
        guard isHapticsEnabled else { return }
        
        #if os(iOS)
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
        #endif
    }
    
    func selectionFeedback() {
        guard isHapticsEnabled else { return }
        
        #if os(iOS)
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        #endif
    }
    
    func customIntensityFeedback(intensity: CGFloat) {
        guard isHapticsEnabled else { return }
        
        #if os(iOS)
        if #available(iOS 13.0, *) {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred(intensity: intensity)
        } else {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
        #endif
    }
    
    func toggleHaptics() {
        isHapticsEnabled.toggle()
        saveSettings()
        
        // Provide feedback for the toggle action itself
        if isHapticsEnabled {
            selectionFeedback()
        }
    }
    
    func setHapticsEnabled(_ enabled: Bool) {
        isHapticsEnabled = enabled
        saveSettings()
    }
    
    private func loadSettings() {
        isHapticsEnabled = userDefaults.bool(forKey: hapticsEnabledKey)
        
        // Default to enabled if no setting exists
        if userDefaults.object(forKey: hapticsEnabledKey) == nil {
            isHapticsEnabled = true
        }
    }
    
    private func saveSettings() {
        userDefaults.set(isHapticsEnabled, forKey: hapticsEnabledKey)
    }
    
    func prepareHaptics() {
        #if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        #endif
    }
}
