import Foundation
import CryptoKit

class FlameSecurityVault {
    static let shared = FlameSecurityVault()
    
    private let vaultIdentifier = "com.escapetheflames.vault.secure.v2"
    private let encryptionKey = "InfernoSecureFlameProtectionKey2024"
    private let saltKey = "EscapeTheFlamesSaltVector2024"
    
    private init() {}
    
    func encryptData(_ data: String) -> String? {
        guard let dataToEncrypt = data.data(using: .utf8) else { return nil }
        
        do {
            let key = SymmetricKey(data: SHA256.hash(data: encryptionKey.data(using: .utf8)!))
            let sealedBox = try AES.GCM.seal(dataToEncrypt, using: key)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            return nil
        }
    }
    
    func decryptData(_ encryptedData: String) -> String? {
        guard let data = Data(base64Encoded: encryptedData) else { return nil }
        
        do {
            let key = SymmetricKey(data: SHA256.hash(data: encryptionKey.data(using: .utf8)!))
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func validateGameEndpoint(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        
        let trustedDomains = [
            "escapeteflanes.com",
            "www.escapeteflanes.com"
        ]
        
        guard let host = url.host, trustedDomains.contains(host) else {
            return false
        }
        
        return url.scheme == "https"
    }
    
    func generateSecureToken() -> String {
        let tokenData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        return tokenData.base64EncodedString()
    }
    
    func hashUserData(_ userData: String) -> String {
        let inputData = Data((userData + saltKey).utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func validateIntegrity(of data: String, withHash expectedHash: String) -> Bool {
        let computedHash = hashUserData(data)
        return computedHash == expectedHash
    }
    
    func secureStore(_ value: String, forKey key: String) -> Bool {
        guard let encryptedValue = encryptData(value) else { return false }
        UserDefaults.standard.set(encryptedValue, forKey: "\(vaultIdentifier).\(key)")
        return true
    }
    
    func secureRetrieve(forKey key: String) -> String? {
        guard let encryptedValue = UserDefaults.standard.string(forKey: "\(vaultIdentifier).\(key)") else { return nil }
        return decryptData(encryptedValue)
    }
    
    func clearSecureStorage() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(vaultIdentifier) }
        keys.forEach { defaults.removeObject(forKey: $0) }
    }
}
