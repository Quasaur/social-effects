import Foundation

/// ElevenLabs Text-to-Speech API Integration
/// Generates high-quality voice narration for video content
class ElevenLabsVoice {
    
    private let apiKey: String
    private let baseURL = "https://api.elevenlabs.io/v1"
    
    /// Cached pronunciation dictionary locator (dictionary_id, version_id)
    private var pronunciationDictionary: (id: String, versionId: String)?
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Voice IDs (Male, Deep, Authoritative)
    
    enum Voice: String {
        case donovan = "pqHfZKP75CvOlQylNhV4"   // User's choice - mature, authoritative
        case adam = "pNInz6obpgDQGcFmaJgB"      // Deep, authoritative
        case antoni = "ErXwobaYiN019PkySvjV"    // Calm, well-rounded
        case josh = "TxGEqnHWrfWFTfGW9XjX"      // Professional narrator
        case sam = "yoZ06aMxZJJ28mfd3POQ"       // Mature, wise
        
        var description: String {
            switch self {
            case .donovan: return "Donovan - Mature, authoritative (USER SELECTED)"
            case .adam: return "Adam - Deep, authoritative"
            case .antoni: return "Antoni - Calm, well-rounded"
            case .josh: return "Josh - Professional narrator"
            case .sam: return "Sam - Mature, wise-sounding"
            }
        }
    }
    
    // MARK: - Pronunciation Dictionary
    
    /// PLS lexicon rules for words ElevenLabs mispronounces.
    /// Uses IPA phonetic alphabet for precise control.
    private static let pronunciationRules: [(grapheme: String, phoneme: String)] = [
        ("ultimate", "ˈʌltɪmɪt"),
        ("Ultimate", "ˈʌltɪmɪt"),
    ]
    
    /// Path to the cached pronunciation dictionary IDs
    private static var dictionaryCachePath: String {
        "output/cache/pronunciation_dict.json"
    }
    
    /// Generates a W3C PLS (Pronunciation Lexicon Specification) XML document
    private static func generatePLS() -> Data {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <lexicon version="1.0" xmlns="http://www.w3.org/2005/01/pronunciation-lexicon" alphabet="ipa" xml:lang="en-US">

        """
        for rule in pronunciationRules {
            xml += "  <lexeme>\n"
            xml += "    <grapheme>\(rule.grapheme)</grapheme>\n"
            xml += "    <phoneme>\(rule.phoneme)</phoneme>\n"
            xml += "  </lexeme>\n"
        }
        xml += "</lexicon>\n"
        return Data(xml.utf8)
    }
    
    /// Loads or creates the pronunciation dictionary via the ElevenLabs API.
    /// Caches the dictionary_id and version_id locally to avoid re-uploading.
    func ensurePronunciationDictionary() async throws {
        // Already loaded this session
        if pronunciationDictionary != nil { return }
        
        let cacheURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(Self.dictionaryCachePath)
        
        // Try loading from local cache
        if let data = try? Data(contentsOf: cacheURL),
           let cached = try? JSONSerialization.jsonObject(with: data) as? [String: String],
           let dictId = cached["dictionary_id"],
           let versionId = cached["version_id"] {
            pronunciationDictionary = (id: dictId, versionId: versionId)
            return
        }
        
        // Upload new dictionary
        print("📖 Creating ElevenLabs pronunciation dictionary...")
        let endpoint = "\(baseURL)/pronunciation-dictionaries/add-from-file"
        guard let url = URL(string: endpoint) else { throw VoiceError.invalidURL }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Build multipart body
        var body = Data()
        let plsData = Self.generatePLS()
        
        // name field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("social-effects-pronunciation\r\n".data(using: .utf8)!)
        
        // description field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        body.append("Pronunciation fixes for social-effects TTS pipeline\r\n".data(using: .utf8)!)
        
        // file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"pronunciation.pls\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/pls+xml\r\n\r\n".data(using: .utf8)!)
        body.append(plsData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let errStr = String(data: data, encoding: .utf8) {
                print("⚠️  Pronunciation dictionary upload failed: \(errStr)")
            }
            // Non-fatal — TTS will work without it
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dictId = json["id"] as? String,
              let versionId = json["version_id"] as? String else {
            print("⚠️  Could not parse pronunciation dictionary response")
            return
        }
        
        pronunciationDictionary = (id: dictId, versionId: versionId)
        
        // Cache to disk
        let cacheDir = cacheURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        let cacheData = try JSONSerialization.data(withJSONObject: [
            "dictionary_id": dictId,
            "version_id": versionId
        ])
        try? cacheData.write(to: cacheURL)
        
        print("✅ Pronunciation dictionary created: \(dictId)")
    }
    
    // MARK: - Generate Voice
    
    /// Generates audio from text using ElevenLabs TTS
    /// - Parameters:
    ///   - text: The text to convert to speech
    ///   - voice: The voice to use (default: Donovan)
    ///   - outputPath: Where to save the MP3 file
    /// - Returns: URL of the generated audio file
    func generateVoice(
        text: String,
        voice: Voice = .donovan,
        outputPath: URL
    ) async throws -> URL {
        
        // Ensure pronunciation dictionary is available
        try await ensurePronunciationDictionary()
        
        let endpoint = "\(baseURL)/text-to-speech/\(voice.rawValue)"
        guard let url = URL(string: endpoint) else {
            throw VoiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "text": text,
            "model_id": "eleven_flash_v2_5",  // Flash/Turbo tier - faster & cheaper
            "voice_settings": [
                "stability": 0.5,           // 0-1 (0.5 = balanced)
                "similarity_boost": 0.75,   // 0-1 (0.75 = high similarity)
                "style": 0.0,               // 0-1 (0 = neutral for stoic)
                "use_speaker_boost": true
            ]
        ]
        
        // Attach pronunciation dictionary if available
        if let dict = pronunciationDictionary {
            body["pronunciation_dictionary_locators"] = [
                [
                    "pronunciation_dictionary_id": dict.id,
                    "version_id": dict.versionId
                ]
            ]
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VoiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            // Try to parse error message
            if let errorString = String(data: data, encoding: .utf8) {
                print("API Error Response: \(errorString)")
            }
            throw VoiceError.apiError(statusCode: httpResponse.statusCode)
        }
        
        // Save MP3 to file
        try data.write(to: outputPath)
        
        print("✅ Generated voice: \(outputPath.lastPathComponent)")
        print("   Voice: \(voice.description)")
        print("   Text length: \(text.count) characters")
        
        return outputPath
    }
    
    // MARK: - Batch Generation
    
    /// Generate voice audio for multiple quotes
    func generateBatch(
        quotes: [(text: String, filename: String)],
        voice: Voice = .donovan,
        outputDirectory: URL
    ) async throws -> [URL] {
        
        var generatedFiles: [URL] = []
        
        for (index, quote) in quotes.enumerated() {
            let outputFile = outputDirectory.appendingPathComponent(quote.filename)
            
            print("Generating \(index + 1)/\(quotes.count): \(quote.filename)...")
            
            let audioURL = try await generateVoice(
                text: quote.text,
                voice: voice,
                outputPath: outputFile
            )
            
            generatedFiles.append(audioURL)
            
            // Rate limiting: wait 1 second between requests (free tier courtesy)
            if index < quotes.count - 1 {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
        
        return generatedFiles
    }
    
    // MARK: - Error Types
    
    enum VoiceError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case apiError(statusCode: Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid ElevenLabs API URL"
            case .invalidResponse:
                return "Invalid response from ElevenLabs API"
            case .apiError(let code):
                return "ElevenLabs API error: HTTP \(code)"
            }
        }
    }
}

// MARK: - Usage Example

/*
 
 let elevenlabs = ElevenLabsVoice(apiKey: "your_api_key_here")
 
 let audioURL = try await elevenlabs.generateVoice(
     text: "True wisdom comes from questions",
     voice: .adam,
     outputPath: URL(fileURLWithPath: "/tmp/quote_01.mp3")
 )
 
 // Or batch generate all 10 demos:
 let quotes = [
     (text: "True wisdom comes from questions...", filename: "demo_01.mp3"),
     (text: "Courage is not absence of fear...", filename: "demo_02.mp3"),
     // ... 8 more
 ]
 
 let audioFiles = try await elevenlabs.generateBatch(
     quotes: quotes,
     voice: .adam,
     outputDirectory: URL(fileURLWithPath: "/tmp/audio")
 )
 
 */
