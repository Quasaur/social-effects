// Swift script to list all US/UK English WaveNet voices from Google Cloud TTS API
// Uses GoogleCloudTTS.swift and RSASigner.swift for OAuth2
import Foundation

// Helper to read service account JSON from environment or file
let serviceAccountPath = "book-of-wisdom-482515-69d6b2d0ae77.json" // Updated to match actual file name

// Helper to load service account JSON
func loadServiceAccount() -> [String: Any]? {
    let url = URL(fileURLWithPath: serviceAccountPath)
    guard let data = try? Data(contentsOf: url) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
}

// Helper to get OAuth2 token using RSASigner
func fetchAccessToken(serviceAccount: [String: Any]) -> String? {
    guard let clientEmail = serviceAccount["client_email"] as? String,
          let privateKey = serviceAccount["private_key"] as? String else {
        print("Invalid service account JSON")
        return nil
    }
    // JWT header
    let header: [String: Any] = ["alg": "RS256", "typ": "JWT"]
    guard let headerData = try? JSONSerialization.data(withJSONObject: header) else { return nil }
    let headerBase64 = headerData.base64URLEncodedString()
    // JWT claim set
    let iat = Int(Date().timeIntervalSince1970)
    let exp = iat + 3600
    let scope = "https://www.googleapis.com/auth/cloud-platform"
    let claims: [String: Any] = [
        "iss": clientEmail,
        "scope": scope,
        "aud": "https://oauth2.googleapis.com/token",
        "exp": exp,
        "iat": iat
    ]
    guard let claimsData = try? JSONSerialization.data(withJSONObject: claims) else { return nil }
    let claimsBase64 = claimsData.base64URLEncodedString()
    // JWT unsigned
    let jwtUnsigned = "\(headerBase64).\(claimsBase64)"
    // Sign JWT with private key (PEM)
    guard let jwtSignature = try? RSASigner.sign(jwtUnsigned, withPEM: privateKey) else { return nil }
    let jwt = "\(jwtUnsigned).\(jwtSignature)"
    // Request access token
    var req = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
    req.httpMethod = "POST"
    req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)"
    req.httpBody = body.data(using: .utf8)
    let semaphore = DispatchSemaphore(value: 0)
    var token: String?
    let task = URLSession.shared.dataTask(with: req) { data, response, error in
        defer { semaphore.signal() }
        if let error = error {
            print("[OAuth2] Network error: \(error)")
            return
        }
        guard let data = data else {
            print("[OAuth2] No data in response")
            return
        }
        if let httpResponse = response as? HTTPURLResponse {
            print("[OAuth2] HTTP status: \(httpResponse.statusCode)")
        }
        if let body = String(data: data, encoding: .utf8) {
            print("[OAuth2] Response body: \n\(body)")
        }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let t = json["access_token"] as? String {
            token = t
        }
    }
    task.resume()
    semaphore.wait()
    return token
}

// --- RSASigner and base64 helpers ---
import Security
import CryptoKit
enum RSASigner {
    static func sign(_ message: String, withPEM pem: String) throws -> String {
        let lines = pem.components(separatedBy: "\n").filter { !$0.contains("PRIVATE KEY") && !$0.isEmpty }
        let base64 = lines.joined()
        guard let keyData = Data(base64Encoded: base64) else { throw NSError(domain: "RSASigner", code: 1, userInfo: nil) }
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA, kSecAttrKeyClass as String: kSecAttrKeyClassPrivate]
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, options as CFDictionary, &error) else { throw error!.takeRetainedValue() as Error }
        guard let messageData = message.data(using: .utf8) else { throw NSError(domain: "RSASigner", code: 2, userInfo: nil) }
        // Use CryptoKit for SHA256
        let hashData = Data(SHA256.hash(data: messageData))
        var error2: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(secKey, .rsaSignatureMessagePKCS1v15SHA256, hashData as CFData, &error2) as Data? else { throw error2!.takeRetainedValue() as Error }
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

// Fetch voices from Google Cloud TTS API
func fetchVoices(token: String) -> [[String: Any]]? {
    let url = URL(string: "https://texttospeech.googleapis.com/v1/voices")!
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let semaphore = DispatchSemaphore(value: 0)
    var result: [[String: Any]]?
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let voices = json["voices"] as? [[String: Any]] else { return }
        result = voices
    }
    task.resume()
    semaphore.wait()
    return result
}

// Main logic
guard let serviceAccount = loadServiceAccount() else {
    print("Could not load service account JSON at \(serviceAccountPath)")
    exit(1)
}
guard let token = fetchAccessToken(serviceAccount: serviceAccount) else {
    print("Could not fetch OAuth2 token")
    exit(1)
}
guard let voices = fetchVoices(token: token) else {
    print("Could not fetch voices from API")
    exit(1)
}

// Filter for US/UK English WaveNet voices
let filtered = voices.filter { voice in
    guard let name = voice["name"] as? String,
          let langs = voice["languageCodes"] as? [String] else { return false }
    let isWaveNet = name.contains("WaveNet")
    let isEnglish = langs.contains(where: { $0 == "en-US" || $0 == "en-GB" })
    return isWaveNet && isEnglish
}

// Print results
print("US/UK English WaveNet voices:")
for voice in filtered {
    let name = voice["name"] as? String ?? "(unknown)"
    let gender = voice["ssmlGender"] as? String ?? "(unknown)"
    let langs = (voice["languageCodes"] as? [String])?.joined(separator: ", ") ?? ""
    print("- \(name) [\(gender)] (\(langs))")
}