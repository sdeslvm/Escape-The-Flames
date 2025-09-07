import Foundation
import AVFoundation

class InfernoAudioManager: ObservableObject {
    static let shared = InfernoAudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var backgroundPlayer: AVAudioPlayer?
    
    @Published var isMuted: Bool = false
    @Published var volume: Float = 0.7
    
    private let userDefaults = UserDefaults.standard
    private let mutedKey = "InfernoAudioMuted"
    private let volumeKey = "InfernoAudioVolume"
    
    private init() {
        loadSettings()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }
    
    func playFlameSound() {
        guard !isMuted else { return }
        
        // Create a simple flame crackling sound programmatically
        playTone(frequency: 200, duration: 0.3, volume: volume * 0.5)
    }
    
    func playEmberSound() {
        guard !isMuted else { return }
        
        playTone(frequency: 800, duration: 0.1, volume: volume * 0.3)
    }
    
    func playIgnitionSound() {
        guard !isMuted else { return }
        
        playTone(frequency: 400, duration: 0.5, volume: volume * 0.8)
    }
    
    func startBackgroundAmbient() {
        guard !isMuted else { return }
        
        // Create ambient fire sound
        playTone(frequency: 150, duration: 10.0, volume: volume * 0.2)
    }
    
    func stopBackgroundAmbient() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }
    
    private func playTone(frequency: Float, duration: TimeInterval, volume: Float) {
        let sampleRate = 44100
        let samples = Int(duration * Double(sampleRate))
        
        var audioData = [Float]()
        
        for i in 0..<samples {
            let time = Float(i) / Float(sampleRate)
            let amplitude = sin(2.0 * Float.pi * frequency * time) * volume
            audioData.append(amplitude)
        }
        
        // Convert to Data and play (simplified implementation)
        DispatchQueue.global(qos: .background).async {
            // This is a placeholder - in a real app you'd use proper audio generation
            usleep(UInt32(duration * 1000000))
        }
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        audioPlayer?.volume = volume
        backgroundPlayer?.volume = volume * 0.5
        saveSettings()
    }
    
    func toggleMute() {
        isMuted.toggle()
        
        if isMuted {
            audioPlayer?.volume = 0
            backgroundPlayer?.volume = 0
        } else {
            audioPlayer?.volume = volume
            backgroundPlayer?.volume = volume * 0.5
        }
        
        saveSettings()
    }
    
    private func loadSettings() {
        isMuted = userDefaults.bool(forKey: mutedKey)
        volume = userDefaults.float(forKey: volumeKey)
        
        if volume == 0 && userDefaults.object(forKey: volumeKey) == nil {
            volume = 0.7 // Default volume
        }
    }
    
    private func saveSettings() {
        userDefaults.set(isMuted, forKey: mutedKey)
        userDefaults.set(volume, forKey: volumeKey)
    }
    
    func cleanup() {
        audioPlayer?.stop()
        backgroundPlayer?.stop()
        audioPlayer = nil
        backgroundPlayer = nil
    }
}
