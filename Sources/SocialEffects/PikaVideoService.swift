import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Service for generating videos using Pika via Fal.ai API
actor PikaVideoService {
    
    // MARK: - Error Types
    enum PikaError: Error, CustomStringConvertible {
        case missingAPIKey
        case apiError(String)
        case downloadFailed(String)
        case invalidResponse
        
        var description: String {
            switch self {
            case .missingAPIKey:
                return "FAL_KEY environment variable not set"
            case .apiError(let message):
                return "API error: \(message)"
            case .downloadFailed(let message):
                return "Download failed: \(message)"
            case .invalidResponse:
                return "Invalid API response"
            }
        }
    }
    
    // MARK: - Configuration
    private let apiKey: String
    private let baseURL = "https://queue.fal.run/fal-ai/pika"
    
    init() throws {
        guard let key = ProcessInfo.processInfo.environment["FAL_KEY"] else {
            throw PikaError.missingAPIKey
        }
        self.apiKey = key
    }
    
    // MARK: - Video Generation
    
    /// Generate and download a video from a prompt
    func generateAndDownload(
        videoPrompt: VideoPrompt,
        outputDirectory: String
    ) async throws -> String {
        print("\n🎬 Generating: \(videoPrompt.name)")
        print("📝 Prompt: \(videoPrompt.prompt)")
        
        // Step 1: Submit video generation request
        let requestId = try await submitRequest(prompt: videoPrompt.prompt)
        print("✅ Request submitted: \(requestId)")
        
        // Step 2: Poll for completion
        let videoURL = try await pollForCompletion(requestId: requestId)
        print("✅ Video generated: \(videoURL)")
        
        // Step 3: Download video
        let filename = String(format: "%02d", videoPrompt.id) + "_\(videoPrompt.name).mp4"
        let outputPath = "\(outputDirectory)/\(filename)"
        try await downloadVideo(from: videoURL, to: outputPath)
        print("✅ Downloaded: \(outputPath)")
        
        return outputPath
    }
    
    // MARK: - Private Methods
    
    private func submitRequest(prompt: String) async throws -> String {
        var request = URLRequest(url: URL(string: "\(baseURL)/v2.2/text-to-video")!)
        request.httpMethod = "POST"
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "prompt": prompt,
            "aspect_ratio": "9:16",
            "duration": 8,
            "resolution": "720p"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        print("📊 HTTP Status: \(statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 Response: \(responseString.prefix(500))")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PikaError.apiError("Invalid response status: \(statusCode)")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let requestId = json["request_id"] as? String else {
            throw PikaError.invalidResponse
        }
        
        return requestId
    }
    
    private func pollForCompletion(requestId: String) async throws -> String {
        let statusURL = URL(string: "\(baseURL)/requests/\(requestId)/status")!
        var request = URLRequest(url: statusURL)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Poll every 5 seconds for up to 10 minutes
        for attempt in 1...120 {
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? String else {
                continue
            }
            
            print("⏳ Status: \(status) (attempt \(attempt)/120)")
            
            // Handle both "completed" (lowercase) and "COMPLETED" (uppercase)
            if status.uppercased() == "COMPLETED" {
                // Fetch the actual result from response_url
                guard let responseURL = json["response_url"] as? String else {
                    throw PikaError.invalidResponse
                }
                
                let resultURL = URL(string: responseURL)!
                var resultRequest = URLRequest(url: resultURL)
                resultRequest.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
                
                let (resultData, _) = try await URLSession.shared.data(for: resultRequest)
                guard let resultJSON = try JSONSerialization.jsonObject(with: resultData) as? [String: Any] else {
                    throw PikaError.invalidResponse
                }
                
                // Try two formats: {"output": {"video": {"url": "..."}}} or {"video": {"url": "..."}}
                let videoDict: [String: Any]?
                if let output = resultJSON["output"] as? [String: Any] {
                    videoDict = output["video"] as? [String: Any]
                } else {
                    videoDict = resultJSON["video"] as? [String: Any]
                }
                
                guard let video = videoDict,
                      let videoURL = video["url"] as? String else {
                    // Debug: print the full response
                    if let responseString = String(data: resultData, encoding: .utf8) {
                        print("⚠️  Could not parse video URL from result: \(responseString.prefix(500))")
                    }
                    throw PikaError.invalidResponse
                }
                return videoURL
            } else if status == "failed" {
                let error = (json["error"] as? String) ?? "Unknown error"
                throw PikaError.apiError(error)
            }
        }
        
        throw PikaError.apiError("Timeout: video generation took too long")
    }
    
    private func downloadVideo(from urlString: String, to outputPath: String) async throws {
        guard let url = URL(string: urlString) else {
            throw PikaError.downloadFailed("Invalid URL")
        }
        
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        try FileManager.default.moveItem(at: tempURL, to: URL(fileURLWithPath: outputPath))
    }
}
