import SwiftUI
import Foundation

class BlazingThemeController: ObservableObject {
    static let shared = BlazingThemeController()
    
    @Published var currentTheme: InfernoTheme = .emberGlow
    @Published var isIntenseMode: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "InfernoSelectedTheme"
    private let intenseModeKey = "InfernoIntenseMode"
    
    private init() {
        loadSettings()
    }
    
    enum InfernoTheme: String, CaseIterable {
        case emberGlow = "emberGlow"
        case blazingFire = "blazingFire"
        case crimsonInferno = "crimsonInferno"
        case moltenCore = "moltenCore"
        case phoenixFlame = "phoenixFlame"
        
        var displayName: String {
            switch self {
            case .emberGlow: return "Ember Glow"
            case .blazingFire: return "Blazing Fire"
            case .crimsonInferno: return "Crimson Inferno"
            case .moltenCore: return "Molten Core"
            case .phoenixFlame: return "Phoenix Flame"
            }
        }
        
        var primaryColor: Color {
            switch self {
            case .emberGlow: return Color(red: 1.0, green: 0.27, blue: 0.0)
            case .blazingFire: return Color(red: 1.0, green: 0.27, blue: 0.0)
            case .crimsonInferno: return Color(red: 0.86, green: 0.08, blue: 0.24)
            case .moltenCore: return Color(red: 1.0, green: 0.4, blue: 0.0)
            case .phoenixFlame: return Color(red: 1.0, green: 0.6, blue: 0.0)
            }
        }
        
        var secondaryColor: Color {
            switch self {
            case .emberGlow: return Color(red: 0.86, green: 0.08, blue: 0.24)
            case .blazingFire: return Color(red: 0.86, green: 0.08, blue: 0.24)
            case .crimsonInferno: return Color(red: 0.55, green: 0.0, blue: 0.0)
            case .moltenCore: return Color(red: 0.8, green: 0.2, blue: 0.0)
            case .phoenixFlame: return Color(red: 0.9, green: 0.3, blue: 0.0)
            }
        }
        
        var accentColor: Color {
            switch self {
            case .emberGlow: return Color(red: 0.55, green: 0.0, blue: 0.0)
            case .blazingFire: return Color(red: 0.55, green: 0.0, blue: 0.0)
            case .crimsonInferno: return Color(red: 0.4, green: 0.0, blue: 0.0)
            case .moltenCore: return Color(red: 0.6, green: 0.1, blue: 0.0)
            case .phoenixFlame: return Color(red: 0.7, green: 0.2, blue: 0.0)
            }
        }
        
        var backgroundGradient: LinearGradient {
            LinearGradient(
                gradient: Gradient(colors: [primaryColor, secondaryColor, accentColor]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    func setTheme(_ theme: InfernoTheme) {
        currentTheme = theme
        saveSettings()
    }
    
    func toggleIntenseMode() {
        isIntenseMode.toggle()
        saveSettings()
    }
    
    private func loadSettings() {
        if let themeRawValue = userDefaults.string(forKey: themeKey),
           let theme = InfernoTheme(rawValue: themeRawValue) {
            currentTheme = theme
        }
        isIntenseMode = userDefaults.bool(forKey: intenseModeKey)
    }
    
    private func saveSettings() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
        userDefaults.set(isIntenseMode, forKey: intenseModeKey)
    }
    
    func getIntensityMultiplier() -> Double {
        return isIntenseMode ? 1.5 : 1.0
    }
    
    func getAnimationSpeed() -> Double {
        return isIntenseMode ? 0.6 : 1.0
    }
}
