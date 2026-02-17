import Foundation

/// Service for interacting with Google's Gemini Veo 3.1 API for video generation
class GeminiVideoService {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    
    enum GeminiError: Error {
        case missingAPIKey
        case invalidResponse
        case apiError(String)
        case downloadFailed
        case timeout
    }
    
    struct VideoGenerationRequest: Codable {
        let instances: [Instance]
        let parameters: Parameters?
        
        struct Instance: Codable {
            let prompt: String
        }
        
        struct Parameters: Codable {
            let aspectRatio: String
            let negativePrompt: String?
            
            enum CodingKeys: String, CodingKey {
                case aspectRatio
                case negativePrompt
            }
        }
    }
    
    struct OperationResponse: Codable {
        let name: String
        let done: Bool?
        let response: VideoResponse?
        let error: ErrorResponse?
        
        struct VideoResponse: Codable {
            let generateVideoResponse: GenerateVideoResponse
            
            struct GenerateVideoResponse: Codable {
                let generatedSamples: [Sample]
                
                struct Sample: Codable {
                    let video: Video
                    
                    struct Video: Codable {
                        let uri: String
                    }
                }
            }
        }
        
        struct ErrorResponse: Codable {
            let message: String
        }
    }
    
    init() throws {
        guard let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] else {
            throw GeminiError.missingAPIKey
        }
        self.apiKey = key
    }
    
    /// Generate a video from a text prompt using Veo 3.1
    /// - Parameters:
    ///   - prompt: The video prompt
    ///   - negativePrompt: Optional negative prompt to avoid certain elements
    ///   - aspectRatio: Video aspect ratio (default: "9:16" for portrait)
    /// - Returns: The operation name to poll for completion
    func generateVideo(prompt: String, negativePrompt: String? = nil, aspectRatio: String = "9:16") async throws -> String {
        let url = URL(string: "\(baseURL)/models/veo-3.1-generate-preview:predictLongRunning")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = VideoGenerationRequest(
            instances: [VideoGenerationRequest.Instance(prompt: prompt)],
            parameters: VideoGenerationRequest.Parameters(
                aspectRatio: aspectRatio,
                negativePrompt: negativePrompt
            )
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw GeminiError.apiError("Invalid response status")
        }
        
        let operationResponse = try JSONDecoder().decode(OperationResponse.self, from: data)
        return operationResponse.name
    }
    
    /// Poll the operation status until the video is ready
    /// - Parameters:
    ///   - operationName: The operation name returned from generateVideo
    ///   - maxAttempts: Maximum number of polling attempts (default: 60)
    ///   - pollInterval: Seconds between each poll (default: 10)
    /// - Returns: The download URI for the generated video
    func pollOperationStatus(operationName: String, maxAttempts: Int = 60, pollInterval: TimeInterval = 10) async throws -> String {
        let url = URL(string: "\(baseURL)/\(operationName)")!
        
        for attempt in 1...maxAttempts {
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw GeminiError.apiError("Polling failed")
            }
            
            let operationResponse = try JSONDecoder().decode(OperationResponse.self, from: data)
            
            if let error = operationResponse.error {
                throw GeminiError.apiError(error.message)
            }
            
            if operationResponse.done == true,
               let videoUri = operationResponse.response?.generateVideoResponse.generatedSamples.first?.video.uri {
                print("✅ Video ready after \(attempt) attempts (\(attempt * Int(pollInterval)) seconds)")
                return videoUri
            }
            
            print("⏳ Attempt \(attempt)/\(maxAttempts): Video still generating...")
            try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
        }
        
        throw GeminiError.timeout
    }
    
    /// Download the generated video from the temporary URI
    /// - Parameters:
    ///   - videoUri: The URI returned from polling
    ///   - outputPath: Local file path to save the video
    func downloadVideo(from videoUri: String, to outputPath: String) async throws {
        guard let url = URL(string: videoUri) else {
            throw GeminiError.downloadFailed
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw GeminiError.downloadFailed
        }
        
        try data.write(to: URL(fileURLWithPath: outputPath))
        print("💾 Downloaded video to: \(outputPath)")
    }
    
    /// Complete workflow: generate, poll, and download a video
    /// - Parameters:
    ///   - videoPrompt: The video prompt template
    ///   - outputDirectory: Directory to save the video
    /// - Returns: The local file path of the downloaded video
    func generateAndDownload(videoPrompt: VideoPrompt, outputDirectory: String) async throws -> String {
        print("\n🎬 Generating: \(videoPrompt.name)")
        print("📝 Prompt: \(videoPrompt.prompt)")
        
        // Step 1: Initiate video generation
        let operationName = try await generateVideo(
            prompt: videoPrompt.prompt,
            negativePrompt: videoPrompt.negativePrompt,
            aspectRatio: "9:16"
        )
        print("🚀 Operation started: \(operationName)")
        
        // Step 2: Poll until ready
        let videoUri = try await pollOperationStatus(operationName: operationName)
        
        // Step 3: Download video
        let outputPath = "\(outputDirectory)/\(String(format: "%02d", videoPrompt.id))_\(videoPrompt.name).mp4"
        try await downloadVideo(from: videoUri, to: outputPath)
        
        return outputPath
    }
}
