import SwiftUI
import Foundation

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension String {
    func secureHash() -> String {
        return FlameSecurityVault.shared.hashUserData(self)
    }
    
    func encrypt() -> String? {
        return FlameSecurityVault.shared.encryptData(self)
    }
    
    func decrypt() -> String? {
        return FlameSecurityVault.shared.decryptData(self)
    }
    
    func isValidGameURL() -> Bool {
        return FlameSecurityVault.shared.validateGameEndpoint(self)
    }
}

extension View {
    func infernoGlow(color: Color = .orange, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.8), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.4), radius: radius * 2, x: 0, y: 0)
    }
    
    func flameAnimation(intensity: Double = 1.0) -> some View {
        self
            .scaleEffect(1.0 + 0.1 * intensity)
            .animation(
                .easeInOut(duration: 1.0 / intensity)
                .repeatForever(autoreverses: true),
                value: intensity
            )
    }
    
    func emberEffect() -> some View {
        self
            .overlay(
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .blur(radius: 5)
                    .scaleEffect(1.2)
            )
    }
}

extension Double {
    func toFlameIntensity() -> String {
        switch self {
        case 0.0..<0.2:
            return "Ember"
        case 0.2..<0.4:
            return "Small Flame"
        case 0.4..<0.6:
            return "Medium Fire"
        case 0.6..<0.8:
            return "Large Blaze"
        case 0.8...1.0:
            return "Inferno"
        default:
            return "Unknown"
        }
    }
}

extension CGFloat {
    static func random(in range: ClosedRange<CGFloat>) -> CGFloat {
        return CGFloat.random(in: range)
    }
}

struct InfernoConstants {
    static let defaultAnimationDuration: Double = 1.0
    static let flameColors: [Color] = [
        Color(hex: "FF4500"), // OrangeRed
        Color(hex: "FF6347"), // Tomato
        Color(hex: "FF0000"), // Red
        Color(hex: "DC143C"), // Crimson
        Color(hex: "B22222"), // FireBrick
        Color(hex: "8B0000")  // DarkRed
    ]
    
    static let emberColors: [Color] = [
        Color(hex: "FFA500"), // Orange
        Color(hex: "FFD700"), // Gold
        Color(hex: "FF8C00"), // DarkOrange
        Color(hex: "FF7F50")  // Coral
    ]
    
    static let gameEndpoints = [
        "https://escapeteflanes.com/view",
        "https://www.escapeteflanes.com/view"
    ]
}

struct FlameParticleModifier: ViewModifier {
    let intensity: Double
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .scaleEffect(0.8 + 0.4 * intensity)
            .opacity(0.7 + 0.3 * intensity)
            .blur(radius: 2 + 3 * intensity)
    }
}

extension View {
    func flameParticle(intensity: Double, color: Color = .orange) -> some View {
        modifier(FlameParticleModifier(intensity: intensity, color: color))
    }
}
