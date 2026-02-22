import Foundation
import CryptoKit

// MARK: - Hashing Utilities

enum Hashing {
    static func sha256(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
