import Foundation

/// Google Cloud Text-to-Speech API wrapper for Swift
/// Requires service account JSON key and internet access.
///
/// Usage:
///   let tts = GoogleCloudTTS(jsonKeyPath: "/path/to/key.json")
///   try tts.synthesize(text: "Hello world", outputPath: URL(...))
class GoogleCloudTTS {
    private let apiKeyPath: String
    private let endpoint = "https://texttospeech.googleapis.com/v1/text:synthesize"
    private var accessToken: String?
    
    init(jsonKeyPath: String) {
        self.apiKeyPath = jsonKeyPath
    }
    
    /// Loads an OAuth2 access token from the service account JSON key
    private func fetchAccessToken() throws -> String {
        // Load service account JSON
        let keyData = try Data(contentsOf: URL(fileURLWithPath: apiKeyPath))
        let keyJson = try JSONSerialization.jsonObject(with: keyData) as! [String: Any]
        guard let clientEmail = keyJson["client_email"] as? String,
              let privateKey = keyJson["private_key"] as? String else {
            throw NSError(domain: "GoogleCloudTTS", code: 10, userInfo: [NSLocalizedDescriptionKey: "Invalid service account JSON"])
        }

        // JWT header
        let header: [String: Any] = ["alg": "RS256", "typ": "JWT"]
        let headerData = try JSONSerialization.data(withJSONObject: header)
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
        let claimsData = try JSONSerialization.data(withJSONObject: claims)
        let claimsBase64 = claimsData.base64URLEncodedString()

        // JWT unsigned
        let jwtUnsigned = "\(headerBase64).\(claimsBase64)"

        // Sign JWT with private key (PEM)
        let jwtSignature = try RSASigner.sign(jwtUnsigned, withPEM: privateKey)
        let jwt = "\(jwtUnsigned).\(jwtSignature)"

        // Request access token
        var req = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        req.httpMethod = "POST"
        req.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)"
        req.httpBody = body.data(using: .utf8)
        let (data, response) = try URLSession.shared.synchronousDataTask(with: req)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "GoogleCloudTTS", code: 11, userInfo: [NSLocalizedDescriptionKey: "OAuth2 token request failed"])
        }
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        guard let token = json["access_token"] as? String else {
            throw NSError(domain: "GoogleCloudTTS", code: 12, userInfo: [NSLocalizedDescriptionKey: "No access_token in response"])
        }
        return token
    }
    
    /// Synthesize speech and save to outputPath (M4A or MP3)
    func synthesize(text: String, outputPath: URL, voice: String = "en-US-Neural2-J", speakingRate: Double = 1.0, pitch: Double = 0.0) throws {
        // 1. Get access token
        let token = try fetchAccessToken()
        
        // 2. Prepare request
        let request: [String: Any] = [
            "input": ["text": text],
            "voice": ["languageCode": "en-US", "name": voice],
            "audioConfig": ["audioEncoding": "MP3", "speakingRate": speakingRate, "pitch": pitch]
        ]
        let requestData = try JSONSerialization.data(withJSONObject: request)
        
        // 3. Make HTTP request
        var urlRequest = URLRequest(url: URL(string: endpoint)!)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = requestData
        
        let (data, response) = try URLSession.shared.synchronousDataTask(with: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "GoogleCloudTTS", code: 2, userInfo: [NSLocalizedDescriptionKey: "Google TTS API error"])
        }
        
        // 4. Parse response
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let audioContent = json?["audioContent"] as? String,
              let audioData = Data(base64Encoded: audioContent) else {
            throw NSError(domain: "GoogleCloudTTS", code: 3, userInfo: [NSLocalizedDescriptionKey: "No audio content in response"])
        }
        try audioData.write(to: outputPath)
    }
}

// Synchronous URLSession helper
extension URLSession {
    func synchronousDataTask(with request: URLRequest) throws -> (Data, URLResponse) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let task = self.dataTask(with: request) { d, r, e in
            data = d; response = r; error = e; semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        if let e = error { throw e }
        return (data!, response!)
    }
}
