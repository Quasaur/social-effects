import Foundation

/// Minimal RSS feed parser for wisdombook.life feeds.
/// Extracts title, content (description), and link from <item> elements.
struct RSSFetcher {
    
    struct FeedItem: Codable {
        let title: String
        let content: String
        let link: String
        let source: String
    }
    
    static let feedURLs: [String: String] = [
        "daily":    "https://www.wisdombook.life/feed/daily.xml",
        "wisdom":   "https://www.wisdombook.life/feed/wisdom.xml",
        "thoughts": "https://www.wisdombook.life/feed/thoughts.xml",
        "quotes":   "https://www.wisdombook.life/feed/quotes.xml",
        "passages": "https://www.wisdombook.life/feed/passages.xml"
    ]
    
    /// Fetch a single item from the specified feed (defaults to "daily").
    static func fetchItem(feed: String = "daily") async throws -> FeedItem {
        guard let urlString = feedURLs[feed],
              let url = URL(string: urlString) else {
            throw NSError(domain: "RSSFetcher", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Unknown feed: \(feed)"])
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "RSSFetcher", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "RSS feed returned non-200 status"])
        }
        
        guard let xml = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "RSSFetcher", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to decode RSS feed"])
        }
        
        // Parse first <item> from RSS XML
        guard let item = parseFirstItem(from: xml) else {
            throw NSError(domain: "RSSFetcher", code: 4,
                          userInfo: [NSLocalizedDescriptionKey: "No items found in RSS feed"])
        }
        
        return item
    }
    
    /// Simple XML extraction — pulls first <item>'s title, description, and link
    private static func parseFirstItem(from xml: String) -> FeedItem? {
        guard let itemStart = xml.range(of: "<item>"),
              let itemEnd = xml.range(of: "</item>") else { return nil }
        
        let itemXML = String(xml[itemStart.upperBound..<itemEnd.lowerBound])
        
        let title = extractTag("title", from: itemXML)?
            .replacingOccurrences(of: "Today's Wisdom: ", with: "") ?? "Untitled"
        let content = extractTag("description", from: itemXML) ?? ""
        let link = extractTag("link", from: itemXML) ?? "https://wisdombook.life"
        
        return FeedItem(
            title: title,
            content: content,
            link: link,
            source: "wisdombook.life"
        )
    }
    
    /// Extract text content between <tag> and </tag>
    private static func extractTag(_ tag: String, from xml: String) -> String? {
        // Try CDATA first
        let cdataPattern = "<\(tag)><![CDATA["
        if let cdataStart = xml.range(of: cdataPattern),
           let cdataEnd = xml.range(of: "]]></\(tag)>", range: cdataStart.upperBound..<xml.endIndex) {
            return String(xml[cdataStart.upperBound..<cdataEnd.lowerBound])
        }
        
        // Plain text
        guard let openEnd = xml.range(of: "<\(tag)>"),
              let closeStart = xml.range(of: "</\(tag)>", range: openEnd.upperBound..<xml.endIndex) else {
            return nil
        }
        
        let value = String(xml[openEnd.upperBound..<closeStart.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
