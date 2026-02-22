import Foundation
import Network

/// HTTP API Server for Social Marketer integration
class APIServer {
    private var listener: NWListener?
    private let port: NWEndpoint.Port
    private var _shouldShutdown = false
    
    init(port: UInt16 = 5390) {
        self.port = NWEndpoint.Port(integerLiteral: port)
    }
    
    var shouldShutdown: Bool {
        return _shouldShutdown
    }
    
    func requestShutdown() {
        _shouldShutdown = true
    }
    
    func start() throws {
        listener = try NWListener(using: .tcp, on: port)
        
        listener?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ API Server listening on port \(self.port)")
            case .failed(let error):
                print("❌ Server failed: \(error)")
            default:
                break
            }
        }
        
        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }
        
        listener?.start(queue: .global())
    }
    
    func stop() {
        listener?.cancel()
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global())
        
        // Accumulate request data until we have a complete HTTP request
        var requestData = Data()
        var headersParsed = false
        var contentLength = 0
        var headerEndIndex: Data.Index?
        
        func receiveNextChunk() {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
                guard let self = self else {
                    connection.cancel()
                    return
                }
                
                if let error = error {
                    print("❌ Connection error: \(error)")
                    connection.cancel()
                    return
                }
                
                if let data = data {
                    requestData.append(data)
                    
                    // Try to parse headers if we haven't yet
                    if !headersParsed {
                        if let headerEnd = requestData.range(of: Data("\r\n\r\n".utf8)) {
                            headersParsed = true
                            headerEndIndex = headerEnd.upperBound
                            
                            // Parse Content-Length
                            if let headers = String(data: requestData[..<headerEnd.upperBound], encoding: .utf8) {
                                contentLength = self.parseContentLength(from: headers)
                            }
                        }
                    }
                    
                    // Check if we have the complete request
                    if headersParsed, let headerEnd = headerEndIndex {
                        let totalExpected = headerEnd + contentLength
                        if requestData.count >= totalExpected {
                            // We have the complete request
                            if let request = String(data: requestData, encoding: .utf8) {
                                self.handleRequest(request, connection: connection)
                            }
                            return
                        }
                    }
                }
                
                // Need more data or connection closed
                if isComplete {
                    // Try to handle what we have
                    if let request = String(data: requestData, encoding: .utf8) {
                        self.handleRequest(request, connection: connection)
                    } else {
                        connection.cancel()
                    }
                } else {
                    receiveNextChunk()
                }
            }
        }
        
        receiveNextChunk()
    }
    
    private func parseContentLength(from headers: String) -> Int {
        let lines = headers.components(separatedBy: "\r\n")
        for line in lines {
            if line.lowercased().hasPrefix("content-length:") {
                let value = line.dropFirst("content-length:".count).trimmingCharacters(in: .whitespaces)
                return Int(value) ?? 0
            }
        }
        return 0
    }
    
    private func handleRequest(_ request: String, connection: NWConnection) {
        let lines = request.components(separatedBy: "\r\n")
        guard let firstLine = lines.first else {
            sendResponse(connection, status: 400, body: "Invalid request")
            return
        }
        
        let parts = firstLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            sendResponse(connection, status: 400, body: "Invalid request")
            return
        }
        
        let method = parts[0]
        let path = parts[1]
        
        switch (method, path) {
        case ("POST", "/generate"):
            handleGenerate(request: request, connection: connection)
        case ("POST", "/shutdown"):
            handleShutdown(connection: connection)
        case ("GET", "/health"):
            sendResponse(connection, status: 200, body: "{\"status\":\"ok\"}", contentType: "application/json")
        default:
            sendResponse(connection, status: 404, body: "{\"error\":\"Not found\"}", contentType: "application/json")
        }
    }
    
    private func handleGenerate(request: String, connection: NWConnection) {
        // Extract body after \r\n\r\n
        guard let bodyStart = request.range(of: "\r\n\r\n") else {
            sendResponse(connection, status: 400, body: "{\"error\":\"Missing body\"}", contentType: "application/json")
            return
        }
        
        let body = String(request[bodyStart.upperBound...])
        
        // Debug: Log the body
        print("📄 Request body (\(body.utf8.count) bytes): \(body.prefix(200))...")
        
        guard !body.isEmpty else {
            sendResponse(connection, status: 400, body: "{\"error\":\"Empty body\"}", contentType: "application/json")
            return
        }
        
        guard let data = body.data(using: .utf8) else {
            sendResponse(connection, status: 400, body: "{\"error\":\"Invalid UTF-8 encoding\"}", contentType: "application/json")
            return
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                sendResponse(connection, status: 400, body: "{\"error\":\"JSON is not a dictionary\"}", contentType: "application/json")
                return
            }
            
            let title = json["title"] as? String ?? ""
            let content = json["content"] as? String ?? ""
            let contentType = json["content_type"] as? String ?? ""
            let nodeTitle = json["node_title"] as? String ?? ""
            let usePingPong = json["ping_pong"] as? Bool ?? true
            
            // Validate required fields
            if title.isEmpty {
                sendResponse(connection, status: 400, body: "{\"error\":\"Missing title\"}", contentType: "application/json")
                return
            }
            
            if content.isEmpty {
                sendResponse(connection, status: 400, body: "{\"error\":\"Missing content\"}", contentType: "application/json")
                return
            }
            
            if contentType.isEmpty {
                sendResponse(connection, status: 400, body: "{\"error\":\"Missing content_type\"}", contentType: "application/json")
                return
            }
            
            if nodeTitle.isEmpty {
                sendResponse(connection, status: 400, body: "{\"error\":\"Missing node_title\"}", contentType: "application/json")
                return
            }
            
            print("🎬 Generating video: '\(title)' (\(contentType))")
            
            Task {
                do {
                    let outputPath = try await generateVideo(
                        title: title,
                        content: content,
                        contentType: contentType,
                        nodeTitle: nodeTitle,
                        usePingPong: usePingPong
                    )
                    let response = "{\"success\":true,\"video_path\":\"\(outputPath)\"}"
                    self.sendResponse(connection, status: 200, body: response, contentType: "application/json")
                } catch {
                    let response = "{\"success\":false,\"error\":\"\(error.localizedDescription)\"}"
                    self.sendResponse(connection, status: 500, body: response, contentType: "application/json")
                }
            }
        } catch {
            print("❌ JSON parsing error: \(error)")
            sendResponse(connection, status: 400, body: "{\"error\":\"Invalid JSON: \(error.localizedDescription)\"}", contentType: "application/json")
        }
    }
    
    private func handleShutdown(connection: NWConnection) {
        sendResponse(connection, status: 200, body: "{\"status\":\"shutting_down\"}", contentType: "application/json")
        requestShutdown()
    }
    
    private func sendResponse(_ connection: NWConnection, status: Int, body: String, contentType: String = "text/plain") {
        let statusText = status == 200 ? "OK" : (status == 404 ? "Not Found" : "Error")
        var response = "HTTP/1.1 \(status) \(statusText)\r\n"
        response += "Content-Type: \(contentType)\r\n"
        response += "Content-Length: \(body.utf8.count)\r\n"
        response += "Connection: close\r\n"
        response += "\r\n"
        response += body
        
        connection.send(content: response.data(using: .utf8), completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
    
    private func generateVideo(title: String, content: String, contentType: String, nodeTitle: String, usePingPong: Bool) async throws -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        
        // Sanitize content_type: lowercase
        let sanitizedContentType = contentType.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Sanitize node_title: Initial_Caps_With_Underscores
        let sanitizedNodeTitle = sanitizeNodeTitle(nodeTitle)
        
        // Build filename: <content-type>-<Node_Title>-<timestamp>.mp4
        let filename = "\(sanitizedContentType)-\(sanitizedNodeTitle)-\(timestamp).mp4"
        let outputPath = "/Volumes/My Passport/social-media-content/social-effects/video/api/\(filename)"
        
        var args = [
            "generate-video",
            "--title", title,
            "--content", content,
            "--content-type", sanitizedContentType,
            "--node-title", sanitizedNodeTitle,
            "--output", outputPath,
            "--output-json"
        ]
        
        if usePingPong {
            args.append("--ping-pong")
        }
        
        let process = Process()
        // Use compiled binary directly instead of 'swift run' for reliability
        let binaryPath = "/Users/quasaur/Developer/social-effects/.build/debug/SocialEffects"
        process.executableURL = URL(fileURLWithPath: binaryPath)
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: "/Users/quasaur/Developer/social-effects")
        
        let pipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = pipe
        process.standardError = errPipe
        
        // Log the command for debugging
        print("🚀 Starting video generation: \(title)")
        print("   Command: \(binaryPath) \(args.joined(separator: " "))")
        
        try process.run()
        
        // Wait with timeout (8 minutes max for video generation)
        let timeout: TimeInterval = 480 // 8 minutes
        let startTime = Date()
        
        while process.isRunning {
            if Date().timeIntervalSince(startTime) > timeout {
                process.terminate()
                print("❌ Video generation timed out after \(timeout) seconds")
                throw NSError(domain: "APIServer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Video generation timed out after \(timeout) seconds"])
            }
            // Check every 0.5 seconds
            try await Task.sleep(nanoseconds: 500_000_000)
            print("⏳ Video generation in progress... (\(String(format: "%.0f", Date().timeIntervalSince(startTime)))s)")
        }
        
        print("✅ Video generation process completed in \(String(format: "%.1f", Date().timeIntervalSince(startTime)))s")
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
        
        // Log stderr for debugging
        let errOutput = String(data: errData, encoding: .utf8) ?? ""
        if !errOutput.isEmpty {
            print("📝 stderr: \(errOutput)")
        }
        
        // Check exit status
        if process.terminationStatus != 0 {
            print("❌ Video generation process failed with exit code \(process.terminationStatus)")
            throw NSError(domain: "APIServer", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "Video generation failed: \(errOutput)"])
        }
        
        // Extract JSON from the last line of output (process outputs human-readable text + JSON)
        let outputStr = String(data: data, encoding: .utf8) ?? ""
        let lines = outputStr.components(separatedBy: .newlines)
        
        // Find the last non-empty line which should be the JSON response
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard let jsonLine = nonEmptyLines.last,
              let jsonData = jsonLine.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let success = json["success"] as? Bool else {
            print("❌ Could not parse video generation response")
            print("   Output: \(outputStr.prefix(500))")
            throw NSError(domain: "APIServer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Video generation failed - invalid response"])
        }
        
        if success, let path = json["videoPath"] as? String {
            print("✅ Video generated: \(path)")
            return path
        } else {
            let errorMsg = json["error"] as? String ?? "Unknown error"
            print("❌ Video generation failed: \(errorMsg)")
            throw NSError(domain: "APIServer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Video generation failed: \(errorMsg)"])
        }
    }
}

// MARK: - Helper Functions

/// Sanitizes node title to Initial_Caps_With_Underscores format
/// Example: "wisdom questions" -> "Wisdom_Questions"
private func sanitizeNodeTitle(_ title: String) -> String {
    // Trim whitespace
    var sanitized = title.trimmingCharacters(in: .whitespaces)
    
    // Replace multiple spaces/special chars with single space
    let allowedChars = CharacterSet.alphanumerics.union(.whitespaces)
    sanitized = sanitized.components(separatedBy: allowedChars.inverted).joined(separator: " ")
    
    // Split by whitespace, capitalize each word, join with underscores
    let words = sanitized.components(separatedBy: .whitespacesAndNewlines)
        .filter { !$0.isEmpty }
    
    let capitalizedWords = words.map { word in
        let first = word.prefix(1).uppercased()
        let rest = word.dropFirst().lowercased()
        return first + rest
    }
    
    return capitalizedWords.joined(separator: "_")
}

// MARK: - API Server Command
extension SocialEffectsCLI {
    static func startAPIServer(arguments: [String]) async {
        let port = arguments.first.flatMap { UInt16($0) } ?? 5390
        let server = APIServer(port: port)
        
        print("🚀 Starting Social Effects API Server on port \(port)")
        print("═══════════════════════════════════════════\n")
        
        do {
            try server.start()
            print("📖 API Endpoints:")
            print("   POST /generate - Generate video")
            print("      Body: {\"title\":\"...\",\"content\":\"...\",\"ping_pong\":true}")
            print("   POST /shutdown - Shutdown server")
            print("   GET  /health   - Health check")
            print("\n⚠️  Press Ctrl+C to stop\n")
            
            while !server.shouldShutdown {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            
            print("\n🛑 Shutting down API server...")
            server.stop()
            print("✅ Server stopped")
        } catch {
            print("❌ Failed to start server: \(error)")
        }
    }
}
