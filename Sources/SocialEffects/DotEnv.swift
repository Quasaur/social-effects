import Foundation

/// Loads environment variables from a .env file into the process environment.
/// Supports KEY=VALUE and KEY="VALUE" formats. Skips comments (#) and blank lines.
enum DotEnv {
    
    /// Load .env from the current working directory, or a specific path.
    /// Variables already set in the shell environment are NOT overwritten.
    @discardableResult
    static func load(path: String? = nil) -> Int {
        let filePath: String
        if let path = path {
            filePath = path
        } else {
            // Walk up from cwd looking for .env (supports running from subdirectories)
            let cwd = FileManager.default.currentDirectoryPath
            filePath = findEnvFile(startingAt: cwd) ?? "\(cwd)/.env"
        }
        
        guard FileManager.default.fileExists(atPath: filePath),
              let contents = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            return 0
        }
        
        var loaded = 0
        for line in contents.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip comments and blank lines
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            
            // Strip optional "export " prefix
            let cleaned = trimmed.hasPrefix("export ")
                ? String(trimmed.dropFirst(7)).trimmingCharacters(in: .whitespaces)
                : trimmed
            
            guard let eqIndex = cleaned.firstIndex(of: "=") else { continue }
            
            let key = String(cleaned[cleaned.startIndex..<eqIndex])
                .trimmingCharacters(in: .whitespaces)
            var value = String(cleaned[cleaned.index(after: eqIndex)...])
                .trimmingCharacters(in: .whitespaces)
            
            // Remove surrounding quotes
            if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
               (value.hasPrefix("'") && value.hasSuffix("'")) {
                value = String(value.dropFirst().dropLast())
            }
            
            guard !key.isEmpty else { continue }
            
            // Don't overwrite existing environment variables
            if ProcessInfo.processInfo.environment[key] == nil {
                setenv(key, value, 0)
                loaded += 1
            }
        }
        
        return loaded
    }
    
    /// Walk up directories to find .env
    private static func findEnvFile(startingAt dir: String) -> String? {
        var current = dir
        while current != "/" {
            let candidate = "\(current)/.env"
            if FileManager.default.fileExists(atPath: candidate) {
                return candidate
            }
            current = (current as NSString).deletingLastPathComponent
        }
        return nil
    }
}
