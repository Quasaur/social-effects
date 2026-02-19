import Foundation
import Security
import CryptoKit

/// Helper for RSA SHA256 signing of JWTs using PEM private keys (for Google service accounts)
enum RSASigner {
    static func sign(_ message: String, withPEM pem: String) throws -> String {
        // Remove PEM header/footer and decode base64
        let lines = pem.components(separatedBy: "\n").filter { !$0.contains("PRIVATE KEY") && !$0.isEmpty }
        let base64 = lines.joined()
        guard let keyData = Data(base64Encoded: base64) else {
            throw NSError(domain: "RSASigner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid PEM base64"])
        }

        // Import private key
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPrivate]
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, options as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }

        // Sign
        guard let messageData = message.data(using: .utf8) else {
            throw NSError(domain: "RSASigner", code: 2, userInfo: [NSLocalizedDescriptionKey: "Message encoding failed"])
        }
        let hashData = Data(SHA256.hash(data: messageData))
        var error2: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(secKey, .rsaSignatureMessagePKCS1v15SHA256, hashData as CFData, &error2) as Data? else {
            throw error2!.takeRetainedValue() as Error
        }
        return signature.base64URLEncodedString()
    }
}

extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString().replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

extension String {
    func base64URLEncodedString() -> String {
        return self.data(using: .utf8)!.base64URLEncodedString()
    }
}