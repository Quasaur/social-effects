import Foundation
import Network

/// HTTP API Server for Social Marketer integration
class APIServer {
    private var listener: NWListener?
    private let port: NWEndpoint.Port
    
    init(port: UInt16 = 5390) {
        self.port = NWEndpoint.Port(integerLiteral: port)
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
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self, let data = data else {
                connection.cancel()
                return
            }
            
            if let request = String(data: data, encoding: .utf8) {
                self.handleRequest(request, connection: connection)
            }
            
            if !isComplete {
                self.handleConnection(connection)
            }
        }
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
        case ("GET", "/health"):
            sendResponse(connection, status: 200, body: "{\"status\":\"ok\"}", contentType: "application/json")
        default:
            sendResponse(connection, status: 404, body: "{\"error\":\"Not found\"}", contentType: "application/json")
        }
    }
    
    private func handleGenerate(request: String, connection: NWConnection) {
        if let bodyStart = request.range(of: "\r\n\r\n") {
            let body = String(request[bodyStart.upperBound...])
            
            do {
                if let data = body.data(using: .utf8),
                   let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    let title = json["title"] as? String ?? ""
                    let content = json["content"] as? String ?? ""
                    let contentType = json["content_type"] as? String ?? ""
                    let nodeTitle = json["node_title"] as? String ?? ""
                    let usePingPong = json["ping_pong"] as? Bool ?? false
                    
                    // Validate required fields
                    if title.isEmpty || content.isEmpty {
                        sendResponse(connection, status: 400, body: "{\"error\":\"Missing title or content\"}", contentType: "application/json")
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
                    return
                }
            } catch {
                sendResponse(connection, status: 400, body: "{\"error\":\"Invalid JSON\"}", contentType: "application/json")
                return
            }
        }
        
        sendResponse(connection, status: 400, body: "{\"error\":\"Missing body\"}", contentType: "application/json")
    }
    
    private func sendResponse(_ connection: NWConnection, status: Int, body: String, contentType: String = "text/plain") {
        let statusText = status == 200 ? "OK" : (status == 404 ? "Not Found" : "Error")
        var response = "HTTP/1.1 \(status) \(statusText)\r\n"
        response += "Content-Type: \(contentType)\r\n"
        response += "Content-Length: \(body.utf8.count)\r\n"
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
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["run", "SocialEffects"] + args
        process.currentDirectoryURL = URL(fileURLWithPath: "/Users/quasaur/Developer/social-effects")
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let success = json["success"] as? Bool,
           success,
           let path = json["videoPath"] as? String {
            return path
        } else {
            throw NSError(domain: "APIServer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Video generation failed"])
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
            print("   GET  /health   - Health check")
            print("\n⚠️  Press Ctrl+C to stop\n")
            
            while true {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        } catch {
            print("❌ Failed to start server: \(error)")
        }
    }
}
